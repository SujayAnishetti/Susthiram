import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:susthiram/features/scan/domain/garment_analysis.dart';

class ResultsScreen extends StatelessWidget {
  final GarmentAnalysis analysis;

  const ResultsScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final isReusable = analysis.classification == 'Reusable';
    final color =
        isReusable ? const Color(0xFF00E676) : const Color(0xFF2979FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '${analysis.score}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: color),
                    ),
                  ],
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 32),
            Text(
              analysis.itemName,
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                analysis.classification.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Quality Assessment',
              analysis.qualityAssessment,
              400.ms,
            ),
            _buildSection(context, 'Reasoning', analysis.reasoning, 500.ms),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children:
                  analysis.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: const Color(0xFF2C2C2C),
                      labelStyle: const TextStyle(color: Colors.white70),
                    );
                  }).toList(),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (isReusable) {
                    context.push('/chat', extra: {'agentType': 'Stylist'});
                  } else {
                    _showRecycleOptions(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: Text(
                  isReusable ? 'Get Styling Suggestions' : 'Recycle Now',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    Duration delay,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(content, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
      ],
    ).animate().fadeIn(delay: delay);
  }

  void _showRecycleOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.white),
                  title: const Text(
                    'Sell to Vendor',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'AI Agent will negotiate for you',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/chat', extra: {
                      'agentType': 'Vendor',
                      'garmentContext': {
                        'itemName': analysis.itemName,
                        'classification': analysis.classification,
                        'score': analysis.score,
                        'qualityAssessment': analysis.qualityAssessment,
                        'tags': analysis.tags,
                        'reasoning': analysis.reasoning,
                      },
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.volunteer_activism,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Donate to NGO',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Track lifecycle impact',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/ngo');
                  },
                ),
              ],
            ),
          ),
    );
  }
}
