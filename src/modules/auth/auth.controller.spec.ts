import { AuthController } from './auth.controller';

describe('AuthController.resetPassword', () => {
  let controller: AuthController;
  const authService = { validateUser: jest.fn(), signUser: jest.fn(), register: jest.fn() };
  const otpService = { createOtp: jest.fn(), verifyOtp: jest.fn() };
  const mailService = { sendVerificationCode: jest.fn() };
  const usersService = { findByEmail: jest.fn(), update: jest.fn() };

  beforeEach(() => {
    jest.clearAllMocks();
    controller = new AuthController(
      authService as any,
      otpService as any,
      usersService as any,
      mailService as any,
    );
  });

  const reset = (body: any) =>
    controller.resetPassword(body) as Promise<{ success: boolean; data?: any }>;

  it('emails the generated code without returning it to the client', async () => {
    otpService.createOtp.mockResolvedValue({ code: '123456' });
    mailService.sendVerificationCode.mockResolvedValue(undefined);
    const result = await controller.requestOtp({ email: ' test@example.test ' });
    expect(otpService.createOtp).toHaveBeenCalledWith('test@example.test');
    expect(mailService.sendVerificationCode).toHaveBeenCalledWith('test@example.test', '123456');
    expect(result).toEqual({ success: true, data: { message: 'OTP sent successfully' } });
  });

  it('does not claim success when email delivery fails', async () => {
    otpService.createOtp.mockResolvedValue({ code: '123456' });
    mailService.sendVerificationCode.mockRejectedValue(new Error('SMTP unavailable'));
    await expect(controller.requestOtp({ email: 'test@example.test' }))
      .rejects.toThrow('Could not send verification email');
  });

  const validUser = { id: 'user-1', email: 'test@example.test' };

  it('rejects a password shorter than the registration minimum', async () => {
    await expect(
      reset({ email: 'test@example.test', code: '123456', password: 'short' }),
    ).rejects.toThrow('Password must be at least 8 characters long');
    // An invalid request must never touch the stored password.
    expect(otpService.verifyOtp).not.toHaveBeenCalled();
    expect(usersService.update).not.toHaveBeenCalled();
  });

  it('rejects a wrong or expired code without changing the password', async () => {
    otpService.verifyOtp.mockResolvedValue(false);

    await expect(
      reset({ email: 'test@example.test', code: '000000', password: 'newpassword1' }),
    ).rejects.toThrow('Invalid or expired OTP');
    expect(usersService.update).not.toHaveBeenCalled();
  });

  it('hashes in the new password only after the code is verified', async () => {
    otpService.verifyOtp.mockResolvedValue(true);
    usersService.findByEmail.mockResolvedValue(validUser);
    usersService.update.mockResolvedValue(validUser);

    const res = await reset({
      email: 'test@example.test',
      code: '123456',
      password: 'newpassword1',
    });

    expect(otpService.verifyOtp).toHaveBeenCalledWith('test@example.test', '123456');
    expect(usersService.update).toHaveBeenCalledWith('user-1', {
      password: 'newpassword1',
    });
    expect(res.success).toBe(true);
  });

  it('reports an unknown email instead of creating an account', async () => {
    otpService.verifyOtp.mockResolvedValue(true);
    usersService.findByEmail.mockResolvedValue(null);

    await expect(
      reset({ email: 'ghost@example.test', code: '123456', password: 'newpassword1' }),
    ).rejects.toThrow('User not found');
    expect(usersService.update).not.toHaveBeenCalled();
  });
});
