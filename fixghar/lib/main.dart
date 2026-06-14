import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/service_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';
import 'services/notification_service.dart';

/// Entry point — initialises Firebase, registers background handlers, and runs the app
Future<void> main() async {
  // Ensure Flutter engine is ready before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase (must happen before any Firebase service call)
  if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

  // Register background FCM message handler (must be top-level function)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialise FCM (foreground listener, permission, token fetch)
  await NotificationService().init();

  runApp(const FixGharApp());
}

/// Root widget of the FixGhar application
class FixGharApp extends StatelessWidget {
  const FixGharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register all providers at the top so any widget in the tree can access them
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: MaterialApp(
        title: 'FixGhar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Auth-aware home: show login or main nav depending on auth state
        home: const _AuthGate(),

        // Named routes (used for navigation from confirmation screens)
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
        },

        // Route generator handles arguments (e.g. tab index from confirmation)
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            final tabIndex = settings.arguments as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => MainNavigation(initialIndex: tabIndex),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Decides whether to show the LoginScreen or MainNavigation
/// based on the current Firebase auth state.
/// Rebuilds automatically when auth state changes.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show a loading spinner while auth state is being resolved
    if (authProvider.isLoading && authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Route to the correct screen
    if (authProvider.isLoggedIn) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }
}
