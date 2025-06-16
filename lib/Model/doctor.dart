class Doctor {
  final String id;
  final String fullName;
  final String email;
  final String status;
  final String assignedInstitute;

  Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.status,
    required this.assignedInstitute,
  });

  // Factory method to convert JSON into Doctor object
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'].toString(),
      fullName: json['full_name'].toString(),
      email: json['email'].toString(),
      status: json['status'].toString(),
      assignedInstitute: json['assigned_institute'].toString(),
    );
  }
}
