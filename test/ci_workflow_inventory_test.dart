import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/ci_workflow_inventory.dart';

void main() {
  group('CiWorkflowInventory — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(CiWorkflowInventory.workflows, isNotEmpty);
    });

    test('every filename is unique', () {
      final names = CiWorkflowInventory.workflows
          .map((w) => w.filename)
          .toList();
      expect(names.toSet().length, names.length);
    });

    test('byFilename resolves every entry', () {
      for (final w in CiWorkflowInventory.workflows) {
        expect(CiWorkflowInventory.byFilename(w.filename), same(w));
      }
      expect(CiWorkflowInventory.byFilename('does-not-exist'), isNull);
    });

    test('every workflow has populated fields', () {
      for (final w in CiWorkflowInventory.workflows) {
        expect(w.displayName, isNotEmpty, reason: w.filename);
        expect(w.triggers, isNotEmpty, reason: w.filename);
        expect(w.owner, isNotEmpty, reason: w.filename);
        expect(w.purpose, isNotEmpty, reason: w.filename);
      }
    });

    test('every filename ends with .yml', () {
      for (final w in CiWorkflowInventory.workflows) {
        expect(w.filename, endsWith('.yml'), reason: w.filename);
      }
    });

    test('every filename uses snake_case (no spaces, no upper-case)', () {
      final snake = RegExp(r'^[a-z][a-z0-9_]*\.yml$');
      for (final w in CiWorkflowInventory.workflows) {
        expect(
          snake.hasMatch(w.filename),
          isTrue,
          reason: '${w.filename}: filename must be snake_case + .yml',
        );
      }
    });

    test('at least one workflow is required for merge', () {
      final req = CiWorkflowInventory.requiredForMerge();
      expect(
        req,
        isNotEmpty,
        reason:
            'at least one workflow MUST block merge — otherwise no CI '
            'gate exists',
      );
    });

    test('the primary CI + CodeQL workflows are both required for merge', () {
      final ci = CiWorkflowInventory.byFilename('ci.yml')!;
      final codeql = CiWorkflowInventory.byFilename('codeql.yml')!;
      expect(ci.isRequiredForMerge, isTrue);
      expect(codeql.isRequiredForMerge, isTrue);
    });

    test('deploy workflows declare their required secrets', () {
      final deploy = CiWorkflowInventory.byFilename('deploy_web.yml')!;
      expect(deploy.requiredSecrets, isNotEmpty);
      expect(deploy.requiredSecrets, contains('SSH_KEY'));
    });

    test('lighthouse is intentionally non-blocking (perf flake)', () {
      final lighthouse = CiWorkflowInventory.byFilename('lighthouse.yml')!;
      expect(
        lighthouse.isRequiredForMerge,
        isFalse,
        reason:
            'lighthouse is informational by design; a flaky perf score '
            'must not block a copy-only PR',
      );
    });

    test('owner roles span beyond a single owner (no bus factor 1)', () {
      final owners = CiWorkflowInventory.workflows.map((w) => w.owner).toSet();
      expect(
        owners.length,
        greaterThanOrEqualTo(2),
        reason: 'spread across CTO / CISO at minimum',
      );
    });
  });

  group('.github/workflows parity', () {
    test('every pinned workflow file actually exists on disk', () {
      for (final w in CiWorkflowInventory.workflows) {
        final path = '${CiWorkflowInventory.workflowsDir}/${w.filename}';
        expect(
          File(path).existsSync(),
          isTrue,
          reason:
              '$path is pinned in the inventory but the file is missing '
              '— either restore the file or remove the pinned row',
        );
      }
    });

    test('every workflow file on disk is pinned in the inventory', () {
      final dir = Directory(CiWorkflowInventory.workflowsDir);
      expect(dir.existsSync(), isTrue);
      final pinnedNames = CiWorkflowInventory.workflows
          .map((w) => w.filename)
          .toSet();
      for (final f in dir.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (!name.endsWith('.yml') && !name.endsWith('.yaml')) continue;
        expect(
          pinnedNames,
          contains(name),
          reason:
              '$name exists on disk but is not pinned in '
              'CiWorkflowInventory.workflows — add a row or delete '
              'the file',
        );
      }
    });

    test('every workflow file declares the pinned display name in its `name:` '
        'header', () async {
      for (final w in CiWorkflowInventory.workflows) {
        final path = '${CiWorkflowInventory.workflowsDir}/${w.filename}';
        final content = await File(path).readAsString();
        // Match `name: <displayName>` allowing optional quoting + ws.
        final pat = RegExp(
          '^\\s*name:\\s*[\\\'"]?'
          '${RegExp.escape(w.displayName)}'
          '[\\\'"]?\\s*\$',
          multiLine: true,
        );
        expect(
          pat.hasMatch(content),
          isTrue,
          reason:
              '${w.filename}: pinned displayName "${w.displayName}" does '
              'not appear in the file\'s `name:` header',
        );
      }
    });
  });

  group('runsOnEveryPr helper', () {
    test('returns true for workflows that include pullRequest', () {
      final ci = CiWorkflowInventory.byFilename('ci.yml')!;
      expect(runsOnEveryPr(ci), isTrue);
    });

    test('returns false for push-only workflows', () {
      final pages = CiWorkflowInventory.byFilename('pages.yml')!;
      expect(runsOnEveryPr(pages), isFalse);
    });

    test('returns false for manual-only workflows', () {
      final deploy = CiWorkflowInventory.byFilename('deploy_web.yml')!;
      expect(runsOnEveryPr(deploy), isFalse);
    });
  });
}
