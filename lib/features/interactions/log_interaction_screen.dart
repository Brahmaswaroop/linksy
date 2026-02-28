import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:drift/drift.dart' hide Column;

import '../../core/database/database.dart';
import '../../core/database/repositories/interactions_repository.dart';

// Interaction types with icons and labels
const _interactionTypes = [
  ('Message', LucideIcons.messageCircle),
  ('Call', LucideIcons.phone),
  ('Meeting', LucideIcons.coffee),
  ('Note', LucideIcons.fileText),
];

class LogInteractionScreen extends ConsumerStatefulWidget {
  final int personId;
  final Interaction? existingInteraction;
  const LogInteractionScreen({
    super.key,
    required this.personId,
    this.existingInteraction,
  });

  @override
  ConsumerState<LogInteractionScreen> createState() =>
      _LogInteractionScreenState();
}

class _LogInteractionScreenState extends ConsumerState<LogInteractionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String _type = 'Message';
  int _energyRating = 3;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingInteraction;
    if (existing != null) {
      _type = existing.type;
      _energyRating = existing.energyRating ?? 3;
      _notesController.text = existing.notes ?? '';
      _selectedDate = existing.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingInteraction != null;

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(interactionsRepositoryProvider);

      if (_isEditing) {
        final updated = widget.existingInteraction!.copyWith(
          type: _type,
          date: _selectedDate,
          notes: Value(_notesController.text.trim()),
          energyRating: Value(_energyRating),
        );
        await repository.updateInteraction(updated);
      } else {
        await repository.logInteraction(
          InteractionsCompanion.insert(
            personId: widget.personId,
            date: Value(_selectedDate),
            notes: Value(_notesController.text.trim()),
            type: Value(_type),
            energyRating: Value(_energyRating),
          ),
        );
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Interaction' : 'Log Interaction',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Type Selector ───────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.layoutGrid,
              title: 'Interaction Type',
              child: Row(
                children: _interactionTypes.map((entry) {
                  final (label, icon) = entry;
                  final isSelected = _type == label;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primaryContainer
                                : cs.surfaceContainerHighest.withValues(
                                    alpha: 0.4,
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? cs.primary
                                  : cs.outlineVariant.withValues(alpha: 0.5),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                icon,
                                size: 20,
                                color: isSelected
                                    ? cs.onPrimaryContainer
                                    : cs.onSurface.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? cs.onPrimaryContainer
                                      : cs.onSurface.withValues(alpha: 0.6),
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
            ),
            const SizedBox(height: 16),

            // ── Date & Time Picker ────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.calendar,
              title: 'Date & Time',
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              _selectedDate.hour,
                              _selectedDate.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 16,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 16,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_selectedDate),
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
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
            const SizedBox(height: 16),

            // ── Notes Card ──────────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.edit,
              title: 'Notes',
              child: TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'What happened? How did it feel?',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 5,
                style: tt.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // ── Energy Rating Card ──────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.zap,
              title: 'Energy After',
              child: Column(
                children: [
                  // Emoji label display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _EnergyLabel(
                        emoji: '😩',
                        label: 'Draining',
                        active: _energyRating == 1,
                      ),
                      _EnergyLabel(
                        emoji: '😐',
                        label: 'Neutral',
                        active: _energyRating == 3,
                      ),
                      _EnergyLabel(
                        emoji: '✨',
                        label: 'Energizing',
                        active: _energyRating == 5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getEnergyColor(_energyRating),
                      thumbColor: _getEnergyColor(_energyRating),
                      inactiveTrackColor: cs.onSurface.withValues(alpha: 0.12),
                      overlayColor: _getEnergyColor(
                        _energyRating,
                      ).withValues(alpha: 0.12),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _energyRating.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (val) {
                        setState(() {
                          _energyRating = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEnergyColor(int rating) {
    const colors = [
      Color(0xFFF44336), // 1 – draining
      Color(0xFFFF7043), // 2
      Color(0xFFFFC107), // 3 – neutral
      Color(0xFF8BC34A), // 4
      Color(0xFF4CAF50), // 5 – energizing
    ];
    return colors[(rating - 1).clamp(0, 4)];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

// ── Section Card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Energy Label ───────────────────────────────────────────────────────────

class _EnergyLabel extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;

  const _EnergyLabel({
    required this.emoji,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(fontSize: active ? 26 : 20),
          child: Text(emoji),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
