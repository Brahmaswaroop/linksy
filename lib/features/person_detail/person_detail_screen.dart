import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/database/database.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/interactions_repository.dart';
import '../../core/database/repositories/labels_repository.dart';
import '../../core/engine/health_score_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/utils/contact_action_helper.dart';
import '../../core/services/call_log_sync_service.dart';
import '../interactions/log_interaction_screen.dart';

class PersonDetailScreen extends ConsumerStatefulWidget {
  final int personId;
  const PersonDetailScreen({super.key, required this.personId});

  @override
  ConsumerState<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends ConsumerState<PersonDetailScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(callLogSyncServiceProvider).syncCallLogs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(callLogSyncServiceProvider).syncCallLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personStreamProvider(widget.personId));
    final interactionsAsync =
        ref.watch(personInteractionsProvider(widget.personId));
    final engine = ref.watch(healthScoreEngineProvider);
    final labelsAsync = ref.watch(labelsForPersonProvider(widget.personId));

    return Scaffold(
      backgroundColor: NeoPalette.canvasLight,
      body: SafeArea(
        child: personAsync.when(
          data: (person) {
            final status = engine.calculateHealth(
              targetFrequencyDays: person.targetFrequencyDays,
              lastInteractionDate: person.lastInteractionDate,
              priorityLevel: person.priorityLevel,
              averageGapDays: person.averageGapDays,
              createdAt: person.createdAt,
            );

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(callLogSyncServiceProvider).syncCallLogs(),
              child: CustomScrollView(
                slivers: [
                  // ── 1. Top Bar ─────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircularNavButton(
                            icon: LucideIcons.arrowLeft,
                            tooltip: 'Back',
                            onTap: () => context.pop(),
                          ),
                          Text(
                            'Relationship Pass',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              _CircularNavButton(
                                icon: LucideIcons.refreshCw,
                                tooltip: 'Sync Call Logs',
                                onTap: () async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  final result = await ref
                                      .read(callLogSyncServiceProvider)
                                      .syncCallLogs();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.syncedInteractionsCount > 0
                                            ? 'Synced ${result.syncedInteractionsCount} new call(s)'
                                            : 'Call history is up to date',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            NeoPalette.radiusPill),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _CircularNavButton(
                                icon: LucideIcons.edit,
                                tooltip: 'Edit Person',
                                onTap: () => context
                                    .go('/people/${widget.personId}/edit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 2. The Boarding Pass Ticket Container ──────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _RelationshipBoardingPass(
                        person: person,
                        status: status,
                        labelsAsync: labelsAsync,
                      ),
                    ),
                  ),

                  // ── 3. Quick Action Buttons ────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          if (person.phoneNumber != null &&
                              person.phoneNumber!.trim().isNotEmpty) ...[
                            _CircleActionBtn(
                              icon: LucideIcons.phone,
                              tooltip: 'Call ${person.name}',
                              color: NeoPalette.skyText,
                              bgColor: NeoPalette.skyBg,
                              onTap: () => ContactActionHelper.call(
                                  person.phoneNumber!),
                            ),
                            const SizedBox(width: 8),
                            _CircleActionBtn(
                              icon: LucideIcons.messageSquare,
                              tooltip: 'SMS',
                              color: NeoPalette.mintText,
                              bgColor: NeoPalette.mintBg,
                              onTap: () =>
                                  ContactActionHelper.sms(person.phoneNumber!),
                            ),
                            const SizedBox(width: 8),
                            _CircleActionBtn(
                              icon: LucideIcons.messageCircle,
                              tooltip: 'WhatsApp',
                              color: const Color(0xFF16A34A),
                              bgColor: const Color(0xFFDCFCE7),
                              onTap: () => ContactActionHelper.openWhatsApp(
                                  person.phoneNumber!),
                            ),
                            const SizedBox(width: 10),
                          ],
                          // Full-Width Pitch-Black Pill CTA: [ Log Interaction ✨ ]
                          Expanded(
                            child: InkWell(
                              onTap: () => context
                                  .go('/people/${widget.personId}/log'),
                              borderRadius:
                                  BorderRadius.circular(NeoPalette.radiusPill),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: NeoPalette.inkBlack,
                                  borderRadius: BorderRadius.circular(
                                      NeoPalette.radiusPill),
                                  boxShadow: NeoPalette.shadowCard,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      LucideIcons.plusCircle,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Log Interaction ✨',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 4. Notes Section (if any) ──────────────────────────────
                  if (person.notes != null && person.notes!.trim().isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: NeoPalette.surfaceWhite,
                            borderRadius:
                                BorderRadius.circular(NeoPalette.radiusCard),
                            border: Border.all(color: NeoPalette.cardBorder),
                            boxShadow: NeoPalette.shadowSoft,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.bookmark,
                                    size: 14,
                                    color: NeoPalette.skyText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'RELATIONSHIP NOTES',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: NeoPalette.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                person.notes!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: NeoPalette.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── 5. Timeline Header ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Interaction History',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: NeoPalette.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Recent Logs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NeoPalette.skyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 6. Timeline List ───────────────────────────────────────
                  interactionsAsync.when(
                    data: (interactions) {
                      if (interactions.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: NeoPalette.skyBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.messageSquareDashed,
                                      size: 24,
                                      color: NeoPalette.skyText,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No interactions logged yet.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: NeoPalette.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap "Log Interaction" above to record your first conversation.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: NeoPalette.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final interaction = interactions[index];
                              return _NeoTimelineItem(
                                interaction: interaction,
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LogInteractionScreen(
                                        personId: widget.personId,
                                        existingInteraction: interaction,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: interactions.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => SliverToBoxAdapter(
                      child: Center(child: Text('Error: $err')),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading contact: $err')),
        ),
      ),
    );
  }
}

// ── The Boarding Pass Ticket Widget ────────────────────────────────────────

class _RelationshipBoardingPass extends StatelessWidget {
  final Person person;
  final RelationshipTargetStatus status;
  final AsyncValue<List<Label>> labelsAsync;

  const _RelationshipBoardingPass({
    required this.person,
    required this.status,
    required this.labelsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final avatarBg = avatarColorFromName(person.name);
    final score = status.baseScore;
    final hColor = healthColor(score);
    final priorityLabel = person.priorityLevel == 3
        ? 'VIP'
        : person.priorityLevel == 2
            ? 'Medium'
            : 'Low';

    String lastContactStr = 'Never';
    if (person.lastInteractionDate != null) {
      lastContactStr =
          timeago.format(person.lastInteractionDate!, locale: 'en_short');
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: NeoPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        border: Border.all(color: NeoPalette.cardBorder),
        boxShadow: NeoPalette.shadowCard,
      ),
        child: Column(
          children: [
            // ── TOP PASS SECTION ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  // Pass Header: Logo / Pass Type + Carrier
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: NeoPalette.mintBg,
                          borderRadius:
                              BorderRadius.circular(NeoPalette.radiusPill),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.sparkles,
                                size: 10, color: NeoPalette.mintText),
                            const SizedBox(width: 4),
                            Text(
                              'LINKPASS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: NeoPalette.mintText,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        person.category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: NeoPalette.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar & Name Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
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
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: NeoPalette.textPrimary,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              person.relation != null &&
                                      person.relation!.isNotEmpty
                                  ? person.relation!
                                  : '${person.category} Connection',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: NeoPalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Transit Journey Indicator (CGK 06:40 ───✈️─── DPS 09:25)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: NeoPalette.canvasLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: NeoPalette.surfaceWhite,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: NeoPalette.cardBorder),
                                  ),
                                  child: const Icon(
                                    LucideIcons.heartHandshake,
                                    size: 12,
                                    color: NeoPalette.skyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TARGET CADENCE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Every ${person.targetFrequencyDays}d',
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

                  // 3 Large Bento Badges (Like Gate G2, Terminal, Seat)
                  Row(
                    children: [
                      // Badge 1: Health Score (Gate G2 style)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: NeoPalette.mintBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NeoPalette.mintBorder),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'HEALTH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: NeoPalette.mintText,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$score%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: hColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge 2: Priority
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: NeoPalette.lavenderBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NeoPalette.lavenderBorder),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'PRIORITY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: NeoPalette.lavenderText,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                priorityLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: NeoPalette.lavenderText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge 3: Due Status
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: status.daysOverdue > 0
                                ? NeoPalette.peachBg
                                : NeoPalette.skyBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: status.daysOverdue > 0
                                  ? NeoPalette.peachBorder
                                  : NeoPalette.skyBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'STATUS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: status.daysOverdue > 0
                                      ? NeoPalette.peachText
                                      : NeoPalette.skyText,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                status.daysOverdue > 0
                                    ? '${status.daysOverdue}d Late'
                                    : 'On Track',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: status.daysOverdue > 0
                                      ? NeoPalette.peachText
                                      : NeoPalette.skyText,
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

            // ── PERFORATION CUTOUT (Dashed separator line with side notches) ──
            Row(
              children: [
                Transform.translate(
                  offset: const Offset(-10, 0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: NeoPalette.canvasLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 2),
                    painter: _DashedLinePainter(
                      color: NeoPalette.cardBorder,
                      dashWidth: 6,
                      dashSpace: 4,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(10, 0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: NeoPalette.canvasLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            // ── BOTTOM PASS SECTION (Passenger Details & Barcode) ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PASSENGER (CONTACT)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            person.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PHONE / CHANNEL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            person.phoneNumber?.isNotEmpty == true
                                ? person.phoneNumber!
                                : 'No phone linked',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NeoPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Connection Barcode Graphic
                  CustomPaint(
                    size: const Size(double.infinity, 38),
                    painter: _BarcodePainter(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LNKSY-PASS-${person.id.toString().padLeft(6, '0')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: NeoPalette.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

// ── Timeline Item Card ─────────────────────────────────────────────────────

class _NeoTimelineItem extends StatelessWidget {
  final Interaction interaction;
  final VoidCallback onEdit;

  const _NeoTimelineItem({
    required this.interaction,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final typeIcon = _iconForType(interaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: NeoPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
        border: Border.all(color: NeoPalette.cardBorder),
        boxShadow: NeoPalette.shadowSoft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(NeoPalette.radiusSm),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: NeoPalette.skyBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, size: 16, color: NeoPalette.skyText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            interaction.type,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                          ),
                          Text(
                            timeago.format(interaction.date, locale: 'en_short'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: NeoPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (interaction.notes != null &&
                          interaction.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          interaction.notes!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: NeoPalette.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (interaction.energyRating != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                            Text(
                              'Energy: ${interaction.energyRating}/5',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NeoPalette.skyText,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  static IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return LucideIcons.phone;
      case 'meeting':
        return LucideIcons.coffee;
      case 'note':
        return LucideIcons.fileText;
      default:
        return LucideIcons.messageCircle;
    }
  }
}

// ── Painters for Boarding Pass ─────────────────────────────────────────────

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoPalette.inkBlack
      ..style = PaintingStyle.fill;

    // Deterministic bar widths pattern for realistic barcode
    final pattern = [
      2, 1, 3, 1, 1, 2, 4, 1, 2, 1, 3, 2, 1, 4, 1, 2, 1, 3, 1, 2, 4, 1, 1, 2,
      3, 1, 2, 1, 4, 2, 1, 3, 1, 2, 1, 4, 1, 2, 3, 1, 1, 2, 4, 1, 2, 1, 3, 2
    ];

    double currentX = 10;
    for (int i = 0; i < pattern.length; i++) {
      final width = pattern[i].toDouble();
      if (i % 2 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(currentX, 0, width, size.height),
            const Radius.circular(1),
          ),
          paint,
        );
      }
      currentX += width + 2.5;
      if (currentX >= size.width - 15) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;

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

class _CircularNavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircularNavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: NeoPalette.surfaceWhite,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeoPalette.cardBorder),
              boxShadow: NeoPalette.shadowSoft,
            ),
            child: Icon(icon, size: 18, color: NeoPalette.textPrimary),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
