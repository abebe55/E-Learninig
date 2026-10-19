import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/course_model.dart';

String courseAsset(CourseModel course) {
  final value = '${course.title} ${course.category}'.toLowerCase();
  if (value.contains('cyber') || value.contains('security')) return 'assets/images/cyber_security.png';
  if (value.contains('mobile') || value.contains('flutter') || value.contains('android')) return 'assets/images/mobile_development.png';
  if (value.contains('design') || value.contains('ux')) return 'assets/images/uiux_design.png';
  return 'assets/images/web_development.png';
}

class CourseArt extends StatelessWidget {
  const CourseArt({super.key, required this.course, this.height = 100, this.width, this.radius = 14});
  final CourseModel course;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          courseAsset(course),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: width,
            height: height,
            color: AppTheme.paleBlue,
            alignment: Alignment.center,
            child: const Icon(Icons.school_rounded, color: AppTheme.blue, size: 36),
          ),
        ),
      );
}
