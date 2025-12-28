import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/habits/data/models/habit_data_model.dart';
import 'package:sakinah_flow/features/habits/data/database/habits_database.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:drift/drift.dart' as drift;

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  List<HabitDataModel> _allPresetHabits = [];
  List<HabitDataModel> _filteredHabits = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;
  final Set<String> _selectedHabitTitles = {};
  Set<String> _existingHabitTitles = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load existing habits from database
      final database = ref.read(habitsDatabaseProvider);
      final existingHabits = await database.getAllHabits();

      // Load preset habits from JSON
      final jsonString = await rootBundle.loadString('assets/data/preset_habits.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final habitsData = HabitsJsonData.fromJson(jsonData);

      setState(() {
        _existingHabitTitles = existingHabits.map((h) => h.title).toSet();
        _allPresetHabits = [...habitsData.fardHabits, ...habitsData.sunnahHabits];
        _filteredHabits = _allPresetHabits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading habits: $e')),
        );
      }
    }
  }

  void _filterHabits(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<HabitDataModel> filtered = _allPresetHabits;

    // Apply category filter
    if (_selectedCategory != 'all') {
      filtered = filtered.where((h) => h.category.name == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((h) {
        return h.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               h.titleArabic.contains(_searchQuery) ||
               h.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    _filteredHabits = filtered;
  }

  void _toggleHabitSelection(HabitDataModel habit) {
    // Don't allow selecting already-added habits
    if (_existingHabitTitles.contains(habit.title)) {
      return;
    }

    setState(() {
      if (_selectedHabitTitles.contains(habit.title)) {
        _selectedHabitTitles.remove(habit.title);
      } else {
        _selectedHabitTitles.add(habit.title);
      }
    });
  }

  Future<void> _addSelectedHabits() async {
    if (_selectedHabitTitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one habit')),
      );
      return;
    }

    final database = ref.read(habitsDatabaseProvider);

    try {
      for (final habitTitle in _selectedHabitTitles) {
        final habit = _allPresetHabits.firstWhere((h) => h.title == habitTitle);

        await database.createHabit(
          HabitsCompanion.insert(
            title: habit.title,
            category: habit.category,
            ayahReference: drift.Value(habit.ayahReference),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${_selectedHabitTitles.length} habit(s) successfully!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding habits: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A5F4E),
              Color(0xFF0F3D30),
              Color(0xFF0A1F1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryFilter(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                      )
                    : _buildHabitsList(),
              ),
              if (_selectedHabitTitles.isNotEmpty) _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Habits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Text(
                  'إضافة العادات',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedHabitTitles.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedHabitTitles.length} selected',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1F1A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _applyFilters();
            });
          },
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Type a habit to search for',
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.black.withValues(alpha: 0.5),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchQuery = '';
                        _applyFilters();
                      });
                    },
                    child: Icon(
                      Icons.clear_rounded,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip('All', 'الكل', 'all'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterChip('Fard', 'فرض', 'fard'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterChip('Sunnah', 'سنة', 'sunnah'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String arabicLabel, String value) {
    final isSelected = _selectedCategory == value;

    return GestureDetector(
      onTap: () => _filterHabits(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF0A1F1A) : Colors.white,
              ),
            ),
            Text(
              arabicLabel,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF0A1F1A).withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList() {
    if (_filteredHabits.isEmpty) {
      return const Center(
        child: Text(
          'No habits found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = _filteredHabits[index];
        final isSelected = _selectedHabitTitles.contains(habit.title);
        final isAlreadyAdded = _existingHabitTitles.contains(habit.title);
        final isFard = habit.category == HabitCategory.fard;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _toggleHabitSelection(habit),
            child: Opacity(
              opacity: isAlreadyAdded ? 0.5 : 1.0,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      )
                    : null,
                child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFard
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isFard ? Icons.star_rounded : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          habit.titleArabic,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isAlreadyAdded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Added',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF0A1F1A),
                              size: 18,
                            )
                          : null,
                    ),
                ],
              ),
            ),
              ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0A1F1A).withValues(alpha: 0.9),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _addSelectedHabits,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            'Add ${_selectedHabitTitles.length} Habit${_selectedHabitTitles.length > 1 ? 's' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1F1A),
            ),
          ),
        ),
      ),
    );
  }
}
