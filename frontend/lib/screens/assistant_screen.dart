import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<String> _quickQueries = [
    'What are my deadlines this week?',
    'Show all interview invitations',
    'How many internships did I apply for?',
    'Summarize my opportunities this month',
  ];

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Scroll to bottom after message list updates
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Quick suggestions row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickQueries.map((q) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(q, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: MailMindTheme.cardBg,
                  onPressed: () => state.askAssistant(q),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Messages View Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: MailMindTheme.glassBox(),
              child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: state.chatMessages.length,
                itemBuilder: (context, idx) {
                  final msg = state.chatMessages[idx];
                  final isUser = msg['sender'] == 'user';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            backgroundColor: MailMindTheme.accent.withOpacity(0.2),
                            radius: 16,
                            child: const Icon(Icons.psychology, color: MailMindTheme.accent, size: 16),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser ? MailMindTheme.accent : const Color(0xFF16161A),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            child: Text(
                              msg['text']!,
                              style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            radius: 16,
                            child: const Icon(Icons.person, color: Colors.white70, size: 16),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Loading response loader
          if (state.isSendingMessage)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: MailMindTheme.accent),
              ),
            ),

          const SizedBox(height: 16),

          // Chat input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ask MailMind assistant...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF16161A),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      state.askAssistant(val);
                      _msgCtrl.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.send, color: MailMindTheme.accent),
                onPressed: () {
                  if (_msgCtrl.text.trim().isNotEmpty) {
                    state.askAssistant(_msgCtrl.text);
                    _msgCtrl.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
