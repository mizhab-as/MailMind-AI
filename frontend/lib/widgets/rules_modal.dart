import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';

class RulesModal extends StatefulWidget {
  const RulesModal({super.key});

  @override
  State<RulesModal> createState() => _RulesModalState();
}

class _RulesModalState extends State<RulesModal> {
  List<dynamic> _rules = [];
  bool _isLoading = true;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();
  final TextEditingController _actionValueCtrl = TextEditingController();

  String _field = 'subject';
  String _operator = 'contains';
  String _action = 'set_category';

  @override
  void initState() {
    super.initState();
    _fetchRules();
  }

  Future<void> _fetchRules() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('http://127.0.0.1:8000/rules'));
      if (res.statusCode == 200) {
        setState(() {
          _rules = jsonDecode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createRule() async {
    if (_nameCtrl.text.isEmpty || _valueCtrl.text.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse('http://127.0.0.1:8000/rules'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rule_name': _nameCtrl.text.trim(),
          'condition_field': _field,
          'condition_operator': _operator,
          'condition_value': _valueCtrl.text.trim(),
          'action_type': _action,
          'action_value': _actionValueCtrl.text.trim().isEmpty ? 'Opportunities' : _actionValueCtrl.text.trim(),
        }),
      );
      if (res.statusCode == 200) {
        _nameCtrl.clear();
        _valueCtrl.clear();
        _actionValueCtrl.clear();
        _fetchRules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rule Created Successfully!')),
          );
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _deleteRule(int ruleId) async {
    await http.delete(Uri.parse('http://127.0.0.1:8000/rules/$ruleId'));
    _fetchRules();
  }

  Future<void> _executeRulesNow() async {
    final res = await http.post(Uri.parse('http://127.0.0.1:8000/rules/execute'));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rules Executed! ${body['applied_actions']} actions applied.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 750,
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
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: MailMindTheme.accent, size: 24),
                      const SizedBox(width: 10),
                      Text('Email Automation Rules Builder', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Create Rule Form Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MailMindTheme.accent.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MailMindTheme.accent.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create New Automation Rule', style: TextStyle(fontWeight: FontWeight.bold, color: MailMindTheme.textMain)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      style: TextStyle(color: MailMindTheme.textMain, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Rule Name', hintText: 'e.g. Auto-Tag Google Emails'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _field,
                            decoration: const InputDecoration(labelText: 'IF Field'),
                            dropdownColor: MailMindTheme.cardBg,
                            items: const [
                              DropdownMenuItem(value: 'subject', child: Text('Subject')),
                              DropdownMenuItem(value: 'sender', child: Text('Sender')),
                              DropdownMenuItem(value: 'body', child: Text('Body')),
                            ],
                            onChanged: (v) => setState(() => _field = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _operator,
                            decoration: const InputDecoration(labelText: 'Operator'),
                            dropdownColor: MailMindTheme.cardBg,
                            items: const [
                              DropdownMenuItem(value: 'contains', child: Text('Contains')),
                              DropdownMenuItem(value: 'equals', child: Text('Equals')),
                            ],
                            onChanged: (v) => setState(() => _operator = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _valueCtrl,
                            style: TextStyle(color: MailMindTheme.textMain, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Value', hintText: 'e.g. google.com'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _action,
                            decoration: const InputDecoration(labelText: 'THEN Action'),
                            dropdownColor: MailMindTheme.cardBg,
                            items: const [
                              DropdownMenuItem(value: 'set_category', child: Text('Set Category')),
                              DropdownMenuItem(value: 'flag_urgent', child: Text('Set Priority')),
                            ],
                            onChanged: (v) => setState(() => _action = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _actionValueCtrl,
                            style: TextStyle(color: MailMindTheme.textMain, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Action Parameter', hintText: 'e.g. Opportunities'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MailMindTheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onPressed: _createRule,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Rule'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Automation Rules', style: Theme.of(context).textTheme.titleMedium),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2CB67D), foregroundColor: Colors.white),
                    onPressed: _executeRulesNow,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Run Rules Engine Now'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: MailMindTheme.accent))
                  : _rules.isEmpty
                      ? Center(child: Text('No active rules', style: TextStyle(color: MailMindTheme.textMuted)))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _rules.length,
                          itemBuilder: (context, idx) {
                            final r = _rules[idx];
                            return Card(
                              color: MailMindTheme.cardBg,
                              child: ListTile(
                                leading: Icon(Icons.rule, color: MailMindTheme.accent),
                                title: Text(r['rule_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(
                                  'IF ${r['condition_field']} ${r['condition_operator']} "${r['condition_value']}" THEN ${r['action_type']} -> ${r['action_value']}',
                                  style: TextStyle(color: MailMindTheme.textMuted, fontSize: 11),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () => _deleteRule(r['id']),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
