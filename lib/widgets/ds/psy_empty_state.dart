/// Structured empty state for clinician surfaces.
///
/// Replaces the ad-hoc "icon + 'No patients yet' + maybe a button"
/// patterns that previously sprawled across every list/form. A
/// clinician opening an empty roster screen should see three things
/// at a glance:
///   - **What** the screen is for (the title).
///   - **Why** it's empty right now (the body, one sentence).
///   - **What to do next** (the action button — optional).
///
/// Honest empty states feel like a clinical platform; "—" or a
/// blank canvas feels like a broken build.
///
/// Usage:
/// ```dart
/// PsyEmptyState(
///   icon: Icons.assignment_outlined,
///   title: 'No assessments yet',
///   body: 'Send a PHQ-9 from any chart to see the outcome trend here.',
///   action: PsyEmptyStateAction(
///     label: 'Send PHQ-9',
///     icon: Icons.psychology_outlined,
///     onTap: () => Navigator.of(context).pushNamed('/assessments/phq9'),
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// CTA configuration for [PsyEmptyState]. Pulled out so the
/// PsyEmptyState constructor stays readable and so tests can
/// assert against `action == null` distinctly from `action.onTap`.
class PsyEmptyStateAction {
  const PsyEmptyStateAction({
    required this.label,
    required this.onTap,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
}

class PsyEmptyState extends StatelessWidget {
  const PsyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final PsyEmptyStateAction? action;

  /// Tighter vertical rhythm for empty states that sit inside an
  /// already-padded card. Default (false) gives the airier layout
  /// used for full-section empty states (e.g. "no patients yet").
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final vSpace = compact ? PsySpacing.lg : PsySpacing.xxl;

    return Semantics(
      container: true,
      // `explicitChildNodes: true` keeps the action button as its own
      // semantic node so TalkBack/VoiceOver name it correctly instead
      // of merging it into the parent description.
      explicitChildNodes: true,
      label: title,
      hint: body,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vSpace),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 28, color: cs.primary),
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: PsySpacing.xs),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: PsySpacing.lg),
                  if (action!.icon != null)
                    FilledButton.icon(
                      onPressed: action!.onTap,
                      icon: Icon(action!.icon, size: 18),
                      label: Text(
                        action!.label,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: PsySpacing.xl,
                        ),
                      ),
                    )
                  else
                    FilledButton(
                      onPressed: action!.onTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: PsySpacing.xl,
                        ),
                      ),
                      child: Text(
                        action!.label,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
