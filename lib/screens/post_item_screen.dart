import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class PostItemScreen extends StatefulWidget {
  final UserModel user;
  const PostItemScreen({super.key, required this.user});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _titleCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl     = TextEditingController();

  String  _type      = 'lost';
  String  _category  = 'ID Card';
  String? _imagePath;
  bool    _loading   = false;

  final _categories = [
    'ID Card', 'Bottle', 'Gadgets',
    'Keys', 'Bag', 'Books', 'Other'
  ];

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

  // ── Show bottom sheet to choose source ───────────
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Photo',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
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
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppTheme.accent),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit form ──────────────────────────────────
  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in title and location.'),
          backgroundColor: AppTheme.lostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final item = ItemModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      type: _type,
      category: _category,
      location: _locationCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imagePath: _imagePath,
      postedBy: widget.user.name,
      email: widget.user.email,
      date: DateTime.now()
          .toLocal()
          .toString()
          .split(' ')[0],
    );

    await StorageService.addItem(item);
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pop(context);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Lost / Found Toggle ──────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _toggleBtn('lost', '😢  I Lost It',
                      AppTheme.lostColor),
                  _toggleBtn('found', '🎉  I Found It',
                      AppTheme.foundColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Item Title ───────────────────────────
            _label('Item name *'),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Blue water bottle',
                prefixIcon:
                Icon(Icons.label_outline, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // ── Category ─────────────────────────────
            _label('Category *'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  icon: const Icon(
                      Icons.keyboard_arrow_down_rounded),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _category = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Location ─────────────────────────────
            _label('Last seen location *'),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Library Block B, 2nd floor',
                prefixIcon: Icon(Icons.location_on_outlined,
                    size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description ──────────────────────────
            _label('Description (optional)'),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                'Color, brand, any special marks...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // ── Photo Upload ─────────────────────────
            _label('Photo (optional) 📷'),
            GestureDetector(
              onTap: _showImageOptions,
              child: _imagePath == null
                  ? Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .add_photo_alternate_outlined,
                      size: 40,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add photo',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gallery or Camera',
                      style: TextStyle(
                        color: AppTheme.textMuted
                            .withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
                  : Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(14),
                    child: Image.file(
                      File(_imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Change photo button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Remove photo button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => setState(
                              () => _imagePath = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.lostColor
                              .withOpacity(0.85),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            _loading
                ? const Center(
                child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Submit Post'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(
      String value, String label, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    ),
  );
}