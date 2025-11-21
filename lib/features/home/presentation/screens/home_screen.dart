import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:susthiram/features/scan/presentation/screens/past_scans_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual user ID from auth provider
    const userId = 'user_123';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Susthiram'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(),
            Text(
              'Sustainable Warrior',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            Text(
              'Your Past Scans',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Expanded(child: PastScansScreen(userId: userId)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        backgroundColor: const Color(0xFF00E676),
        icon: const Icon(Icons.camera_alt, color: Colors.black),
        label: const Text(
          'Scan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ).animate().scale(delay: 500.ms),
    );
  }
}
