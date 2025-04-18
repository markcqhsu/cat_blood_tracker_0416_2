import 'package:flutter/material.dart';

class ChartLimit {
  final String catId;
  final double lower;
  final double upper;
  final Color lowerColor;
  final Color upperColor;

  ChartLimit({
    required this.catId,
    required this.lower,
    required this.upper,
    required this.lowerColor,
    required this.upperColor,
  });

  Map<String, dynamic> toJson() => {
    'catId': catId,
    'lower': lower,
    'upper': upper,
    'lowerColor': lowerColor.value,
    'upperColor': upperColor.value,
  };

  factory ChartLimit.fromJson(Map<String, dynamic> json) => ChartLimit(
    catId: json['catId'],
    lower: (json['lower'] as num).toDouble(),
    upper: (json['upper'] as num).toDouble(),
    lowerColor: Color(json['lowerColor']),
    upperColor: Color(json['upperColor']),
  );
}
