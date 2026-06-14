import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

/// Login screen — supports phone OTP and email/password login
/// Users can switch between the two modes using tabs
class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Phone form
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  // Email form
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Phone OTP Login
  // ---------------------------------------------------------------------------

  void _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final phoneNumber = '+91${_phoneController.text.trim()}';

    await authProvider.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: () {
        // Navigate to OTP verification screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(phoneNumber: phoneNumber),
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Email Login
  // ---------------------------------------------------------------------------

  void _signInWithEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );

    if (success && mounted) {
      // Navigate to home — handled by the auth state listener in main.dart
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // App logo / brand header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_repair_service_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // "Welcome back" heading
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sign in to continue booking home services',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              // Login mode tab switcher
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Phone OTP'),
                    Tab(text: 'Email'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Tab content
              SizedBox(
                height: 260,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Phone OTP tab
                    _buildPhoneTab(authProvider),
                    // Email tab
                    _buildEmailTab(authProvider),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.dontHaveAccount,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      AppStrings.signUp,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Phone OTP tab UI
  Widget _buildPhoneTab(AuthProvider authProvider) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your phone number to receive an OTP',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          // Phone number field with +91 prefix
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            ),
            onChanged: (value) {
            print("Typed: $value");
            },

             
            validator: Validators.phone,
            decoration: InputDecoration(
              hintText: '9876543210',
              counterText: '',
              prefixText: '+91 ',
              prefixStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),       
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: AppStrings.sendOtp,
            onPressed: _sendOtp,
            isLoading: authProvider.isLoading,
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  // Email / Password tab UI
  Widget _buildEmailTab(AuthProvider authProvider) {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            decoration: const InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.email_outlined),
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.password,
            decoration: InputDecoration(
              hintText: '••••••',
              prefixIcon: const Icon(Icons.lock_outlined),
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: AppStrings.signIn,
            onPressed: _signInWithEmail,
            isLoading: authProvider.isLoading,
          ),
        ],
      ),
    );
  }
}
