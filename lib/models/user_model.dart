import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime dateOfBirth;

  @HiveField(2)
  int age;

  @HiveField(3)
  double weight;

  @HiveField(4)
  double height;

  @HiveField(5)
  String goal;

  @HiveField(6)
  String? profilePhotoPath;

  @HiveField(7)
  DateTime createdAt;

  UserModel({
    required this.name,
    required this.dateOfBirth,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    this.profilePhotoPath,
    required this.createdAt,
  });
}
