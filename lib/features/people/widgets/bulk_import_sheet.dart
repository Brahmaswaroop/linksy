import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/database/database.dart';
import '../../../core/database/repositories/people_repository.dart';
import '../../../core/services/call_log_sync_service.dart';
import '../../../core/services/contacts_service.dart';
import '../../../core/theme/app_theme.dart';

class BulkImportSheet extends ConsumerStatefulWidget {
  const BulkImportSheet({super.key});

  @override
  ConsumerState<BulkImportSheet> createState() => _BulkImportSheetState();
}

class _BulkImportSheetState extends ConsumerState<BulkImportSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;

  List<PickedContactData> _allContacts = [];
  final Set<String> _selectedContactIds = {};

  int _selectedFrequencyDays = 30;
  String _selectedCategory = 'Friend';

  static const _categories = ['Friend', 'Family', 'Colleague', 'Other'];
  static const _cadenceOptions = [
    {'label': 'Weekly', 'days': 7},
    {'label': '2 Weeks', 'days': 14},
    {'label': 'Monthly', 'days': 30},
    {'label': '2 Months', 'days': 60},
    {'label': 'Quarterly', 'days': 90},
  ];

  @override
  void initState() {
    super.initState();
    _loadDeviceContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contactsService = ref.read(contactsServiceProvider);
      final rawContacts = await contactsService.fetchAllDeviceContacts();

      // Filter out contacts that already exist in our Linksy database
      final existingPeople = await ref.read(peopleRepositoryProvider).getAllPeople();
      final existingPhones = existingPeople
          .where((p) => p.phoneNumber != null)
          .map((p) => p.phoneNumber!.replaceAll(RegExp(r'\D'), ''))
          .toSet();
      final existingSystemIds = existingPeople
          .where((p) => p.systemContactId != null)
          .map((p) => p.systemContactId!)
          .toSet();

      final availableContacts = rawContacts.where((c) {
        if (existingSystemIds.contains(c.id)) return false;
        if (c.phoneNumber != null) {
          final cleanPhone = c.phoneNumber!.replaceAll(RegExp(r'\D'), '');
          if (cleanPhone.isNotEmpty && existingPhones.contains(cleanPhone)) {
            return false;
          }
        }
        return true;
      }).toList();

      // Sort alphabetically by name
      availableContacts.sort((a, b) => a.displayName.compareTo(b.displayName));

      if (mounted) {
        setState(() {
          _allContacts = availableContacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load contacts: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelectAll(List<PickedContactData> filtered) {
    setState(() {
      final filteredIds = filtered.map((c) => c.id).toSet();
      final allFilteredSelected = filteredIds.every(_selectedContactIds.contains);

      if (allFilteredSelected) {
        _selectedContactIds.removeAll(filteredIds);
      } else {
        _selectedContactIds.addAll(filteredIds);
      }
    });
  }

  Future<void> _importSelected() async {
    if (_selectedContactIds.isEmpty) return;

    final selectedContacts = _allContacts
        .where((c) => _selectedContactIds.contains(c.id))
        .toList();

    final peopleRepo = ref.read(peopleRepositoryProvider);

    for (final contact in selectedContacts) {
      await peopleRepo.insertPerson(
        PeopleCompanion.insert(
          name: contact.displayName,
          phoneNumber: contact.phoneNumber != null
              ? Value(contact.phoneNumber!)
              : const Value.absent(),
          email: contact.email != null
              ? Value(contact.email!)
              : const Value.absent(),
          systemContactId: Value(contact.id),
          category: Value(_selectedCategory),
          targetFrequencyDays: Value(_selectedFrequencyDays),
          priorityLevel: const Value(2),
        ),
      );
    }

    // Automatically check call history for newly imported contacts
    final syncService = ref.read(callLogSyncServiceProvider);
    final syncResult = await syncService.syncCallLogs();

    if (mounted) {
      Navigator.of(context).pop();
      final callMsg = syncResult.syncedInteractionsCount > 0
          ? ' & synced ${syncResult.syncedInteractionsCount} past calls'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${selectedContacts.length} contacts$callMsg',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filtered = _allContacts.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final nameMatches = c.displayName.toLowerCase().contains(q);
      final phoneMatches = c.phoneNumber?.toLowerCase().contains(q) ?? false;
      return nameMatches || phoneMatches;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Phone Contacts',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose contacts to add to your reminder circle',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search contacts by name or phone...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Cadence & Category configuration row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Default Cadence: ',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _cadenceOptions.map((opt) {
                            final days = opt['days'] as int;
                            final isSel = _selectedFrequencyDays == days;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(opt['label'] as String),
                                selected: isSel,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _selectedFrequencyDays = days);
                                  }
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Category: ',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _selectedCategory = cat);
                                  }
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Select All / Count Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  '${_selectedContactIds.length} of ${filtered.length} selected',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: filtered.isEmpty
                      ? null
                      : () => _toggleSelectAll(filtered),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    filtered.every((c) => _selectedContactIds.contains(c.id))
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Contact list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_errorMessage!),
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.users,
                                  size: 40,
                                  color: cs.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _allContacts.isEmpty
                                      ? 'All device contacts already in Linksy!'
                                      : 'No contacts match "$_searchQuery"',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, indent: 68),
                            itemBuilder: (context, index) {
                              final contact = filtered[index];
                              final isSelected =
                                  _selectedContactIds.contains(contact.id);

                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedContactIds.add(contact.id);
                                    } else {
                                      _selectedContactIds.remove(contact.id);
                                    }
                                  });
                                },
                                secondary: CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      avatarColorFromName(contact.displayName),
                                  backgroundImage: contact.photoThumbnail != null
                                      ? MemoryImage(contact.photoThumbnail!)
                                      : null,
                                  child: contact.photoThumbnail == null
                                      ? Text(
                                          contact.displayName.isNotEmpty
                                              ? contact.displayName[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  contact.displayName,
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  contact.phoneNumber ??
                                      contact.email ??
                                      'No phone/email',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              );
                            },
                          ),
          ),

          // Bottom Action Button
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedContactIds.isEmpty ? null : _importSelected,
                  icon: const Icon(LucideIcons.userPlus, size: 18),
                  label: Text(
                    _selectedContactIds.isEmpty
                        ? 'Select Contacts to Import'
                        : 'Import ${_selectedContactIds.length} Contact${_selectedContactIds.length == 1 ? '' : 's'}',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
