import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/database/database.dart';
import '../../../core/database/repositories/labels_repository.dart';
import '../../../core/engine/health_score_engine.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neo_palette.dart';
import '../../../core/utils/contact_action_helper.dart';

class PersonCard extends ConsumerWidget {
  final Person person;
  final RelationshipTargetStatus status;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  const PersonCard({
    super.key,
    required this.person,
    required this.status,
    required this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarBg = avatarColorFromName(person.name);
    final score = status.baseScore;
    final isOverdue = status.daysOverdue > 0;
    final isDueToday = status.daysOverdue == 0;
    final labelsAsync = ref.watch(labelsForPersonProvider(person.id));

    String lastContactStr = 'Never';
    if (person.lastInteractionDate != null) {
      lastContactStr = timeago.format(person.lastInteractionDate!, locale: 'en_short');
    }

    String nextDueStr;
    if (isOverdue) {
      nextDueStr = '${status.daysOverdue}d overdue';
    } else if (isDueToday) {
      nextDueStr = 'Due Today';
    } else {
      nextDueStr = 'in ${status.daysOverdue.abs()}d';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? NeoPalette.skyBg.withValues(alpha: 0.5)
              : NeoPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          border: Border.all(
            color: isSelected ? NeoPalette.skyText : NeoPalette.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: NeoPalette.shadowCard,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Top Row: Avatar + Name + Category + Favorite ────────
                  Row(
                    children: [
                      if (isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => onTap(),
                            activeColor: NeoPalette.inkBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      // Avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: avatarBg,
                        backgroundImage: person.avatarPath != null
                            ? FileImage(File(person.avatarPath!))
                            : null,
                        child: person.avatarPath == null
                            ? Text(
                                person.name.isNotEmpty
                                    ? person.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Name & Relation
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: NeoPalette.textPrimary,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              person.relation != null &&
                                      person.relation!.isNotEmpty
                                  ? '${person.category} • ${person.relation}'
                                  : person.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: NeoPalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Priority / Due Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue || isDueToday
                              ? NeoPalette.peachBg
                              : NeoPalette.mintBg,
                          borderRadius:
                              BorderRadius.circular(NeoPalette.radiusPill),
                          border: Border.all(
                            color: isOverdue || isDueToday
                                ? NeoPalette.peachBorder
                                : NeoPalette.mintBorder,
                          ),
                        ),
                        child: Text(
                          nextDueStr,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOverdue || isDueToday
                                ? NeoPalette.peachText
                                : NeoPalette.mintText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Optional Labels / Tags
                  labelsAsync.when(
                    data: (labels) {
                      if (labels.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: labels.map((l) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeoPalette.lavenderBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: NeoPalette.lavenderBorder,
                                ),
                              ),
                              child: Text(
                                l.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: NeoPalette.lavenderText,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 14),

                  // ── 2. Transit Journey Timeline Row (Origin ───✈️─── Destination) ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: NeoPalette.canvasLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Last Contact
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LAST CONTACT',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lastContactStr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        // Middle: Dashed Transit Line with Central Pill
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(double.infinity, 2),
                                  painter: _DashedLinePainter(
                                    color: NeoPalette.cardBorder,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NeoPalette.surfaceWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: NeoPalette.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.repeat,
                                        size: 10,
                                        color: NeoPalette.skyText,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${person.targetFrequencyDays}d',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: NeoPalette.skyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right: Status Health %
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'HEALTH SCORE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: healthColor(score),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$score%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NeoPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 3. Bottom Row: Quick Action Chips & Pitch-Black Button ─
                  Row(
                    children: [
                      // Quick Channel Call / WhatsApp Icons
                      if (person.phoneNumber != null &&
                          person.phoneNumber!.trim().isNotEmpty) ...[
                        _CircleActionBtn(
                          icon: LucideIcons.phone,
                          tooltip: 'Call',
                          color: NeoPalette.skyText,
                          bgColor: NeoPalette.skyBg,
                          onTap: () =>
                              ContactActionHelper.call(person.phoneNumber!),
                        ),
                        const SizedBox(width: 6),
                        _CircleActionBtn(
                          icon: LucideIcons.messageCircle,
                          tooltip: 'WhatsApp',
                          color: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                          onTap: () => ContactActionHelper.openWhatsApp(
                            person.phoneNumber!,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Energy Vibe Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NeoPalette.lavenderBg,
                          borderRadius:
                              BorderRadius.circular(NeoPalette.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 3),
                            Text(
                              person.priorityLevel == 3
                                  ? 'VIP Bond'
                                  : 'Regular',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.lavenderText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // High-Contrast Pitch Black Pill Button: [ Log Note ]
                      InkWell(
                        onTap: () => context.go('/people/${person.id}/log'),
                        borderRadius:
                            BorderRadius.circular(NeoPalette.radiusPill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: NeoPalette.inkBlack,
                            borderRadius:
                                BorderRadius.circular(NeoPalette.radiusPill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.plus,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Log Note',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CircleActionBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;

    const dashWidth = 3.5;
    const dashSpace = 2.5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
