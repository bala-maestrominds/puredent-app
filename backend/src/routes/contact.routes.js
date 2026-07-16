import { Router } from "express";
import rateLimit from "express-rate-limit";
import { createTransporter, buildContactEmail } from "../utils/mailer.js";

const router = Router();

// Guard against abuse of the mail-sending endpoint.
const contactLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many messages sent. Please try again later." },
});

const EMAIL_REGEX = /^\S+@\S+\.\S+$/;

router.post("/", contactLimiter, async (req, res) => {
  try {
    const { name, email, service, message } = req.body;

    if (!name?.trim() || !email?.trim() || !message?.trim()) {
      return res.status(400).json({ error: "Name, email, and message are required." });
    }
    if (!EMAIL_REGEX.test(email)) {
      return res.status(400).json({ error: "Please provide a valid email address." });
    }

    const transporter = createTransporter();
    const { subject, text, html } = buildContactEmail({
      name: name.trim(),
      email: email.trim(),
      service: service?.trim() || "General Dentistry",
      message: message.trim(),
    });

    await transporter.sendMail({
      from: `"PureDent Website" <${process.env.GMAIL_USER}>`,
      to: process.env.ADMIN_EMAIL || process.env.GMAIL_USER,
      replyTo: email.trim(),
      subject,
      text,
      html,
    });

    return res.status(200).json({ success: true });
  } catch (err) {
    console.error("Failed to send contact email:", err);
    return res.status(500).json({ error: "Failed to send your message. Please try again shortly." });
  }
});

export default router;