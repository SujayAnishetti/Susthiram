import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class NgoDonationScreen extends StatefulWidget {
  const NgoDonationScreen({super.key});

  @override
  State<NgoDonationScreen> createState() => _NgoDonationScreenState();
}

class _NgoDonationScreenState extends State<NgoDonationScreen> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate to NGO'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _submitted ? _buildLifecycleView() : _buildDonationForm(),
    );
  }

  Widget _buildDonationForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Make a Difference',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Your donation will help those in need. Choose an NGO partner.',
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          _buildNgoCard(
            'Hope Foundation',
            'Supporting underprivileged children',
          ),
          const SizedBox(height: 16),
          _buildNgoCard('Green Earth', 'Recycling for a better planet'),
          const SizedBox(height: 16),
          _buildNgoCard('Care India', 'Empowering rural communities'),
        ],
      ),
    );
  }

  Widget _buildNgoCard(String name, String description) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(Icons.volunteer_activism, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            setState(() => _submitted = true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.black,
          ),
          child: const Text('Donate'),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildLifecycleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF00E676),
            size: 64,
          ).animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Donation Successful!',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          const Text(
            'Here is the projected lifecycle of your garment:',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 48),
          _buildTimelineItem(
            icon: Icons.inventory_2,
            title: 'Collection',
            description: 'Picked up by our logistics partner.',
            isLast: false,
            delay: 200.ms,
          ),
          _buildTimelineItem(
            icon: Icons.cleaning_services,
            title: 'Processing',
            description: 'Cleaned and refurbished at our facility.',
            isLast: false,
            delay: 400.ms,
          ),
          _buildTimelineItem(
            icon: Icons.checkroom,
            title: 'Distribution',
            description: 'Sent to rural distribution centers.',
            isLast: false,
            delay: 600.ms,
          ),
          _buildTimelineItem(
            icon: Icons.sentiment_satisfied_alt,
            title: 'New Life',
            description: 'Worn by someone in need, extending its life.',
            isLast: true,
            delay: 800.ms,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ).animate().fadeIn(delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isLast,
    required Duration delay,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            if (!isLast) Container(width: 2, height: 60, color: Colors.white24),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay).slideX(begin: 0.2, end: 0);
  }
}
