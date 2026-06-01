import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/telemetry_service.dart';
import '../../widgets/landing/cookie_consent.dart';
import '../../widgets/landing/demo_modal.dart';
import '../../widgets/landing/exit_intent_modal.dart';
import '../../widgets/landing/sticky_cta_bar.dart';
import '../../widgets/landing/trust_strip.dart';
import 'sections/built_for_section.dart';
import 'sections/comparison_table_section.dart';
import 'sections/denial_shield_section.dart';
import 'sections/faq_section.dart';
import 'sections/feature_grid_section.dart';
import 'sections/final_cta_section.dart';
import 'sections/footer_section.dart';
import 'sections/hero_section.dart';
import 'sections/how_it_works_section.dart';
import 'sections/pricing_section.dart';
import 'sections/problem_section.dart';
import 'sections/product_gallery_section.dart';
import 'sections/testimonials_section.dart';
import 'sections/trust_bar_section.dart';

/// Landing page — modular composition of section widgets.
///
/// Each section lives under `lib/screens/landing/sections/`. This file is the
/// orchestrator only: it wires navigation handlers, chooses the order, and
/// drives the scroll-aware sticky CTA bar.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scroll = ScrollController();
  bool _stickyVisible = false;

  final _anchors = <String, GlobalKey>{
    'comparison': GlobalKey(),
    'pricing': GlobalKey(),
    'faq': GlobalKey(),
  };

  bool _exitIntentShown = false;

  void _onMouseHover(PointerHoverEvent e) {
    if (_exitIntentShown) return;
    // After the visitor has scrolled past the hero — they've seen the
    // pitch — fire when the cursor approaches the browser tab bar.
    if (_scroll.hasClients && _scroll.offset > 1200 && e.position.dy < 8) {
      _exitIntentShown = true;
      ExitIntentModal.show(
          context, (email) => _waitlistSubmit(context, email));
    }
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scroll.offset > 600;
    if (shouldShow != _stickyVisible) {
      setState(() => _stickyVisible = shouldShow);
    }
  }

  void _scrollTo(String anchor) {
    final key = _anchors[anchor];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  void _gotoSignup(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  void _gotoLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  void _bookDemo(BuildContext context) {
    DemoModal.show(context);
  }

  void _pickTier(BuildContext context, String tier) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserving a $tier seat — sign in to continue'),
      ),
    );
    Navigator.of(context).pushNamed('/login');
  }

  Future<void> _waitlistSubmit(BuildContext context, String email) async {
    TelemetryService.instance.capture(TelemetryEvents.landingHeroEmailSubmit,
        properties: {'source': 'hero'});
    // Best-effort Firestore write — if rules deny, the user still gets a
    // success confirmation (we never block conversion on backend ACK).
    if (PsyFirebase.isReady) {
      try {
        await FirebaseFirestore.instance.collection('landing_waitlist').add({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'hero',
        });
      } catch (_) {
        // Rules deny / network fail — ignore, fall through to UI ack.
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You're in. We'll email $email the moment a founding seat opens."),
      ),
    );
  }

  void _footerLink(BuildContext context, String id) {
    // Anchors scroll inside the landing.
    if (_anchors.containsKey(id) ||
        const ['features', 'roadmap'].contains(id)) {
      final mapped = switch (id) {
        'features' => 'comparison',
        'roadmap' => 'faq',
        _ => id,
      };
      _scrollTo(mapped);
      return;
    }

    final route = switch (id) {
      'security' => '/security',
      'about' => '/about',
      'changelog' => '/changelog',
      'status' => '/status',
      'privacy' => '/privacy',
      'tos' => '/tos',
      'contact' => '/contact',
      'press' => '/press',
      'help' => '/security',
      'baa' => '/privacy',
      'dpa' => '/privacy',
      _ => null,
    };
    if (route != null) {
      Navigator.of(context).pushNamed(route);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$id" page coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _LandingAppBar(
        onSignIn: () => _gotoLogin(context),
        onStart: () => _gotoSignup(context),
        onScrollTo: _scrollTo,
        onSecurity: () => Navigator.of(context).pushNamed('/security'),
      ),
      drawer: _LandingDrawer(
        onScrollTo: (a) {
          Navigator.of(context).pop();
          _scrollTo(a);
        },
        onRoute: (r) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(r);
        },
      ),
      body: MouseRegion(
        onHover: _onMouseHover,
        child: Stack(
        children: [
          ListView(
            controller: _scroll,
            padding: EdgeInsets.zero,
            children: [
              HeroSection(
                onPrimaryCta: () => _gotoSignup(context),
                onSecondaryCta: () => _bookDemo(context),
                onWaitlistEmail: (email) =>
                    _waitlistSubmit(context, email),
              ),
              const TrustStrip(),
              const TrustBarSection(),
              KeyedSubtree(
                  key: _anchors['comparison'],
                  child: const ComparisonTableSection()),
              const ProductGallerySection(),
              const HowItWorksSection(),
              const FeatureGridSection(),
              const BuiltForSection(),
              const ProblemSection(),
              const DenialShieldSection(),
              KeyedSubtree(
                  key: _anchors['pricing'],
                  child: PricingSection(
                      onPickTier: (t) => _pickTier(context, t))),
              TestimonialsSection(onCta: () => _gotoSignup(context)),
              KeyedSubtree(
                  key: _anchors['faq'], child: const FaqSection()),
              FinalCtaSection(
                onPrimary: () => _gotoSignup(context),
                onSecondary: () => _bookDemo(context),
              ),
              FooterSection(onLink: (id) => _footerLink(context, id)),
              // Leave room for the sticky bar so the footer doesn't hide.
              const SizedBox(height: 80),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyCtaBar(
              visible: _stickyVisible,
              onPrimary: () => _gotoSignup(context),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: CookieConsent(),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _LandingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LandingAppBar({
    required this.onSignIn,
    required this.onStart,
    required this.onScrollTo,
    required this.onSecurity,
  });

  final VoidCallback onSignIn;
  final VoidCallback onStart;

  /// Scroll to a named landing section (`pricing`, `faq`, `comparison`).
  final void Function(String anchor) onScrollTo;
  final VoidCallback onSecurity;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 720;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: cs.surface,
      // Scale-down on narrow phones so the brand never overflows the AppBar
      // middle slot (fixes the 28px OVERFLOWED stripe seen on iPhone widths).
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            Icon(Icons.psychology, color: cs.primary, size: 26),
            const SizedBox(width: 8),
            Text(
              'PsyClinicAI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isWide) ...[
          _NavLink('Pricing', () => onScrollTo('pricing'), cs),
          _NavLink('Compare', () => onScrollTo('comparison'), cs),
          _NavLink('FAQ', () => onScrollTo('faq'), cs),
          _NavLink('Security', onSecurity, cs),
          const SizedBox(width: 12),
        ],
        TextButton(
          onPressed: onSignIn,
          child: Text('Sign in', style: TextStyle(color: cs.onSurface)),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Text('Start free'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.onPressed, this.cs);
  final String label;
  final VoidCallback onPressed;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: cs.onSurface.withValues(alpha: 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

class _LandingDrawer extends StatelessWidget {
  const _LandingDrawer(
      {required this.onScrollTo, required this.onRoute});

  final void Function(String anchor) onScrollTo;
  final void Function(String route) onRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Widget tile(IconData icon, String label, VoidCallback onTap) {
      return ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(label,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        onTap: onTap,
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: cs.primary, size: 28),
                  const SizedBox(width: 8),
                  Text('PsyClinicAI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      )),
                ],
              ),
            ),
            const Divider(),
            tile(Icons.attach_money, 'Pricing',
                () => onScrollTo('pricing')),
            tile(Icons.compare_arrows, 'Compare',
                () => onScrollTo('comparison')),
            tile(Icons.help_outline, 'FAQ', () => onScrollTo('faq')),
            const Divider(),
            tile(Icons.verified_user_outlined, 'Security',
                () => onRoute('/security')),
            tile(Icons.info_outline, 'About', () => onRoute('/about')),
            tile(Icons.email_outlined, 'Contact',
                () => onRoute('/contact')),
            tile(Icons.gavel_outlined, 'Privacy',
                () => onRoute('/privacy')),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FilledButton.icon(
                onPressed: () => onRoute('/login'),
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Start free'),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
