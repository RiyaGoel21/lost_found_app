import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'post_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ItemModel> _allItems = [];
  String _typeFilter = 'all';
  String _catFilter  = 'All';
  bool _loading = true;

  final _categories = [
    'All', 'ID Card', 'Bottle', 'Gadgets',
    'Keys', 'Bag', 'Books', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final items = await StorageService.getItems();
    setState(() {
      _allItems = items;
      _loading  = false;
    });
  }

  List<ItemModel> get _filtered => _allItems.where((item) {
    final typeOk = _typeFilter == 'all' || item.type == _typeFilter;
    final catOk  = _catFilter == 'All' || item.category == _catFilter;
    return typeOk && catOk;
  }).toList();

  Future<void> _logout() async {
    await StorageService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          // ── Collapsing Header ─────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _logout,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey, ${widget.user.name.split(' ').first} 👋',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Campus Board',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter Row ────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.bgLight,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Type filter (All / Lost / Found)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _typeChip('all', 'All', AppTheme.primary),
                        const SizedBox(width: 8),
                        _typeChip('lost', '😢 Lost', AppTheme.lostColor),
                        const SizedBox(width: 8),
                        _typeChip(
                            'found', '🎉 Found', AppTheme.foundColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category filter chips (scrollable)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                      itemBuilder: (_, i) =>
                          _catChip(_categories[i]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],

        // ── Items Grid ────────────────────────────────
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
            ? _emptyState()
            : RefreshIndicator(
          onRefresh: _loadItems,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.75,
            ),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _ItemCard(
              item: _filtered[i],
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(
                      item: _filtered[i],
                    ),
                  ),
                );
                _loadItems();
              },
            ),
          ),
        ),
      ),

      // ── Floating Action Button ────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostItemScreen(user: widget.user),
            ),
          );
          _loadItems();
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Post Item',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          'Nothing posted yet',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap + to post a lost or found item',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    ),
  );

  Widget _typeChip(String value, String label, Color color) {
    final selected = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : const Color(0xFFE2E8F0),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _catChip(String label) {
    final selected = _catFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _catFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.accent
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
            selected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Item Card Widget ─────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  const _ItemCard({required this.item, required this.onTap});

  static const _emojis = {
    'ID Card': '🪪',
    'Bottle': '💧',
    'Gadgets': '🎧',
    'Keys': '🔑',
    'Bag': '🎒',
    'Books': '📚',
    'Other': '📦',
  };

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == 'lost';
    final accent = isLost ? AppTheme.lostColor : AppTheme.foundColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / Emoji area ─────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              child: item.imagePath != null &&
                  File(item.imagePath!).existsSync()
                  ? Image.file(
                File(item.imagePath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 120,
                width: double.infinity,
                color: accent.withOpacity(0.07),
                child: Center(
                  child: Text(
                    _emojis[item.category] ?? '📦',
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
            ),

            // ── Info ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLost ? 'LOST' : 'FOUND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}