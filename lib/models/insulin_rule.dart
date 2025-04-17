// import 'package:flutter/foundation.dart';

class InsulinRule {
  final String comparison;
  final double glucose;
  final int insulin;

  InsulinRule({
    required this.comparison,
    required this.glucose,
    required this.insulin,
  });

  factory InsulinRule.fromJson(Map<String, dynamic> json) {
    return InsulinRule(
      comparison: json['comparison'],
      glucose: json['glucose'] != null ? (json['glucose'] as num).toDouble() : 0.0,
      insulin: (json['insulin'] is int)
          ? json['insulin'] as int
          : (json['insulin'] as num?)?.round() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'comparison': comparison,
    'glucose': glucose,
    'insulin': insulin,
  };
}