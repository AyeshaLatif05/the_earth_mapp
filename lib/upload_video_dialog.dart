import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class UploadVideoDialog extends StatefulWidget {
  const UploadVideoDialog({super.key});

  @override
  State<UploadVideoDialog> createState() => _UploadVideoDialogState();
}

class _UploadVideoDialogState extends State<UploadVideoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'United States');
  final TextEditingController _flagController = TextEditingController(text: '🇺🇸');
  final TextEditingController _urlController = TextEditingController();

  String _selectedCategory = 'Nature';
  File? _selectedVideoFile;
  VideoPlayerController? _videoPlayerController;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _categories = [
    'Nature',
    'City View',
    'Space',
    'Beaches',
    'Animals',
    'Traffic',
    'Concerts',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _countryController.dispose();
    _flagController.dispose();
    _urlController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 10),
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        _videoPlayerController?.dispose();
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        controller.setLooping(true);
        controller.play();

        setState(() {
          _selectedVideoFile = file;
          _videoPlayerController = controller;
          _urlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick video: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVideoFile == null && _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file or enter a stream URL')),
      );
      return;
    }

    final newCamera = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _titleController.text.trim(),
      'videoUrl': _selectedVideoFile?.path ?? _urlController.text.trim(),
      'imageUrl': 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=500&auto=format&fit=crop&q=80',
      'countryCode': 'US',
      'countryName': _countryController.text.trim(),
      'flagEmoji': _flagController.text.trim().isEmpty ? '🌐' : _flagController.text.trim(),
      'isFavorite': false,
      'category': _selectedCategory,
      'isLocalFile': _selectedVideoFile != null,
    };

    Navigator.pop(context, newCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upload Live Stream Video',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Video Preview or Picker Buttons
              if (_selectedVideoFile != null && _videoPlayerController != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio > 0
                        ? _videoPlayerController!.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedVideoFile = null;
                      _videoPlayerController?.dispose();
                      _videoPlayerController = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Remove Selected Video', style: TextStyle(color: Colors.red)),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A7A68),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : () => _pickVideo(ImageSource.gallery),
                        icon: const Icon(Icons.video_library),
                        label: const Text('From Gallery'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A7A68),
                          side: const BorderSide(color: Color(0xFF1A7A68)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : () => _pickVideo(ImageSource.camera),
                        icon: const Icon(Icons.videocam),
                        label: const Text('Record Video'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'OR Enter Video / Stream URL',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'e.g. https://example.com/stream.mp4',
                    labelText: 'Video Stream URL',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                decoration: InputDecoration(
                  labelText: 'Stream / Video Name',
                  hintText: 'e.g. Paris Beach Stream',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // Country & Flag fields
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: 'Country Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _flagController,
                      decoration: InputDecoration(
                        labelText: 'Flag',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7A68),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Add Video Stream',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
