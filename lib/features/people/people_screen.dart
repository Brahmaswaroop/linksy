import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/engine/health_score_engine.dart';
import '../../core/engine/sorting_service.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/theme/neo_palette.dart';
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

  void _cycleCategory() {
    final nextIndex = (_categories.indexOf(_selectedCategory) + 1) % _categories.length;
    setState(() {
      _selectedCategory = _categories[nextIndex];
    });
  }

  void _cycleSortOrder(PersonSortOrder currentOrder) {
    const orders = PersonSortOrder.values;
    final nextIndex = (orders.indexOf(currentOrder) + 1) % orders.length;
    ref.read(sortOrderProvider.notifier).setOrder(orders[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final sortOrder = ref.watch(sortOrderProvider);
    final peopleAsync = ref.watch(sortedPeopleProvider);
    final engine = ref.watch(healthScoreEngineProvider);

    return Scaffold(
      backgroundColor: NeoPalette.canvasLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Bar / Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _isSelectionMode
                  ? Row(
                      children: [
                        _CircularNavBtn(
                          icon: LucideIcons.x,
                          tooltip: 'Clear',
                          onTap: _clearSelection,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedPersonIds.length} Selected',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: NeoPalette.textPrimary,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        _CircularNavBtn(
                          icon: LucideIcons.home,
                          tooltip: 'Home',
                          onTap: () => context.go('/dashboard'),
                        ),
                        const Spacer(),
                        _CircularNavBtn(
                          icon: _isSearching ? LucideIcons.x : LucideIcons.search,
                          tooltip: 'Search',
                          onTap: () {
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
                        const SizedBox(width: 8),
                        _CircularNavBtn(
                          icon: LucideIcons.userPlus,
                          tooltip: 'Import Contacts',
                          onTap: _openBulkImportSheet,
                        ),
                        const SizedBox(width: 8),
                        _CircularNavBtn(
                          icon: LucideIcons.plus,
                          tooltip: 'Add Person',
                          onTap: () => context.go('/people/add'),
                        ),
                      ],
                    ),
            ),

            // ── 2. Headline & Dynamic Count Subtitle ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: peopleAsync.when(
                data: (people) {
                  final filtered = people.where((p) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        p.name.toLowerCase().contains(_searchQuery) ||
                        (p.relation?.toLowerCase().contains(_searchQuery) ?? false) ||
                        (p.notes?.toLowerCase().contains(_searchQuery) ?? false);
                    final matchesCategory = _selectedCategory == 'All' ||
                        p.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSearching ? 'Search Results' : 'Network Directory',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: NeoPalette.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: NeoPalette.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'There are '),
                            TextSpan(
                              text: '${filtered.length} active bonds',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.skyText,
                              ),
                            ),
                            TextSpan(
                              text: _selectedCategory == 'All'
                                  ? ' in your circle'
                                  : ' in $_selectedCategory',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(height: 40),
                error: (err, stack) => const SizedBox(height: 40),
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. Search Bar (if searching) ─────────────────────────────────
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by name, relation, or notes...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    filled: true,
                    fillColor: NeoPalette.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                      borderSide: const BorderSide(color: NeoPalette.cardBorder),
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

            // ── 4. Top Dual Connected Route Pill Filter Bar (Jakarta ⇄ Bandung)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NeoPalette.surfaceWhite,
                  borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                  border: Border.all(color: NeoPalette.cardBorder),
                  boxShadow: NeoPalette.shadowSoft,
                ),
                child: Row(
                  children: [
                    // Left Pill: Circle Category Filter
                    Expanded(
                      child: InkWell(
                        onTap: _cycleCategory,
                        borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: NeoPalette.mintBg,
                            borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.users,
                                size: 13,
                                color: NeoPalette.mintText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Circle: $_selectedCategory',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: NeoPalette.mintText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Center Connected Swap Icon ⇄
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: NeoPalette.skyBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.repeat,
                          size: 13,
                          color: NeoPalette.skyText,
                        ),
                      ),
                    ),
                    // Right Pill: Sort Order Filter
                    Expanded(
                      child: InkWell(
                        onTap: () => _cycleSortOrder(sortOrder),
                        borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: NeoPalette.skyBg,
                            borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.slidersHorizontal,
                                size: 13,
                                color: NeoPalette.skyText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sort: ${sortOrder.label.split(' ').first}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: NeoPalette.skyText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── 5. Contacts Feed List (Transit Ticket Cards) ─────────────────
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

                    final matchesCategory = _selectedCategory == 'All' ||
                        p.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredPeople.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: NeoPalette.skyBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.searchX,
                              size: 26,
                              color: NeoPalette.skyText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No matching connections found',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try adjusting your search query or circle filter.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: NeoPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredPeople.length,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
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
                    Center(child: Text('Error loading contacts: $err')),
              ),
            ),
          ],
        ),
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

// ── Circular Navigation Button ─────────────────────────────────────────────

class _CircularNavBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircularNavBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: NeoPalette.surfaceWhite,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeoPalette.cardBorder),
              boxShadow: NeoPalette.shadowSoft,
            ),
            child: Icon(icon, size: 18, color: NeoPalette.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onImport;

  const _EmptyState({required this.onAdd, required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: NeoPalette.mintBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.users,
                size: 36,
                color: NeoPalette.mintText,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Contacts Added Yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NeoPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Import your contacts from your phone or create them manually to start tracking your relationship health.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: NeoPalette.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(LucideIcons.userPlus, size: 16),
                  label: Text(
                    'Import Contacts',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeoPalette.inkBlack,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: Text(
                    'Manual Add',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NeoPalette.textPrimary,
                    side: const BorderSide(color: NeoPalette.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: NeoPalette.cardBorder)),
        boxShadow: NeoPalette.shadowCard,
      ),
      child: SafeArea(
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
              label: 'Cadence',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          ),
          backgroundColor: NeoPalette.surfaceWhite,
          title: Text(
            'Change Circle',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: NeoPalette.textPrimary,
            ),
          ),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => selected = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoPalette.inkBlack,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (res != null) {
      await ref
          .read(peopleRepositoryProvider)
          .bulkUpdateCategory(selectedIds, res);
      onClear();
    }
  }

  Future<void> _showPriorityDialog(BuildContext context, WidgetRef ref) async {
    int selected = 2;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          ),
          backgroundColor: NeoPalette.surfaceWhite,
          title: Text(
            'Change Priority',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: NeoPalette.textPrimary,
            ),
          ),
          content: DropdownButtonFormField<int>(
            initialValue: selected,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Low')),
              DropdownMenuItem(value: 2, child: Text('Medium')),
              DropdownMenuItem(value: 3, child: Text('High (VIP)')),
            ],
            onChanged: (v) => setState(() => selected = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoPalette.inkBlack,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (res != null) {
      await ref
          .read(peopleRepositoryProvider)
          .bulkUpdatePriority(selectedIds, res);
      onClear();
    }
  }

  Future<void> _showFrequencyDialog(BuildContext context, WidgetRef ref) async {
    int selected = 30;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          ),
          backgroundColor: NeoPalette.surfaceWhite,
          title: Text(
            'Change Reconnect Cadence',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: NeoPalette.textPrimary,
            ),
          ),
          content: DropdownButtonFormField<int>(
            initialValue: selected,
            items: const [
              DropdownMenuItem(value: 7, child: Text('Every Week (7 days)')),
              DropdownMenuItem(value: 14, child: Text('Every 2 Weeks (14 days)')),
              DropdownMenuItem(value: 30, child: Text('Every Month (30 days)')),
              DropdownMenuItem(value: 60, child: Text('Every 2 Months (60 days)')),
              DropdownMenuItem(value: 90, child: Text('Every 3 Months (90 days)')),
            ],
            onChanged: (v) => setState(() => selected = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoPalette.inkBlack,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (res != null) {
      await ref
          .read(peopleRepositoryProvider)
          .bulkUpdateTargetFrequency(selectedIds, res);
      onClear();
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        ),
        backgroundColor: NeoPalette.surfaceWhite,
        title: Text(
          'Delete Selected?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: NeoPalette.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${selectedIds.length} people? This will also remove their interactions.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: NeoPalette.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? NeoPalette.textPrimary),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color ?? NeoPalette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
