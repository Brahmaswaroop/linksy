import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/interactions_repository.dart';
import '../../core/engine/health_score_engine.dart';
import '../../core/database/database.dart';
import '../../core/services/call_log_sync_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neo_palette.dart';
import '../people/widgets/bulk_import_sheet.dart';
import 'widgets/neo_dashboard_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSyncing = false;
  String? _selectedCategory;

  void _openBulkImportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BulkImportSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _syncCallLogs(showFeedback: false);
      final people = await ref.read(peopleRepositoryProvider).getAllPeople();
      final prefs = await SharedPreferences.getInstance();
      final hasSeenPrompt =
          prefs.getBool('has_prompted_contacts_onboarding') ?? false;
      if (people.isEmpty && !hasSeenPrompt && mounted) {
        await prefs.setBool('has_prompted_contacts_onboarding', true);
        _openBulkImportSheet();
      }
    });
  }

  Future<void> _syncCallLogs({bool showFeedback = false}) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final syncService = ref.read(callLogSyncServiceProvider);
      final result = await syncService.syncCallLogs();

      if (mounted && showFeedback) {
        final message = result.syncedInteractionsCount > 0
            ? 'Synced ${result.syncedInteractionsCount} calls with ${result.updatedContactNames.join(", ")}'
            : 'Call history is up to date';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showKarmaDialog(int points, int strongBonds) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          ),
          backgroundColor: NeoPalette.surfaceWhite,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Relationship Karma',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: NeoPalette.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have $points Karma Points!',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: NeoPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Karma reflects your relationship consistency. Earn points by logging interactions on time and keeping bonds in the green zone ($strongBonds strong bonds currently active).',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: NeoPalette.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Going 🚀',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: NeoPalette.textPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(allPeopleProvider);
    final engine = ref.watch(healthScoreEngineProvider);

    return Scaffold(
      backgroundColor: NeoPalette.canvasLight,
      body: SafeArea(
        child: peopleAsync.when(
          data: (people) {
            int strong = 0;
            int neutral = 0;
            int fading = 0;

            final categoryCounts = <String, int>{};
            final overdueCounts = <String, int>{};
            final needsAttention = <Map<String, dynamic>>[];

            for (final person in people) {
              final status = engine.calculateHealth(
                targetFrequencyDays: person.targetFrequencyDays,
                lastInteractionDate: person.lastInteractionDate,
                priorityLevel: person.priorityLevel,
                averageGapDays: person.averageGapDays,
                createdAt: person.createdAt,
              );

              // Category count
              final cat = person.category.isNotEmpty ? person.category : 'Other';
              categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;

              if (status.statusEmoji == '🟢') {
                strong++;
              } else if (status.statusEmoji == '🟡') {
                neutral++;
              } else {
                fading++;
                overdueCounts[cat] = (overdueCounts[cat] ?? 0) + 1;
              }

              // Filter needs attention
              final isOverdueOrUpcoming =
                  status.statusEmoji == '🔴' || status.daysOverdue >= -2;
              if (isOverdueOrUpcoming) {
                if (_selectedCategory == null ||
                    person.category.toLowerCase() ==
                        _selectedCategory!.toLowerCase()) {
                  needsAttention.add({'person': person, 'status': status});
                }
              }
            }

            // Sort needs attention: highest overdue first
            needsAttention.sort((a, b) {
              final statusA = a['status'] as RelationshipTargetStatus;
              final statusB = b['status'] as RelationshipTargetStatus;
              final cmp = statusB.daysOverdue.compareTo(statusA.daysOverdue);
              if (cmp != 0) return cmp;
              return statusB.totalScoreWithPriority.compareTo(
                statusA.totalScoreWithPriority,
              );
            });

            final total = people.length;
            final strongRatio = total == 0 ? 0.0 : strong / total;
            final karma = (strong * 40) + (neutral * 15) + (total * 10);

            return RefreshIndicator(
              onRefresh: () => _syncCallLogs(showFeedback: true),
              child: CustomScrollView(
                slivers: [
                  // ── 1. Neo Top Bar (Karma Points, Search, Sync, Settings) ──
                  SliverToBoxAdapter(
                    child: NeoTopBar(
                      karmaPoints: karma,
                      isSyncing: _isSyncing,
                      onSync: () => _syncCallLogs(showFeedback: true),
                      onSearch: () => context.go('/people'),
                      onSettings: () => context.push('/settings'),
                      onKarmaTap: () => _showKarmaDialog(karma, strong),
                    ),
                  ),

                  // ── 2. Hero Headline (Relationships Made Effortless) ─────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Relationships\nMade Effortless',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: NeoPalette.textPrimary,
                              height: 1.15,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nurture your circle with zero friction.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: NeoPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 3. Pastel Category Bento Pills ──────────────────────────
                  SliverToBoxAdapter(
                    child: NeoCategoryRow(
                      selectedCategory: _selectedCategory,
                      onSelectCategory: (cat) {
                        setState(() => _selectedCategory = cat);
                      },
                      categoryCounts: categoryCounts,
                      overdueCounts: overdueCounts,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ── 4. Priority Reconnects Section Header ────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Priority Reconnects',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: NeoPalette.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (_selectedCategory != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NeoPalette.mintBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _selectedCategory!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: NeoPalette.mintText,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.go('/people'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'View All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.skyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ── 5. Horizontal Reconnect Ticket Cards (Transit Style) ────
                  if (people.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: _WelcomeEmptyDashboardCard(
                          onImport: _openBulkImportSheet,
                        ),
                      ),
                    )
                  else if (needsAttention.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: NeoPalette.surfaceWhite,
                          borderRadius:
                              BorderRadius.circular(NeoPalette.radiusCard),
                          border: Border.all(color: NeoPalette.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: NeoPalette.mintBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.checkCheck,
                                color: NeoPalette.mintText,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All bonds are caught up! 🎉',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: NeoPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedCategory != null
                                        ? 'No overdue contacts in $_selectedCategory'
                                        : 'Every relationship in your network is healthy.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: NeoPalette.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 215,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: needsAttention.length,
                          itemBuilder: (context, index) {
                            final item = needsAttention[index];
                            final person = item['person'] as Person;
                            final status =
                                item['status'] as RelationshipTargetStatus;
                            return NeoReconnectTicketCard(
                              person: person,
                              status: status,
                              onTap: () => context.go('/people/${person.id}'),
                              onLog: () =>
                                  context.go('/people/${person.id}/log'),
                            );
                          },
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ── 6. Conversation Sparks Section (Recommendations) ────────
                  SliverToBoxAdapter(
                    child: NeoConversationSparksSection(
                      people: people,
                      onOpenPerson: (person) {
                        context.go('/people/${person.id}');
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ── 7. Network Health Bento Pulse ────────────────────────────
                  SliverToBoxAdapter(
                    child: NeoHealthPulseCard(
                      strong: strong,
                      neutral: neutral,
                      fading: fading,
                      total: total,
                      strongRatio: strongRatio,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ── 8. Recently Contacted Section ────────────────────────────
                  SliverToBoxAdapter(child: _RecentlyContactedSection()),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading data: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: NeoPalette.inkBlack,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (sheetContext) {
              return DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (_, scrollController) {
                  return _LogInteractionSheet(
                    scrollController: scrollController,
                  );
                },
              );
            },
          );
        },
        icon: const Icon(LucideIcons.plusCircle, size: 18),
        label: Text(
          'Quick Log',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Recently Contacted Section ─────────────────────────────────────────────

class _RecentlyContactedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentlyContactedPeopleProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Contacted',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: NeoPalette.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          recentAsync.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No interactions logged yet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: NeoPalette.textSecondary,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: contacts.take(5).map((contact) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
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
                        onTap: () => context.go('/people/${contact.personId}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    avatarColorFromName(contact.personName),
                                child: Text(
                                  contact.personName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.personName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: NeoPalette.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          _iconForType(contact.type),
                                          size: 11,
                                          color: NeoPalette.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          contact.type,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: NeoPalette.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                timeago.format(contact.date, locale: 'en_short'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: NeoPalette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
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

// ── Log Interaction Sheet ────────────────────────────────────────────────

class _LogInteractionSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _LogInteractionSheet({required this.scrollController});

  @override
  ConsumerState<_LogInteractionSheet> createState() =>
      _LogInteractionSheetState();
}

class _LogInteractionSheetState extends ConsumerState<_LogInteractionSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(allPeopleProvider);

    return Container(
      decoration: const BoxDecoration(
        color: NeoPalette.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: NeoPalette.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Log Interaction For...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: NeoPalette.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: NeoPalette.canvasLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase());
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: peopleAsync.when(
              data: (people) {
                final filtered = people.where((p) {
                  return p.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No people found.',
                      style: GoogleFonts.plusJakartaSans(
                        color: NeoPalette.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemBuilder: (context, index) {
                    final person = filtered[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: avatarColorFromName(person.name),
                        child: Text(
                          person.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        person.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: NeoPalette.textPrimary,
                        ),
                      ),
                      trailing: const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: NeoPalette.textMuted,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/people/${person.id}/log');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeEmptyDashboardCard extends StatelessWidget {
  final VoidCallback onImport;
  const _WelcomeEmptyDashboardCard({required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NeoPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        border: Border.all(color: NeoPalette.cardBorder),
        boxShadow: NeoPalette.shadowCard,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: NeoPalette.mintBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 32,
              color: NeoPalette.mintText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Keep Your Circle Close',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add friends, family, or colleagues from your contacts and set your reconnect target. Linksy will guide your outreach with zero effort.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: NeoPalette.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(LucideIcons.userPlus, size: 16),
            label: Text(
              'Select Contacts to Track',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoPalette.inkBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
