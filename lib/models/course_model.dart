import 'chapter_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailColor;
  final String category;
  final double rating;
  final int studentsCount;
  final List<ChapterModel> chapters;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailColor,
    required this.category,
    required this.rating,
    required this.studentsCount,
    required this.chapters,
  });

  int get totalLessons =>
      chapters.fold(0, (sum, ch) => sum + ch.lessons.length);

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        thumbnailColor: (json['thumbnailColor'] as String?) ?? '#1565C0',
        category: json['category'] as String,
        rating: (json['rating'] as num).toDouble(),
        studentsCount: json['studentsCount'] as int,
        chapters: (json['chapters'] as List<dynamic>)
            .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'thumbnailColor': thumbnailColor,
        'category': category,
        'rating': rating,
        'studentsCount': studentsCount,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };
}
