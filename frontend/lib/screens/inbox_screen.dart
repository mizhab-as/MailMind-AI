import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.all_inbox},
    {'name': 'Opportunities', 'icon': Icons.work_outline, 'color': Colors.purple},
    {'name': 'Interviews', 'icon': Icons.video_call_outlined, 'color': Colors.amber},
    {'name': 'Acceptance', 'icon': Icons.check_circle_outline, 'color': const Color(0xFF2CB67D)},
    {'name': 'Rejection', 'icon': Icons.cancel_outlined, 'color': Colors.red},
    {'name': 'Academic', 'icon': Icons.school_outlined, 'color': Colors.blue},
    {'name': 'Finance', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.green},
    {'name': 'Social', 'icon': Icons.people_outline, 'color': Colors.teal},
    {'name': 'Spam', 'icon': Icons.gpp_bad_outlined, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchEmails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 1000;

    // Filter emails by search query locally
    final filteredEmails = state.emails.where((e) {
      final query = state.searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      return e['sender'].toString().toLowerCase().contains(query) ||
          e['subject'].toString().toLowerCase().contains(query) ||
          e['body'].toString().toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        // Left Panel: Categories filtering
        if (width >= 1200)
          Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = state.selectedCategory == (cat['name'] == 'All' ? null : cat['name']);
                return ListTile(
                  leading: Icon(cat['icon'], color: cat['color'] ?? MailMindTheme.textMuted, size: 18),
                  title: Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : MailMindTheme.textMuted,
                    ),
                  ),
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: Colors.white.withOpacity(0.04),
                  onTap: () => state.selectCategory(cat['name'] == 'All' ? null : cat['name']),
                );
              },
            ),
          ),

        // Middle Panel: Email Feed list
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => state.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search emails...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF16161A),
                    ),
                  ),
                ),
                Expanded(
                  child: state.isLoadingEmails
                      ? const Center(child: CircularProgressIndicator(color: MailMindTheme.accent))
                      : filteredEmails.isEmpty
                          ? const Center(child: Text('No emails found', style: TextStyle(color: MailMindTheme.textMuted)))
                          : ListView.builder(
                              itemCount: filteredEmails.length,
                              itemBuilder: (context, idx) {
                                final e = filteredEmails[idx];
                                final isSelected = state.selectedEmail != null && state.selectedEmail!['id'] == e['id'];
                                final receivedAt = DateTime.parse(e['received_at']);
                                
                                return InkWell(
                                  onTap: () => state.selectEmail(e['id']),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.04) : Colors.transparent,
                                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                e['sender'],
                                                style: TextStyle(
                                                  fontWeight: e['is_read'] ? FontWeight.normal : FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('hh:mm a').format(receivedAt),
                                              style: const TextStyle(color: MailMindTheme.textMuted, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          e['subject'],
                                          style: TextStyle(
                                            fontWeight: e['is_read'] ? FontWeight.normal : FontWeight.bold,
                                            fontSize: 13,
                                            color: e['is_read'] ? MailMindTheme.textMuted : Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Priority Score Circle Indicator badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: MailMindTheme.getPriorityColor(e['importance_score']).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Priority: ${e['importance_score']}',
                                                style: TextStyle(
                                                  color: MailMindTheme.getPriorityColor(e['importance_score']),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                e['category'],
                                                style: const TextStyle(color: MailMindTheme.textMuted, fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),

        // Right Panel: Email Detail & AI Summarization Viewer
        if (!isCompact)
          Expanded(
            flex: 6,
            child: state.selectedEmail == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: MailMindTheme.textMuted, size: 40),
                        SizedBox(height: 12),
                        Text('Select an email to view AI insights', style: TextStyle(color: MailMindTheme.textMuted)),
                      ],
                    ),
                  )
                : _EmailDetailPane(email: state.selectedEmail!),
          ),
      ],
    );
  }
}

class _EmailDetailPane extends StatelessWidget {
  final Map<String, dynamic> email;

  const _EmailDetailPane({required this.email});

  @override
  Widget build(BuildContext context) {
    final summary = email['summary'] ?? {};
    final spam = email['spam_analysis'] ?? {};
    final isPhishing = spam['phishing_detected'] == true;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Header details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email['subject'], style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: MailMindTheme.cardBg,
                      child: const Icon(Icons.person, color: MailMindTheme.textMuted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email['sender'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('To: ${email['recipient']}', style: const TextStyle(color: MailMindTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Security Alert Shield (Spam / Phishing warning card)
          if (spam.isNotEmpty && spam['risk_score'] > 40)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPhishing ? Colors.red.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isPhishing ? Colors.red.withOpacity(0.3) : Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(isPhishing ? Icons.gpp_bad : Icons.warning_amber, color: isPhishing ? Colors.red : Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPhishing ? 'CRITICAL: Phishing Attempt Detected!' : 'Warning: High Spam Risk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPhishing ? Colors.red : Colors.amber,
                              fontSize: 12,
                            ),
                          ),
                          Text(spam['explanation'], style: const TextStyle(fontSize: 11, color: MailMindTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // AI Tab bar
          const TabBar(
            tabs: [
              Tab(text: 'AI Summary'),
              Tab(text: 'Key Points'),
              Tab(text: 'Action Items'),
            ],
            indicatorColor: MailMindTheme.accent,
            labelColor: Colors.white,
            unselectedLabelColor: MailMindTheme.textMuted,
          ),

          // AI Tab views
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: AI Summary (Quick summary sentence)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    summary['quick'] ?? 'No summary available.',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
                // Tab 2: Bullet points
                ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: (summary['bullets'] as List?)?.length ?? 0,
                  itemBuilder: (context, idx) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, color: MailMindTheme.accent, size: 6),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            summary['bullets'][idx],
                            style: const TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab 3: Action items checklist
                ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: (summary['actions'] as List?)?.length ?? 0,
                  itemBuilder: (context, idx) => CheckboxListTile(
                    title: Text(summary['actions'][idx], style: const TextStyle(fontSize: 13)),
                    value: false,
                    onChanged: (val) {},
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Actual Email Body Text Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                email['body'],
                style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
