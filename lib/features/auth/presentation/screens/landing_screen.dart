import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.eco_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  'Susthiram',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Sustainable Garment Management\nPowered by AI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate().fadeIn(delay: 400.ms),
                const Spacer(),
                _buildRoleButton(
                  context,
                  title: 'Normal User',
                  subtitle: 'Recycle, Reuse & Get Styled',
                  icon: Icons.person_outline,
                  onTap: () => context.go('/auth/user'),
                  delay: 600.ms,
                ),
                const SizedBox(height: 16),
                _buildRoleButton(
                  context,
                  title: 'Commercial',
                  subtitle: 'Vendors, NGOs & Companies',
                  icon: Icons.business_outlined,
                  onTap: () => context.go('/auth/commercial'),
                  delay: 800.ms,
                  isOutlined: true,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Duration delay,
    bool isOutlined = false,
  }) {
    final buttonStyle =
        isOutlined
            ? OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
            : ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );

    return SizedBox(
      height: 90,
      child:
          isOutlined
              ? OutlinedButton(
                onPressed: onTap,
                style: buttonStyle,
                child: _buildButtonContent(
                  context,
                  title,
                  subtitle,
                  icon,
                  isOutlined,
                ),
              )
              : ElevatedButton(
                onPressed: onTap,
                style: buttonStyle,
                child: _buildButtonContent(
                  context,
                  title,
                  subtitle,
                  icon,
                  isOutlined,
                ),
              ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2, end: 0);
  }

  Widget _buildButtonContent(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isOutlined,
  ) {
    final color =
        isOutlined ? Theme.of(context).colorScheme.primary : Colors.black;
    final subColor = isOutlined ? Colors.white70 : Colors.black54;

    return Row(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isOutlined ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: subColor),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: color),
      ],
    );
  }
}
