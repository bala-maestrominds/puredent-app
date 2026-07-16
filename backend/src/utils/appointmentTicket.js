import crypto from 'crypto';
import QRCode from 'qrcode';
import PDFDocument from 'pdfkit';

// ---------------------------------------------------------------------------
// Booking code + verification token
// ---------------------------------------------------------------------------

/** Generates a human-friendly booking reference, e.g. "PD-4X9K2LQ". */
export function generateAppointmentCode() {
  const random = crypto.randomBytes(5).toString('hex').toUpperCase().slice(0, 7);
  return `PD-${random}`;
}

/**
 * Signs the appointment code with a server-side secret so the QR payload can't
 * be forged by simply guessing/incrementing the code. Verified again at
 * check-in time with a timing-safe comparison.
 */
export function signAppointmentCode(code) {
  const secret = process.env.APPOINTMENT_QR_SECRET || process.env.GMAIL_APP_PASSWORD || 'dev-secret';
  return crypto.createHmac('sha256', secret).update(code).digest('hex').slice(0, 24);
}

export function verifyAppointmentToken(code, token) {
  const expected = signAppointmentCode(code);
  const a = Buffer.from(expected);
  const b = Buffer.from(String(token || ''));
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

// ---------------------------------------------------------------------------
// QR code
// ---------------------------------------------------------------------------

/**
 * Builds the payload embedded in the QR code. Kept as compact JSON so the
 * reception desk's scanner (or the /admin/checkin page) can parse it directly.
 */
export function buildQrPayload(appointment) {
  return JSON.stringify({
    code: appointment.appointmentCode,
    token: appointment.verificationToken,
  });
}

/** Returns a PNG data URL (for embedding directly in the API JSON response / <img src>). */
export async function generateQrDataUrl(appointment) {
  return QRCode.toDataURL(buildQrPayload(appointment), {
    errorCorrectionLevel: 'M',
    margin: 1,
    width: 400,
    color: { dark: '#005c55', light: '#ffffff' },
  });
}

/** Returns a raw PNG buffer (for embedding in the generated PDF). */
export async function generateQrBuffer(appointment) {
  return QRCode.toBuffer(buildQrPayload(appointment), {
    errorCorrectionLevel: 'M',
    margin: 1,
    width: 400,
    color: { dark: '#005c55', light: '#ffffff' },
  });
}

// ---------------------------------------------------------------------------
// PDF ticket ("movie ticket" style stub with QR code)
// ---------------------------------------------------------------------------

const PRIMARY = '#005c55';
const MUTED = '#3e4947';
const LIGHT_BG = '#f1f4f3';

function formatDate(dateStr) {
  const d = new Date(`${dateStr}T00:00:00`);
  if (Number.isNaN(d.getTime())) return dateStr;
  return d.toLocaleDateString('en-US', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
}

function formatTime(timeStr) {
  const [h, m] = timeStr.split(':').map(Number);
  const period = h >= 12 ? 'PM' : 'AM';
  const hour12 = ((h + 11) % 12) + 1;
  return `${String(hour12).padStart(2, '0')}:${String(m).padStart(2, '0')} ${period}`;
}

/**
 * Renders a movie-ticket-style PDF: a main stub with appointment/patient
 * details and a perforated side stub carrying the QR code for check-in.
 * Returns a Buffer.
 */
export async function generateAppointmentPdf(appointment) {
  const qrBuffer = await generateQrBuffer(appointment);

  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: [560, 300], margin: 0 });
    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    const stubWidth = 190;
    const mainWidth = 560 - stubWidth;

    // --- Main stub (left) ---
    doc.rect(0, 0, mainWidth, 300).fill('#ffffff');
    doc.rect(0, 0, mainWidth, 64).fill(PRIMARY);

    doc
      .fillColor('#ffffff')
      .fontSize(18)
      .font('Helvetica-Bold')
      .text('PureDent Clinic', 28, 20);
    doc
      .fillColor('#d7f5ef')
      .fontSize(9)
      .font('Helvetica')
      .text('Appointment Ticket', 28, 42);

    doc
      .fillColor(MUTED)
      .fontSize(9)
      .font('Helvetica-Bold')
      .text('BOOKING ID', 28, 82);
    doc
      .fillColor(PRIMARY)
      .fontSize(16)
      .font('Helvetica-Bold')
      .text(appointment.appointmentCode, 28, 96);

    const col1X = 28;
    const col2X = mainWidth / 2 + 10;
    let rowY = 132;

    const field = (label, value, x, y) => {
      doc.fillColor(MUTED).fontSize(8).font('Helvetica-Bold').text(label.toUpperCase(), x, y);
      doc.fillColor('#181c1c').fontSize(11).font('Helvetica').text(value || '-', x, y + 12, {
        width: mainWidth / 2 - 40,
      });
    };

    field('Patient', appointment.patientName, col1X, rowY);
    field('Doctor', appointment.doctorName, col2X, rowY);
    rowY += 40;
    field('Service', appointment.serviceName, col1X, rowY);
    field('Date', formatDate(appointment.date), col2X, rowY);
    rowY += 40;
    field('Time', formatTime(appointment.time), col1X, rowY);
    field('Amount', `$${Number(appointment.amount || 0).toFixed(2)}`, col2X, rowY);

    doc
      .fillColor('#9aa5a3')
      .fontSize(7.5)
      .font('Helvetica')
      .text(
        'Please arrive 10 minutes early. Present this ticket (printed or on your phone) at reception.',
        col1X,
        260,
        { width: mainWidth - 56 }
      );

    // --- Perforation ---
    doc.save();
    doc.dash(4, { space: 4 });
    doc
      .moveTo(mainWidth, 0)
      .lineTo(mainWidth, 300)
      .lineWidth(1)
      .strokeColor('#c7d0ce')
      .stroke();
    doc.undash();
    doc.restore();

    for (let cy = -6; cy <= 300; cy += 24) {
      doc.circle(mainWidth, cy, 6).fill('#f7faf8');
    }

    // --- QR stub (right) ---
    doc.rect(mainWidth, 0, stubWidth, 300).fill(LIGHT_BG);
    doc
      .fillColor(PRIMARY)
      .fontSize(9)
      .font('Helvetica-Bold')
      .text('SCAN AT RECEPTION', mainWidth, 22, { width: stubWidth, align: 'center' });

    const qrSize = 140;
    const qrX = mainWidth + (stubWidth - qrSize) / 2;
    doc.image(qrBuffer, qrX, 44, { width: qrSize, height: qrSize });

    doc
      .fillColor(MUTED)
      .fontSize(8)
      .font('Helvetica')
      .text(appointment.appointmentCode, mainWidth, 44 + qrSize + 10, { width: stubWidth, align: 'center' });

    doc
      .fillColor(MUTED)
      .fontSize(7)
      .text(formatDate(appointment.date), mainWidth, 44 + qrSize + 26, { width: stubWidth, align: 'center' });
    doc
      .fillColor(MUTED)
      .fontSize(7)
      .text(formatTime(appointment.time), mainWidth, 44 + qrSize + 38, { width: stubWidth, align: 'center' });

    doc.end();
  });
}