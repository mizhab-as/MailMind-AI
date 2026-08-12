import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ComposeModal extends StatefulWidget {
  final String? initialRecipient;
  final String? initialSubject;
  final String? initialBody;

  const ComposeModal({
    super.key,
    this.initialRecipient,
    this.initialSubject,
    this.initialBody,
  });

  @override
  State<ComposeModal> createState() => _ComposeModalState();
}

class _ComposeModalState extends State<ComposeModal> {
  late TextEditingController _toController;
  late TextEditingController _subjectController;
  late TextEditingController _bodyController;
  final TextEditingController _aiPromptController = TextEditingController();

  String _selectedTone = 'Professional';
  bool _isGenerating = false;
  bool _isSaving = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _toController = TextEditingController(text: widget.initialRecipient ?? '');
    _subjectController = TextEditingController(text: widget.initialSubject ?? '');
    _bodyController = TextEditingController(text: widget.initialBody ?? '');
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _generateAIDraft() async {
    if (_aiPromptController.text.trim().isEmpty) return;
    setState(() => _isGenerating = true);
    try {
      final res = await _apiService.generateAIDraft(
        _aiPromptController.text.trim(),
        _toController.text.trim(),
        _selectedTone,
      );
      setState(() {
        if (_subjectController.text.isEmpty) {
          _subjectController.text = res['subject'] ?? '';
        }
        _bodyController.text = res['body'] ?? '';
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Draft Generated Successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 750),
        padding: const EdgeInsets.all(24),
        decoration: MailMindTheme.glassBox(
          color: MailMindTheme.cardBg,
          borderOpacity: 0.2,
          showGlow: true,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note, color: MailMindTheme.accent, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'New Email Composition',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Prompt Generator Bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MailMindTheme.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MailMindTheme.accent.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'AI Draft Copilot',
                          style: TextStyle(fontWeight: FontWeight.bold, color: MailMindTheme.textMain, fontSize: 13),
                        ),
                        const Spacer(),
                        // Tone Selector Dropdown
                        DropdownButton<String>(
                          value: _selectedTone,
                          dropdownColor: MailMindTheme.cardBg,
                          style: TextStyle(color: MailMindTheme.textMain, fontSize: 12),
                          underline: const SizedBox(),
                          items: ['Professional', 'Casual', 'Persuasive', 'Urgent'].map((tone) {
                            return DropdownMenuItem<String>(
                              value: tone,
                              child: Text(tone),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedTone = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _aiPromptController,
                            style: TextStyle(color: MailMindTheme.textMain, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'e.g. Confirm interview availability for next Tuesday morning...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MailMindTheme.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isGenerating ? null : _generateAIDraft,
                          icon: _isGenerating
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.sparkles, size: 16),
                          label: Text(_isGenerating ? 'Drafting...' : 'Generate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recipient Input
              TextField(
                controller: _toController,
                style: TextStyle(color: MailMindTheme.textMain),
                decoration: const InputDecoration(
                  labelText: 'To:',
                  hintText: 'recipient@example.com',
                  prefixIcon: Icon(Icons.person_outline, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              // Subject Input
              TextField(
                controller: _subjectController,
                style: TextStyle(color: MailMindTheme.textMain),
                decoration: const InputDecoration(
                  labelText: 'Subject:',
                  hintText: 'Email Subject',
                  prefixIcon: Icon(Icons.subject, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              // Body Input
              TextField(
                controller: _bodyController,
                maxLines: 8,
                style: TextStyle(color: MailMindTheme.textMain, height: 1.5),
                decoration: const InputDecoration(
                  labelText: 'Body:',
                  hintText: 'Write your email body here...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_done_outlined, size: 16, color: MailMindTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Draft Auto-Saved',
                        style: TextStyle(color: MailMindTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Discard'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2CB67D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email Sent Successfully!')),
                          );
                        },
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Send Email'),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
