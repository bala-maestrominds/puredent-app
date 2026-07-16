import { Appointment } from '../models/appointments.model.js';
import { Doctor } from '../models/doctors.model.js';
import { Service } from '../models/services.model.js';

function todayStr() {
  return new Date().toISOString().slice(0, 10); // "YYYY-MM-DD"
}

async function getDashboardStats() {
  const today = todayStr();
  const now = new Date();
  const nowMinutes = now.getHours() * 60 + now.getMinutes();

  const [
    totalDoctors,
    activeDoctors,
    totalServices,
    todaysAppointments,
    pendingAppointments,
    completedAppointments,
    totalAppointments,
    recentAppointments,
    todaysAppointmentDocs,
    todayRevenue,
  ] = await Promise.all([
    Doctor.countDocuments({}),
    Doctor.countDocuments({ isActive: { $ne: false } }),
    Service.countDocuments({}),
    Appointment.countDocuments({ date: today }),
    Appointment.countDocuments({ status: { $in: ['Pending', 'Confirmed'] } }),
    Appointment.countDocuments({ status: 'Completed' }),
    Appointment.countDocuments({}),
    Appointment.find({}).sort({ createdAt: -1 }).limit(8),
    Appointment.find({ date: today, status: { $ne: 'Cancelled' } }),
    getTodayRevenueSummary(),
  ]);

  // Distinct patients, derived from the appointments collection (there's no
  // separate Patient model -- patient details are snapshotted per booking).
  const distinctPatients = await Appointment.distinct('patientEmail');

  // Soonest appointment still ahead of us today, for the "up next" insight.
  const nextAppointment =
    todaysAppointmentDocs
      .filter((a) => minutesOfDay(a.time) >= nowMinutes)
      .sort((a, b) => minutesOfDay(a.time) - minutesOfDay(b.time))[0] || null;

  return {
    totalDoctors,
    activeDoctors,
    totalServices,
    todaysAppointments,
    pendingAppointments,
    completedAppointments,
    totalAppointments,
    totalPatients: distinctPatients.length,
    recentAppointments,
    todayRevenue,
    nextAppointment,
  };
}

// There's no dedicated Patient model in this system -- patient details are
// captured per-booking on the Appointment document (guest checkout is
// allowed). We derive a patient directory by grouping appointments by email.
async function listPatients({ search } = {}) {
  const match = {};
  if (search) {
    const re = new RegExp(search, 'i');
    match.$or = [{ patientName: re }, { patientEmail: re }, { patientPhone: re }];
  }

  const patients = await Appointment.aggregate([
    { $match: match },
    { $sort: { createdAt: -1 } },
    {
      $group: {
        _id: '$patientEmail',
        name: { $first: '$patientName' },
        email: { $first: '$patientEmail' },
        phone: { $first: '$patientPhone' },
        gender: { $first: '$patientGender' },
        age: { $first: '$patientAge' },
        lastVisit: { $first: '$date' },
        totalAppointments: { $sum: 1 },
        lastStatus: { $first: '$status' },
      },
    },
    { $sort: { lastVisit: -1 } },
  ]);

  return patients.map((p) => ({ id: p._id, ...p, _id: undefined }));
}

function toDateStr(d) {
  return d.toISOString().slice(0, 10);
}

// Parse a "YYYY-MM-DD" string as a UTC calendar date (not local time). Using
// `new Date(`${dateStr}T00:00:00`)` here instead would parse as *local*
// midnight; round-tripping that through `toISOString()` (which is always
// UTC) then silently shifts the date by a day on any server whose local
// timezone is ahead of UTC (e.g. IST, UTC+5:30) -- which was the root cause
// of the weekly revenue buckets coming back empty/misaligned.
function parseDateStr(dateStr) {
  const [y, m, d] = dateStr.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

function addDays(dateStr, delta) {
  const d = parseDateStr(dateStr);
  d.setUTCDate(d.getUTCDate() + delta);
  return toDateStr(d);
}

function shortWeekday(dateStr) {
  return parseDateStr(dateStr).toLocaleDateString('en-US', { weekday: 'short', timeZone: 'UTC' });
}

// Buckets a HH:mm time string into one of the clinic's rough opening-hour
// slots, for the "Day" view of the revenue chart.
const DAY_BUCKETS = [
  { label: '8AM', from: 0, to: 599 },
  { label: '10AM', from: 600, to: 719 },
  { label: '12PM', from: 720, to: 839 },
  { label: '2PM', from: 840, to: 959 },
  { label: '4PM', from: 960, to: 1079 },
  { label: '6PM', from: 1080, to: 1439 },
];

function minutesOfDay(time) {
  const [h, m] = (time || '00:00').split(':').map((n) => parseInt(n, 10) || 0);
  return h * 60 + m;
}

// "Collected" revenue means actual money in hand -- `amountPaid` -- not the
// full treatment cost (`amount`). This matters now that patients can pay
// just the consultation fee upfront and settle the rest later: a
// 'partially_paid' appointment still contributes its collected portion to
// revenue, it just doesn't contribute the remaining balanceDue.
const COLLECTED_MATCH = { amountPaid: { $gt: 0 } };

async function sumCollected(query) {
  const result = await Appointment.aggregate([
    { $match: { ...query, ...COLLECTED_MATCH } },
    { $group: { _id: null, total: { $sum: '$amountPaid' } } },
  ]);
  return result[0]?.total ?? 0;
}

async function getRevenue({ period = 'week' } = {}) {
  const today = todayStr();

  let values = [];
  let labels = [];
  let total = 0;
  let previousTotal = 0;
  let rangeQuery;

  if (period === 'day') {
    const collected = await Appointment.find({ date: today, ...COLLECTED_MATCH });
    values = DAY_BUCKETS.map((bucket) =>
      collected
        .filter((a) => {
          const mins = minutesOfDay(a.time);
          return mins >= bucket.from && mins <= bucket.to;
        })
        .reduce((sum, a) => sum + (a.amountPaid || 0), 0)
    );
    labels = DAY_BUCKETS.map((b) => b.label);
    total = values.reduce((a, b) => a + b, 0);
    previousTotal = await sumCollected({ date: addDays(today, -1) });
    rangeQuery = { date: today };
  } else if (period === 'month') {
    // Trailing 30 days, grouped into 6 buckets of 5 days each, oldest first.
    const rangeStart = addDays(today, -29);
    const collected = await Appointment.find({
      date: { $gte: rangeStart, $lte: today },
      ...COLLECTED_MATCH,
    });

    const bucketStarts = Array.from({ length: 6 }, (_, i) => addDays(rangeStart, i * 5));
    values = bucketStarts.map((start, i) => {
      const end = i === bucketStarts.length - 1 ? today : addDays(start, 4);
      return collected.filter((a) => a.date >= start && a.date <= end).reduce((sum, a) => sum + (a.amountPaid || 0), 0);
    });
    labels = bucketStarts.map((d) => {
      const dt = parseDateStr(d);
      return dt.toLocaleDateString('en-US', { month: 'short', day: 'numeric', timeZone: 'UTC' });
    });
    total = values.reduce((a, b) => a + b, 0);

    const prevStart = addDays(rangeStart, -30);
    const prevEnd = addDays(rangeStart, -1);
    previousTotal = await sumCollected({ date: { $gte: prevStart, $lte: prevEnd } });
    rangeQuery = { date: { $gte: rangeStart, $lte: today } };
  } else {
    // week: trailing 7 days, oldest first.
    const days = Array.from({ length: 7 }, (_, i) => addDays(today, i - 6));
    const collected = await Appointment.find({ date: { $gte: days[0], $lte: today }, ...COLLECTED_MATCH });
    values = days.map((d) => collected.filter((a) => a.date === d).reduce((sum, a) => sum + (a.amountPaid || 0), 0));
    labels = days.map(shortWeekday);
    total = values.reduce((a, b) => a + b, 0);

    const prevStart = addDays(days[0], -7);
    const prevEnd = addDays(days[0], -1);
    previousTotal = await sumCollected({ date: { $gte: prevStart, $lte: prevEnd } });
    rangeQuery = { date: { $gte: days[0], $lte: today } };
  }

  const [methodBreakdown, topServices, serviceDoctorBreakdown, paymentOptionBreakdown] = await Promise.all([
    Appointment.aggregate([
      { $match: { ...rangeQuery, ...COLLECTED_MATCH } },
      { $group: { _id: '$paymentMethod', total: { $sum: '$amountPaid' } } },
      { $sort: { total: -1 } },
    ]),
    Appointment.aggregate([
      { $match: { ...rangeQuery, ...COLLECTED_MATCH } },
      { $group: { _id: '$serviceName', total: { $sum: '$amountPaid' } } },
      { $sort: { total: -1 } },
      { $limit: 5 },
    ]),
    // "Which service, performed by which doctor, earned how much" -- powers
    // the detailed breakdown table on the Revenue screen.
    Appointment.aggregate([
      { $match: { ...rangeQuery, ...COLLECTED_MATCH } },
      {
        $group: {
          _id: { service: '$serviceName', doctor: '$doctorName' },
          amount: { $sum: '$amountPaid' },
          visits: { $sum: 1 },
        },
      },
      { $sort: { amount: -1 } },
      { $limit: 20 },
    ]),
    // Full-payment vs consultation-fee-only bookings, and how much is still
    // outstanding from the latter -- surfaces the new booking feature on the
    // Revenue screen.
    Appointment.aggregate([
      { $match: { ...rangeQuery, status: { $ne: 'Cancelled' } } },
      {
        $group: {
          _id: '$paymentOption',
          count: { $sum: 1 },
          collected: { $sum: '$amountPaid' },
          outstanding: { $sum: '$balanceDue' },
        },
      },
    ]),
  ]);

  const methodTotal = methodBreakdown.reduce((sum, m) => sum + m.total, 0) || 1;
  const outstandingBalance = paymentOptionBreakdown.reduce((sum, p) => sum + (p.outstanding || 0), 0);

  return {
    period,
    values,
    labels,
    total,
    previousTotal,
    outstandingBalance,
    paymentMethods: methodBreakdown.map((m) => ({
      method: m._id || 'Other',
      amount: m.total,
      percent: m.total / methodTotal,
    })),
    topServices: topServices.map((s) => ({ name: s._id || 'Unknown', amount: s.total })),
    breakdown: serviceDoctorBreakdown.map((b) => ({
      serviceName: b._id.service || 'Unknown',
      doctorName: b._id.doctor || 'Unknown',
      amount: b.amount,
      visits: b.visits,
    })),
    paymentOptions: paymentOptionBreakdown.map((p) => ({
      option: p._id || 'Full Payment',
      count: p.count,
      collected: p.collected,
      outstanding: p.outstanding,
    })),
  };
}

async function getTodayRevenueSummary() {
  const today = todayStr();
  const [collected, total] = await Promise.all([
    Appointment.find({ date: today, ...COLLECTED_MATCH }),
    sumCollected({ date: today }),
  ]);
  const values = DAY_BUCKETS.map((bucket) =>
    collected
      .filter((a) => {
        const mins = minutesOfDay(a.time);
        return mins >= bucket.from && mins <= bucket.to;
      })
      .reduce((sum, a) => sum + (a.amountPaid || 0), 0)
  );
  return {
    total,
    values,
    labels: DAY_BUCKETS.map((b) => b.label),
  };
}

async function getPatientAppointments(email) {
  return Appointment.find({ patientEmail: email.toLowerCase().trim() }).sort({ createdAt: -1 });
}

export const adminService = {
  getDashboardStats,
  listPatients,
  getRevenue,
  getPatientAppointments,
};
