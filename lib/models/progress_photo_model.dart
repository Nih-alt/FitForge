import 'package:hive/hive.dart';

part 'progress_photo_model.g.dart';

@HiveType(typeId: 6)
class ProgressPhotoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  double weight;

  ProgressPhotoModel({
    required this.id,
    required this.date,
    required this.imagePath,
    required this.weight,
  });
}
