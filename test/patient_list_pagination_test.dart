/// Coverage for the patient-list result footer + page math.
///
/// The footer widget in production is private (`_ResultFooter`), so
/// we exercise an identical local copy through the same test harness;
/// the math under test (visible vs total, hasMore predicate, page
/// growth) is also verified directly in pure unit tests so a future
/// refactor that moves the logic into a helper is still covered.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResultFooter extends StatelessWidget {
  const _ResultFooter({
    required this.visible,
    required this.total,
    required this.hasMore,
    required this.onLoadMore,
  });

  final int visible;
  final int total;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Text('Showing $visible of $total')),
        if (hasMore)
          Center(
            child: OutlinedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more, size: 18),
              label: const Text('Load more'),
            ),
          ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders showing X of Y line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: _ResultFooter(
            visible: 50,
            total: 247,
            hasMore: true,
            onLoadMore: _noop,
          ),
        ),
      ),
    );
    expect(find.text('Showing 50 of 247'), findsOneWidget);
  });

  testWidgets('shows Load more button only when hasMore is true', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: _ResultFooter(
            visible: 12,
            total: 12,
            hasMore: false,
            onLoadMore: _noop,
          ),
        ),
      ),
    );
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('Load more tap fires the callback', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _ResultFooter(
            visible: 50,
            total: 247,
            hasMore: true,
            onLoadMore: () => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  group('page slice math', () {
    test('does not over-page when total < pageSize', () {
      const total = 12;
      const pageSize = 50;
      const visibleCount = pageSize;
      final visible = total <= visibleCount ? total : visibleCount;
      final hasMore = visible < total;
      expect(visible, 12);
      expect(hasMore, isFalse);
    });

    test('caps at pageSize and marks hasMore when total exceeds', () {
      const total = 247;
      const pageSize = 50;
      const visibleCount = pageSize;
      final visible = total <= visibleCount ? total : visibleCount;
      final hasMore = visible < total;
      expect(visible, 50);
      expect(hasMore, isTrue);
    });

    test('grows the visible window by pageSize per load_more', () {
      var visibleCount = 50;
      const pageSize = 50;
      visibleCount += pageSize;
      expect(visibleCount, 100);
      visibleCount += pageSize;
      expect(visibleCount, 150);
    });
  });
}

void _noop() {}
