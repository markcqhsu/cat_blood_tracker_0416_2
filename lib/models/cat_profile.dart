// import 'package:flutter/foundation.dart';

class CatProfile {
  final String id;
  String name;
  double? weight;
  int? age;

  CatProfile({
    required this.id,
    required this.name,
    this.weight,
    this.age,
  });

  // Optional: Convert to/from Map for storage or JSON usage
  factory CatProfile.fromMap(Map<String, dynamic> map) {
    return CatProfile(
      id: map['id'],
      name: map['name'],
      weight: map['weight']?.toDouble(),
      age: map['age'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'age': age,
    };
  }
}
