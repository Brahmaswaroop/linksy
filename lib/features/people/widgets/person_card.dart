import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/database/database.dart';
import '../../../core/database/repositories/labels_repository.dart';
import '../../../core/engine/health_score_engine.dart';
import '../../../core/theme/app_theme.dart';

class PersonCard extends ConsumerWidget {
  final Person person;
  final RelationshipTargetStatus status;
  final VoidCallback onTap;

  const PersonCard({
    super.key,
    required this.person,
    required this.status,
    required this.onTap,
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
      followUpStr = 'Overdue by ${status.daysOverdue} days';
      followUpColor = Colors.red;
    } else if (status.daysOverdue < 0) {
      followUpStr = 'Due in ${status.daysOverdue.abs()} days';
    } else {
      followUpStr = 'Due today';
      followUpColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1) Photo / Avatar Avatar ────────
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: avatarColorFromName(person.name),
                      backgroundImage: person.avatarPath != null
                          ? FileImage(File(person.avatarPath!))
                          : null,
                      child: person.avatarPath == null
                          ? Text(
                              person.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: hColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

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
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                          if (person.category.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorForCategory(person.category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                person.relation != null &&
                                        person.relation!.isNotEmpty
                                    ? '${person.category} • ${person.relation}'
                                    : person.category,
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Tags/Labels
                      labelsAsync.when(
                        data: (labels) {
                          if (labels.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: labels.map((l) {
                                final colorStr = l.colorHex.replaceAll('#', '');
                                final color = Color(
                                  int.parse(colorStr, radix: 16) + 0xFF000000,
                                );
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    l.name,
                                    style: tt.labelSmall?.copyWith(
                                      color: color.withValues(alpha: 0.9),
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
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              followUpStr,
                              style: tt.bodySmall?.copyWith(
                                color: followUpColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Health Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: status.progressPercent,
                                minHeight: 6,
                                backgroundColor: cs.onSurface.withValues(
                                  alpha: 0.1,
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
        ),
      ),
    );
  }
}
