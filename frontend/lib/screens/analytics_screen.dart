import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final stats = state.analytics;

    if (stats.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: MailMindTheme.accent));
    }

    final catStats = stats['categories_breakdown'] as Map<String, dynamic>? ?? {};
    final appStats = stats['applications'] as Map<String, dynamic>? ?? {};

    // Find the maximum category count for relative bar scaling
    int maxCount = 1;
    catStats.forEach((k, v) {
      if (v is int && v > maxCount) maxCount = v;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email Intelligence Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text('Visual metrics summarizing opportunities, categories, and inbox loads.', style: TextStyle(color: MailMindTheme.textMuted)),
          const SizedBox(height: 24),

          // Core Metrics
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Acceptance Rate',
                  '${appStats['total'] != null && appStats['total'] > 0 ? ((appStats['accepts'] ?? 0) / appStats['total'] * 100).toStringAsFixed(1) : 0}%',
                  Icons.verified_user_outlined,
                  const Color(0xFF2CB67D),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStat(
                  'Interview Conversion',
                  '${appStats['total'] != null && appStats['total'] > 0 ? ((appStats['interviews'] ?? 0) / appStats['total'] * 100).toStringAsFixed(1) : 0}%',
                  Icons.video_call_outlined,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStat(
                  'Blocked Scams Rate',
                  '${stats['total_emails'] != null && stats['total_emails'] > 0 ? ((stats['blocked_phishing'] ?? 0) / stats['total_emails'] * 100).toStringAsFixed(1) : 0}%',
                  Icons.gpp_good_outlined,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Side by side charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories distribution custom chart
              Expanded(
                flex: 6,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category Breakdown', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 20),
                        ...catStats.entries.map((entry) {
                          final label = entry.key;
                          final count = entry.value as int;
                          final percentage = maxCount > 0 ? count / maxCount : 0.0;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text('$count emails', style: const TextStyle(fontSize: 11, color: MailMindTheme.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Custom visual bar
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          width: constraints.maxWidth,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        Container(
                                          height: 8,
                                          width: constraints.maxWidth * percentage,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [MailMindTheme.accent, Color(0xFF2CB67D)],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Funnel statistics
              Expanded(
                flex: 4,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Opportunity Pipeline', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 24),
                        _buildPipelineRow('Applied Stages', '${appStats['total'] ?? 0}', Colors.blue, 1.0),
                        _buildPipelineRow('Assessments Scheduled', '${appStats['total'] != null ? appStats['total'] - (appStats['rejects'] ?? 0) : 0}', Colors.purple, 0.8),
                        _buildPipelineRow('Live Interviews', '${appStats['interviews'] ?? 0}', Colors.amber, 0.5),
                        _buildPipelineRow('Hired Offers', '${appStats['accepts'] ?? 0}', const Color(0xFF2CB67D), 0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MailMindTheme.glassBox(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: MailMindTheme.textMuted)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPipelineRow(String label, String value, Color color, double widthPercent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => Container(
              height: 24,
              width: constraints.maxWidth * widthPercent,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
