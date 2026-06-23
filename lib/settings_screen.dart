import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'services/firebase_service.dart';
import 'providers/language_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Color _primaryColor = const Color(0xFF1E7E6C);

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);
    final activeCode = ref.watch(languageProvider);

    final List<Map<String, String>> langs = [
      {'name': 'English', 'flag': '🇺🇸', 'code': 'en'},
      {'name': 'Arabic (العربية)', 'flag': '🇸🇦', 'code': 'ar'},
      {'name': 'Spanish (Español)', 'flag': '🇪🇸', 'code': 'es'},
      {'name': 'French (Français)', 'flag': '🇫🇷', 'code': 'fr'},
      {'name': 'German (Deutsch)', 'flag': '🇩🇪', 'code': 'de'},
      {'name': 'Urdu (اردو)', 'flag': '🇵🇰', 'code': 'ur'},
      {'name': 'Hindi (हिन्दी)', 'flag': '🇮🇳', 'code': 'hi'},
    ];

    final activeLangMap = langs.firstWhere(
      (l) => l['code'] == activeCode,
      orElse: () => langs[0],
    );
    final currentLanguageName = activeLangMap['name']!;

    return Scaffold(
      backgroundColor: Colors.white, // Matches exact clean white background from screenshot
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr['settings'] ?? 'Settings',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // 1. App Language Card
              _buildSettingsCard(
                title: tr['app_language'] ?? 'App Language',
                subtitle: currentLanguageName,
                iconAsset: 'assets/lang.png',
                fallbackIcon: Icons.language_rounded,
                onTap: _showLanguageSelector,
              ),

              // 2. Rate Us Card
              _buildSettingsCard(
                title: tr['rate_us'] ?? 'Rate Us',
                subtitle: tr['rate_us_subtitle'] ?? 'Your positive rating motivate us',
                iconAsset: 'assets/rate.png',
                fallbackIcon: Icons.thumb_up_alt_outlined,
                onTap: _showRatingDialog,
              ),

              // 3. Feedback Card
              _buildSettingsCard(
                title: tr['feedback'] ?? 'Feedback',
                subtitle: tr['feedback_subtitle'] ?? 'Help us improve with your valuable feedback',
                iconAsset: 'assets/feedback_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24 1.png',
                fallbackIcon: Icons.sms_failed_outlined,
                onTap: () => Navigator.pushNamed(context, '/feedback'),
              ),

              // 4. Share App Card
              _buildSettingsCard(
                title: tr['share_app'] ?? 'Share App',
                subtitle: tr['share_app_subtitle'] ?? 'Share and invite your friends',
                iconAsset: 'assets/share.png',
                fallbackIcon: Icons.share_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr['generating_invite_link'] ?? 'Generating invitation link to share with friends...'),
                      backgroundColor: _primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),

              // 5. More Apps Card
              _buildSettingsCard(
                title: tr['more_apps'] ?? 'More Apps',
                subtitle: tr['more_apps_subtitle'] ?? 'Try our other apps',
                iconAsset: 'assets/user.png',
                fallbackIcon: Icons.person_outline_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr['loading_dev_profile'] ?? 'Loading developer profile in Store...'),
                      backgroundColor: _primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),

              // 6. Privacy Policy Card
              _buildSettingsCard(
                title: tr['privacy_policy'] ?? 'Privacy Policy',
                subtitle: tr['privacy_policy_subtitle'] ?? 'How we protect your data',
                iconAsset: 'assets/privacy.png',
                fallbackIcon: Icons.security_outlined,
                onTap: _showPrivacySheet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable Settings Card Widget precisely matching screenshot specs ──
  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required String iconAsset,
    required IconData fallbackIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Clean grey card color from screenshot
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                // Icon on Left in signature teal brand color
                Image.asset(
                  iconAsset,
                  width: 26,
                  height: 26,
                  color: _primaryColor,
                  errorBuilder: (_, __, ___) => Icon(
                    fallbackIcon,
                    color: _primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 18),

                // Text Stack
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Show Interactive Bottom Sheet Language Chooser ──
  void _showLanguageSelector() {
    final tr = ref.read(translationProvider);
    final activeCode = ref.read(languageProvider);

    final List<Map<String, String>> langs = [
      {'name': 'English', 'flag': '🇺🇸', 'code': 'en'},
      {'name': 'Arabic (العربية)', 'flag': '🇸🇦', 'code': 'ar'},
      {'name': 'Spanish (Español)', 'flag': '🇪🇸', 'code': 'es'},
      {'name': 'French (Français)', 'flag': '🇫🇷', 'code': 'fr'},
      {'name': 'German (Deutsch)', 'flag': '🇩🇪', 'code': 'de'},
      {'name': 'Urdu (اردو)', 'flag': '🇵🇰', 'code': 'ur'},
      {'name': 'Hindi (हिन्दी)', 'flag': '🇮🇳', 'code': 'hi'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        tr['select_app_language'] ?? 'Select App Language',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: langs.length,
                        itemBuilder: (context, idx) {
                          final l = langs[idx];
                          final isSelected = l['code'] == activeCode;

                          return ListTile(
                            leading: Text(
                              l['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              l['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? _primaryColor : const Color(0xFF1F1F1F),
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded, color: _primaryColor)
                                : null,
                            onTap: () async {
                              await ref.read(languageProvider.notifier).setLanguage(l['code']!);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${tr['language_changed_to'] ?? 'Language changed to '}${l['name']}'),
                                    backgroundColor: _primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Show Polished 5-Star Rating Dialog matching mockup ──
  void _showRatingDialog() {
    final tr = ref.read(translationProvider);
    int selectedStars = 3; // Default 3 stars matches screenshot exactly

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title matching screenshot
                    Text(
                      tr['how_was_experience'] ?? "How was your experience ? We'd greatly appreciate if you can rate us",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Custom Smiley Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (idx) {
                        final starNum = idx + 1;
                        final isSel = starNum <= selectedStars;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _SmileyStar(
                            isSelected: isSel,
                            size: 46,
                            onTap: () {
                              setDlgState(() {
                                selectedStars = starNum;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),

                    // Motivation text in brand green/teal color
                    if (selectedStars >= 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tr['best_we_can_get'] ?? 'The best we can get',
                            style: const TextStyle(
                              color: Color(0xFF1E7E6C),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.north_east_rounded,
                            color: Color(0xFF1E7E6C),
                            size: 18,
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 22), // Keep vertical structure consistent

                    const SizedBox(height: 26),

                    // Actions Row: Maybe Later (left), Rate (right)
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              tr['maybe_later'] ?? 'Maybe Later',
                              style: const TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  await FirebaseService.instance.saveRating(selectedStars);
                                } catch (e) {
                                  debugPrint("Failed to save rating: $e");
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${tr['thank_you_rating'] ?? 'Thank you for your rating! Opening Play Store...'} ($selectedStars stars)'),
                                      backgroundColor: _primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                tr['rate'] ?? 'Rate',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Show Privacy Policy Sheet ──
  void _showPrivacySheet() {
    final tr = ref.read(translationProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tr['privacy_policy'] ?? 'Privacy Policy',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr['privacy_last_updated'] ?? 'Last Updated: May 31, 2026',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text(
                          '${tr['privacy_collect'] ?? '1. Information We Collect\nExplore Earth collects device sensor telemetry, approximate coordinates for weather forecasts, and usage logs to deliver premium core map tools. We do NOT harvest or sell any personal identifiers.'}\n\n'
                          '${tr['privacy_use'] ?? '2. How We Use Data\nTelemetric readings from the Level Meter or Altimeter are processed strictly locally on-device and are never transmitted to cloud servers. Location information is fetched dynamically through standard Google Maps services under secure tokens.'}\n\n'
                          '${tr['privacy_security'] ?? '3. Security Safeguards\nWe incorporate advanced encryption pipelines and secure local sandboxing structures. No telemetry logs are persisted after closing application threads.'}\n\n'
                          '${tr['privacy_consent'] ?? '4. Your Consent & Rights\nBy using our satellite cameras, weather overlays, and altimeter telemetry tools, you explicitly agree to our data practices mapped in this sheet. You can toggle off device sensor permissions anytime in system settings.'}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF374151),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Custom Interactive Smiley Star Widget ──
class _SmileyStar extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const _SmileyStar({
    required this.isSelected,
    required this.onTap,
    this.size = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: SmileyStarPainter(isSelected: isSelected),
        ),
      ),
    );
  }
}

// ── Custom Painter to Draw a Cute Star with Smiley Face ──
class SmileyStarPainter extends CustomPainter {
  final bool isSelected;

  SmileyStarPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the 5-point star path
    final path = Path();
    final double angle = math.pi / 5;
    for (int i = 0; i < 10; i++) {
      final double r = (i % 2 == 0) ? radius : radius * 0.43;
      final double currAngle = i * angle - math.pi / 2;
      final double x = center.dx + r * math.cos(currAngle);
      final double y = center.dy + r * math.sin(currAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    if (isSelected) {
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEE58), // Vibrant yellow
            Color(0xFFFFB300), // Rich amber/orange-yellow
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      final strokePaint = Paint()
        ..color = const Color(0xFFF57C00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, strokePaint);

      final eyePaint = Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.fill;

      final leftEyeCenter = Offset(center.dx - radius * 0.22, center.dy - radius * 0.08);
      final rightEyeCenter = Offset(center.dx + radius * 0.22, center.dy - radius * 0.08);
      
      canvas.drawCircle(leftEyeCenter, radius * 0.09, eyePaint);
      canvas.drawCircle(rightEyeCenter, radius * 0.09, eyePaint);

      final pupilShinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(leftEyeCenter - Offset(radius * 0.02, radius * 0.02), radius * 0.035, pupilShinePaint);
      canvas.drawCircle(rightEyeCenter - Offset(radius * 0.02, radius * 0.02), radius * 0.035, pupilShinePaint);

      final smilePaint = Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final smileRect = Rect.fromCenter(
        center: center + Offset(0, radius * 0.12),
        width: radius * 0.36,
        height: radius * 0.2,
      );
      canvas.drawArc(smileRect, 0, math.pi, false, smilePaint);
    } else {
      final outlinePaint = Paint()
        ..color = const Color(0xFFFFB300).withAlpha(178)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmileyStarPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected;
  }
}
