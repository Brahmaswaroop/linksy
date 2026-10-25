import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/engine/health_score_engine.dart';
import '../../core/engine/sorting_service.dart';
import '../../core/database/repositories/people_repository.dart';
import 'widgets/bulk_import_sheet.dart';
import 'widgets/person_card.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  bool _isSelectionMode = false;
  final Set<int> _selectedPersonIds = {};

  final List<String> _categories = [
    'All',
    'Friend',
    'Family',
    'Colleague',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBulkImportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BulkImportSheet(),
    );
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedPersonIds.contains(id)) {
        _selectedPersonIds.remove(id);
        if (_selectedPersonIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPersonIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedPersonIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortOrder = ref.watch(sortOrderProvider);
    final peopleAsync = ref.watch(sortedPeopleProvider);
    final engine = ref.watch(healthScoreEngineProvider);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: _clearSelection,
              ),
              title: Text(
                '${_selectedPersonIds.length} Selected',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            )
          : AppBar(
              title: _isSearching
                  ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                style: tt.bodyLarge,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : Text(
                'People',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus),
            tooltip: 'Import from Contacts',
            onPressed: _openBulkImportSheet,
          ),
          _SortMenu(
            currentOrder: sortOrder,
            onSelected: (order) {
              ref.read(sortOrderProvider.notifier).setOrder(order);
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          // List
          Expanded(
            child: peopleAsync.when(
              data: (people) {
                if (people.isEmpty) {
                  return _EmptyState(
                    onAdd: () => context.go('/people/add'),
                    onImport: _openBulkImportSheet,
                  );
                }

                final filteredPeople = people.where((p) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      p.name.toLowerCase().contains(_searchQuery) ||
                      (p.relation?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (p.notes?.toLowerCase().contains(_searchQuery) ?? false);

                  final matchesCategory =
                      _selectedCategory == 'All' ||
                      p.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredPeople.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.searchX,
                          size: 48,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No results found',
                          style: tt.bodyLarge?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPeople.length,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemBuilder: (context, index) {
                    final person = filteredPeople[index];
                    final status = engine.calculateHealth(
                      targetFrequencyDays: person.targetFrequencyDays,
                      lastInteractionDate: person.lastInteractionDate,
                      priorityLevel: person.priorityLevel,
                      averageGapDays: person.averageGapDays,
                      createdAt: person.createdAt,
                    );

                    return PersonCard(
                      person: person,
                      status: status,
                      isSelectionMode: _isSelectionMode,
                      isSelected: _selectedPersonIds.contains(person.id),
                      onLongPress: () {
                        setState(() {
                          _isSelectionMode = true;
                          _selectedPersonIds.add(person.id);
                        });
                      },
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(person.id);
                        } else {
                          context.go('/people/${person.id}');
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error loading people: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
        onPressed: () => context.go('/people/add'),
        tooltip: 'Add Person',
        child: const Icon(LucideIcons.userPlus),
      ),
      bottomNavigationBar: _isSelectionMode
          ? _BulkActionBar(
              selectedIds: _selectedPersonIds.toList(),
              onClear: _clearSelection,
            )
          : null,
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onImport;
  const _EmptyState({required this.onAdd, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.users,
                size: 36,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No bonds yet',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your meaningful\nrelationships today.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(LucideIcons.userPlus),
              label: const Text('Import Phone Contacts'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Manually'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  final PersonSortOrder currentOrder;
  final ValueChanged<PersonSortOrder> onSelected;

  const _SortMenu({required this.currentOrder, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<PersonSortOrder>(
      icon: const Icon(LucideIcons.listFilter),
      tooltip: 'Sort list',
      initialValue: currentOrder,
      onSelected: onSelected,
      itemBuilder: (context) {
        return PersonSortOrder.values.map((order) {
          final isSelected = order == currentOrder;
          return PopupMenuItem(
            value: order,
            child: Row(
              children: [
                Icon(
                  isSelected ? LucideIcons.check : null,
                  size: 16,
                  color: cs.primary,
                ),
                SizedBox(width: isSelected ? 8 : 24),
                Text(
                  order.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : null,
                    color: isSelected ? cs.primary : null,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

// ── Bulk Action Bar ─────────────────────────────────────────────────────────

class _BulkActionBar extends ConsumerWidget {
  final List<int> selectedIds;
  final VoidCallback onClear;

  const _BulkActionBar({required this.selectedIds, required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: LucideIcons.users,
            label: 'Category',
            onTap: () => _showCategoryDialog(context, ref),
          ),
          _ActionButton(
            icon: LucideIcons.flame,
            label: 'Priority',
            onTap: () => _showPriorityDialog(context, ref),
          ),
          _ActionButton(
            icon: LucideIcons.repeat,
            label: 'Frequency',
            onTap: () => _showFrequencyDialog(context, ref),
          ),
          _ActionButton(
            icon: LucideIcons.trash2,
            label: 'Delete',
            color: Colors.red,
            onTap: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context, WidgetRef ref) async {
    final categories = ['Friend', 'Family', 'Colleague', 'Other'];
    String selected = categories.first;
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Change Category'),
          content: DropdownButtonFormField<String>(
            value: selected,
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => selected = v!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (res != null) {
      await ref.read(peopleRepositoryProvider).bulkUpdateCategory(selectedIds, res);
      onClear();
    }
  }

  Future<void> _showPriorityDialog(BuildContext context, WidgetRef ref) async {
    int selected = 2;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Change Priority'),
          content: DropdownButtonFormField<int>(
            value: selected,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Low')),
              DropdownMenuItem(value: 2, child: Text('Medium')),
              DropdownMenuItem(value: 3, child: Text('High')),
            ],
            onChanged: (v) => setState(() => selected = v!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (res != null) {
      await ref.read(peopleRepositoryProvider).bulkUpdatePriority(selectedIds, res);
      onClear();
    }
  }

  Future<void> _showFrequencyDialog(BuildContext context, WidgetRef ref) async {
    int selected = 30;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Change Frequency'),
          content: DropdownButtonFormField<int>(
            value: selected,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 Day')),
              DropdownMenuItem(value: 7, child: Text('1 Week')),
              DropdownMenuItem(value: 14, child: Text('2 Weeks')),
              DropdownMenuItem(value: 30, child: Text('1 Month')),
              DropdownMenuItem(value: 90, child: Text('3 Months')),
            ],
            onChanged: (v) => setState(() => selected = v!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (res != null) {
      await ref.read(peopleRepositoryProvider).bulkUpdateTargetFrequency(selectedIds, res);
      onClear();
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected?'),
        content: Text('Are you sure you want to delete ${selectedIds.length} people? This will also delete their interactions and connections.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (res == true) {
      await ref.read(peopleRepositoryProvider).bulkDeletePeople(selectedIds);
      onClear();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? cs.onSurface),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color ?? cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
