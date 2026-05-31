import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final Color _primaryColor = const Color(0xFF1E7E6C);
  final TextEditingController _feedbackController = TextEditingController();

  // Selected issue tag - matches the mockup's selected default
  String _selectedTag = 'Map not working';

  // Available feedback category tags
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
  void _submitFeedback() {
    // Hide keyboard if open
    FocusScope.of(context).unfocus();

    // Show premium bottom sheet acknowledging submission
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
                const Text(
                  'Feedback Submitted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thank you for helping us improve Explore Earth! Our engineering team will review your report immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                    child: const Text(
                      'Done',
                      style: TextStyle(
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
        title: const Text(
          'Feedback',
          style: TextStyle(
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
                        const Text(
                          'Tell us about the problem you encountered and we will try our best to solve it',
                          style: TextStyle(
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
                                  tag,
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
                            decoration: const InputDecoration(
                              hintText: 'Tell us your feedback here',
                              hintStyle: TextStyle(
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
                          child: const Text(
                            'Submit',
                            style: TextStyle(
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
