class Employee {
  final int? id;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? jobTitle;
  final String? phone;
  final DateTime? hireDate;

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.jobTitle,
    this.phone,
    this.hireDate,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      photoUrl: map['photo_url'],
      jobTitle: map['job_title'],
      phone: map['phone'],
      hireDate:
          map['hire_date'] != null ? DateTime.parse(map['hire_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'job_title': jobTitle,
      'phone': phone,
      'hire_date': hireDate?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
