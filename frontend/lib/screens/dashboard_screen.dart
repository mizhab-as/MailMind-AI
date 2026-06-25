import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final stats = state.analytics;

    if (stats.isEmpty) {
      return Center(child: CircularProgressIndicator(color: MailMindTheme.accent));
    }

    final appStats = stats['applications'] ?? {};
    final catStats = stats['categories_breakdown'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good Afternoon, ${state.username}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Here is what MailMind AI summarized for you today.', style: TextStyle(color: MailMindTheme.textMuted)),
          const SizedBox(height: 24),
          
          // Cards grid row
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 768 ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMetricCard('Total Emails', '${stats['total_emails']}', Icons.email_outlined, Colors.blue),
              _buildMetricCard('Unread Important', '${stats['unread_important']}', Icons.star_border, Colors.amber),
              _buildMetricCard('Tracked Applications', '${appStats['total'] ?? 0}', Icons.timeline, Colors.purple),
              _buildMetricCard('Blocked Attacks', '${stats['blocked_phishing']}', Icons.gpp_bad_outlined, Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // Daily AI Summary Card widget
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: MailMindTheme.glassBox(color: MailMindTheme.accent.withOpacity(0.06), borderOpacity: 0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text('Today\'s AI Insights', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '✓ Google scheduled your data structures interview session for June 30.\n'
                  '✓ Microsoft assigned your online coding assessment (due in 5 days).\n'
                  '✓ CS-401 professor extended your Machine Learning Midterm Homework deadline.\n'
                  '✗ Flagged and isolated 1 phishing threat attempting credential theft.',
                  style: TextStyle(height: 1.6, fontSize: 14),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Side-by-side modules
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Deadlines
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upcoming Deadlines', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _buildListItem('Google Coding Assessment', 'Due in 5 Days', Icons.code),
                        _buildListItem('CS-401 ML Midterm HW', 'Due in 10 Days', Icons.assignment),
                        _buildListItem('Final Exams Registration', 'Due in 4 Days', Icons.app_registration),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Column 2: Recent Activity
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Opportunities Status', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _buildListItem('Google (Internship)', 'Interview Scheduled', Icons.check_circle_outline, const Color(0xFF2CB67D)),
                        _buildListItem('Microsoft (SE Role)', 'Assessment Pending', Icons.hourglass_empty, Colors.amber),
                        _buildListItem('StartupXYZ (Internship)', 'Rejection Email Received', Icons.cancel_outlined, Colors.red),
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

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MailMindTheme.glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: MailMindTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, IconData icon, [Color color = Colors.white]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: MailMindTheme.cardBg,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
