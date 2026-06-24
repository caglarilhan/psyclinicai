/// Source of truth for the entries the global Cmd+K / Ctrl+K
/// command palette surfaces. Mirrors the rail navigation + adds
/// frequent destinations buried two or three taps deep.
///
/// Entries are pure data — keep the file dependency-free so any
/// route can ship a "this command opens here" registration without
/// pulling in the rest of the app.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'command_palette.dart';
import 'keyboard_shortcuts_sheet.dart';

List<CommandPaletteEntry> buildAppCommands(BuildContext context) {
  void go(String route) {
    unawaited(Navigator.of(context).pushReplacementNamed(route));
  }

  return [
    CommandPaletteEntry(
      label: 'Dashboard',
      section: 'Navigation',
      icon: Icons.dashboard_outlined,
      subtitle: 'Greeting, KPIs, quick actions',
      onSelect: () => go('/dashboard'),
    ),
    CommandPaletteEntry(
      label: 'Patients',
      section: 'Navigation',
      icon: Icons.group_outlined,
      subtitle: 'Roster, search, charts',
      onSelect: () => go('/patients'),
    ),
    CommandPaletteEntry(
      label: 'Calendar',
      section: 'Navigation',
      icon: Icons.event_outlined,
      subtitle: 'Today + upcoming sessions',
      onSelect: () => go('/appointments'),
    ),
    CommandPaletteEntry(
      label: 'New session',
      section: 'Sessions',
      icon: Icons.graphic_eq,
      subtitle: 'Open the live AI co-pilot panel',
      shortcut: 'S',
      onSelect: () => go('/session'),
    ),
    CommandPaletteEntry(
      label: 'AI assistant',
      section: 'Copilot',
      icon: Icons.smart_toy_outlined,
      subtitle: 'Chat with the clinician copilot',
      onSelect: () => go('/ai_chatbot'),
    ),
    CommandPaletteEntry(
      label: 'AI diagnosis',
      section: 'Copilot',
      icon: Icons.biotech_outlined,
      subtitle: 'Decision-support differential drafter',
      onSelect: () => go('/ai_diagnosis'),
    ),
    CommandPaletteEntry(
      label: 'Mood tracking',
      section: 'Measurement',
      icon: Icons.mood_outlined,
      subtitle: 'Patient mood + symptom logs',
      onSelect: () => go('/mood_tracking'),
    ),
    CommandPaletteEntry(
      label: 'Outcomes',
      section: 'Measurement',
      icon: Icons.insights_outlined,
      subtitle: 'PHQ-9 / GAD-7 trends across caseload',
      onSelect: () => go('/outcomes'),
    ),
    CommandPaletteEntry(
      label: 'Superbill',
      section: 'Billing',
      icon: Icons.receipt_long_outlined,
      subtitle: 'CPT + ICD-10 reimbursement bill',
      onSelect: () => go('/superbill'),
    ),
    CommandPaletteEntry(
      label: 'Settings',
      section: 'Account',
      icon: Icons.settings_outlined,
      subtitle: 'Profile, API keys, audit log, data export',
      onSelect: () => go('/settings'),
    ),
    CommandPaletteEntry(
      label: 'Audit log',
      section: 'Account',
      icon: Icons.fact_check_outlined,
      subtitle: 'Tamper-evident PHI access history',
      onSelect: () => go('/settings/audit'),
    ),
    CommandPaletteEntry(
      label: 'Risk coverage',
      section: 'Admin',
      icon: Icons.shield_outlined,
      subtitle: 'Leadership view: were risk signals acted on?',
      onSelect: () => go('/admin/risk_coverage'),
    ),
    CommandPaletteEntry(
      label: 'API keys',
      section: 'Account',
      icon: Icons.key_outlined,
      subtitle: 'BYOK Claude key + provider rotation',
      onSelect: () => go('/settings/api_keys'),
    ),
    CommandPaletteEntry(
      label: 'Data export',
      section: 'Account',
      icon: Icons.download_outlined,
      subtitle: 'DSAR export of your tenant data',
      onSelect: () => go('/settings/export'),
    ),
    CommandPaletteEntry(
      label: 'Changelog',
      section: 'Help',
      icon: Icons.history_outlined,
      subtitle: 'What we have shipped, newest first',
      onSelect: () => go('/changelog'),
    ),
    CommandPaletteEntry(
      label: 'Security',
      section: 'Help',
      icon: Icons.lock_outline,
      subtitle: 'Our security + compliance posture',
      onSelect: () => go('/security'),
    ),
    CommandPaletteEntry(
      label: 'Keyboard shortcuts',
      section: 'Help',
      icon: Icons.keyboard_outlined,
      subtitle: 'List every global shortcut (also: press ?)',
      onSelect: () => unawaited(showKeyboardShortcuts(context)),
    ),
  ];
}
