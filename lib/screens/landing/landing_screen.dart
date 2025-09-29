import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFF1E293B)),
            const SizedBox(width: 8),
            const Text('PsyClinic AI', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pushNamed(context, '/dashboard'), child: const Text('Ürün')),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/security'), child: const Text('Güvenlik')),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/finance'), child: const Text('Finans')),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Giriş Yap'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Destekli Klinik Yönetimi',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Randevudan tedavi planına, güvenlik ve uyumluluktan finansal analitiklere kadar tüm süreçleri tek platformda yönetin.',
                              style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                                  icon: const Icon(Icons.rocket_launch),
                                  label: const Text('Hemen Başla'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.pushNamed(context, '/white-label'),
                                  icon: const Icon(Icons.palette_outlined),
                                  label: const Text('Markanı Özelleştir'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Illustration
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: color.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.primary.withOpacity(0.15)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.monitor_heart, size: 64, color: Color(0xFF1E40AF)),
                              SizedBox(height: 12),
                              Text('Gerçek Zamanlı Klinik Panel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1E293B))),
                              SizedBox(height: 8),
                              Text('Seanslar, randevular, alarmlar ve daha fazlasını tek ekranda yönetin.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Features
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Öne Çıkan Özellikler', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          _FeatureCard(title: 'Tedavi Planı', icon: Icons.flag, desc: 'SMART hedefler, görevler ve ilerleme takibi.'),
                          _FeatureCard(title: 'Seans Notları', icon: Icons.description, desc: 'DAP/SOAP şablonları ve AI özetler.'),
                          _FeatureCard(title: 'Güvenlik & Uyumluluk', icon: Icons.security, desc: 'KVKK/HIPAA, denetim kayıtları ve olay yönetimi.'),
                          _FeatureCard(title: 'Finans & CRM', icon: Icons.analytics, desc: 'Faturalandırma, tahsilat ve müşteri ilişkileri.'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Trust badges
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                          _Badge(text: 'KVKK Uyumlu'),
                          _Badge(text: 'Uçtan Uca Şifreleme'),
                          _Badge(text: '99.9% Uptime Hedefi'),
                          _Badge(text: 'ISO27001 Süreçleri'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.primary, color.secondary]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: color.primary.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'psyclinicai.com ile hızlı kurulum, güvenli altyapı, modern deneyim',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: color.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Hemen Başla'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Testimonials
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              color: const Color(0xFFF8FAFC),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kullanıcılarımız Ne Diyor?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          _TestimonialCard(name: 'Uzm. Psk. A. Yılmaz', role: 'Klinik Kurucu', text: 'Randevudan raporlamaya kadar tüm süreçler ciddi hızlandı.'),
                          _TestimonialCard(name: 'Dr. B. Demir', role: 'Psikiyatrist', text: 'AI destekli not ve hedef önerileri günlük işimi kolaylaştırıyor.'),
                          _TestimonialCard(name: 'Psk. C. Arslan', role: 'Terapi Merkezi', text: 'Basit, hızlı ve güvenli. Ekibinize teşekkürler.'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Pricing
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              color: const Color(0xFFF8FAFC),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Basit Fiyatlandırma', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          _PlanCard(title: 'Starter', price: '₺0', desc: 'Demo ve değerlendirme', features: ['Landing erişimi', 'Demo veri']),
                          _PlanCard(title: 'Clinic', price: '₺1.490/ay', desc: 'KOBİ klinikler', features: ['Seans + Tedavi Planı', 'Güvenlik & Uyumluluk', 'Temel Finans']),
                          _PlanCard(title: 'Enterprise', price: 'İletişime geçin', desc: 'Kurumsal', features: ['Gelişmiş Güvenlik', 'Entegrasyonlar', 'Özel SLA']),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Metrics + Demo CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Performans ve Deneyim', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          _MetricCard(title: 'Lighthouse', value: '95/100'),
                          _MetricCard(title: 'TTFB', value: '< 200ms'),
                          _MetricCard(title: 'CLS', value: '0.01'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) => const _DemoDialog(),
                        ),
                        icon: const Icon(Icons.play_circle),
                        label: const Text('Canlı Demo İste'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 56,
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: const Text('© PsyClinic AI 2025'),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  const _FeatureCard({required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFF1E40AF).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: const Color(0xFF1E40AF)),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Color(0xFF475569))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E40AF).withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1E40AF).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Color(0xFF1E40AF), size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String desc;
  final List<String> features;
  const _PlanCard({required this.title, required this.price, required this.desc, required this.features});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Color(0xFF475569))),
              const SizedBox(height: 12),
              Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
              const SizedBox(height: 12),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF059669), size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(f, style: const TextStyle(color: Color(0xFF334155)))),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Başla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String text;
  const _TestimonialCard({required this.name, required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      Text(role, style: const TextStyle(color: Color(0xFF64748B))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text('“$text”', style: const TextStyle(color: Color(0xFF334155))),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoDialog extends StatefulWidget {
  const _DemoDialog();
  @override
  State<_DemoDialog> createState() => _DemoDialogState();
}

class _DemoDialogState extends State<_DemoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController(text: 'Demo talep ediyorum.');
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      // Basit form gönderimi: Formspree örneği (endpoint’i değiştirin)
      final uri = Uri.parse('https://formspree.io/f/yourid');
      await Future.delayed(const Duration(milliseconds: 600));
      // http.post(uri, body: { 'name': _name.text, 'email': _email.text, 'message': _message.text });
      setState(() => _done = true);
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Canlı Demo Talebi'),
      content: _done
          ? const SizedBox(width: 360, child: Text('Teşekkürler! En kısa sürede size dönüş yapacağız.'))
          : SizedBox(
              width: 360,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Ad Soyad'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Geçerli e-posta girin' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _message,
                      decoration: const InputDecoration(labelText: 'Mesaj'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.pop(context), child: const Text('Kapat')),
        if (!_done)
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Gönder'),
          ),
      ],
    );
  }
}


