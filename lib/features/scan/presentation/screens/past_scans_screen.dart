import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:susthiram/features/scan/data/scan_repository.dart';
import 'package:susthiram/features/scan/domain/garment_analysis.dart';

class PastScansScreen extends StatelessWidget {
  final String userId;

  const PastScansScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final repository = ScanRepository();

    return StreamBuilder<List<GarmentAnalysis>>(
      stream: repository.getScans(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading scans',
              style: TextStyle(color: Colors.red[400]),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final scans = snapshot.data ?? [];

        if (scans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'No scans yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan your first garment to get started',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ).animate().fadeIn();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            final isReusable = scan.classification == 'Reusable';
            final color =
                isReusable ? const Color(0xFF00E676) : const Color(0xFF2979FF);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white10),
              ),
              child: InkWell(
                onTap: () => context.push('/results', extra: scan),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isReusable ? Icons.checkroom : Icons.recycling,
                          color: color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.itemName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    scan.classification,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Score: ${scan.score}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white24,
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideX();
          },
        );
      },
    );
  }
}
