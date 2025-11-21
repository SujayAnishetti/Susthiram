import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class CommercialDashboardScreen extends StatelessWidget {
  const CommercialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd get the role from the Auth Provider
    const String role = 'Company'; // Placeholder: 'Vendor', 'NGO', or 'Company'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(),
            Text(
              '$role Partner',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            if (role == 'Company') _buildCompanyWidgets(context),
            if (role == 'Vendor') _buildVendorWidgets(context),
            if (role == 'NGO') _buildNgoWidgets(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyWidgets(BuildContext context) {
    return Column(
      children: [
        _buildStatCard(
          context,
          'Carbon Credits',
          '1,250',
          Icons.co2,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          'Launch Campaign',
          'Start a new sustainability drive',
          Icons.campaign,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          'Employee Leaderboard',
          'View top contributors',
          Icons.leaderboard,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildVendorWidgets(BuildContext context) {
    return Column(
      children: [
        _buildStatCard(
          context,
          'Active Negotiations',
          '5',
          Icons.chat,
          Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          'Incoming Requests',
          'View items for sale',
          Icons.inventory,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildNgoWidgets(BuildContext context) {
    return Column(
      children: [
        _buildStatCard(
          context,
          'Donations Received',
          '128',
          Icons.volunteer_activism,
          Colors.red,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          'Update Impact Stories',
          'Share lifecycle visualizations',
          Icons.history_edu,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          Icon(icon, size: 48, color: color.withOpacity(0.5)),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
        ],
      ),
    ).animate().fadeIn().slideY();
  }
}
