import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/engine/health_score_engine.dart';
import '../../core/engine/sorting_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final sortOrder = ref.watch(sortOrderProvider);
    final peopleAsync = ref.watch(sortedPeopleProvider);
    final engine = ref.watch(healthScoreEngineProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
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
                  return _EmptyState(onAdd: () => context.go('/people/add'));
                }

                final filteredPeople = people.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(
                    _searchQuery,
                  );
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
                      onTap: () => context.go('/people/${person.id}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/people/add'),
        tooltip: 'Add Person',
        child: const Icon(LucideIcons.userPlus),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

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
              onPressed: onAdd,
              icon: const Icon(LucideIcons.userPlus),
              label: const Text('Add First Person'),
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
