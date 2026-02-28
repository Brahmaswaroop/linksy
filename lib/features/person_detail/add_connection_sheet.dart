import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../core/database/database.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/database/repositories/person_connections_repository.dart';
import '../../core/theme/app_theme.dart';

class AddConnectionSheet extends ConsumerStatefulWidget {
  final int sourcePersonId;

  const AddConnectionSheet({super.key, required this.sourcePersonId});

  @override
  ConsumerState<AddConnectionSheet> createState() => _AddConnectionSheetState();
}

class _AddConnectionSheetState extends ConsumerState<AddConnectionSheet> {
  final _searchController = TextEditingController();
  final _relationController = TextEditingController();

  String _searchQuery = '';
  Person? _selectedPerson;

  @override
  void dispose() {
    _searchController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _saveConnection() async {
    if (_selectedPerson == null) return;
    final relationLabel = _relationController.text.trim();
    if (relationLabel.isEmpty) return;

    final repo = ref.read(personConnectionsRepositoryProvider);
    await repo.insertConnection(
      PersonConnectionsCompanion.insert(
        personId: widget.sourcePersonId,
        connectedPersonId: _selectedPerson!.id,
        relationLabel: Value(relationLabel),
      ),
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final peopleAsync = ref.watch(allPeopleProvider);

    return Padding(
      // Padding for keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Connection',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedPerson == null) ...[
              // Search Phase
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  prefixIcon: const Icon(LucideIcons.search),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  context.pop();
                  context.go(
                    '/people/add?linkToPersonId=${widget.sourcePersonId}',
                  );
                },
                icon: const Icon(LucideIcons.userPlus),
                label: const Text('Create New Person'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: peopleAsync.when(
                  data: (people) {
                    final filtered = people.where((p) {
                      return p.id != widget.sourcePersonId &&
                          p.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No existing people found.',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: avatarColorFromName(p.name),
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(p.name),
                          onTap: () {
                            setState(() {
                              _selectedPerson = p;
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ] else ...[
              // Relation Entry Phase
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: avatarColorFromName(_selectedPerson!.name),
                    child: Text(
                      _selectedPerson!.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connecting with:',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          _selectedPerson!.name,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.xCircle),
                    tooltip: 'Change person',
                    onPressed: () {
                      setState(() {
                        _selectedPerson = null;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _relationController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Relation Label',
                  hintText: 'e.g. Manager, Friend, Sibling',
                  prefixIcon: const Icon(LucideIcons.link),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveConnection,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Connection'),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
