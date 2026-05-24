import 'package:flutter/material.dart';

import '../../widgets/landing/demo_modal.dart';
import 'sections/built_for_section.dart';
import 'sections/comparison_table_section.dart';
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
/// orchestrator only: it wires navigation handlers and chooses the order.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pushNamed('/login');
  }

  void _footerLink(BuildContext context, String id) {
    final route = switch (id) {
      'security' => '/security',
      'about' => '/about',
      'changelog' => '/changelog',
      'status' => '/status',
      'pricing' => null, // anchor on current page; future Sprint
      _ => null,
    };
    if (route != null) {
      Navigator.of(context).pushNamed(route);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$id" page coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _LandingAppBar(
        onSignIn: () => _gotoLogin(context),
        onStart: () => _gotoSignup(context),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeroSection(
            onPrimaryCta: () => _gotoSignup(context),
            onSecondaryCta: () => _bookDemo(context),
          ),
          const TrustBarSection(),
          const ComparisonTableSection(),
          const ProductGallerySection(),
          const HowItWorksSection(),
          const FeatureGridSection(),
          const BuiltForSection(),
          const ProblemSection(),
          PricingSection(onPickTier: (t) => _pickTier(context, t)),
          TestimonialsSection(onCta: () => _gotoSignup(context)),
          const FaqSection(),
          FinalCtaSection(
            onPrimary: () => _gotoSignup(context),
            onSecondary: () => _bookDemo(context),
          ),
          FooterSection(onLink: (id) => _footerLink(context, id)),
        ],
      ),
    );
  }
}

class _LandingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LandingAppBar({required this.onSignIn, required this.onStart});

  final VoidCallback onSignIn;
  final VoidCallback onStart;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: cs.surface,
      title: Row(
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
      actions: [
        TextButton(
          onPressed: onSignIn,
          child: Text('Sign in', style: TextStyle(color: cs.onSurface)),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onStart,
          style: FilledButton.styleFrom(
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
