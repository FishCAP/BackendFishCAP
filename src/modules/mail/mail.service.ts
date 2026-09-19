// src/modules/mail/mail.service.ts
import { Injectable } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT ?? 587),
    secure: Number(process.env.SMTP_PORT ?? 587) === 465,
    connectionTimeout: 10000,
    greetingTimeout: 10000,
    socketTimeout: 10000,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });

  async sendVerificationCode(email: string, code: string) {
    if (!process.env.SMTP_HOST) {
      throw new Error('SMTP_HOST is not configured');
    }

    const sendMailPromise = this.transporter.sendMail({
      from: process.env.SMTP_FROM ?? 'no-reply@fishcap.app',
      to: email,
      subject: 'Your FishCAP verification code',
      text: `Your FishCAP verification code is ${code}. It expires in 5 minutes. Enter this code in the FishCAP app. If you did not request it, ignore this email.`,
    });

    // Convert the raw nodemailer promise into a settled promise so the caller
    // (request-otp handler) can always catch the error path and surface a
    // ServiceUnavailableException to the client without the request hanging.
    return Promise.resolve(sendMailPromise)
      .catch((error) => {
        // Surface a normalized error so the controller can catch it.
        throw new Error(`sendVerificationCode failed: ${error.message}`);
      });
  }

  async sendPasswordReset(email: string, link: string) {
    await this.transporter.sendMail({
      from: process.env.SMTP_FROM ?? 'no-reply@fishcap.app',
      to: email,
      subject: 'Reset your FishCap password',
      html: `
        <p>You requested a password reset.</p>
        <p><a href="${link}">Click here to reset your password</a></p>
        <p>The link expires in 30 minutes.</p>
        <p>If you didn't request this, you can ignore this email.</p>
      `,
    });
  }
}
