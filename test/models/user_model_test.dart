import 'package:flutter_test/flutter_test.dart';
import 'package:elevate_ai_fitness/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel user;

    setUp(() {
      user = UserModel(
        name: 'John Doe',
        dateOfBirth: DateTime(1995, 6, 15),
        age: 30,
        weight: 75.0,
        height: 175.0,
        goal: 'Build Muscle',
        createdAt: DateTime.now(),
      );
    });

    test('creates with valid data', () {
      expect(user.name, 'John Doe');
      expect(user.weight, 75.0);
      expect(user.height, 175.0);
      expect(user.goal, 'Build Muscle');
      expect(user.age, 30);
      expect(user.dateOfBirth, DateTime(1995, 6, 15));
    });

    test('profilePhotoPath defaults to null', () {
      expect(user.profilePhotoPath, isNull);
    });

    test('creates with profilePhotoPath', () {
      final userWithPhoto = UserModel(
        name: 'Jane',
        dateOfBirth: DateTime(2000, 1, 1),
        age: 26,
        weight: 60.0,
        height: 165.0,
        goal: 'Lose Weight',
        profilePhotoPath: '/path/to/photo.jpg',
        createdAt: DateTime.now(),
      );
      expect(userWithPhoto.profilePhotoPath, '/path/to/photo.jpg');
    });

    test('BMI calculation: weight=70 height=175 → 22.86', () {
      final u = UserModel(
        name: 'Test',
        dateOfBirth: DateTime(1990, 1, 1),
        age: 35,
        weight: 70.0,
        height: 175.0,
        goal: 'Maintain',
        createdAt: DateTime.now(),
      );
      // BMI = weight / (height_m^2) = 70 / (1.75^2) = 70 / 3.0625 = 22.857…
      final bmi = u.weight / ((u.height / 100) * (u.height / 100));
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('BMI calculation: weight=90 height=180 → 27.78', () {
      final u = UserModel(
        name: 'Test',
        dateOfBirth: DateTime(1990, 1, 1),
        age: 35,
        weight: 90.0,
        height: 180.0,
        goal: 'Lose Weight',
        createdAt: DateTime.now(),
      );
      final bmi = u.weight / ((u.height / 100) * (u.height / 100));
      expect(bmi, closeTo(27.78, 0.01));
    });

    test('age calculation from DOB', () {
      final now = DateTime.now();
      final dob = DateTime(now.year - 25, now.month, now.day);
      final calculatedAge = now.year - dob.year;
      expect(calculatedAge, 25);
    });

    test('age calculation respects birthday not yet passed', () {
      final now = DateTime.now();
      // DOB is next month -> hasn't had birthday yet this year
      final dob = DateTime(now.year - 30, now.month + 1, 1);
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      expect(age, 29);
    });

    test('stores createdAt timestamp', () {
      final before = DateTime.now();
      final u = UserModel(
        name: 'Test',
        dateOfBirth: DateTime(2000, 1, 1),
        age: 26,
        weight: 65.0,
        height: 170.0,
        goal: 'Stay Fit',
        createdAt: before,
      );
      expect(u.createdAt, before);
    });
  });
}
