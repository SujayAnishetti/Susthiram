import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:susthiram/features/auth/presentation/screens/landing_screen.dart';
import 'package:susthiram/features/auth/presentation/screens/login_screen.dart';
import 'package:susthiram/features/auth/presentation/screens/signup_user_screen.dart';
import 'package:susthiram/features/auth/presentation/screens/signup_commercial_screen.dart';
import 'package:susthiram/features/home/presentation/screens/home_screen.dart';
import 'package:susthiram/features/scan/presentation/screens/camera_screen.dart';
import 'package:susthiram/features/scan/presentation/screens/results_screen.dart';
import 'package:susthiram/features/scan/domain/garment_analysis.dart';
import 'package:susthiram/features/chat/presentation/screens/chat_screen.dart';
import 'package:susthiram/features/ngo/presentation/screens/ngo_donation_screen.dart';
import 'package:susthiram/features/commercial/presentation/screens/commercial_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(
      path: '/auth/user',
      builder: (context, state) => const SignupUserScreen(),
    ),
    GoRoute(
      path: '/auth/commercial',
      builder: (context, state) => const SignupCommercialScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/scan', builder: (context, state) => const CameraScreen()),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final analysis = state.extra as GarmentAnalysis;
        return ResultsScreen(analysis: analysis);
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final agentType = extra?['agentType'] as String? ?? 'Stylist';
        final garmentContext = extra?['garmentContext'] as Map<String, dynamic>?;
        return ChatScreen(
          agentType: agentType,
          garmentContext: garmentContext,
        );
      },
    ),
    GoRoute(
      path: '/ngo',
      builder: (context, state) => const NgoDonationScreen(),
    ),
    GoRoute(
      path: '/commercial-dashboard',
      builder: (context, state) => const CommercialDashboardScreen(),
    ),
  ],
);
