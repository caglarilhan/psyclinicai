import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Apple-Pencil / finger signature surface — closes the apple-hig-
/// expert + healthcare-reviewer note in rapor 12 (clinician sign-off
/// needs a real pad on iPad).
class SignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];

  List<List<Offset>> get strokes => List.unmodifiable(_strokes);
  bool get isEmpty => _strokes.isEmpty;
  bool get isNotEmpty => _strokes.isNotEmpty;

  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }

  void beginStroke(Offset start) {
    _strokes.add([start]);
    notifyListeners();
  }

  void appendPoint(Offset p) {
    if (_strokes.isEmpty) {
      _strokes.add([p]);
    } else {
      _strokes.last.add(p);
    }
    notifyListeners();
  }
}

class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 180,
    this.strokeColor,
    this.strokeWidth = 2.4,
  });

  final SignaturePadController controller;
  final double height;
  final Color? strokeColor;
  final double strokeWidth;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listen);
    super.dispose();
  }

  void _listen() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.strokeColor ?? cs.onSurface;
    return Stack(children: [
      Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(PsyRadius.md),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => widget.controller.beginStroke(d.localPosition),
          onPanUpdate: (d) =>
              widget.controller.appendPoint(d.localPosition),
          child: CustomPaint(
            painter: _SignaturePainter(
              strokes: widget.controller.strokes,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
            size: Size.infinite,
          ),
        ),
      ),
      Positioned(
        right: 4,
        bottom: 4,
        child: TextButton.icon(
          onPressed:
              widget.controller.isEmpty ? null : widget.controller.clear,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Clear'),
        ),
      ),
      if (widget.controller.isEmpty)
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Text(
                'Sign with Apple Pencil or your finger',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.length == 1) {
          canvas.drawCircle(stroke.first, strokeWidth / 2, paint);
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.strokes != strokes ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
