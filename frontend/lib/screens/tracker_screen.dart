import '../services/api_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  int? _selectedAppIdx;
  final ApiService _apiService = ApiService();

  void _showInterviewCoach(String company, String role) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 650,
          padding: const EdgeInsets.all(24),
          decoration: MailMindTheme.glassBox(color: MailMindTheme.cardBg, borderOpacity: 0.2, showGlow: true),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _apiService.generateInterviewPrep(company, role),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.amber),
                      SizedBox(height: 16),
                      Text('Generating AI Interview Prep Guide...'),
                    ],
                  ),
                );
              }
              final data = snapshot.data ?? {};
              final insights = data['company_insights'] ?? '';
              final topics = (data['core_topics'] as List?) ?? [];
              final questions = (data['technical_questions'] as List?) ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: Colors.amber, size: 24),
                            const SizedBox(width: 10),
                            Text('AI Interview Coach: $company ($role)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Company & Role Insights:', style: TextStyle(fontWeight: FontWeight.bold, color: MailMindTheme.accent)),
                    const SizedBox(height: 4),
                    Text(insights, style: const TextStyle(fontSize: 13, height: 1.5)),
                    const SizedBox(height: 16),
                    Text('Core Topics to Master:', style: TextStyle(fontWeight: FontWeight.bold, color: MailMindTheme.accent)),
                    const SizedBox(height: 4),
                    ...topics.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [const Icon(Icons.check, size: 14, color: Color(0xFF2CB67D)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 12))]),
                    )),
                    const SizedBox(height: 16),
                    Text('Expected Technical Questions:', style: TextStyle(fontWeight: FontWeight.bold, color: MailMindTheme.accent)),
                    const SizedBox(height: 4),
                    ...questions.map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(q, style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500)),
                    )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final apps = state.emails
        .where((e) => e['category'] == 'Opportunities' || e['category'] == 'Interviews' || e['category'] == 'Acceptance' || e['category'] == 'Rejection')
        .toList();

    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, color: MailMindTheme.textMuted, size: 48),
            const SizedBox(height: 12),
            Text('No active applications tracked in workspace.', style: TextStyle(color: MailMindTheme.textMuted)),
          ],
        ),
      );
    }

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
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05)))),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, idx) {
                final a = apps[idx];
                final isSelected = _selectedAppIdx == idx;
                final date = DateTime.parse(a['received_at']);
                final comp = a['sender'].split('@').first.toUpperCase();
                
                return Card(
                  color: isSelected ? MailMindTheme.accent.withOpacity(0.12) : const Color(0xFF16161A),
                  child: ListTile(
                    title: Text(comp, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(a['subject'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(DateFormat('MMM dd').format(date), style: TextStyle(fontSize: 11, color: MailMindTheme.textMuted)),
                    onTap: () => setState(() => _selectedAppIdx = idx),
                  ),
                );
              },
            ),
          ),
        ),

        // Right Column: Details & AI Prep
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
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
                        Text('$company: $role', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Current Status: $status', style: TextStyle(color: MailMindTheme.accent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      onPressed: () => _showInterviewCoach(company, role),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('AI Interview Prep Coach'),
                    ),
                  ],
                ),
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
              color: isCompleted ? const Color(0xFF2CB67D) : MailMindTheme.textMuted,
              size: 20,
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? const Color(0xFF2CB67D) : MailMindTheme.textMuted.withOpacity(0.3),
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
                style: TextStyle(color: MailMindTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

