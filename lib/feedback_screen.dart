import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firebase_service.dart';
import 'providers/language_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final Color _primaryColor = const Color(0xFF1E7E6C);
  final TextEditingController _feedbackController = TextEditingController();

  // Selected issue tag - matches the mockup's selected default (English key)
  String _selectedTag = 'Map not working';

  // Available feedback category tags (English keys)
  final List<String> _tags = [
    'Map not working',
    'Live Location not working',
    'Features & Tools',
    'Sensors not working',
    'App crash',
    'Can not watch street view',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // Handle feedback submission
  void _submitFeedback() async {
    final tr = ref.read(translationProvider);
    // Hide keyboard if open
    FocusScope.of(context).unfocus();

    final category = _selectedTag;
    final content = _feedbackController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr['enter_feedback_content'] ?? 'Please enter some feedback content before submitting.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E7E6C),
        ),
      ),
    );

    try {
      await FirebaseService.instance.submitFeedback(category, content);
      if (mounted) Navigator.pop(context); // Dismiss loading spinner
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading spinner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr['failed_submit_feedback'] ?? 'Failed to submit feedback: '}$e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Show premium bottom sheet acknowledging submission
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Teal Checkmark Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: _primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tr['feedback_submitted'] ?? 'Feedback Submitted!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr['feedback_submitted_desc'] ?? 'Thank you for helping us improve Explore Earth! Our engineering team will review your report immediately.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                // Done button to close and navigate back
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pop(context); // Go back to settings screen
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
                      tr['done'] ?? 'Done',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr['feedback'] ?? 'Feedback',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle Instruction Text
                        Text(
                          tr['tell_us_problem'] ?? 'Tell us about the problem you encountered and we will try our best to solve it',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // List of Selectable Issue Pills/Tags using Wrap
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _tags.map((tag) {
                            final isSelected = tag == _selectedTag;
                            String displayTag = tag;
                            if (tag == 'Map not working') displayTag = tr['map_not_working'] ?? tag;
                            if (tag == 'Live Location not working') displayTag = tr['live_location_not_working'] ?? tag;
                            if (tag == 'Features & Tools') displayTag = tr['features_tools'] ?? tag;
                            if (tag == 'Sensors not working') displayTag = tr['sensors_not_working'] ?? tag;
                            if (tag == 'App crash') displayTag = tr['app_crash'] ?? tag;
                            if (tag == 'Can not watch street view') displayTag = tr['cannot_watch_street_view'] ?? tag;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTag = tag;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected
                                      ? Border.all(color: _primaryColor, width: 1.8)
                                      : null,
                                ),
                                child: Text(
                                  displayTag,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: const Color(0xFF111111),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Text Feedback Box Container
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _feedbackController,
                            maxLines: 8,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Color(0xFF111111),
                            ),
                            decoration: InputDecoration(
                              hintText: tr['tell_feedback_here'] ?? 'Tell us your feedback here',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                    // Submit Button at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            tr['submit'] ?? 'Submit',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
