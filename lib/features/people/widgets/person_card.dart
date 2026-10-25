import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/database/database.dart';
import '../../../core/database/repositories/interactions_repository.dart';
import '../../../core/database/repositories/labels_repository.dart';
import '../../../core/engine/health_score_engine.dart';
import '../../../core/theme/app_theme.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hColor = healthColor(status.baseScore);
    final labelsAsync = ref.watch(labelsForPersonProvider(person.id));

    final lastContactStr = person.lastInteractionDate == null
        ? 'Never contacted'
        : 'Last: ${timeago.format(person.lastInteractionDate!)}';

    String followUpStr;
    Color followUpColor = cs.onSurface.withValues(alpha: 0.6);
    if (status.daysOverdue > 0) {
      followUpStr = 'Overdue by ${status.daysOverdue}d';
      followUpColor = Colors.redAccent.shade700;
    } else if (status.daysOverdue < 0) {
      followUpStr = 'Due in ${status.daysOverdue.abs()}d';
    } else {
      followUpStr = 'Due today';
      followUpColor = Colors.orange.shade800;
    }

    final hasPhone = person.phoneNumber != null && person.phoneNumber!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? cs.primary
                    : cs.outlineVariant.withValues(alpha: 0.45),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? cs.primaryContainer.withValues(alpha: 0.35) : null,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12, top: 10),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => onTap(),
                        ),
                      ),
                    // ── 1) Photo / Avatar ────────
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: avatarColorFromName(person.name),
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
                                    fontSize: 22,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: hColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.surface, width: 2.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // ── 2) Info Stream ────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Category
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  person.name,
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              if (person.category.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorForCategory(person.category),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    person.relation != null &&
                                            person.relation!.isNotEmpty
                                        ? '${person.category} • ${person.relation}'
                                        : person.category,
                                    style: tt.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Tags/Labels
                          labelsAsync.when(
                            data: (labels) {
                              if (labels.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: labels.map((l) {
                                    final colorStr =
                                        l.colorHex.replaceAll('#', '');
                                    final color = Color(
                                      int.parse(colorStr, radix: 16) + 0xFF000000,
                                    );
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Text(
                                        l.name,
                                        style: tt.labelSmall?.copyWith(
                                          color: color.withValues(alpha: 0.95),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
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

                          // Dates
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  lastContactStr,
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                    fontSize: 11.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                followUpStr,
                                style: tt.bodySmall?.copyWith(
                                  color: followUpColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Health Bar
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: status.progressPercent,
                                    minHeight: 5,
                                    backgroundColor: cs.onSurface.withValues(
                                      alpha: 0.08,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      hColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${status.baseScore}%',
                                style: tt.labelSmall?.copyWith(
                                  color: hColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Quick Actions Row (Call, SMS, WhatsApp, Quick Log) ──
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (hasPhone) ...[
                      _ActionIconButton(
                        icon: LucideIcons.phone,
                        tooltip: 'Call',
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        onTap: () => ContactActionHelper.call(person.phoneNumber!),
                      ),
                      const SizedBox(width: 8),
                      _ActionIconButton(
                        icon: LucideIcons.messageSquare,
                        tooltip: 'Message',
                        color: const Color(0xFF0D9488),
                        bgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        onTap: () => ContactActionHelper.sms(person.phoneNumber!),
                      ),
                      const SizedBox(width: 8),
                      _ActionIconButton(
                        icon: LucideIcons.messageCircle,
                        tooltip: 'WhatsApp',
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        onTap: () =>
                            ContactActionHelper.openWhatsApp(person.phoneNumber!),
                      ),
                    ],
                    const Spacer(),
                    _QuickCheckInPill(person: person),
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

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionIconButton({
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
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

class _QuickCheckInPill extends ConsumerWidget {
  final Person person;
  const _QuickCheckInPill({required this.person});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final repo = ref.read(interactionsRepositoryProvider);
          await repo.logInteraction(
            InteractionsCompanion.insert(
              personId: person.id,
              type: const Value('Call'),
              notes: const Value('Quick check-in'),
              date: Value(DateTime.now()),
            ),
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logged interaction with ${person.name}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.checkCheck, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Mark Contacted',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
