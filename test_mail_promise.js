process.env.SMTP_HOST = "";
process.env.SMTP_PORT = "587";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";
process.env.SMTP_FROM = "no-reply@fishcap.app";

const nodemailer = require("nodemailer");
const host = process.env.SMTP_HOST;
const port = Number(process.env.SMTP_PORT ?? 587);
console.log("Host:", JSON.stringify(host), "Port:", port);

const transporter = nodemailer.createTransport({
  host,
  port,
  secure: port === 465,
  connectionTimeout: 10000,
  greetingTimeout: 10000,
  socketTimeout: 10000,
  auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
});

const p = transporter.sendMail({
  from: process.env.SMTP_FROM,
  to: "daline@gmail.com",
  subject: "Test",
  text: "Test body",
});

p.catch((err) => {
  console.log("CAUGHT rejection:", err.code, err.message);
});

console.log("Promise state after creation:", p instanceof Promise ? "pending Promise" : typeof p);

setTimeout(() => {
  console.log("Timeout reached, exiting");
  process.exit(0);
}, 5000);
