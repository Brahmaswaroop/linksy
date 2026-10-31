import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/database/database.dart';
import '../../../core/engine/health_score_engine.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neo_palette.dart';
import '../../../core/utils/contact_action_helper.dart';

// ── 1. Top Bar with Karma Points & Action Pills ──────────────────────────────

class NeoTopBar extends StatelessWidget {
  final int karmaPoints;
  final bool isSyncing;
  final VoidCallback onSync;
  final VoidCallback onSearch;
  final VoidCallback onSettings;
  final VoidCallback onKarmaTap;

  const NeoTopBar({
    super.key,
    required this.karmaPoints,
    required this.isSyncing,
    required this.onSync,
    required this.onSearch,
    required this.onSettings,
    required this.onKarmaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // Karma Points Badge (Pill button with orange star)
          InkWell(
            onTap: onKarmaTap,
            borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: NeoPalette.surfaceWhite,
                borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                border: Border.all(color: NeoPalette.cardBorder),
                boxShadow: NeoPalette.shadowSoft,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF97316),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$karmaPoints karma',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NeoPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Search Icon Button (Circular Pill)
          _CircleIconButton(
            icon: LucideIcons.search,
            tooltip: 'Search Contacts',
            onTap: onSearch,
          ),
          const SizedBox(width: 8),
          // Sync / Notification Icon Button (with active dot)
          _CircleIconButton(
            icon: isSyncing ? LucideIcons.loader2 : LucideIcons.refreshCw,
            isLoading: isSyncing,
            tooltip: 'Sync Call Logs',
            showBadge: true,
            onTap: onSync,
          ),
          const SizedBox(width: 8),
          // Settings Icon Button
          _CircleIconButton(
            icon: LucideIcons.settings,
            tooltip: 'Settings',
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool showBadge;
  final bool isLoading;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showBadge = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: NeoPalette.surfaceWhite,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLoading ? null : onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeoPalette.cardBorder),
              boxShadow: NeoPalette.shadowSoft,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(icon, size: 18, color: NeoPalette.textPrimary),
                if (showBadge && !isLoading)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 2. Category Selector Cards (Mint, Sky, Lavender, Peach) ──────────────────

class NeoCategoryRow extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onSelectCategory;
  final Map<String, int> categoryCounts;
  final Map<String, int> overdueCounts;

  const NeoCategoryRow({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.categoryCounts,
    required this.overdueCounts,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryMeta(
        name: 'Friends',
        categoryKey: 'Friend',
        icon: LucideIcons.smile,
        bgColor: NeoPalette.mintBg,
        borderColor: NeoPalette.mintBorder,
        textColor: NeoPalette.mintText,
      ),
      _CategoryMeta(
        name: 'Work',
        categoryKey: 'Colleague',
        icon: LucideIcons.briefcase,
        bgColor: NeoPalette.skyBg,
        borderColor: NeoPalette.skyBorder,
        textColor: NeoPalette.skyText,
      ),
      _CategoryMeta(
        name: 'Family',
        categoryKey: 'Family',
        icon: LucideIcons.home,
        bgColor: NeoPalette.lavenderBg,
        borderColor: NeoPalette.lavenderBorder,
        textColor: NeoPalette.lavenderText,
      ),
      _CategoryMeta(
        name: 'VIPs',
        categoryKey: 'VIP',
        icon: LucideIcons.crown,
        bgColor: NeoPalette.peachBg,
        borderColor: NeoPalette.peachBorder,
        textColor: NeoPalette.peachText,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat.categoryKey;
          final count = categoryCounts[cat.categoryKey] ?? 0;
          final overdue = overdueCounts[cat.categoryKey] ?? 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  if (isSelected) {
                    onSelectCategory(null); // Deselect to show all
                  } else {
                    onSelectCategory(cat.categoryKey);
                  }
                },
                borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? cat.textColor : cat.bgColor,
                    borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
                    border: Border.all(
                      color: isSelected ? cat.textColor : cat.borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected ? NeoPalette.shadowCard : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge overlay if overdue
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            cat.icon,
                            size: 20,
                            color: isSelected ? Colors.white : cat.textColor,
                          ),
                          if (overdue > 0 && !isSelected)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoPalette.peachText,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$overdue',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : cat.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count people',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : cat.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryMeta {
  final String name;
  final String categoryKey;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _CategoryMeta({
    required this.name,
    required this.categoryKey,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}

// ── 3. Journey Reconnect Card (Transit Aesthetic) ───────────────────────────

class NeoReconnectTicketCard extends StatelessWidget {
  final Person person;
  final RelationshipTargetStatus status;
  final VoidCallback onTap;
  final VoidCallback onLog;

  const NeoReconnectTicketCard({
    super.key,
    required this.person,
    required this.status,
    required this.onTap,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final avatarBg = avatarColorFromName(person.name);
    final score = status.baseScore;
    final isOverdue = status.daysOverdue > 0;
    final isDueToday = status.daysOverdue == 0;

    String lastSpokeText = 'Never';
    if (person.lastInteractionDate != null) {
      lastSpokeText = timeago.format(person.lastInteractionDate!, locale: 'en_short');
    }

    final targetDays = person.targetFrequencyDays;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: NeoPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        border: Border.all(color: NeoPalette.cardBorder),
        boxShadow: NeoPalette.shadowCard,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row: Avatar + Name + Due Status Pill
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: avatarBg,
                      child: Text(
                        person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            person.category.isNotEmpty ? person.category : 'Connection',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: NeoPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOverdue || isDueToday
                            ? NeoPalette.peachBg
                            : NeoPalette.mintBg,
                        borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                        border: Border.all(
                          color: isOverdue || isDueToday
                              ? NeoPalette.peachBorder
                              : NeoPalette.mintBorder,
                        ),
                      ),
                      child: Text(
                        isDueToday
                            ? 'Due Today'
                            : isOverdue
                                ? '${status.daysOverdue}d overdue'
                                : 'in ${status.daysOverdue.abs()}d',
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
                const SizedBox(height: 16),

                // Transit Route Visualization (Last Contact ───💬─── Cadence Goal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: NeoPalette.canvasLight,
                    borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Origin (Last Spoke)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LAST SPOKE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lastSpokeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Dashed Transit Route Line with Center Icon
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
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: NeoPalette.surfaceWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: NeoPalette.cardBorder),
                                ),
                                child: const Icon(
                                  LucideIcons.messageCircle,
                                  size: 11,
                                  color: NeoPalette.skyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Destination (Target Frequency)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GOAL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Every ${targetDays}d',
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
                ),
                const SizedBox(height: 16),

                // Bottom Row: Health indicator & Pitch Black Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: healthColor(score),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$score% Health',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: NeoPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (person.phoneNumber != null &&
                            person.phoneNumber!.trim().isNotEmpty) ...[
                          IconButton.filled(
                            onPressed: () =>
                                ContactActionHelper.call(person.phoneNumber!),
                            icon: const Icon(LucideIcons.phone, size: 14),
                            style: IconButton.styleFrom(
                              backgroundColor: NeoPalette.skyBg,
                              foregroundColor: NeoPalette.skyText,
                              padding: const EdgeInsets.all(8),
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        // High-contrast Pitch Black Pill Button
                        InkWell(
                          onTap: onLog,
                          borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
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
                                  'Log',
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
              ],
            ),
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
      ..strokeWidth = 1.5;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
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

// ── 4. Conversation Sparks & Milestones (Fills Empty Space) ──────────────────

class NeoConversationSparksSection extends StatelessWidget {
  final List<Person> people;
  final Function(Person person) onOpenPerson;

  const NeoConversationSparksSection({
    super.key,
    required this.people,
    required this.onOpenPerson,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    // Generate contextual prompts based on people
    final prompts = <_SparkItem>[];

    for (final person in people) {
      if (person.birthday != null) {
        prompts.add(_SparkItem(
          person: person,
          title: 'Birthday Reminder 🎂',
          subtitle: "${person.name}'s special day is noted. Send them warm wishes!",
          gradientColors: const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          accentColor: const Color(0xFFE11D48),
          icon: LucideIcons.cake,
        ));
      } else if (person.notes != null && person.notes!.trim().isNotEmpty) {
        final snippet = person.notes!.split('\n').first;
        prompts.add(_SparkItem(
          person: person,
          title: 'Context Recall 💡',
          subtitle: "You noted: \"$snippet\" for ${person.name}. Follow up on this!",
          gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          accentColor: const Color(0xFF2563EB),
          icon: LucideIcons.sparkles,
        ));
      } else if (person.priorityLevel == 3) {
        prompts.add(_SparkItem(
          person: person,
          title: 'VIP Relationship 👑',
          subtitle: "${person.name} is a high-priority bond. A 5-minute check-in keeps it strong.",
          gradientColors: const [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
          accentColor: const Color(0xFF7C3AED),
          icon: LucideIcons.crown,
        ));
      }
    }

    if (prompts.isEmpty && people.isNotEmpty) {
      final p = people.first;
      prompts.add(_SparkItem(
        person: p,
        title: 'Reconnect Prompt 🌿',
        subtitle: "A quick hello to ${p.name} can brighten their day. Send a voice memo or text!",
        gradientColors: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        accentColor: const Color(0xFF059669),
        icon: LucideIcons.send,
      ));
    }

    final displayPrompts = prompts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conversation Sparks',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: NeoPalette.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${displayPrompts.length} ideas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NeoPalette.skyText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: displayPrompts.length,
            itemBuilder: (context, index) {
              final spark = displayPrompts[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: spark.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
                  border: Border.all(
                    color: spark.accentColor.withValues(alpha: 0.2),
                  ),
                  boxShadow: NeoPalette.shadowSoft,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
                    onTap: () => onOpenPerson(spark.person),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(spark.icon, size: 16, color: spark.accentColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  spark.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: spark.accentColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              spark.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: NeoPalette.textPrimary.withValues(alpha: 0.85),
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SparkItem {
  final Person person;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  _SparkItem({
    required this.person,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}

// ── 5. Health Pulse Summary Card (Bento Style) ──────────────────────────────

class NeoHealthPulseCard extends StatelessWidget {
  final int strong;
  final int neutral;
  final int fading;
  final int total;
  final double strongRatio;

  const NeoHealthPulseCard({
    super.key,
    required this.strong,
    required this.neutral,
    required this.fading,
    required this.total,
    required this.strongRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        border: Border.all(color: NeoPalette.cardBorder),
        boxShadow: NeoPalette.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: NeoPalette.mintBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.heartPulse,
                  size: 16,
                  color: NeoPalette.mintText,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network Health',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: NeoPalette.textPrimary,
                    ),
                  ),
                  Text(
                    '$total tracked bonds',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: NeoPalette.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: NeoPalette.mintBg,
                  borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                ),
                child: Text(
                  total == 0 ? '0%' : '${(strongRatio * 100).round()}% Strong',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NeoPalette.mintText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 3 Bento Stats
          Row(
            children: [
              _BentoStat(
                count: strong,
                label: 'Strong',
                emoji: '🟢',
                bgColor: NeoPalette.mintBg,
                textColor: NeoPalette.mintText,
              ),
              const SizedBox(width: 8),
              _BentoStat(
                count: neutral,
                label: 'Warning',
                emoji: '🟡',
                bgColor: NeoPalette.amberBg,
                textColor: NeoPalette.amberText,
              ),
              const SizedBox(width: 8),
              _BentoStat(
                count: fading,
                label: 'Overdue',
                emoji: '🔴',
                bgColor: NeoPalette.peachBg,
                textColor: NeoPalette.peachText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Clean Pill Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0.0 : strongRatio,
              backgroundColor: NeoPalette.canvasLight,
              valueColor: const AlwaysStoppedAnimation<Color>(NeoPalette.mintText),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoStat extends StatelessWidget {
  final int count;
  final String label;
  final String emoji;
  final Color bgColor;
  final Color textColor;

  const _BentoStat({
    required this.count,
    required this.label,
    required this.emoji,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
