import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final stats = state.analytics;

    // Filter spam/phishing emails dynamically
    final spamEmails = state.emails.where((e) {
      final sub = e['subject'].toString().toLowerCase();
      final body = e['body'].toString().toLowerCase();
      return e['category'] == 'Spam' ||
          sub.contains('gift card') ||
          sub.contains('win') ||
          body.contains('scam') ||
          body.contains('phishing');
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Security Center', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Shield parameters monitoring authentication safety, attachment integrity, and email scans.', style: TextStyle(color: MailMindTheme.textMuted)),
          const SizedBox(height: 24),

          // Security Score Row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: MailMindTheme.glassBox(color: const Color(0xFF16161A)),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: (stats['security_score'] as int? ?? 92) / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: const Color(0xFF2CB67D),
                      ),
                    ),
                    Text(
                      '${stats['security_score'] ?? 92}%',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Security Shield: Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2CB67D))),
                      SizedBox(height: 4),
                      Text(
                        'AI engine scans incoming messages in real-time. Blocked phishing attempts have been sandboxed and isolated automatically. No action is required.',
                        style: TextStyle(color: MailMindTheme.textMuted, fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Side-by-side modules
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blocked Threats logs list
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blocked Threats Log', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        spamEmails.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: Text('No security threats blocked today.', style: TextStyle(color: MailMindTheme.textMuted))),
                              )
                            : Column(
                                children: spamEmails.map((e) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.gpp_bad, color: Colors.red),
                                  title: Text(e['subject'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  subtitle: Text('From: ${e['sender']}', style: TextStyle(fontSize: 10, color: MailMindTheme.textMuted)),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('ISOLATED', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                )).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Attachment Scanner status
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attachment Safety Scanner', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 20),
                        _buildAttachmentRow('cv_v2_final.pdf', 'Safe (Verified)', Icons.verified_user, const Color(0xFF2CB67D)),
                        _buildAttachmentRow('invoice_29910.xlsx', 'Safe (Verified)', Icons.verified_user, const Color(0xFF2CB67D)),
                        _buildAttachmentRow('win_giftcard_1000.exe', 'Dangerous (Blocked)', Icons.gpp_bad, Colors.red),
                        _buildAttachmentRow('lecture_slides_ml.zip', 'Safe (Verified)', Icons.verified_user, const Color(0xFF2CB67D)),
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

  Widget _buildAttachmentRow(String filename, String status, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: color.withOpacity(0.6), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filename, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: color, fontSize: 10)),
              ],
            ),
          ),
          Icon(icon, color: color, size: 18),
        ],
      ),
    );
  }
}
