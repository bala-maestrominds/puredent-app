import nodemailer from "nodemailer";

// ---------------------------------------------------------------------------
// Why this reliably lands in the inbox instead of spam:
//
// 1. We authenticate as a real Gmail account via SMTP (smtp.gmail.com) using
//    an App Password. Google's own servers relay the mail, so SPF/DKIM/DMARC
//    are already correctly signed for the gmail.com sending domain -- unlike
//    an unauthenticated "contact form mailer" hitting an arbitrary SMTP relay.
// 2. The "From" address matches the authenticated account, and the visitor's
//    email is set as "Reply-To" (never spoofed into "From"), which keeps
//    Gmail's spoofing/alignment checks happy.
// 3. The subject and body are plain, non-spammy, and specific to the message.
//
// For higher send volume in production, consider a transactional provider
// (Resend, Postmark, SendGrid) with a verified custom domain instead -- but
// for a clinic's low-volume contact form, authenticated Gmail SMTP is simple
// and dependable.
// ---------------------------------------------------------------------------

export function createTransporter() {
  const { GMAIL_USER, GMAIL_APP_PASSWORD } = process.env;

  if (!GMAIL_USER || !GMAIL_APP_PASSWORD) {
    throw new Error(
      "Missing GMAIL_USER or GMAIL_APP_PASSWORD environment variables. See server/.env.example."
    );
  }

  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: GMAIL_USER,
      pass: GMAIL_APP_PASSWORD,
    },
    // Some campus/corporate networks and antivirus tools intercept TLS
    // connections with their own certificate ("SSL inspection"), which makes
    // Node reject Gmail's real certificate as untrusted. This relaxes that
    // check ONLY outside production, so local dev on such networks still
    // works. Never do this in production -- deploy behind a network that
    // doesn't intercept TLS instead.
    tls: {
      rejectUnauthorized: process.env.NODE_ENV === "production",
    },
  });
}

export function buildAppointmentEmail(appointment) {
  const safe = (s) => String(s ?? '').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  const dateLabel = new Date(`${appointment.date}T00:00:00`).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return {
    subject: `Your PureDent Appointment is Confirmed — ${appointment.appointmentCode}`,
    text:
      `Hi ${appointment.patientName},\n\n` +
      `Your appointment at PureDent Clinic is confirmed.\n\n` +
      `Booking ID: ${appointment.appointmentCode}\n` +
      `Service: ${appointment.serviceName}\n` +
      `Doctor: ${appointment.doctorName}\n` +
      `Date: ${dateLabel}\n` +
      `Time: ${appointment.time}\n\n` +
      `Your ticket is attached as a PDF. Please bring it (printed or on your phone) ` +
      `and show the QR code at reception when you arrive.\n\n` +
      `See you soon!\nPureDent Clinic`,
    html: `
      <div style="font-family: 'Inter', Arial, sans-serif; color: #181c1c; max-width: 560px; margin: 0 auto;">
        <div style="background: #005c55; padding: 24px; border-radius: 12px 12px 0 0;">
          <h2 style="color: #ffffff; margin: 0; font-family: 'Plus Jakarta Sans', Arial, sans-serif;">Appointment Confirmed</h2>
        </div>
        <div style="background: #f7faf8; padding: 24px; border-radius: 0 0 12px 12px; border: 1px solid #e0e3e1; border-top: none;">
          <p style="margin: 0 0 16px;">Hi ${safe(appointment.patientName)}, your visit to PureDent Clinic is booked.</p>
          <div style="background: #ffffff; border: 1px solid #e0e3e1; border-radius: 8px; padding: 16px;">
            <p style="margin: 0 0 8px;"><strong>Booking ID:</strong> ${safe(appointment.appointmentCode)}</p>
            <p style="margin: 0 0 8px;"><strong>Service:</strong> ${safe(appointment.serviceName)}</p>
            <p style="margin: 0 0 8px;"><strong>Doctor:</strong> ${safe(appointment.doctorName)}</p>
            <p style="margin: 0 0 8px;"><strong>Date:</strong> ${safe(dateLabel)}</p>
            <p style="margin: 0;"><strong>Time:</strong> ${safe(appointment.time)}</p>
          </div>
          <p style="margin-top: 16px; font-size: 13px;">
            Your ticket is attached as a PDF, with a QR code — please show it at reception when you arrive.
          </p>
          <p style="margin-top: 24px; font-size: 12px; color: #3e4947;">
            This is an automated confirmation from the PureDent Clinic booking system.
          </p>
        </div>
      </div>
    `,
  };
}

export function buildContactEmail({ name, email, service, message }) {
  const safe = (s) => String(s).replace(/</g, "&lt;").replace(/>/g, "&gt;");

  return {
    subject: `New Contact Inquiry from ${name} — PureDent Website`,
    text:
      `New inquiry received via the PureDent contact form\n\n` +
      `Name: ${name}\n` +
      `Email: ${email}\n` +
      `Service Interest: ${service}\n\n` +
      `Message:\n${message}`,
    html: `
      <div style="font-family: 'Inter', Arial, sans-serif; color: #181c1c; max-width: 560px; margin: 0 auto;">
        <div style="background: #005c55; padding: 24px; border-radius: 12px 12px 0 0;">
          <h2 style="color: #ffffff; margin: 0; font-family: 'Plus Jakarta Sans', Arial, sans-serif;">PureDent — New Contact Inquiry</h2>
        </div>
        <div style="background: #f7faf8; padding: 24px; border-radius: 0 0 12px 12px; border: 1px solid #e0e3e1; border-top: none;">
          <p style="margin: 0 0 8px;"><strong>Name:</strong> ${safe(name)}</p>
          <p style="margin: 0 0 8px;"><strong>Email:</strong> ${safe(email)}</p>
          <p style="margin: 0 0 16px;"><strong>Service Interest:</strong> ${safe(service)}</p>
          <div style="background: #ffffff; border: 1px solid #e0e3e1; border-radius: 8px; padding: 16px;">
            <p style="margin: 0; white-space: pre-wrap;">${safe(message)}</p>
          </div>
          <p style="margin-top: 24px; font-size: 12px; color: #3e4947;">
            This message was sent from the "Send Inquiry" form on the PureDent contact page.
          </p>
        </div>
      </div>
    `,
  };
}