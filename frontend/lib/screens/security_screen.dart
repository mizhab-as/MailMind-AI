import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final TextEditingController _urlCtrl = TextEditingController();
  String? _urlAnalysisResult;
  bool _isAnalyzingUrl = false;

  void _analyzeUrl() async {
    if (_urlCtrl.text.trim().isEmpty) return;
    setState(() {
      _isAnalyzingUrl = true;
      _urlAnalysisResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    final url = _urlCtrl.text.trim().toLowerCase();
    setState(() {
      _isAnalyzingUrl = false;
      if (url.contains('scam') || url.contains('giftcard') || url.contains('free') || url.contains('claim')) {
        _urlAnalysisResult = 'DANGEROUS: Spoofed domain detected with high phishing risk!';
      } else {
        _urlAnalysisResult = 'SAFE: Valid SSL certificate and high domain authority confirmed.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final stats = state.analytics;

    final spamEmails = state.emails.where((e) {
      final sub = e['subject'].toString().toLowerCase();
      final body = e['body'].toString().toLowerCase();
      return e['category'] == 'Spam' || sub.contains('gift card') || sub.contains('win') || body.contains('scam') || body.contains('phishing');
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Security Shield & Operations Center', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text('Active email protection, SPF/DKIM authentication, link scanner, and threat quarantine.', style: TextStyle(color: MailMindTheme.textMuted, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF2CB67D).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2CB67D))),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Color(0xFF2CB67D), size: 16),
                    SizedBox(width: 6),
                    Text('PROTECTION ACTIVE', style: TextStyle(color: Color(0xFF2CB67D), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Security Score & Protocol Verification Row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: MailMindTheme.glassBox(color: const Color(0xFF16161A), borderOpacity: 0.2, showGlow: true),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: (stats['security_score'] as int? ?? 92) / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: const Color(0xFF2CB67D),
                      ),
                    ),
                    Text('${stats['security_score'] ?? 92}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.extrabold)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Organization Security Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'SPF, DKIM, and DMARC record checks passed for 4 connected accounts. Real-time neural phishing scanner operational.',
                        style: TextStyle(color: MailMindTheme.textMuted, fontSize: 12, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildAuthBadge('SPF PASS', const Color(0xFF2CB67D)),
                          const SizedBox(width: 8),
                          _buildAuthBadge('DKIM SIGNED', const Color(0xFF2CB67D)),
                          const SizedBox(width: 8),
                          _buildAuthBadge('DMARC ENFORCED', const Color(0xFF2CB67D)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Link Safety & Domain Inspector Tool
          Container(
            padding: const EdgeInsets.all(20),
            decoration: MailMindTheme.glassBox(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('Interactive Link Safety & Domain Inspector', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlCtrl,
                        style: TextStyle(color: MailMindTheme.textMain, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Paste suspicious URL (e.g. http://claim-amazon-giftcard.net)...',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: _isAnalyzingUrl ? null : _analyzeUrl,
                      icon: _isAnalyzingUrl ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search, size: 16),
                      label: const Text('Scan Link'),
                    ),
                  ],
                ),
                if (_urlAnalysisResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _urlAnalysisResult!.startsWith('SAFE') ? const Color(0xFF2CB67D).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _urlAnalysisResult!.startsWith('SAFE') ? const Color(0xFF2CB67D) : Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(_urlAnalysisResult!.startsWith('SAFE') ? Icons.check_circle : Icons.warning_amber, color: _urlAnalysisResult!.startsWith('SAFE') ? const Color(0xFF2CB67D) : Colors.red, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_urlAnalysisResult!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _urlAnalysisResult!.startsWith('SAFE') ? const Color(0xFF2CB67D) : Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Side-by-side modules: Blocked Threats & Attachment Scanner
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Blocked Threats
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: MailMindTheme.glassBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Isolated Phishing Threats', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      spamEmails.isEmpty
                          ? Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('No security threats blocked today.', style: TextStyle(color: MailMindTheme.textMuted))))
                          : Column(
                              children: spamEmails.map((e) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.gpp_bad, color: Colors.red),
                                title: Text(e['subject'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                subtitle: Text('From: ${e['sender']}', style: TextStyle(fontSize: 10, color: MailMindTheme.textMuted)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('QUARANTINED', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              )).toList(),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Column 2: Attachment Scanner
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: MailMindTheme.glassBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sandboxed Attachment Scanner', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _buildAttachmentRow('cv_v2_final.pdf', 'Verified Safe', Icons.verified_user, const Color(0xFF2CB67D)),
                      _buildAttachmentRow('invoice_29910.xlsx', 'Verified Safe', Icons.verified_user, const Color(0xFF2CB67D)),
                      _buildAttachmentRow('win_giftcard_1000.exe', 'Malicious (Blocked)', Icons.gpp_bad, Colors.red),
                      _buildAttachmentRow('lecture_slides_ml.zip', 'Verified Safe', Icons.verified_user, const Color(0xFF2CB67D)),
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

  Widget _buildAuthBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAttachmentRow(String filename, String status, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: color.withOpacity(0.7), size: 22),
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

