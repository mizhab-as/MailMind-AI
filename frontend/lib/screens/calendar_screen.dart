import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Extract deadlines dynamically from email subjects/bodies
    final deadlines = state.emails.where((e) {
      final sub = e['subject'].toString().toLowerCase();
      final body = e['body'].toString().toLowerCase();
      return sub.contains('deadline') ||
          sub.contains('test') ||
          sub.contains('assessment') ||
          sub.contains('interview') ||
          body.contains('due') ||
          body.contains('close');
    }).toList();

    return Padding(
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
                  Text('Smart Deadlines Calendar', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('AI-extracted timings and deadline reminders synced with local systems.', style: TextStyle(color: MailMindTheme.textMuted)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.sync, color: Colors.blue),
                    label: const Text('Google Calendar', style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.sync, color: Colors.teal),
                    label: const Text('Outlook Calendar', style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: deadlines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: MailMindTheme.textMuted, size: 40),
                        const SizedBox(height: 12),
                        Text('No upcoming deadlines detected.', style: TextStyle(color: MailMindTheme.textMuted)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: deadlines.length,
                    itemBuilder: (context, idx) {
                      final d = deadlines[idx];
                      final receivedAt = DateTime.parse(d['received_at']);
                      final dueAt = receivedAt.add(const Duration(days: 5)); // Mock due date
                      
                      IconData typeIcon = Icons.assignment_outlined;
                      Color typeColor = Colors.blue;
                      
                      if (d['category'] == 'Interviews') {
                        typeIcon = Icons.video_call_outlined;
                        typeColor = Colors.amber;
                      } else if (d['category'] == 'Opportunities') {
                        typeIcon = Icons.school_outlined;
                        typeColor = Colors.purple;
                      } else if (d['category'] == 'Spam') {
                        typeIcon = Icons.warning_amber_outlined;
                        typeColor = Colors.red;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: MailMindTheme.glassBox(),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: typeColor.withOpacity(0.12),
                              child: Icon(typeIcon, color: typeColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d['subject'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Source: ${d['account_name']}', style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(dueAt),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(dueAt),
                                  style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
