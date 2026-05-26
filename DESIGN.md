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

**Empty states are designed, not blank:** icon + one-line explanation + a primary button to create the first item. Never show a blank area.

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
