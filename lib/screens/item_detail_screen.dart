import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../theme.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

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
    final firstName = item.postedBy.split(' ').first;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Image App Bar ─────────────────────
          SliverAppBar(
            expandedHeight:
            item.imagePath != null ? 300 : 180,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imagePath != null &&
                  File(item.imagePath!).existsSync()
                  ? Image.file(
                File(item.imagePath!),
                fit: BoxFit.cover,
              )
                  : Container(
                color: accent.withOpacity(0.15),
                child: Center(
                  child: Text(
                    _emojis[item.category] ?? '📦',
                    style: const TextStyle(
                        fontSize: 80),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // Badges row
                  Row(
                    children: [
                      _badge(
                        isLost ? 'LOST' : 'FOUND',
                        accent,
                      ),
                      const SizedBox(width: 8),
                      _badge(item.category,
                          const Color(0xFF64748B)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info rows
                  _infoRow(
                    Icons.location_on_rounded,
                    item.location,
                    accent,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.calendar_today_rounded,
                    item.date,
                    accent,
                  ),

                  // Description
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // Posted by card
                  Text(
                    'Posted by',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              item.postedBy[0]
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.postedBy,
                                style: GoogleFonts
                                    .plusJakartaSans(
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 15,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contact: ${item.email}',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          action: SnackBarAction(
                            label: 'OK',
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                    ),
                    icon: const Icon(
                        Icons.mail_outline_rounded,
                        size: 18),
                    label: Text('Contact $firstName'),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _infoRow(
      IconData icon, String text, Color color) =>
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
            Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
}