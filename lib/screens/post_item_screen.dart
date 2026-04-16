import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item_model.dart';
import '../services/storage_service.dart';
import 'dart:io';

import '../theme.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _type = 'lost';
  String? _imagePath;
  bool _loading = false;

  // ── Pick image from gallery ──────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1000,
    );
    if (xFile != null) {
      setState(() => _imagePath = xFile.path);
    }
  }

  // ── Pick image from camera ───────────────────────
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1000,
    );
    if (xFile != null) {
      setState(() => _imagePath = xFile.path);
    }
  }

  // ── Bottom sheet ─────────────────────────────────
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Photo',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _imageOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _imageOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppTheme.accent),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SUBMIT FUNCTION (LOCAL STORAGE) ─────────────
  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final user = await StorageService.getSession();
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final item = ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        type: _type,
        category: 'Other', // default category
        location: _locationCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imagePath: _imagePath,
        postedBy: user.name,
        email: user.email,
        date: DateTime.now().toIso8601String(),
      );

      await StorageService.addItem(item);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item posted successfully ✅')),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Item name',
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                hintText: 'Location',
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _showImageOptions,
              child: _imagePath == null
                  ? Container(
                height: 120,
                color: Colors.grey[200],
                child: const Center(child: Text("Add Image")),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_imagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}