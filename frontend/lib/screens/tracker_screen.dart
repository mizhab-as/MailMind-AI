import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  int? _selectedAppIdx;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // Extract applications dynamically from emails loaded in the provider
    final apps = state.emails
        .where((e) => e['category'] == 'Opportunities' || e['category'] == 'Interviews' || e['category'] == 'Acceptance' || e['category'] == 'Rejection')
        .toList();

    if (apps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, color: MailMindTheme.textMuted, size: 48),
            SizedBox(height: 12),
            Text('No active applications tracked in this workspace.', style: TextStyle(color: MailMindTheme.textMuted)),
          ],
        ),
      );
    }

    // Default selection
    if (_selectedAppIdx == null && apps.isNotEmpty) {
      _selectedAppIdx = 0;
    }

    final selectedEmail = apps[_selectedAppIdx!];
    final company = selectedEmail['sender'].split('@').first.toUpperCase();
    final role = selectedEmail['subject'].contains('Intern') ? 'Software Engineering Intern' : 'Software Engineer';
    final status = selectedEmail['category'] == 'Interviews'
        ? 'Interview'
        : selectedEmail['category'] == 'Acceptance'
            ? 'Accepted'
            : selectedEmail['category'] == 'Rejection'
                ? 'Rejected'
                : 'Applied';

    return Row(
      children: [
        // Left Column: Active Applications List
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, idx) {
                final a = apps[idx];
                final isSelected = _selectedAppIdx == idx;
                final date = DateTime.parse(a['received_at']);
                
                return Card(
                  color: isSelected ? MailMindTheme.accent.withOpacity(0.12) : const Color(0xFF16161A),
                  child: ListTile(
                    title: Text(a['sender'].split('@').first.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(a['subject'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(DateFormat('MMM dd').format(date), style: const TextStyle(fontSize: 11, color: MailMindTheme.textMuted)),
                    onTap: () => setState(() => _selectedAppIdx = idx),
                  ),
                );
              },
            ),
          ),
        ),

        // Right Column: Vertical Timelines
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$company: $role', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                Text('Current Status: $status', style: const TextStyle(color: MailMindTheme.accent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                // Timeline milestones
                _buildTimelineNode('Applied', 'Resume submitted & verified', true, true),
                _buildTimelineNode('Technical Assessment', 'Completed online coding challenges', status != 'Applied', true),
                _buildTimelineNode('Interviews Scheduled', 'Live interviews with hiring managers', status == 'Interview' || status == 'Accepted', true),
                _buildTimelineNode('Offer Received', 'Status review and onboarding confirmation', status == 'Accepted', false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineNode(String milestone, String subtitle, bool isCompleted, bool showConnector) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.emerald : MailMindTheme.textMuted,
              size: 20,
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? Colors.emerald : MailMindTheme.textMuted.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                milestone,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.white : MailMindTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: MailMindTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
