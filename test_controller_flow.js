// Simulate the request-otp handler flow
process.env.SMTP_HOST = "";
process.env.SMTP_PORT = "587";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";
process.env.SMTP_FROM = "no-reply@fishcap.app";

const nodemailer = require("nodemailer");

function sendMailStub(email, code) {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT ?? 587),
    secure: Number(process.env.SMTP_PORT ?? 587) === 465,
    connectionTimeout: 10000,
    greetingTimeout: 10000,
    socketTimeout: 10000,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });
  const p = transporter.sendMail({
    from: process.env.SMTP_FROM,
    to: email,
    subject: "Test",
    text: `Code is ${code}`,
  });
  return Promise.resolve(p)
    .catch((error) => {
      throw new Error(`sendVerificationCode failed: ${error.message}`);
    });
}

async function requestOtp(email) {
  console.log("1. createOtp (simulated) -> code=123456");
  const otp = { code: "123456" };
  try {
    console.log("2. calling sendVerificationCode...");
    await sendMailStub(email, otp.code);
    console.log("3. send succeeded");
    return { success: true, data: { message: "OTP sent successfully" } };
  } catch (err) {
    console.log("4. catch block entered, throwing 503");
    const err2 = new Error("Could not send verification email. Please try again later.");
    err2.statusCode = 503;
    err2.status = 503;
    throw err2;
  }
}

(async () => {
  try {
    const result = await requestOtp("daline@gmail.com");
    console.log("RESULT:", JSON.stringify(result));
  } catch (err) {
    console.log("FINAL ERROR:", err.status || err.statusCode, err.message);
  }
  process.exit(0);
})();
