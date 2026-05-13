import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const List<_OnboardingFeature> _features = [
    _OnboardingFeature(
      icon: Icons.explore,
      label: 'Compass',
      color: Color(0xFF00897B),
    ),
    _OnboardingFeature(
      icon: Icons.location_on,
      label: 'Maps',
      color: Color(0xFF43A047),
    ),
    _OnboardingFeature(
      icon: Icons.place,
      label: 'Navigate',
      color: Color(0xFF1E88E5),
    ),
    _OnboardingFeature(
      icon: Icons.traffic,
      label: 'Traffic',
      color: Color(0xFFF4511E),
    ),
    _OnboardingFeature(
      icon: Icons.public,
      label: 'Landmarks',
      color: Color(0xFF8E24AA),
    ),
    _OnboardingFeature(
      icon: Icons.thermostat,
      label: 'Weather',
      color: Color(0xFFFDD835),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: _features.map((feature) {
                    return _FeatureCard(feature: feature);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Navigate the World Smarter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Discover maps, live data, and smart tools to understand the world around you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Let’s Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _OnboardingFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: feature.color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: feature.color.withAlpha(56)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: feature.color,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(feature.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            feature.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: feature.color.darken(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingFeature {
  final IconData icon;
  final String label;
  final Color color;

  const _OnboardingFeature({
    required this.icon,
    required this.label,
    required this.color,
  });
}

extension on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
