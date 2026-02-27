import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:drift/drift.dart' hide Column;

import '../../core/database/database.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/labels_repository.dart';
import '../../core/database/repositories/person_connections_repository.dart';
import '../../core/utils/frequency_formatter.dart';

class AddPersonScreen extends ConsumerStatefulWidget {
  final int? personId;
  final int? linkToPersonId;

  const AddPersonScreen({super.key, this.personId, this.linkToPersonId});

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>(); // Form states
  late TextEditingController _nameController;
  late TextEditingController
  _relationController; // Used as the specific relation label
  final Set<int> _selectedLabelIds = {};
  int _targetFrequencyDays = 30;
  int _priorityLevel = 2; // 1 = Low, 2 = Medium, 3 = High
  String _category = 'Friend'; // Default category

  static const _categories = ['Friend', 'Family', 'Colleague', 'Other'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _relationController = TextEditingController();
    if (widget.personId != null) {
      _loadPersonData();
    }
  }

  Future<void> _loadPersonData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(peopleRepositoryProvider);
      final person = await repo.getPerson(widget.personId!);

      final labelsRepo = ref.read(labelsRepositoryProvider);
      final labels = await labelsRepo.getLabelsForPerson(widget.personId!);

      if (mounted) {
        setState(() {
          _nameController.text = person.name;
          _relationController.text = person.relation ?? '';
          _priorityLevel = person.priorityLevel;
          _targetFrequencyDays = person.targetFrequencyDays;
          _selectedLabelIds.addAll(labels.map((e) => e.id));
          if (_categories.contains(person.category)) {
            _category = person.category;
          }
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(peopleRepositoryProvider);
      final relationText = _relationController.text.trim();

      int savedPersonId;

      if (widget.personId != null) {
        final currentPerson = await repository.getPerson(widget.personId!);
        await repository.updatePerson(
          currentPerson.copyWith(
            name: _nameController.text.trim(),
            category: _category,
            relation: Value(relationText.isEmpty ? null : relationText),
            priorityLevel: _priorityLevel,
            targetFrequencyDays: _targetFrequencyDays,
          ),
        );
        savedPersonId = widget.personId!;
      } else {
        savedPersonId = await repository.insertPerson(
          PeopleCompanion.insert(
            name: _nameController.text.trim(),
            category: Value(_category),
            relation: relationText.isEmpty
                ? const Value.absent()
                : Value(relationText),
            priorityLevel: Value(_priorityLevel),
            targetFrequencyDays: Value(_targetFrequencyDays),
          ),
        );
      }

      final labelsRepo = ref.read(labelsRepositoryProvider);
      if (widget.personId != null) {
        await labelsRepo.clearLabelsForPerson(savedPersonId);
      }

      if (_selectedLabelIds.isNotEmpty) {
        for (final labelId in _selectedLabelIds) {
          await labelsRepo.attachLabelToPerson(savedPersonId, labelId);
        }
      }

      // Automatically link to another person if requested (only on creation)
      if (widget.personId == null && widget.linkToPersonId != null) {
        final connectionsRepo = ref.read(personConnectionsRepositoryProvider);
        await connectionsRepo.insertConnection(
          PersonConnectionsCompanion.insert(
            personId: widget.linkToPersonId!,
            connectedPersonId: savedPersonId,
            relationLabel: const Value('Connection'),
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final labelsAsync = ref.watch(allLabelsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEdit = widget.personId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Person' : 'Add Person',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(LucideIcons.check, size: 16),
              label: Text(isEdit ? 'Update' : 'Save'),
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
            // ── Basic Info Card ─────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.user,
              title: 'Basic Info',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    icon: const Icon(LucideIcons.chevronDown),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(LucideIcons.users),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _category = val);
                      }
                    },
                  ),
                  if (_category == 'Family' || _category == 'Other') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relationController,
                      decoration: const InputDecoration(
                        labelText: 'Specific Relation (Optional)',
                        hintText: 'e.g. Brother, Sister, Manager',
                        prefixIcon: Icon(LucideIcons.heartHandshake),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Labels Card ─────────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.tag,
              title: 'Labels',
              child: labelsAsync.when(
                data: (labels) {
                  if (labels.isEmpty) {
                    return Text(
                      'No labels available.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: labels.map((label) {
                      final isSelected = _selectedLabelIds.contains(label.id);
                      return FilterChip(
                        label: Text(label.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedLabelIds.add(label.id);
                            } else {
                              _selectedLabelIds.remove(label.id);
                            }
                          });
                        },
                        selectedColor: cs.primaryContainer,
                        checkmarkColor: cs.onPrimaryContainer,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(
                  'Error loading labels: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Priority Card ───────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.flame,
              title: 'Priority Level',
              child: Row(
                children: [
                  _PriorityChip(
                    label: 'Low',
                    icon: LucideIcons.arrowDown,
                    value: 1,
                    selected: _priorityLevel == 1,
                    selectedColor: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _priorityLevel = 1),
                  ),
                  const SizedBox(width: 10),
                  _PriorityChip(
                    label: 'Medium',
                    icon: LucideIcons.minus,
                    value: 2,
                    selected: _priorityLevel == 2,
                    selectedColor: const Color(0xFFFFC107),
                    onTap: () => setState(() => _priorityLevel = 2),
                  ),
                  const SizedBox(width: 10),
                  _PriorityChip(
                    label: 'High',
                    icon: LucideIcons.arrowUp,
                    value: 3,
                    selected: _priorityLevel == 3,
                    selectedColor: const Color(0xFFF44336),
                    onTap: () => setState(() => _priorityLevel = 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Frequency Card ──────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.repeat,
              title: 'Contact Frequency',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'How often to reconnect?',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatTargetFrequency(_targetFrequencyDays),
                          style: tt.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          (label: '1D', days: 1),
                          (label: '1W', days: 7),
                          (label: '2W', days: 14),
                          (label: '1M', days: 30),
                          (label: '3M', days: 90),
                        ].map((preset) {
                          final isSelected =
                              _targetFrequencyDays == preset.days;
                          return ChoiceChip(
                            label: Text(preset.label),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(
                                  () => _targetFrequencyDays = preset.days,
                                );
                              }
                            },
                            selectedColor: cs.primaryContainer,
                            checkmarkColor: cs.onPrimaryContainer,
                            side: BorderSide(
                              color: isSelected
                                  ? cs.primary
                                  : cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                            labelStyle: tt.labelMedium?.copyWith(
                              color: isSelected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _targetFrequencyDays.toDouble(),
                    min: 1,
                    max: 90,
                    divisions: 89,
                    label: formatTargetFrequency(_targetFrequencyDays),
                    onChanged: (value) {
                      setState(() {
                        _targetFrequencyDays = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

// ── Priority Chip ──────────────────────────────────────────────────────────

class _PriorityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.15)
                : cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? selectedColor
                  : cs.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? selectedColor
                    : cs.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? selectedColor
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
