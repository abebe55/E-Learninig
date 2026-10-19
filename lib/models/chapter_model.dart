import 'lesson_model.dart';

class ChapterModel {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  ChapterModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
        id: json['id'] as String,
        title: json['title'] as String,
        lessons: (json['lessons'] as List<dynamic>)
            .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };
}
