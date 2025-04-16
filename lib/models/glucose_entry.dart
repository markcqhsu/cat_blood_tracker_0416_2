import 'package:uuid/uuid.dart';

class GlucoseEntry {
  final String id;
  final DateTime dateTime;
  final int bloodGlucose;
  final double insulinDose;
  final double? weight;

  GlucoseEntry({
    String? id,
    required this.dateTime,
    required this.bloodGlucose,
    required this.insulinDose,
    this.weight,
  }) : id = id ?? const Uuid().v4();

  factory GlucoseEntry.fromJson(Map<String, dynamic> json) {
    return GlucoseEntry(
      id: json['id'] as String?,
      dateTime: DateTime.parse(json['dateTime']),
      bloodGlucose: json['bloodGlucose'],
      insulinDose: json['insulinDose'].toDouble(),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'bloodGlucose': bloodGlucose,
      'insulinDose': insulinDose,
      'weight': weight,
    };
  }
}