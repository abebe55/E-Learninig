import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../services/learnflow_store.dart';
import '../../widgets/course_card.dart';
import '../course_detail_screen.dart';

/// Course catalog with live search and category filter chips.
class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Programming', 'Design', 'Security'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LearnFlowStore.instance,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();
        final courses = LearnFlowStore.instance.courses.where((course) {
          final matchesCategory = _selectedCategory == 'All' ||
              course.category
                  .toLowerCase()
                  .contains(_selectedCategory.toLowerCase()) ||
              (_selectedCategory == 'Security' &&
                  course.title.toLowerCase().contains('security'));
          final matchesQuery = query.isEmpty ||
              course.title.toLowerCase().contains(query) ||
              course.description.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            const Text(
              'Explore Courses',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 16),
            // Search field
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search courses...',
                suffixIcon: Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(height: 12),
            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final selected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                      showCheckmark: false,
                      selectedColor: AppTheme.paleBlue,
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: selected ? AppTheme.blue : AppTheme.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            // Results
            if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No courses found. Try another search.',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ),
              )
            else
              ...courses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: CourseCard(
                    course: course,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: course),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
