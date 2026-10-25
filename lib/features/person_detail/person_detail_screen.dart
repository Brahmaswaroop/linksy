import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/database/database.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/interactions_repository.dart';
import '../../core/database/repositories/labels_repository.dart';
import '../../core/engine/health_score_engine.dart';
import '../../core/utils/frequency_formatter.dart';
import '../../core/theme/app_theme.dart';
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
    final interactionsAsync = ref.watch(personInteractionsProvider(widget.personId));
    final engine = ref.watch(healthScoreEngineProvider);
    final labelsAsync = ref.watch(labelsForPersonProvider(widget.personId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: personAsync.when(
        data: (person) {
          final status = engine.calculateHealth(
            targetFrequencyDays: person.targetFrequencyDays,
            lastInteractionDate: person.lastInteractionDate,
            priorityLevel: person.priorityLevel,
            averageGapDays: person.averageGapDays,
            createdAt: person.createdAt,
          );
          final avatarColor = avatarColorFromName(person.name);
          final score = status.baseScore;
          final hColor = healthColor(score);

          return RefreshIndicator(
            onRefresh: () => ref.read(callLogSyncServiceProvider).syncCallLogs(),
            child: CustomScrollView(
            slivers: [
              // ── Hero SliverAppBar ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                actions: [
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw, color: Colors.white),
                    tooltip: 'Sync Call Logs',
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final result = await ref.read(callLogSyncServiceProvider).syncCallLogs();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            result.syncedInteractionsCount > 0
                                ? 'Synced ${result.syncedInteractionsCount} new call(s)'
                                : 'Call log is up to date',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit, color: Colors.white),
                    onPressed: () => context.go('/people/${widget.personId}/edit'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          avatarColor,
                          avatarColor.withValues(alpha: 0.7),
                          cs.primary.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: avatarColor.withValues(
                                alpha: 0.5,
                              ),
                              child: Text(
                                person.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            person.name,
                            style: tt.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (person.category.isNotEmpty || score < 100) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (person.category.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorForCategory(person.category),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      person.relation != null &&
                                              person.relation!.isNotEmpty
                                          ? '${person.category} • ${person.relation}'
                                          : person.category,
                                      style: tt.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),

              // ── Labels ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: labelsAsync.when(
                  data: (labels) {
                    if (labels.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: labels
                            .map(
                              (label) => Chip(
                                label: Text(label.name),
                                backgroundColor: cs.secondaryContainer,
                                labelStyle: TextStyle(
                                  color: cs.onSecondaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              // ── Quick Communication Actions ────────────────────────────
              if ((person.phoneNumber != null &&
                      person.phoneNumber!.trim().isNotEmpty) ||
                  (person.email != null && person.email!.trim().isNotEmpty))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _ContactActionCard(person: person),
                  ),
                ),

              // ── Health Stats ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _HealthStatsCard(
                    person: person,
                    status: status,
                    score: score,
                    hColor: hColor,
                  ),
                ),
              ),

              // ── Notes ──────────────────────────────────────────────────
              if (person.notes != null && person.notes!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _NotesSection(notes: person.notes!),
                  ),
                ),

              // ── Timeline Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
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
                        'Timeline',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => context.go('/people/${widget.personId}/log'),
                        icon: const Icon(LucideIcons.plusCircle, size: 14),
                        label: const Text('Log'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Timeline Items ──────────────────────────────────────────
              interactionsAsync.when(
                data: (interactions) {
                  if (interactions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.inbox,
                                size: 40,
                                color: cs.onSurface.withValues(alpha: 0.25),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No interactions logged yet.',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final interaction = interactions[index];
                        final isLast = index == interactions.length - 1;
                        return _TimelineItem(
                          interaction: interaction,
                          isLast: isLast,
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
                      }, childCount: interactions.length),
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
            Center(child: Text('Error loading person: $err')),
      ),
    );
  }
}

// ── Health Stats Card ──────────────────────────────────────────────────────

class _HealthStatsCard extends StatelessWidget {
  final Person person;
  final RelationshipTargetStatus status;
  final int score;
  final Color hColor;

  const _HealthStatsCard({
    required this.person,
    required this.status,
    required this.score,
    required this.hColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lastContactStr = person.lastInteractionDate == null
        ? 'Never contacted'
        : timeago.format(person.lastInteractionDate!);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.activity, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Relationship Stats',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Health score with animated bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Health Score',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '$score%',
                style: tt.labelLarge?.copyWith(
                  color: hColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(hColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          _StatRow(
            icon: LucideIcons.repeat,
            label: 'Target Frequency',
            value: formatTargetFrequency(person.targetFrequencyDays),
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: LucideIcons.clock,
            label: 'Last Contact',
            value: lastContactStr,
            valueColor: score < 30 ? const Color(0xFFF44336) : null,
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: LucideIcons.calendarClock,
            label: status.daysOverdue > 0 ? 'Overdue By' : 'Due In',
            value: status.daysOverdue == 0
                ? 'Today'
                : status.daysOverdue > 0
                ? '${status.daysOverdue} days'
                : '${status.daysOverdue.abs()} days',
            valueColor: status.daysOverdue > 0 ? const Color(0xFFF44336) : null,
          ),
          if (person.birthday != null) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: LucideIcons.cake,
              label: 'Birthday',
              value: _formatBirthday(person.birthday!),
            ),
          ],
        ],
      ),
    );
  }

  String _formatBirthday(DateTime bday) {
    final now = DateTime.now();
    int age = now.year - bday.year;
    if (now.month < bday.month || (now.month == bday.month && now.day < bday.day)) {
      age--;
    }
    
    DateTime nextBday = DateTime(now.year, bday.month, bday.day);
    if (nextBday.isBefore(DateTime(now.year, now.month, now.day))) {
      nextBday = DateTime(now.year + 1, bday.month, bday.day);
    }
    final daysUntil = nextBday.difference(DateTime(now.year, now.month, now.day)).inDays;
    final daysStr = daysUntil == 0 ? 'Today' : 'in $daysUntil days';
    
    return '${bday.month}/${bday.day}/${bday.year} ($age yrs, $daysStr)';
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;
  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileText, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Notes',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ── Timeline Item ──────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final Interaction interaction;
  final bool isLast;
  final VoidCallback? onEdit;

  const _TimelineItem({
    required this.interaction,
    required this.isLast,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final icon = _iconForType(interaction.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline track
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: cs.onPrimaryContainer),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            interaction.type,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                timeago.format(interaction.date),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              Text(
                                _formatDateTime(interaction.date),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.35),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (interaction.notes != null &&
                          interaction.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          interaction.notes!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
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

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }
}

class _ContactActionCard extends StatelessWidget {
  final Person person;
  const _ContactActionCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final phone = person.phoneNumber?.trim();
    final email = person.email?.trim();

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Contact',
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.phone, size: 16, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phone,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Mobile',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => ContactActionHelper.call(phone),
                    icon: const Icon(LucideIcons.phoneCall, size: 16),
                    tooltip: 'Call',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    onPressed: () => ContactActionHelper.sms(phone),
                    icon: const Icon(LucideIcons.messageSquare, size: 16),
                    tooltip: 'SMS',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
                      foregroundColor: const Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    onPressed: () => ContactActionHelper.openWhatsApp(phone),
                    icon: const Icon(LucideIcons.messageCircle, size: 16),
                    tooltip: 'WhatsApp',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.12),
                      foregroundColor: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ],
            if (email != null && email.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.mail, size: 16, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Email',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => ContactActionHelper.sendEmail(email),
                    icon: const Icon(LucideIcons.send, size: 16),
                    tooltip: 'Send Email',
                    style: IconButton.styleFrom(
                      backgroundColor: cs.primary.withValues(alpha: 0.12),
                      foregroundColor: cs.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

