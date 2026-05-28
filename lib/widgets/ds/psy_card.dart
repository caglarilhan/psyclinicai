import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Design-system card. Wraps surface + border + padding + optional hover/
/// tap behaviour. Consistent radius (PsyRadius.lg = 16) across the app.
class PsyCard extends StatefulWidget {
  const PsyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PsySpacing.xl),
    this.onTap,
    this.elevated = false,
    this.tinted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;
  final bool tinted;

  @override
  State<PsyCard> createState() => _PsyCardState();
}

class _PsyCardState extends State<PsyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.tinted
        ? cs.primary.withValues(alpha: 0.05)
        : cs.surface;
    final canHover = widget.onTap != null;
    final lifted = canHover && _hover;

    final card = AnimatedContainer(
      duration: PsyMotion.fast,
      curve: PsyMotion.standard,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, lifted ? -1.0 : 0.0, 0.0, 1.0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(
          color: lifted
              ? cs.primary.withValues(alpha: 0.45)
              : cs.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: widget.elevated || lifted
            ? [
                BoxShadow(
                  color: cs.primary
                      .withValues(alpha: lifted ? 0.10 : 0.06),
                  blurRadius: lifted ? 14 : 10,
                  offset: Offset(0, lifted ? 6 : 4),
                ),
              ]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: canHover ? (_) => setState(() => _hover = true) : null,
      onExit: canHover ? (_) => setState(() => _hover = false) : null,
      child: card,
    );
  }
}
