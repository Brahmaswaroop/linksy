import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:drift/drift.dart' hide Column;

import '../../core/database/database.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/labels_repository.dart';
import '../../core/services/contacts_service.dart';

class AddPersonScreen extends ConsumerStatefulWidget {
  final int? personId;

  const AddPersonScreen({super.key, this.personId});

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _relationController;
  late TextEditingController _notesController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _frequencyCountController;
  String _frequencyUnit = 'Weeks';
  String? _systemContactId;
  String? _avatarPath;
  DateTime? _birthday;
  final Set<int> _selectedLabelIds = {};
  int _targetFrequencyDays = 14;
  int _priorityLevel = 2; // 1 = Low, 2 = Medium, 3 = High
  String _category = 'Friend';

  static const _categories = ['Friend', 'Family', 'Colleague', 'Other'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _relationController = TextEditingController();
    _notesController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _frequencyCountController = TextEditingController(text: '2');
    _frequencyUnit = 'Weeks';
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
          _notesController.text = person.notes ?? '';
          _phoneController.text = person.phoneNumber ?? '';
          _emailController.text = person.email ?? '';
          _systemContactId = person.systemContactId;
          _avatarPath = person.avatarPath;
          _birthday = person.birthday;
          _priorityLevel = person.priorityLevel;
          _targetFrequencyDays = person.targetFrequencyDays;
          _decomposeDaysToCountAndUnit(person.targetFrequencyDays);
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

  Future<void> _importFromContacts() async {
    try {
      final contactService = ref.read(contactsServiceProvider);
      final contact = await contactService.pickDeviceContact();
      if (contact == null) return;

      if (mounted) {
        setState(() {
          if (contact.displayName.isNotEmpty) {
            _nameController.text = contact.displayName;
          }
          if (contact.phoneNumber != null) {
            _phoneController.text = contact.phoneNumber!;
          }
          if (contact.email != null) {
            _emailController.text = contact.email!;
          }
          _systemContactId = contact.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported details for ${contact.displayName}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access contacts: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _frequencyCountController.dispose();
    super.dispose();
  }

  void _decomposeDaysToCountAndUnit(int days) {
    if (days <= 0) days = 14;
    if (days % 365 == 0 && days >= 365) {
      _frequencyCountController.text = (days ~/ 365).toString();
      _frequencyUnit = 'Years';
    } else if (days % 30 == 0 && days >= 30) {
      _frequencyCountController.text = (days ~/ 30).toString();
      _frequencyUnit = 'Months';
    } else if (days % 7 == 0 && days >= 7) {
      _frequencyCountController.text = (days ~/ 7).toString();
      _frequencyUnit = 'Weeks';
    } else {
      _frequencyCountController.text = days.toString();
      _frequencyUnit = 'Days';
    }
  }

  void _updateFrequencyFromInputs() {
    final count = int.tryParse(_frequencyCountController.text.trim()) ?? 1;
    final safeCount = count <= 0 ? 1 : count;
    int multiplier = 1;
    switch (_frequencyUnit) {
      case 'Days':
        multiplier = 1;
        break;
      case 'Weeks':
        multiplier = 7;
        break;
      case 'Months':
        multiplier = 30;
        break;
      case 'Years':
        multiplier = 365;
        break;
    }
    setState(() {
      _targetFrequencyDays = (safeCount * multiplier).clamp(1, 3650);
    });
  }

  void _applyPresetFrequency(int count, String unit) {
    setState(() {
      _frequencyCountController.text = count.toString();
      _frequencyUnit = unit;
    });
    _updateFrequencyFromInputs();
  }

  String _formatFrequencyDisplay() {
    final count = int.tryParse(_frequencyCountController.text.trim()) ?? 1;
    final unitSingular = _frequencyUnit.endsWith('s')
        ? _frequencyUnit.substring(0, _frequencyUnit.length - 1)
        : _frequencyUnit;
    final unitStr = count == 1 ? unitSingular : _frequencyUnit;
    return 'Every $count $unitStr (${_targetFrequencyDays}d)';
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(peopleRepositoryProvider);
      final relationText = _relationController.text.trim();
      final phoneText = _phoneController.text.trim();
      final emailText = _emailController.text.trim();

      int savedPersonId;

      if (widget.personId != null) {
        final currentPerson = await repository.getPerson(widget.personId!);
        await repository.updatePerson(
          currentPerson.copyWith(
            name: _nameController.text.trim(),
            category: _category,
            relation: Value(relationText.isEmpty ? null : relationText),
            phoneNumber: Value(phoneText.isEmpty ? null : phoneText),
            email: Value(emailText.isEmpty ? null : emailText),
            systemContactId: Value(_systemContactId),
            avatarPath: Value(_avatarPath),
            notes: Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
            birthday: Value(_birthday),
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
            phoneNumber: Value(phoneText.isEmpty ? null : phoneText),
            email: Value(emailText.isEmpty ? null : emailText),
            systemContactId: Value(_systemContactId),
            avatarPath: Value(_avatarPath),
            notes: Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
            birthday: Value(_birthday),
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
            // ── Google / Phone Contact Import Banner ────────────
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.contact, color: cs.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import from Phone Contacts',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Fill details from Google / Phone Contacts',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _importFromContacts,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Import'),
                  ),
                ],
              ),
            ),

            // ── Basic Info Card ─────────────────────────────────────────
            _SectionCard(
              icon: LucideIcons.user,
              title: 'Basic Info',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1 234 567 8900',
                      prefixIcon: Icon(LucideIcons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'alex@example.com',
                      prefixIcon: Icon(LucideIcons.mail),
                    ),
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
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _birthday ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _birthday = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Birthday (Optional)',
                        prefixIcon: Icon(LucideIcons.calendar),
                      ),
                      child: Text(_birthday == null
                          ? 'Select Date'
                          : '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any background context, preferences, etc.',
                      prefixIcon: Icon(LucideIcons.fileText),
                    ),
                  ),
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
                          _formatFrequencyDisplay(),
                          style: tt.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Editable Number Input + Interval Dropdown Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number input (e.g. 2, 3, 4)
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _frequencyCountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _updateFrequencyFromInputs(),
                          textAlign: TextAlign.center,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Every',
                            hintText: '2',
                            prefixIcon: const Icon(LucideIcons.calendarClock, size: 18),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Interval Dropdown (Days, Weeks, Months, Years)
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: _frequencyUnit,
                          items: const [
                            DropdownMenuItem(value: 'Days', child: Text('Days')),
                            DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                            DropdownMenuItem(value: 'Months', child: Text('Months')),
                            DropdownMenuItem(value: 'Years', child: Text('Years')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _frequencyUnit = val;
                              });
                              _updateFrequencyFromInputs();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Interval',
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick Presets',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      (label: 'Weekly', count: 1, unit: 'Weeks'),
                      (label: '2 Weeks', count: 2, unit: 'Weeks'),
                      (label: 'Monthly', count: 1, unit: 'Months'),
                      (label: '2 Months', count: 2, unit: 'Months'),
                      (label: '3 Months', count: 3, unit: 'Months'),
                      (label: '6 Months', count: 6, unit: 'Months'),
                      (label: 'Yearly', count: 1, unit: 'Years'),
                    ].map((preset) {
                      final isSelected =
                          _frequencyCountController.text.trim() == preset.count.toString() &&
                          _frequencyUnit == preset.unit;
                      return ChoiceChip(
                        label: Text(preset.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _applyPresetFrequency(preset.count, preset.unit);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
