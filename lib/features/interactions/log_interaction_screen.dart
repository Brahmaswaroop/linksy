import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../core/database/database.dart';
import '../../core/database/repositories/interactions_repository.dart';
import '../../core/database/repositories/people_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neo_palette.dart';

const _channelTypes = [
  ('Message', LucideIcons.messageCircle),
  ('Call', LucideIcons.phone),
  ('Coffee / Meet', LucideIcons.coffee),
  ('Quick Note', LucideIcons.fileText),
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

  // Mode: 0 = Quick Log, 1 = Plan Future
  int _modeIndex = 0;
  String _type = 'Call';
  int _energyRating = 5;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingInteraction;
    if (existing != null) {
      _type = existing.type;
      _energyRating = existing.energyRating ?? 4;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_modeIndex == 0 ? 'Interaction logged!' : 'Catch-up scheduled!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: NeoPalette.inkBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
            ),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personStreamProvider(widget.personId));

    return Scaffold(
      backgroundColor: NeoPalette.canvasLight,
      body: personAsync.when(
        data: (person) => _buildContent(person),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(Person person) {
    final avatarBg = avatarColorFromName(person.name);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Curved Hero Header with Smooth Curves ─────────────────────
          Stack(
            children: [
              // Pastel Teal / Mint Curved Background
              CustomPaint(
                size: const Size(double.infinity, 240),
                painter: _CurvedHeroPainter(),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Back button <, Center Title, Options ::
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircularNavButton(
                            icon: LucideIcons.arrowLeft,
                            onTap: () => context.pop(),
                            tooltip: 'Back',
                          ),
                          Text(
                            _isEditing ? 'Edit Catch-up' : 'Plan Your Catch-up',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: NeoPalette.textPrimary,
                            ),
                          ),
                          _CircularNavButton(
                            icon: LucideIcons.moreHorizontal,
                            onTap: () {},
                            tooltip: 'Options',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Hero Heading
                      Text(
                        'Deepen Your\nConnection',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: NeoPalette.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Log thoughts & capture commitments while fresh.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: NeoPalette.mintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 2. Floating Form Card (Overlapping the Hero) ──────────────────
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NeoPalette.surfaceWhite,
                  borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
                  border: Border.all(color: NeoPalette.cardBorder),
                  boxShadow: NeoPalette.shadowCard,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Segmented Pill Toggle: [ Quick Log ] vs [ Future Catch-up ]
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: NeoPalette.canvasLight,
                          borderRadius:
                              BorderRadius.circular(NeoPalette.radiusPill),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SegmentPill(
                                label: 'Quick Log',
                                icon: LucideIcons.checkCheck,
                                isSelected: _modeIndex == 0,
                                onTap: () => setState(() => _modeIndex = 0),
                              ),
                            ),
                            Expanded(
                              child: _SegmentPill(
                                label: 'Future Catch-up',
                                icon: LucideIcons.calendarClock,
                                isSelected: _modeIndex == 1,
                                onTap: () => setState(() => _modeIndex = 1),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Connected Fields with Swap Icon: Person ⇄ Channel
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Column(
                            children: [
                              // Person Row
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoPalette.canvasLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: avatarBg,
                                      child: Text(
                                        person.name.isNotEmpty
                                            ? person.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'WITH',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: NeoPalette.textMuted,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            person.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: NeoPalette.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NeoPalette.surfaceWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: NeoPalette.cardBorder,
                                        ),
                                      ),
                                      child: Text(
                                        person.category,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: NeoPalette.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Channel Selector Container
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: NeoPalette.canvasLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INTERACTION CHANNEL',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: NeoPalette.textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: _channelTypes.map((c) {
                                        final (name, icon) = c;
                                        final isSelected = _type == name;
                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            child: InkWell(
                                              onTap: () =>
                                                  setState(() => _type = name),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? NeoPalette.inkBlack
                                                      : NeoPalette.surfaceWhite,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? NeoPalette.inkBlack
                                                        : NeoPalette.cardBorder,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      icon,
                                                      size: 16,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : NeoPalette
                                                              .textPrimary,
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      name.split(' ').first,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : NeoPalette
                                                                .textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Date & Time Field
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_selectedDate),
                            );
                            setState(() {
                              _selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time?.hour ?? _selectedDate.hour,
                                time?.minute ?? _selectedDate.minute,
                              );
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: NeoPalette.canvasLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: NeoPalette.skyBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.calendar,
                                  size: 16,
                                  color: NeoPalette.skyText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DATE & TIME',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: NeoPalette.textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_formatTime(_selectedDate)}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: NeoPalette.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                LucideIcons.chevronRight,
                                size: 16,
                                color: NeoPalette.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Energy Vibe Selector (1 to 5)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NeoPalette.canvasLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ENERGY VIBE AFTER',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: NeoPalette.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  _energyLabelText(_energyRating),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _energyColor(_energyRating),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [1, 2, 3, 4, 5].map((rating) {
                                final isSelected = _energyRating == rating;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _energyRating = rating),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _energyColor(rating)
                                          : NeoPalette.surfaceWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? _energyColor(rating)
                                            : NeoPalette.cardBorder,
                                      ),
                                    ),
                                    child: Text(
                                      _energyEmoji(rating),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Context Notes Input
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: NeoPalette.canvasLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INTERACTION NOTES',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: NeoPalette.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText:
                                    'What did you discuss? Key takeaways or commitments...',
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: NeoPalette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Big Full-Width Pitch Black Pill Action Button
                      InkWell(
                        onTap: _save,
                        borderRadius:
                            BorderRadius.circular(NeoPalette.radiusPill),
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: NeoPalette.inkBlack,
                            borderRadius:
                                BorderRadius.circular(NeoPalette.radiusPill),
                            boxShadow: NeoPalette.shadowCard,
                          ),
                          child: Text(
                            _isEditing
                                ? 'Update Interaction'
                                : 'Save Interaction ✨',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Relationship Sparks / Commitment Vouchers (Bottom Section) ─
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Relationship Sparks',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: NeoPalette.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Quick Templates',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NeoPalette.skyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal Tilted Voucher Cards (Inspired by the Voucher cards in image)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _VoucherCard(
                  title: 'Ask About Work',
                  subtitle: '"How is the new project or team going?"',
                  badge: '30% Faster',
                  bgColor: NeoPalette.lavenderBg,
                  accentColor: NeoPalette.lavenderText,
                  icon: LucideIcons.briefcase,
                  onApply: () {
                    final curr = _notesController.text;
                    _notesController.text = curr.isEmpty
                        ? 'Discussed work & new project progress.'
                        : '$curr\nDiscussed work & new project progress.';
                  },
                ),
                _VoucherCard(
                  title: 'Life Check-in',
                  subtitle: '"How are you feeling and holding up lately?"',
                  badge: 'High Warmth',
                  bgColor: NeoPalette.mintBg,
                  accentColor: NeoPalette.mintText,
                  icon: LucideIcons.heart,
                  onApply: () {
                    final curr = _notesController.text;
                    _notesController.text = curr.isEmpty
                        ? 'General life check-in and catch-up.'
                        : '$curr\nGeneral life check-in and catch-up.';
                  },
                ),
                _VoucherCard(
                  title: 'Future Promise',
                  subtitle: '"Promised to grab coffee or send recommendation"',
                  badge: 'Follow-up',
                  bgColor: NeoPalette.peachBg,
                  accentColor: NeoPalette.peachText,
                  icon: LucideIcons.bookmark,
                  onApply: () {
                    final curr = _notesController.text;
                    _notesController.text = curr.isEmpty
                        ? 'Follow-up commitment: Meet for coffee next week.'
                        : '$curr\nFollow-up commitment: Meet for coffee next week.';
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }

  static String _energyEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😩';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '⚡';
      default:
        return '😐';
    }
  }

  static String _energyLabelText(int rating) {
    switch (rating) {
      case 1:
        return '1/5 Draining';
      case 2:
        return '2/5 Low Energy';
      case 3:
        return '3/5 Neutral';
      case 4:
        return '4/5 Good Vibes';
      case 5:
        return '5/5 Energizing!';
      default:
        return 'Neutral';
    }
  }

  static Color _energyColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF10B981);
      case 5:
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

// ── Reusable Component Widgets for Screen 2 ────────────────────────────────

class _CircularNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircularNavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
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

class _SegmentPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? NeoPalette.inkBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(NeoPalette.radiusPill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : NeoPalette.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : NeoPalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color bgColor;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onApply;

  const _VoucherCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.bgColor,
    required this.accentColor,
    required this.icon,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: NeoPalette.shadowSoft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(NeoPalette.radiusCard),
          onTap: onApply,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 14, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: NeoPalette.surfaceWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: NeoPalette.textPrimary.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tap to insert +',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
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

class _CurvedHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6F2EB) // Soft pastel mint/cyan
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height,
        size.width,
        size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Subtle decorative concentric wave rings in corner
    final ringPaint = Paint()
      ..color = const Color(0xFFBCEAE0).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(size.width * 0.85, 40), 50, ringPaint);
    canvas.drawCircle(Offset(size.width * 0.85, 40), 75, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
