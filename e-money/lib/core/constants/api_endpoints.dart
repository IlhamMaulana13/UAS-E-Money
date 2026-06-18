import 'app_constants.dart';

class ApiEndpoints {
  static const String _base = AppConstants.apiVersion;

  // Health
  static const String health = '$_base/health';

  // Auth
  static const String verifyToken = '$_base/auth/verify-token';
  static const String register = '$_base/auth/register';
  static const String verifyEmailOtp = '$_base/auth/verify-email-otp';
  static const String me = '$_base/auth/me';
  static const String fcmToken = '$_base/auth/fcm-token';

  // OTP
  static const String sendOtpFirebase = '$_base/otp/send-firebase';
  static const String sendOtpEmail = '$_base/otp/send-email';
  static const String confirmOtp = '$_base/otp/confirm';
  static const String totpRegister = '$_base/otp/totp/register';
  static const String totpVerify = '$_base/otp/totp/verify';

  // Account
  static const String account = '$_base/account';
  static const String transactions = '$_base/account/transactions';

  // Payment
  static const String topup = '$_base/payment/topup';
  static const String transfer = '$_base/payment/transfer';
}
