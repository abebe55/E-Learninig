class LessonModel {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;

  LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        id: json['id'] as String,
        title: json['title'] as String,
        duration: json['duration'] as String,
        videoUrl: json['videoUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'videoUrl': videoUrl,
      };
}
