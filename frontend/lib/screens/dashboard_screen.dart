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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Live Status & Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Welcome Back, ${state.username}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2CB67D).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2CB67D), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record, color: Color(0xFF2CB67D), size: 10),
                            SizedBox(width: 6),
                            Text('SYSTEM ONLINE', style: TextStyle(color: Color(0xFF2CB67D), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('AI Executive Intelligence & Operations Overview', style: TextStyle(color: MailMindTheme.textMuted, fontSize: 13)),
                ],
              ),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MailMindTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () => state.triggerSync(),
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Live Sync'),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // 4 Main Metric Glass Cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 768 ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 1.6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMetricCard('TOTAL EMAILS', '${stats['total_emails']}', Icons.email_outlined, Colors.blue, 'Synced Across 4 Accounts'),
              _buildMetricCard('UNREAD PRIORITY', '${stats['unread_important']}', Icons.star_border, Colors.amber, 'Requires Immediate Review'),
              _buildMetricCard('TRACKED PIPELINE', '${appStats['total'] ?? 0}', Icons.timeline, Colors.purple, '${appStats['interviews'] ?? 0} Interviews Scheduled'),
              _buildMetricCard('SECURITY SHIELD', '${stats['security_score']}%', Icons.gpp_good_outlined, Colors.emerald, '${stats['blocked_phishing']} Threats Isolated'),
            ],
          ),
          const SizedBox(height: 24),

          // Daily AI Summary Card widget
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: MailMindTheme.glassBox(color: MailMindTheme.accent.withOpacity(0.08), borderOpacity: 0.2, showGlow: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                        const SizedBox(width: 8),
                        Text('AI Copilot Daily Briefing', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MailMindTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('UPDATED JUST NOW', style: TextStyle(color: MailMindTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Google Technical Interview: Confirmed for June 30. Recommendation: Complete binary search tree practice.\n'
                  '• Microsoft OA: Technical coding assessment link active. Submission deadline in 5 days.\n'
                  '• CS-401 Homework: Machine Learning Midterm extended to July 4 by Prof. Adams.\n'
                  '• Threat Mitigation: Isolated 1 phishing attempt claiming Amazon Gift Card reward.',
                  style: TextStyle(height: 1.7, fontSize: 13, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Side-by-side modules: Deadlines & Opportunities Pipeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Deadlines
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: MailMindTheme.glassBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Upcoming Deadlines', style: Theme.of(context).textTheme.titleMedium),
                          const Icon(Icons.alarm, size: 18, color: Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildListItem('Google Coding Assessment', 'Due in 5 Days (June 30)', Icons.code, Colors.blue),
                      _buildListItem('CS-401 ML Midterm HW', 'Due in 10 Days (July 4)', Icons.assignment, Colors.purple),
                      _buildListItem('Final Exams Registration', 'Due in 4 Days (June 28)', Icons.app_registration, Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Column 2: Recent Activity
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: MailMindTheme.glassBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Opportunities', style: Theme.of(context).textTheme.titleMedium),
                          const Icon(Icons.work_outline, size: 18, color: Color(0xFF2CB67D)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildListItem('Google (Software Intern)', 'Interview Scheduled', Icons.check_circle_outline, const Color(0xFF2CB67D)),
                      _buildListItem('Microsoft (SE Role)', 'Assessment Active', Icons.hourglass_empty, Colors.amber),
                      _buildListItem('University Registrar', 'Exam Notice Pending', Icons.info_outline, Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MailMindTheme.glassBox(showGlow: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(val, style: TextStyle(fontSize: 26, fontWeight: FontWeight.extrabold, color: MailMindTheme.textMain)),
          Text(subtitle, style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MailMindTheme.textMain)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

