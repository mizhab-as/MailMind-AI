import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import 'compose_modal.dart';
import 'rules_modal.dart';

class CommandPaletteModal extends StatefulWidget {
  final Function(int) onNavigate;

  const CommandPaletteModal({super.key, required this.onNavigate});

  @override
  State<CommandPaletteModal> createState() => _CommandPaletteModalState();
}

class _CommandPaletteModalState extends State<CommandPaletteModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    final commands = [
      {
        'title': 'Go to Dashboard',
        'subtitle': 'Executive intelligence & live operational metrics',
        'icon': Icons.dashboard_outlined,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(0);
        }
      },
      {
        'title': 'Open Smart Inbox',
        'subtitle': 'Browse categorized email threads with AI summaries',
        'icon': Icons.mail_outline,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(1);
        }
      },
      {
        'title': 'Open Opportunity Kanban Tracker',
        'subtitle': 'Manage job search pipeline & AI interview prep',
        'icon': Icons.timeline,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(2);
        }
      },
      {
        'title': 'Open Calendar & Deadlines',
        'subtitle': 'View synced exams, assessments, and interview dates',
        'icon': Icons.calendar_today_outlined,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(3);
        }
      },
      {
        'title': 'Open AI Assistant Chat',
        'subtitle': 'Ask questions about your email inbox & job status',
        'icon': Icons.chat_bubble_outline,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(4);
        }
      },
      {
        'title': 'Open Analytics Hub',
        'subtitle': 'Inspect email velocity charts & conversion funnel',
        'icon': Icons.bar_chart_outlined,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(5);
        }
      },
      {
        'title': 'Open Security Shield',
        'subtitle': 'Phishing threat inspector & link verification',
        'icon': Icons.security_outlined,
        'action': () {
          Navigator.of(context).pop();
          widget.onNavigate(6);
        }
      },
      {
        'title': 'Compose New Email (AI Copilot)',
        'subtitle': 'Draft email with customizable tone generator',
        'icon': Icons.edit_note,
        'action': () {
          Navigator.of(context).pop();
          showDialog(context: context, builder: (context) => const ComposeModal());
        }
      },
      {
        'title': 'Open Automation Rules Builder',
        'subtitle': 'Create custom conditional email workflow rules',
        'icon': Icons.tune,
        'action': () {
          Navigator.of(context).pop();
          showDialog(context: context, builder: (context) => const RulesModal());
        }
      },
      {
        'title': 'Trigger Live Mail Sync',
        'subtitle': 'Simulate real-time inbox synchronization',
        'icon': Icons.sync,
        'action': () {
          Navigator.of(context).pop();
          state.triggerSync();
        }
      },
    ];

    final filtered = commands.where((c) {
      if (_query.isEmpty) return true;
      return c['title'].toString().toLowerCase().contains(_query.toLowerCase()) ||
          c['subtitle'].toString().toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 16, right: 16),
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: MailMindTheme.glassBox(
          color: MailMindTheme.cardBg,
          borderOpacity: 0.25,
          showGlow: true,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Command Palette Search Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.search, color: MailMindTheme.accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: TextStyle(color: MailMindTheme.textMain, fontSize: 15),
                      onChanged: (val) => setState(() => _query = val),
                      decoration: const InputDecoration(
                        hintText: 'Type a command or search actions (Cmd+K)...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ESC to exit', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text('No matching commands found', style: TextStyle(color: MailMindTheme.textMuted)))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final cmd = filtered[idx];
                        return ListTile(
                          leading: Icon(cmd['icon'] as IconData, color: MailMindTheme.accent, size: 20),
                          title: Text(cmd['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(cmd['subtitle'] as String, style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11)),
                          onTap: cmd['action'] as VoidCallback,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
