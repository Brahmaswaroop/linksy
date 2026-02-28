import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/interactions_repository.dart';
import '../../core/engine/health_score_engine.dart';
import '../../core/database/database.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(allPeopleProvider);
    final engine = ref.watch(healthScoreEngineProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Linksy',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: peopleAsync.when(
        data: (people) {
          int strong = 0;
          int neutral = 0;
          int fading = 0;

          final needsAttention = <Map<String, dynamic>>[];

          for (final person in people) {
            final status = engine.calculateHealth(
              targetFrequencyDays: person.targetFrequencyDays,
              lastInteractionDate: person.lastInteractionDate,
              priorityLevel: person.priorityLevel,
              averageGapDays: person.averageGapDays,
              createdAt: person.createdAt,
            );

            if (status.statusEmoji == '🟢') {
              strong++;
            } else if (status.statusEmoji == '🟡') {
              neutral++;
            } else {
              fading++;
              needsAttention.add({'person': person, 'status': status});
            }
          }

          needsAttention.sort((a, b) {
            final statusA = a['status'] as RelationshipTargetStatus;
            final statusB = b['status'] as RelationshipTargetStatus;
            return statusB.totalScoreWithPriority.compareTo(
              statusA.totalScoreWithPriority,
            );
          });

          final total = people.length;
          final strongRatio = total == 0 ? 0.0 : strong / total;

          return CustomScrollView(
            slivers: [
              // ── Gradient Health Header ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _HealthHeaderCard(
                    strong: strong,
                    neutral: neutral,
                    fading: fading,
                    total: total,
                    strongRatio: strongRatio,
                  ),
                ),
              ),

              // ── Section Header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Needs Attention',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (needsAttention.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${needsAttention.length}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Needs Attention List ────────────────────────────────────
              if (needsAttention.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.partyPopper,
                            color: Color(0xFF4CAF50),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Everyone is caught up!',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All your bonds are looking healthy 🎉',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = needsAttention[index];
                      final person = item['person'] as Person;
                      final status = item['status'] as RelationshipTargetStatus;
                      return _AttentionCard(
                        person: person,
                        status: status,
                        onTap: () => context.push('/people/${person.id}'),
                        onLog: () => context.push('/people/${person.id}/log'),
                      );
                    }, childCount: needsAttention.length),
                  ),
                ),

              // ── Recently Contacted Section ──────────────────────────────
              SliverToBoxAdapter(child: _RecentlyContactedSection()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) {
              return DraggableScrollableSheet(
                initialChildSize: 0.6,
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
        icon: const Icon(LucideIcons.plusCircle),
        label: const Text('Log'),
      ),
    );
  }
}

// ── Health Header Card ─────────────────────────────────────────────────────

class _HealthHeaderCard extends StatelessWidget {
  final int strong, neutral, fading, total;
  final double strongRatio;
  const _HealthHeaderCard({
    required this.strong,
    required this.neutral,
    required this.fading,
    required this.total,
    required this.strongRatio,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.75),
            cs.tertiary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.heartPulse, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Relationship Health',
                style: tt.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$total people',
                style: tt.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatPill(
                count: strong,
                label: 'Strong',
                color: const Color(0xFF4CAF50),
              ),
              _StatPill(
                count: neutral,
                label: 'Neutral',
                color: const Color(0xFFFFC107),
              ),
              _StatPill(
                count: fading,
                label: 'Fading',
                color: const Color(0xFFF44336),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : strongRatio,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            total == 0
                ? 'No connections yet'
                : '${(strongRatio * 100).round()}% of your bonds are strong',
            style: tt.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatPill({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(
          '$count',
          style: tt.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ── Attention Card ─────────────────────────────────────────────────────────

class _AttentionCard extends StatelessWidget {
  final Person person;
  final RelationshipTargetStatus status;
  final VoidCallback onTap;
  final VoidCallback onLog;
  const _AttentionCard({
    required this.person,
    required this.status,
    required this.onTap,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final avatarColor = avatarColorFromName(person.name);
    final score = status.baseScore;
    final hColor = healthColor(score);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: hColor, width: 4)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor,
                  child: Text(
                    person.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: hColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Health: $score%',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.clock,
                            size: 12,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            person.lastInteractionDate == null
                                ? 'Never'
                                : timeago.format(person.lastInteractionDate!),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Log button
                FilledButton.tonal(
                  onPressed: onLog,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.messageCircle, size: 14),
                      SizedBox(width: 4),
                      Text('Log', style: TextStyle(fontSize: 12)),
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
}

// ── Recently Contacted Section ─────────────────────────────────────────────

class _RecentlyContactedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentlyContactedPeopleProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recently Contacted',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          recentAsync.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No interactions logged yet.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: contacts.map((contact) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            context.push('/people/${contact.personId}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: avatarColorFromName(
                                  contact.personName,
                                ),
                                child: Text(
                                  contact.personName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
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
                                      style: tt.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          _iconForType(contact.type),
                                          size: 12,
                                          color: cs.onSurface.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          contact.type,
                                          style: tt.labelSmall?.copyWith(
                                            color: cs.onSurface.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                timeago.format(contact.date),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final peopleAsync = ref.watch(allPeopleProvider);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
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
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
          // List
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
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
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
                            fontSize: 16,
                          ),
                        ),
                      ),
                      title: Text(
                        person.name,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close sheet
                        context.push('/people/${person.id}/log');
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
