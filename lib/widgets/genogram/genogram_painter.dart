/// CustomPainter that draws a McGoldrick / Gerson-standard
/// genogram from a [GenogramLayout]. Renders:
///
///   - Squares for male, circles for female, diamonds for non-
///     binary, dotted outlines for unknown sex.
///   - Doubled outline on the index patient.
///   - X through deceased nodes (deathYear set).
///   - Solid parent-child lines, parallel marriage lines, double
///     diagonals for divorce, single diagonal for separation,
///     dashed lines for adoption / estrangement, zigzag for
///     conflict, thick coloured line for close emotional bond.
library;

import 'package:flutter/material.dart';

import '../../models/genogram.dart';
import 'genogram_layout.dart';

class GenogramPainter extends CustomPainter {
  GenogramPainter({
    required this.layout,
    required this.theme,
    this.nodeWidth = 96,
    this.nodeHeight = 64,
  });

  final GenogramLayout layout;
  final ThemeData theme;
  final double nodeWidth;
  final double nodeHeight;

  @override
  void paint(Canvas canvas, Size size) {
    _paintEdges(canvas);
    for (final n in layout.nodes) {
      _paintNode(canvas, n);
    }
  }

  void _paintEdges(Canvas canvas) {
    for (final r in layout.relationships) {
      final from = layout.nodeFor(r.fromPersonId);
      final to = layout.nodeFor(r.toPersonId);
      if (from == null || to == null) continue;
      final start = Offset(from.x, from.y);
      final end = Offset(to.x, to.y);
      switch (r.kind) {
        case GenogramRelationshipKind.parentChild:
          _drawSolid(canvas, start, end, theme.colorScheme.outline);
        case GenogramRelationshipKind.sibling:
          _drawSolid(canvas, start, end, theme.colorScheme.outlineVariant);
        case GenogramRelationshipKind.marriage:
          _drawDouble(canvas, start, end, theme.colorScheme.outline);
        case GenogramRelationshipKind.partnership:
          _drawSolid(canvas, start, end, theme.colorScheme.outline);
        case GenogramRelationshipKind.divorce:
          _drawDouble(canvas, start, end, theme.colorScheme.outline);
          _drawSlash(canvas, start, end, theme.colorScheme.outline);
          _drawSlash(canvas, start, end, theme.colorScheme.outline, offset: 8);
        case GenogramRelationshipKind.separation:
          _drawDouble(canvas, start, end, theme.colorScheme.outline);
          _drawSlash(canvas, start, end, theme.colorScheme.outline);
        case GenogramRelationshipKind.adoption:
          _drawDashed(canvas, start, end, theme.colorScheme.outline);
        case GenogramRelationshipKind.closeFriend:
          _drawSolid(canvas, start, end, theme.colorScheme.primary, width: 3);
        case GenogramRelationshipKind.estrangement:
          _drawDashed(canvas, start, end, theme.colorScheme.error);
        case GenogramRelationshipKind.conflict:
          _drawZigzag(canvas, start, end, theme.colorScheme.error);
      }
    }
  }

  void _paintNode(Canvas canvas, GenogramNodeLayout node) {
    final rect = Rect.fromCenter(
      center: Offset(node.x, node.y),
      width: nodeWidth,
      height: nodeHeight,
    );

    final fill = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = theme.colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (node.person.sex) {
      case GenogramSex.male:
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, stroke);
      case GenogramSex.female:
        final radius = nodeHeight / 2;
        canvas.drawCircle(rect.center, radius, fill);
        canvas.drawCircle(rect.center, radius, stroke);
      case GenogramSex.nonBinary:
        final path = _diamondPath(rect);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      case GenogramSex.unknown:
        canvas.drawRect(rect, fill);
        canvas.drawRect(
          rect,
          stroke
            ..strokeWidth = 1
            ..color = theme.colorScheme.outlineVariant,
        );
    }

    if (node.person.isIndexPatient) {
      final inset = rect.deflate(4);
      final indexPaint = Paint()
        ..color = theme.colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      switch (node.person.sex) {
        case GenogramSex.female:
          canvas.drawCircle(inset.center, inset.height / 2, indexPaint);
        case GenogramSex.nonBinary:
          canvas.drawPath(_diamondPath(inset), indexPaint);
        case GenogramSex.male:
        case GenogramSex.unknown:
          canvas.drawRect(inset, indexPaint);
      }
    }

    if (node.person.isDeceased) {
      final p = Paint()
        ..color = theme.colorScheme.onSurface
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(rect.topLeft, rect.bottomRight, p);
      canvas.drawLine(rect.topRight, rect.bottomLeft, p);
    }

    final years = _yearsLabel(node.person);
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: node.person.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (years.isNotEmpty)
            TextSpan(
              text: '\n$years',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: nodeWidth - 8);
    textPainter.paint(
      canvas,
      Offset(node.x - textPainter.width / 2, node.y - textPainter.height / 2),
    );
  }

  String _yearsLabel(GenogramPerson p) {
    final by = p.birthYear, dy = p.deathYear;
    if (by == null && dy == null) return '';
    if (by != null && dy != null) return '$by – $dy';
    if (by != null) return 'b. $by';
    return 'd. $dy';
  }

  Path _diamondPath(Rect rect) {
    return Path()
      ..moveTo(rect.center.dx, rect.top)
      ..lineTo(rect.right, rect.center.dy)
      ..lineTo(rect.center.dx, rect.bottom)
      ..lineTo(rect.left, rect.center.dy)
      ..close();
  }

  void _drawSolid(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color, {
    double width = 1.5,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawLine(a, b, paint);
  }

  void _drawDouble(Canvas canvas, Offset a, Offset b, Color color) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len2 = dx * dx + dy * dy;
    if (len2 == 0) return;
    final len = len2 / dx.abs().clamp(1.0, double.infinity);
    final norm = Offset(-dy, dx) / len;
    final off = norm * 2;
    _drawSolid(canvas, a + off, b + off, color);
    _drawSolid(canvas, a - off, b - off, color);
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b, Color color) {
    const dash = 6.0;
    const gap = 4.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var t = 0.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    while (t < total) {
      final end = (t + dash).clamp(0.0, total);
      canvas.drawLine(a + dir * t, a + dir * end, paint);
      t = end + gap;
    }
  }

  void _drawZigzag(Canvas canvas, Offset a, Offset b, Color color) {
    final dir = b - a;
    final len = dir.distance;
    if (len == 0) return;
    final unit = dir / len;
    final norm = Offset(-unit.dy, unit.dx);
    final path = Path()..moveTo(a.dx, a.dy);
    const segs = 8;
    for (var i = 1; i <= segs; i++) {
      final t = i / segs;
      final base = a + unit * (len * t);
      final wave = i.isEven ? -4.0 : 4.0;
      path.lineTo(base.dx + norm.dx * wave, base.dy + norm.dy * wave);
    }
    path.lineTo(b.dx, b.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawSlash(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color, {
    double offset = 0,
  }) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = (dx * dx + dy * dy);
    if (len == 0) return;
    final norm = Offset(-dy, dx) / len * 10;
    final from = Offset(mid.dx + offset - norm.dx, mid.dy - norm.dy);
    final to = Offset(mid.dx + offset + norm.dx, mid.dy + norm.dy);
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant GenogramPainter old) =>
      old.layout != layout || old.theme.colorScheme != theme.colorScheme;
}
