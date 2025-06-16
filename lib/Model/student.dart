class StudentModel {
  final String id;
  final String fullName;
  final String email;
  final String gender;
  final int age;
  final String bloodGroup;
  final bool isTestCompleted;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.age,
    required this.bloodGroup,
    required this.isTestCompleted,
  });

  // Factory constructor to create a StudentModel from a map (JSON)
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      bloodGroup: json['blood_group'] ?? '',
      isTestCompleted: json['is_test_completed'] ?? false,
    );
  }

  // Named constructor for creating from a map (alternative to fromJson)
  StudentModel.fromMap(Map<String, dynamic> map)
      : id = map['id'].toString(),
        fullName = map['full_name'] ?? '',
        email = map['email'] ?? '',
        gender = map['gender'] ?? '',
        age = int.tryParse(map['age'].toString()) ?? 0,
        bloodGroup = map['blood_group'] ?? '',
        isTestCompleted = map['is_test_completed'] ?? false;

  // Convert StudentModel to a map (JSON format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'gender': gender,
      'age': age,
      'blood_group': bloodGroup,
      'is_test_completed': isTestCompleted,
    };
  }

  // Convert StudentModel to a map (alternative to toJson)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'gender': gender,
      'age': age,
      'blood_group': bloodGroup,
      'is_test_completed': isTestCompleted,
    };
  }
}
