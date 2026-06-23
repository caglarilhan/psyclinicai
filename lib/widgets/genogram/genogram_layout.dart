/// Pure layout maths for the genogram canvas. Given a [Genogram]
/// (people + relationships, PR #14), produces a [GenogramLayout]
/// with each person placed at (x, y) coordinates in a finite
/// bounding box.
///
/// Algorithm: simple generation-based row assignment. Every person
/// gets a generation number — the index patient is gen 0, each
/// parent edge adds -1 to the parent (older generation), each
/// parent edge subtracts from the child. Siblings sit side by side
/// on the same row, sorted by birthYear when known.
///
/// Pure module — no Flutter dependencies. Renders entirely from
/// [GenogramLayout] in the canvas screen.
library;

import 'dart:math' as math;

import '../../models/genogram.dart';

class GenogramLayout {
  const GenogramLayout({
    required this.nodes,
    required this.relationships,
    required this.size,
  });

  /// One entry per [GenogramPerson] in the original document.
  final List<GenogramNodeLayout> nodes;

  /// Mirrors `Genogram.relationships` — kept here so the painter
  /// only needs the layout object.
  final List<GenogramRelationship> relationships;

  /// Outer bounding box (width × height).
  final ({double width, double height}) size;

  GenogramNodeLayout? nodeFor(String personId) {
    for (final n in nodes) {
      if (n.person.id == personId) return n;
    }
    return null;
  }
}

class GenogramNodeLayout {
  const GenogramNodeLayout({
    required this.person,
    required this.x,
    required this.y,
    required this.generation,
  });

  final GenogramPerson person;

  /// Centre of the node in canvas coordinates.
  final double x;
  final double y;

  /// 0 = index-patient row, negative = parents/grandparents,
  /// positive = children/grandchildren.
  final int generation;
}

class GenogramLayoutEngine {
  GenogramLayoutEngine({
    this.nodeWidth = 96,
    this.nodeHeight = 64,
    this.horizontalGap = 32,
    this.verticalGap = 80,
    this.padding = 32,
  });

  final double nodeWidth;
  final double nodeHeight;
  final double horizontalGap;
  final double verticalGap;
  final double padding;

  /// Compute the layout for [genogram].
  GenogramLayout compute(Genogram genogram) {
    if (genogram.people.isEmpty) {
      return GenogramLayout(
        nodes: const [],
        relationships: genogram.relationships,
        size: (width: 0, height: 0),
      );
    }

    final generations = _assignGenerations(genogram);
    final byGen = <int, List<GenogramPerson>>{};
    for (final p in genogram.people) {
      final gen = generations[p.id] ?? 0;
      byGen.putIfAbsent(gen, () => []).add(p);
    }
    // Sort each row by birthYear when known, otherwise by label,
    // so the layout is deterministic across renders.
    for (final row in byGen.values) {
      row.sort((a, b) {
        final ay = a.birthYear, by = b.birthYear;
        if (ay != null && by != null) return ay.compareTo(by);
        if (ay != null) return -1;
        if (by != null) return 1;
        return a.label.compareTo(b.label);
      });
    }

    final maxRowCount = byGen.values
        .map((r) => r.length)
        .fold<int>(0, math.max);
    final rowWidth =
        maxRowCount * nodeWidth + (maxRowCount - 1) * horizontalGap;

    final genKeys = byGen.keys.toList()..sort();
    final canvasWidth = rowWidth + padding * 2;
    final canvasHeight =
        genKeys.length * (nodeHeight + verticalGap) - verticalGap + padding * 2;

    final nodes = <GenogramNodeLayout>[];
    for (var gi = 0; gi < genKeys.length; gi++) {
      final gen = genKeys[gi];
      final row = byGen[gen]!;
      final rowActualWidth =
          row.length * nodeWidth + (row.length - 1) * horizontalGap;
      final rowOffset = (canvasWidth - rowActualWidth) / 2;
      final y = padding + gi * (nodeHeight + verticalGap) + nodeHeight / 2;
      for (var ri = 0; ri < row.length; ri++) {
        final x = rowOffset + ri * (nodeWidth + horizontalGap) + nodeWidth / 2;
        nodes.add(
          GenogramNodeLayout(person: row[ri], x: x, y: y, generation: gen),
        );
      }
    }

    return GenogramLayout(
      nodes: nodes,
      relationships: genogram.relationships,
      size: (width: canvasWidth, height: canvasHeight),
    );
  }

  /// Walks the relationship graph and assigns each person a
  /// generation number relative to the index patient (or, if none,
  /// the first person in the people list).
  Map<String, int> _assignGenerations(Genogram g) {
    final out = <String, int>{};
    final anchor = g.indexPatient ?? g.people.first;
    out[anchor.id] = 0;
    final queue = <String>[anchor.id];

    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      final gen = out[id]!;
      for (final r in g.relationships) {
        if (r.kind == GenogramRelationshipKind.parentChild) {
          // Canonical edge direction: parent → child.
          if (r.fromPersonId == id && !out.containsKey(r.toPersonId)) {
            out[r.toPersonId] = gen + 1;
            queue.add(r.toPersonId);
          } else if (r.toPersonId == id && !out.containsKey(r.fromPersonId)) {
            out[r.fromPersonId] = gen - 1;
            queue.add(r.fromPersonId);
          }
        } else if (r.kind == GenogramRelationshipKind.sibling ||
            r.kind == GenogramRelationshipKind.marriage ||
            r.kind == GenogramRelationshipKind.partnership ||
            r.kind == GenogramRelationshipKind.divorce ||
            r.kind == GenogramRelationshipKind.separation) {
          // Same-generation edges.
          final other = r.fromPersonId == id
              ? r.toPersonId
              : r.toPersonId == id
              ? r.fromPersonId
              : null;
          if (other != null && !out.containsKey(other)) {
            out[other] = gen;
            queue.add(other);
          }
        }
      }
    }

    // Anyone the walk missed lands on the index row by default.
    for (final p in g.people) {
      out.putIfAbsent(p.id, () => 0);
    }
    return out;
  }
}
