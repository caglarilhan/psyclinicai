# PsyClinicAI — Design System & UI Guidelines

> Flutter (Material 3) clinical product for EU/US markets. This file is the single source of truth for UI work.
> When building or editing any screen, read this file first and follow it.
>
> **Runtime tokens (use these, in order):**
> 1. `Theme.of(context).colorScheme.*` — the live brand scheme. This is what you reach for 95% of the time.
> 2. `lib/theme/brand_colors.dart` (`PsyColors`) — raw brand hexes for charts/gradients/illustrations that need a color independent of theme.
> 3. `lib/theme/tokens.dart` (`PsySpacing`, `PsyRadius`, `PsyElevation`, `PsyMotion`, `PsyBreakpoints`) — spacing, radius, motion.
> 4. `lib/theme/psy_theme.dart` (`PsyTheme.light()/.dark()`) builds the `ThemeData` from the above.
>
> `lib/utils/theme.dart` (`AppColors`/`AppTheme`, the old purple palette) is **legacy** — do not use it in new code. Never hard-code hex values in a screen.
> Every authenticated screen wraps its body in `lib/widgets/app_shell.dart` (`AppShell`) — never a bare `Scaffold`.

---

## 0. The 4 problems this system fixes

Our current UI looks **empty and flat** next to competitors. This system exists to fix exactly four things:

1. **Density / richness** — pages feel bare. Fill them with *meaningful* content (stats, context, recent activity, guidance), not decoration.
2. **Cross-page continuity** — screens feel disconnected. Every screen sits in the **same shell** (sidebar + header + breadcrumb), so the user never loses context.
3. **Button prominence** — actions are invisible. Primary actions must be the **most obvious thing** on the screen.
4. **Eye comfort** — nothing should strain the eyes. Soft surfaces, generous spacing, calm contrast.

Every design decision below traces back to one of these.

---

## 1. Foundations

### Color (defined in `PsyColors`, surfaced via `colorScheme` — reference, don't redefine)
Brand = **deep teal** (calm + clinical) with an **indigo** accent. Resolve everything through `Theme.of(context).colorScheme.*`:

| Role | colorScheme token | Hex (light) | Use for |
|---|---|---|---|
| Primary (teal) | `primary` | `#0F766E` | Primary buttons, active nav, key accents |
| Primary tint | `primaryContainer` | `#CCFBF1` | Active nav background, tinted chips/icon wells |
| Accent (indigo) | `secondary` | `#4F46E5` | Secondary CTAs, AI highlights |
| Accent tint | `secondaryContainer` | `#E0E7FF` | Indigo chips/badges |
| Tertiary (pink) | `tertiary` | `#DB2777` | Sparing accents only |
| Success / Warning / Error | `*` via `PsyColors` | `#16A34A / #D97706 / #DC2626` | Status only |
| Surface (cards + page) | `surface` | `#FFFFFF` | Cards and base surface |
| Page tint | `surfaceContainerLow` | `#F8FAFC` | Subtle section/inset backgrounds |
| Outline | `outline` / `outlineVariant` | `#94A3B8 / #E2E8F0` | Borders, dividers, card outlines |
| Text | `onSurface` + `PsyColors.n600/n400` | `#0F172A / #475569 / #94A3B8` | Hierarchy |

Risk bands (PHQ-9/GAD-7 charts) live in `PsyColors.riskMinimal/Mild/Moderate/Severe`.

**Rule (eye comfort, web-native):** this is a flat, **bordered** system (Linear/Stripe/Vercel feel), not a soft-shadow one. Cards are `surface` (#FFFFFF) at elevation 0, separated by a 1px `outlineVariant` border — not by drop shadows. Body text is `onSurface` `#0F172A` (deep slate, never pure `#000`). For large inset regions use `surfaceContainerLow` to add a calm tint behind white cards.

### Spacing scale (4-pt base — `PsySpacing` in `lib/theme/tokens.dart`)
Use **only** these tokens. Consistent spacing is what makes a UI feel "designed":
```
xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 48 · huge 64 · gigantic 96
```
- Card inner padding: **24** (`PsySpacing.xl`)
- Gap between cards: **16** (`PsySpacing.lg`)
- Section vertical rhythm: **32** (`PsySpacing.xxl`)
- Page padding (handled by `AppShell`): horizontal `xl` (24), top `xxl` (32)

### Type scale (Material 3 `TextTheme`)
| Style | Size / Weight | Use |
|---|---|---|
| `displaySmall` | 32 / w700 | Page title (once per page) |
| `headlineSmall` | 24 / w600 | Section headers |
| `titleMedium` | 16 / w600 | Card titles |
| `bodyMedium` | 14 / w400 | Body, 1.5 line-height |
| `labelLarge` | 14 / w600 | Buttons |
| `bodySmall` | 12 / w400 | Captions, `textTertiary` |

**Rule:** one `displaySmall` per page. Hierarchy = size + weight + color, not color alone.

### Radius & elevation (`PsyRadius` / `PsyElevation`)
- Radius: cards/sheets **12** (`PsyRadius.lg`), buttons/inputs **8** (`PsyRadius.md`), chips **999** (`PsyRadius.full`, pill). Web-native — deliberately sharper than Material Android defaults.
- Elevation: **flat (0) by default.** Separation comes from `outlineVariant` borders, not drop shadows. Reserve real elevation for transient surfaces — menus/dialogs (`PsyElevation.modal`).

---

## 2. Page shell — cross-page continuity (problem #2)

**Every authenticated screen uses ONE shell.** Never build a bare `Scaffold` with just a body. Create/keep `lib/widgets/app_shell.dart`:

```
┌──────────────────────────────────────────────────────┐
│  NavigationRail        │  Header: Breadcrumb · Search · User │
│  (persistent, left)    ├──────────────────────────────┤
│  · Dashboard           │                              │
│  · Patients            │   Breadcrumb: Home / Patients / Ali │
│  · Sessions            │   ┌── Page title ────────────┐│
│  · AI Notes            │   │  [Primary CTA]           ││
│  · Reports             │   └──────────────────────────┘│
│  · Settings            │   <page content in cards>     │
└────────────────────────┴──────────────────────────────┘
```

Continuity rules:
- **Persistent left `NavigationRail`** (web/tablet) or `NavigationBar` (mobile <600px). Active item uses `primary`.
- **Header on every page**: breadcrumb (left) + search + user menu (right). Breadcrumb is what gives "where am I / how did I get here" context.
- **Max content width 1200px**, centered. Content never stretches edge-to-edge on wide screens (eye comfort + scannability).
- **Page transitions**: shared-axis / fade-through (`package:animations`), 200–250ms. Pages should *flow*, not cut.
- Same page-padding everywhere: horizontal `lg(24)`, top `xl(32)`.

---

## 3. Density & richness — fill pages meaningfully (problem #1)

A clinical screen should answer: *what's the state, what changed, what do I do next.* Empty space → replace with **context**, not filler.

**Dashboard composition (top → bottom):**
1. **Greeting + date + primary CTA** ("New session")
2. **Stat row** — 4 metric cards (today's sessions, active patients, pending notes, alerts). Each: big number + label + tiny trend.
3. **Two-column**: left = "Upcoming sessions" list; right = "Recent AI notes" / activity feed.
4. **Secondary**: charts (weekly load), quick actions.

**Card anatomy (the building block):**
```
┌─ Card (surface, radius16, elevation2, padding24) ─┐
│  ●  Title (titleMedium)            [overflow ⋮]   │
│     Subtitle / context (bodySmall, textSecondary) │
│  ───────────────────────────────────────────────  │
│  Main content                                      │
│  [Secondary action]            [Primary action →] │
└────────────────────────────────────────────────────┘
```

Richness rules:
- **No naked text on a page** — wrap content in cards/sections with a header.
- Lists show **3 lines of info per row** (title, meta, status chip) — not single-line.
- Use **status chips** (pill, tinted bg of success/warning/error at ~12% opacity) to add scannable color.
- Add **leading icons/avatars** to list rows — competitors look "full" largely because of consistent iconography.

**Empty states are designed, not blank:** use `PsyEmptyState` (see §8) — icon well + title + body + optional primary action. Never show a blank area or a centered grey paragraph.

---

## 4. Buttons & CTAs — make actions obvious (problem #3)

Strict hierarchy. The primary action is the most prominent element after the page title.

| Level | Widget | Style | Use |
|---|---|---|---|
| **Primary** | `FilledButton` | `primary` bg, white text, w600, height **48**, radius 12 | The ONE main action per view |
| **Secondary** | `OutlinedButton` | `primary` border+text | Alternative actions |
| **Tertiary** | `TextButton` | `primary` text only | Low-priority / cancel |
| **Destructive** | `FilledButton` (error) | `error` bg | Delete, end session |

```dart
FilledButton.icon(
  onPressed: onCreate,
  icon: const Icon(Icons.add),
  label: const Text('New session'),
  // Colour, radius and weight come from PsyTheme.filledButtonTheme — just size it.
  style: FilledButton.styleFrom(
    minimumSize: const Size(0, 48),
    padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
  ),
);
```

Rules:
- **One primary button per screen region.** Two primaries compete = neither wins.
- Primary buttons get an **icon + label** — more visible, more scannable.
- Min touch target **48×48**. Min text-button hit area 44.
- Primary CTA sits **top-right of the page header** AND/OR bottom-right of its card — predictable placement = the user always finds it.
- Disabled ≠ hidden: dim to 38% opacity, keep visible.

---

## 5. Eye comfort (problem #4)

- Body text `onSurface #0F172A` (deep slate) — strong but never pure black (`#000` strains on screens).
- Line-height 1.5 for body; max line length ~70 chars (enforced by the 1200px max width + columns).
- **Thin `outlineVariant` borders are the primary separator** (web-native flat system). Use `surfaceContainerLow` tints behind white cards when a region needs to recede; reserve shadows for transient surfaces (menus/dialogs).
- Motion: subtle, from `PsyMotion` (`fast` 160ms / `normal` 240ms, ease-out), never bouncy. Page transitions are instant on web/desktop by design. Respect `MediaQuery.disableAnimations`.
- Dark mode: `PsyColors.darkScheme` (teal `#5EEAD4` primary; surfaces `#111827` on `#0B1220`). Resolve via `colorScheme` and it just works.

---

## 6. Do / Don't

| ✅ Do | ❌ Don't |
|---|---|
| Wrap content in cards with headers | Drop raw `Text`/`Column` onto a bare Scaffold |
| One `displaySmall` title per page | Multiple competing big headings |
| Spacing only from the scale | Random `EdgeInsets.all(13)` |
| `FilledButton` for the main action | All-`TextButton` screens (invisible CTAs) |
| Status as tinted pill chips | Long sentences for status |
| Persistent shell + breadcrumb | Standalone screens with no nav |
| Icons on every list row | Walls of text |

---

## 7. Working with Claude on UI

When you ask for a screen, Claude will:
1. Build it inside `AppShell` (never a bare Scaffold).
2. Resolve colours via `Theme.of(context).colorScheme` (or `PsyColors` for charts) + use `PsySpacing`/`PsyRadius` tokens only — never hard-code hex or magic numbers.
3. Apply the card-anatomy + density rules (stat row, lists with icons, status chips, designed empty states).
4. Place a clear `FilledButton` primary CTA.
5. Run `flutter analyze` and verify the screen builds.

Trigger phrases: *"DESIGN.md'ye göre X ekranını yap"*, *"bu sayfayı dolu/profesyonel yap"*, *"butonları belirginleştir"*.

Reference competitors for richness (composition only, never copy): SimplePractice, TheraNest, Tebra.

---

## 8. Design-system widgets (`lib/widgets/ds/`)

These six widgets are the canonical vocabulary for the clinician surface. **Always pick the DS widget over a bespoke implementation** — they carry the telemetry, a11y, and brightness/contrast rules the rest of this doc demands. Each one is covered by `test/ds_widgets_test.dart`.

### `PsySnack` — unified snackbar (`psy_snack.dart`)

Replaces every `ScaffoldMessenger.of(context).showSnackBar(...)` call site. Four levels (`info` / `success` / `warning` / `error`). Each call:

- Fires `psysnack.shown {level, hint}` telemetry — use a **stable** `hint` like `safety_plan.save_failed`, not a sentence.
- Carries `Semantics(liveRegion: true)` so screen readers announce all four levels (polite for info/success, assertive for error).
- Tints are **brightness-aware** (WCAG 1.4.11 — light theme needs darker accents on the dark `inverseSurface`; dark theme inverts).

```dart
PsySnack.success(context, 'Safety plan saved.', hint: 'safety_plan.save');
PsySnack.error(
  context,
  'Could not save — please retry.',
  hint: 'safety_plan.save_failed',
  action: SnackBarAction(label: 'Retry', onPressed: _save),
);
```

**Never** pass `'$e'` into the message — route exceptions through `TelemetryService.captureError(e, st, hint: '...')` and surface a generic message ("PDF generation failed — please retry."). PHI / internal paths must not reach the UI.

### `PsyEmptyState` — designed empty / null states (`psy_empty_state.dart`)

The opposite of a centered grey paragraph. Icon well + bold title + body + optional action button. `Semantics(container: true, explicitChildNodes: true)` keeps the action button as its own SR node.

```dart
PsyEmptyState(
  icon: Icons.group_outlined,
  title: 'No patients yet',
  body: 'Add your first patient to get started.',
  action: PsyEmptyStateAction(
    label: 'Add patient',
    icon: Icons.person_add_alt_1,
    onTap: _openAddPatient,
  ),
);
```

Use `compact: true` when the empty state sits inside a `PsyCard` that already has padding. Title is the short headline; body is the explanation — never swap the two. When there's no unambiguous next action, omit `action` instead of inventing one.

### `PsyTooltip` — code / term tooltip (`psy_tooltip.dart`)

For dense data where a short code (ICD-10, CPT, lab abbr.) is the visible label and the full expansion is needed on demand.

```dart
PsyTooltip(
  label: 'F32.1',
  description: 'Major Depressive Disorder, Single Episode, Moderate',
  child: <chip widget>,
);
```

- `Semantics(label, hint)` wraps the chip so SR users hear the expansion without hovering.
- Inner child is wrapped in `ExcludeSemantics` so the label isn't announced twice.
- `triggerMode: TooltipTriggerMode.longPress` gives touch parity (iPad / phone).
- `richMessage` renders bold label + description with a 6s show duration.
- Empty `label` returns the child as-is (no tooltip), so it's safe to call unconditionally.

### `PsySkeleton*` — loading placeholders (`psy_skeleton.dart`)

Replaces every `CircularProgressIndicator` that fronts a list or a card. Shapes match the real layout so the page doesn't jump on load.

```dart
// Inside a list-bearing screen (uses ListView under the hood):
PsySkeletonList(itemBuilder: (_) => const _PatientTileSkeleton())

// Inside an AppShell with its own scroll, compose primitives directly:
Column(children: const [
  PsySkeletonBlock(height: 64),
  SizedBox(height: PsySpacing.lg),
  PsySkeletonBlock(height: 144),
]);

// Primitives: PsySkeletonLine, PsySkeletonBlock, PsySkeletonCircle
```

- A shared `PsySkeletonGroup` drives every nested primitive with one pulse — sibling shapes pulse in sync, not in a noisy stutter.
- Respects `MediaQuery.disableAnimationsOf(context)` — reduce-motion freezes the pulse.
- The pulse alpha is tuned (max 0.28 of `onSurface`) so a fully-skeleton screen remains perceivable for low-vision clinicians, with a `Semantics(label: 'Loading content')` wrapper so SR announces the loading state.
- **Do not** nest `PsySkeletonList` directly inside an `AppShell` (both scroll — unbounded viewport). Use the primitives in a `Column` instead.

### `SavingIndicator` + `SavingIndicatorController` — write-state pill (`saving_indicator.dart`)

Cures the "did it actually save?" anxiety. One controller per form; pin one `SavingIndicator` in the page header (next to the primary CTA).

```dart
class _MyScreenState extends State<MyScreen> {
  final _saveCtrl = SavingIndicatorController();

  @override
  void dispose() { _saveCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    _saveCtrl.startSaving();
    try {
      await _repo.save(...);
      _saveCtrl.markSaved();             // auto-fades after 2s
    } catch (e, st) {
      unawaited(TelemetryService.instance.captureError(
        e, st, hint: 'my_screen.save_failed'));
      _saveCtrl.markError(onRetry: _save); // pill becomes tap-to-retry
    }
  }

  // In the AppShell primaryAction slot:
  Row(children: [SavingIndicator(controller: _saveCtrl), const SizedBox(width: PsySpacing.md), _primaryCta]);
}
```

- State machine: `idle → saving → saved → idle` or `… → error → idle`.
- `SemanticsService.sendAnnouncement` fires on every state flip ("Saved." polite / "Save failed — tap to retry." assertive) — clinicians never miss a write outcome.
- The error pill has a 32-px minimum hit target (WCAG 2.5.8) and tap-to-retry.

### `PsySaveShortcut` — Cmd+S / Ctrl+S binding (`psy_save_shortcut.dart`)

Wrap any screen that has a save action so the power-user shortcut works:

```dart
PsySaveShortcut(
  enabled: _canSave,
  onSave: _save,
  child: <screen body>,
);
```

Uses Flutter's `Shortcuts` + `Actions` + `FocusableActionDetector` so the binding does not leak into nested editors. When `enabled: false` the shortcut is a no-op (no surprise saves while the form is incomplete).

---

### Rule of thumb

If you find yourself writing `ScaffoldMessenger.showSnackBar`, a centered `Column` for an empty state, a bare `CircularProgressIndicator` on a content area, or a one-off `Tooltip(message: '$code $description')` — stop and reach for the DS widget above. The DS surface is what makes the clinician trust that *this* save behaved like *that* save did yesterday.

---

## 9. Modality session templates (`lib/screens/session/modalities/`)

The session screen ships four note styles. The clinician picks at session start via a `SegmentedButton` in the notes-panel header; the picker only surfaces the modalities the clinician has both **enabled** in Settings AND **paid for** (Pro tier).

| Modality | Source | What it is | Where to use |
|---|---|---|---|
| **Standard** | `StructuredNoteEditor` (SOAP / DAP / BIRP) | Free-form structured note. Markdown export. | Default for every clinician. Generalist sessions, supervisors writing about cases, anywhere a modality-specific template would be overkill. |
| **CBT** | `CbtThoughtRecordPanel` | Beck/Padesky 7-column thought record + Burns' 10 cognitive distortions. `intensityDelta` = sum(before) − sum(after). | Cognitive restructuring sessions. Captures the hot thought + the cognitive work + the outcome on one page. |
| **DBT** | `DbtDiaryCardPanel` | Linehan 7-day diary card: 5 default target behaviours, 7 core emotions 0-5, 15 DBT skills across 4 modules. SI peak + self-harm act roll-up. | Borderline-spectrum / emotion-regulation work. The card is the week between sessions; the panel is where the clinician walks through it. |
| **EMDR** | `EmdrSessionTrackerPanel` | Shapiro 8-Phase tracker: NC/PC/VOC/SUDS/Body assessment, BLS-set log, body scan + closure + reevaluation. Hard abreaction safety gate on closure. | Trauma reprocessing sessions. Mandatory for any clinician trained in EMDR — the SUDS/VOC trajectory is what supervisors review. |

### Picker behaviour (tier + enablement)

`ModalityPreferences` (`lib/models/modality_preferences.dart`) carries `{clinicianId, enabled: Set<ModalityKind>, tier: free|pro}`. The session-screen picker filters via `prefs.isEnabled(kind)`:

- **Free** clinician → picker shows **Standard only**.
- **Pro** clinician → picker shows **Standard + each enabled modality**. Pre-toggling a modality while Free pre-stores the choice so upgrading flips it on automatically (nobody has to "remember to toggle" after upgrading).
- Until prefs load async → only Standard shows, so a Free clinician never glimpses a paid segment before the gate applies.

### Panel anatomy (shared shape)

Every modality panel follows the same composition so a clinician moving between modalities never relearns the surface:

```
┌─ Header ──────────────────────────────────────────────┐
│  [Title]  [SavingIndicator]  [FilledButton Save]      │
├─ Subheader ───────────────────────────────────────────┤
│  One-line "what this is + the clinical convention"    │
├─ Body ────────────────────────────────────────────────┤
│  PsyCard sections, each:                              │
│   • numbered step (or labelled phase)                 │
│   • short subtitle stating the clinical rule          │
│   • the editor (TextField / Slider / FilterChip /     │
│     stepper / tile list)                              │
├─ Outcome / Arc summary ───────────────────────────────┤
│  PsyCard tinted with the delta / arc the supervisor   │
│  reads (intensityDelta / SI peak / SUDS arc).         │
└───────────────────────────────────────────────────────┘
```

### Persistence — `ModalitySessionRepository`

One SharedPreferences key (`modality_sessions`), tagged-envelope JSON list: `{type: 'cbt'|'dbt'|'emdr', payload: <model JSON>}`. The factory in `ModalityRecord.fromJson` dispatches to the matching `fromJson`. Per-record resilience — one corrupt entry drops + logs, never wipes the list. Mirror to Firestore lands when the tenant flips to managed sync.

### Telemetry hints

Stable strings — never change them; dashboards rely on the slug.

| Event | Properties | When |
|---|---|---|
| `cbt_thought_record.saved` | `{distortions, thoughts, intensity_delta}` | Save success |
| `cbt_thought_record.save_failed` | (captureError) | Save error path |
| `dbt_diary_card.saved` | `{filled_days, si_peak, sh_act}` | Save success |
| `dbt_diary_card.save_failed` | (captureError) | Save error path |
| `emdr_session.saved` | `{phase, bls_sets, suds_delta, voc_delta, abreaction, closure_safe}` | Save success |
| `emdr_session.save_failed` | (captureError) | Save error path |
| `emdr_session.closure_blocked` | (PsySnack.warning) | Closure attempt with unresolved abreaction |
| `session.modality_changed` | `{modality}` | Picker flip |
| `modality_preferences.toggled` | `{kind, enabled}` | Settings toggle |
| `modality_preferences.tier_upgraded_local` | — | Upgrade button |

**No PHI** in any property — only counts, deltas, enums, booleans.

### Clinical fidelity sources

Don't reinvent or "improve" the scales. The clinicians know these references — diverging from them is the fastest way to lose trust.

- **CBT distortions** — David D. Burns, *Feeling Good* (1980, revised). 10 distortions, our `CbtCognitiveDistortion` enum order matches the book.
- **CBT thought-record columns** — Greenberger & Padesky, *Mind Over Mood* (2nd ed., 2015). 7-column model.
- **DBT diary card** — Marsha M. Linehan, *DBT Skills Training Manual* (2nd ed., 2014). Adult standard card.
- **DBT skills (15 + 4 modules)** — same source. Our IDs are the canonical short names (`tip`, `dear_man`, `please`, etc.).
- **EMDR 8 phases** — Francine Shapiro, *Eye Movement Desensitization and Reprocessing* (3rd ed., 2018).
- **SUDS** — Joseph Wolpe (1969). Scale 0-10.
- **VOC** — Shapiro (1989 → ongoing). Scale 1-7.

### Adding a new modality (the cookbook)

When the next modality lands (ACT / IFS / Schema / MI / Solution-Focused / …):

1. **Model** — `lib/models/modalities/<name>.dart`. JSON round-trip with per-field clamps and an enum for any controlled vocabulary. Include a `clinicianNotes` field for the clinician's own addendum.
2. **Repository** — extend `ModalityKind` (`lib/services/data/modality_session_repository.dart`) with the new enum value + switch arm in `ModalityRecord.fromJson` / `toJson` / `sortDate` / convenience getter. No schema migration needed — old records still decode because the dispatch is on `type`.
3. **Panel** — `lib/screens/session/modalities/<name>_panel.dart` following the shared anatomy above. PsyCard sections, `SavingIndicator` controller, `PsySnack` on save/error, telemetry hint `<modality>.saved`.
4. **Preferences row** — add to `lib/screens/settings/modalities_screen.dart`; the picker auto-respects the tier gate.
5. **Session screen** — extend `SessionNoteModality` enum + `switch` in the body builder + `_modalitySegments()`.
6. **Tests** — JSON round-trip, clinical-rule assertions (e.g. SUDS within 0-10), repository upsert idempotence. Mirror `test/modality_session_repository_test.dart` shape.
7. **DESIGN.md §9** — add the modality row to the table at the top of this section + cite the clinical source.

Seven steps; ~600-900 lines per modality. Keep the panel scrollable so the picker doesn't dictate viewport assumptions.
