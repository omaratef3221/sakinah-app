import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/core/widgets/empty_state.dart';
import 'package:sakinah_flow/core/shared_models/habit_category.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/habits/presentation/add_habit_screen.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

class HabitsScreen extends HookConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final fardHabitsAsync = ref.watch(watchFardHabitsProvider);
    final sunnahHabitsAsync = ref.watch(watchSunnahHabitsProvider);
    final searchQuery = useState('');
    final l = AppLocalizations.of(context);
    final themeColors = ref.watch(themeColorsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: themeColors.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, l),
                    const SizedBox(height: 24),
                    _buildSearchBar(searchQuery, l),
                    const SizedBox(height: 16),
                    _buildCategoryFilter(ref, selectedCategory, l),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _buildHabitsList(
                context,
                selectedCategory,
                fardHabitsAsync,
                sunnahHabitsAsync,
                ref,
                searchQuery.value,
                l,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.habitsTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddHabitScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Color(0xFF0A1F1A),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
      ValueNotifier<String> searchQuery, AppLocalizations l) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: TextField(
        onChanged: (value) => searchQuery.value = value,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: l.habitsSearchHint,
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          suffixIcon: searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () => searchQuery.value = '',
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
    );
  }

  Widget _buildCategoryFilter(
      WidgetRef ref, String selectedCategory, AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(l.habitsFilterAll, 'all', selectedCategory, ref),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFilterChip(l.habitsFilterFard, 'fard', selectedCategory, ref),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _buildFilterChip(l.habitsFilterSunnah, 'sunnah', selectedCategory, ref),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String selectedCategory,
    WidgetRef ref,
  ) {
    final isSelected = selectedCategory == value;

    return GestureDetector(
      onTap: () => ref.read(selectedCategoryProvider.notifier).state = value,
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFF0A1F1A) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsList(
    BuildContext context,
    String selectedCategory,
    AsyncValue<List<dynamic>> fardHabitsAsync,
    AsyncValue<List<dynamic>> sunnahHabitsAsync,
    WidgetRef ref,
    String searchQuery,
    AppLocalizations l,
  ) {
    return fardHabitsAsync.when(
      data: (fardHabits) => sunnahHabitsAsync.when(
        data: (sunnahHabits) {
          List<dynamic> habitsToShow = [];

          if (selectedCategory == 'all') {
            habitsToShow = [...fardHabits, ...sunnahHabits];
          } else if (selectedCategory == 'fard') {
            habitsToShow = fardHabits;
          } else {
            habitsToShow = sunnahHabits;
          }

          // Apply search filter
          if (searchQuery.isNotEmpty) {
            habitsToShow = habitsToShow.where((habit) {
              return habit.title.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();
          }

          if (habitsToShow.isEmpty) {
            return SliverToBoxAdapter(
              child: EmptyState(
                title: l.habitsEmptyTitle,
                subtitle: l.habitsEmptySubtitle,
                icon: Icons.add_circle_outline_rounded,
                actionText: l.habitsEmptyAction,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHabitScreen(),
                    ),
                  );
                },
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = habitsToShow[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHabitCard(context, habit, ref),
                );
              },
              childCount: habitsToShow.length,
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
    );
  }

  bool _isCompletedToday(dynamic habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final lastCompleted = habit.lastCompleted as DateTime;
    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }

  Widget _buildHabitCard(BuildContext context, dynamic habit, WidgetRef ref) {
    final isFard = habit.category == HabitCategory.fard;
    final l = AppLocalizations.of(context);

    return GestureDetector(
      onLongPress: () => _showBackdateSheet(context, ref, habit),
      child: GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  boxShadow: [
                    BoxShadow(
                      color: (isFard
                              ? const Color(0xFF10B981)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFard
                              ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669)
                                ]
                              : [
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF2563EB)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isFard
                            ? l.habitsCategoryFard
                            : l.habitsCategorySunnah,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final database = ref.read(habitsDatabaseProvider);
                  if (_isCompletedToday(habit)) {
                    // Uncomplete the habit
                    await database.uncompleteHabit(habit.id);
                  } else {
                    // Complete the habit
                    await database.completeHabit(habit.id);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: _isCompletedToday(habit)
                        ? const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                          )
                        : null,
                    color: _isCompletedToday(habit)
                        ? null
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCompletedToday(habit)
                          ? Colors.transparent
                          : const Color(0xFFD4AF37),
                      width: 2,
                    ),
                  ),
                  child: _isCompletedToday(habit)
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF0A1F1A),
                          size: 20,
                        )
                      : null,
                ),
              ),
            ],
          ),
          if (habit.ayahReference != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.ayahReference,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (habit.currentStreak > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: Color(0xFFF97316),
                ),
                const SizedBox(width: 4),
                Text(
                  l.habitsDayStreak(habit.currentStreak as int),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  // Bottom sheet that lets the user pick a past date and toggle a habit's
  // completion on that date. Triggered by long-pressing the habit card.
  Future<void> _showBackdateSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic habit,
  ) async {
    final l = AppLocalizations.of(context);
    final database = ref.read(habitsDatabaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = today.subtract(const Duration(days: 90));

    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: firstDate,
      lastDate: today,
      helpText: l.habitsBackdateHelp(habit.title as String),
      cancelText: l.commonCancel,
      confirmText: l.commonNext,
    );
    if (picked == null) return;
    if (!context.mounted) return;

    final pickedDay = DateTime(picked.year, picked.month, picked.day);
    final alreadyDone = await database.isCompletedOnDate(habit.id, pickedDay);
    if (!context.mounted) return;

    final dateLabel =
        '${pickedDay.year}-${pickedDay.month.toString().padLeft(2, '0')}-${pickedDay.day.toString().padLeft(2, '0')}';

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0F3D30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                habit.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              if (alreadyDone) ...[
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('uncomplete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(l.habitsBackdateRemove),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0A1F1A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l.habitsBackdateMarkComplete),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == 'complete') {
      await database.completeHabitOnDate(habit.id, pickedDay);
    } else if (action == 'uncomplete') {
      await database.uncompleteHabitOnDate(habit.id, pickedDay);
    }
  }
}
