import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

/// OTP Verification screen — entered after phone number is submitted
/// User types the 6-digit SMS code to complete login
class OtpScreen extends StatefulWidget {
  static const routeName = '/otp';
  final String phoneNumber; // Displayed as a hint (e.g. '+919876543210')

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  // Countdown timer for resend button (60 seconds)
  int _secondsRemaining = 60;
  Timer? _timer;
  bool get _canResend => _secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  void _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      smsCode: _otpController.text.trim(),
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );

    if (success && mounted) {
      // Auth state listener in main.dart will navigate to home
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  // ---------------------------------------------------------------------------
  // Resend OTP
  // ---------------------------------------------------------------------------

  void _resendOtp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOtp(
      phoneNumber: widget.phoneNumber,
      onCodeSent: () {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully!')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Phone'),
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // SMS illustration
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit OTP to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // OTP input field
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  validator: Validators.otp,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      letterSpacing: 8,
                      fontSize: 24,
                    ),
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Resend timer / button
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: authProvider.isLoading ? null : _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        'Resend OTP in ${_secondsRemaining}s',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              CustomButton(
                label: 'Verify & Login',
                onPressed: _verifyOtp,
                isLoading: authProvider.isLoading,
                icon: Icons.verified_user_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
