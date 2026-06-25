import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'inbox_screen.dart';
import 'tracker_screen.dart';
import 'calendar_screen.dart';
import 'assistant_screen.dart';
import 'analytics_screen.dart';
import 'security_screen.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _activeTabIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<Widget> _screens = const [
    DashboardScreen(),
    InboxScreen(),
    TrackerScreen(),
    CalendarScreen(),
    AssistantScreen(),
    AnalyticsScreen(),
    SecurityScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.mail_outline, 'activeIcon': Icons.mail, 'label': 'Inbox'},
    {'icon': Icons.timeline, 'activeIcon': Icons.timeline, 'label': 'Applications'},
    {'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today, 'label': 'Calendar'},
    {'icon': Icons.chat_bubble_outline, 'activeIcon': Icons.chat_bubble, 'label': 'AI Assistant'},
    {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Analytics'},
    {'icon': Icons.security_outlined, 'activeIcon': Icons.security, 'label': 'Security'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Panel
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _isSidebarCollapsed ? 76 : 240,
              color: const Color(0xFF16161A),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // App Title / Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, color: MailMindTheme.accent, size: 32),
                      if (!_isSidebarCollapsed) ...[
                        const SizedBox(width: 12),
                        Text(
                          'MailMind AI',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            letterSpacing: 0.5,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Navigation Actions List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      itemBuilder: (context, idx) {
                        final item = _navItems[idx];
                        final isActive = _activeTabIndex == idx;
                        return ListTile(
                          leading: Icon(
                            isActive ? item['activeIcon'] : item['icon'],
                            color: isActive ? MailMindTheme.accent : MailMindTheme.textMuted,
                          ),
                          title: _isSidebarCollapsed ? null : Text(
                            item['label'],
                            style: TextStyle(
                              color: isActive ? Colors.white : MailMindTheme.textMuted,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () => setState(() => _activeTabIndex = idx),
                          selected: isActive,
                          selectedColor: MailMindTheme.accent.withOpacity(0.1),
                        );
                      },
                    ),
                  ),
                  // Sidebar Collapse Toggle Button
                  IconButton(
                    icon: Icon(
                      _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: MailMindTheme.textMuted,
                    ),
                    onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          
          // Main Body Work Area
          Expanded(
            child: Column(
              children: [
                // Top Header / Toolbar Action Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161A),
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Row(
                    children: [
                      if (isMobile) ...[
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            // Simple bottom drawer selector for navigation
                            _showNavigationSheet(context);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Workspace Selector Dropdown
                      Icon(Icons.workspaces_outline, color: MailMindTheme.textMuted),
                      const SizedBox(width: 8),
                      DropdownButton<int?>(
                        value: state.selectedAccountId,
                        dropdownColor: const Color(0xFF16161A),
                        underline: const SizedBox(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Unified AI Inbox'),
                          ),
                          ...state.accounts.map((acc) => DropdownMenuItem(
                            value: acc['id'] as int,
                            child: Text(acc['name'] as String),
                          )),
                        ],
                        onChanged: (val) => state.selectAccount(val),
                      ),
                      const Spacer(),
                      // Dynamic Theme Selector Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: MailMindTheme.textMain.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: MailMindTheme.textMain.withOpacity(0.08)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.selectedThemeName,
                            dropdownColor: MailMindTheme.cardBg,
                            icon: Icon(Icons.palette_outlined, size: 16, color: MailMindTheme.textMuted),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MailMindTheme.textMain),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                state.setTheme(newValue);
                              }
                            },
                            items: MailMindTheme.themes.map<DropdownMenuItem<String>>((AppTheme theme) {
                              return DropdownMenuItem<String>(
                                value: theme.name,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: theme.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      theme.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add Mock Email Sync Button
                      FilledButton.icon(
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync Emails'),
                        style: FilledButton.styleFrom(backgroundColor: MailMindTheme.accent),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Syncing email accounts...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          await state.triggerMockSync();
                        },
                      ),
                      const SizedBox(width: 12),
                      // Add Account Icon Button
                      IconButton(
                        icon: const Icon(Icons.add_link),
                        tooltip: 'Connect Account',
                        onPressed: () => _showAddAccountDialog(context, state),
                      ),
                      const SizedBox(width: 8),
                      // User Profile Avatar
                      CircleAvatar(
                        backgroundColor: MailMindTheme.accent.withOpacity(0.2),
                        child: Text(
                          state.username.isNotEmpty ? state.username[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                // Tab Content Rendering Screen
                Expanded(
                  child: _screens[_activeTabIndex],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showNavigationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161A),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _navItems.length,
          itemBuilder: (context, idx) {
            return ListTile(
              leading: Icon(_navItems[idx]['icon']),
              title: Text(_navItems[idx]['label']),
              onTap: () {
                setState(() => _activeTabIndex = idx);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showAddAccountDialog(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String provider = 'Gmail';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161A),
        title: const Text('Connect New Email Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Account Label (e.g. Work Mail)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: provider,
              dropdownColor: const Color(0xFF16161A),
              decoration: const InputDecoration(labelText: 'Mail Provider'),
              items: const [
                DropdownMenuItem(value: 'Gmail', child: Text('Gmail')),
                DropdownMenuItem(value: 'Outlook', child: Text('Outlook')),
                DropdownMenuItem(value: 'Microsoft 365', child: Text('Microsoft 365')),
              ],
              onChanged: (val) {
                if (val != null) provider = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MailMindTheme.accent),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                await state.addAccount(nameCtrl.text, provider, emailCtrl.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Connect'),
          )
        ],
      ),
    );
  }
}
