class InsulinRule {
  final String comparisonType; // e.g., 'lessThan', 'greaterThanOrEqual', 'between'
  final double glucoseStart;
  final double? glucoseEnd;
  final double insulin;

  InsulinRule({
    required this.comparisonType,
    required this.glucoseStart,
    this.glucoseEnd,
    required this.insulin,
  });

  factory InsulinRule.fromJson(Map<String, dynamic> json) {
    return InsulinRule(
      comparisonType: json['comparisonType'],
      glucoseStart: (json['glucoseStart'] as num).toDouble(),
      glucoseEnd: json['glucoseEnd'] != null ? (json['glucoseEnd'] as num).toDouble() : null,
      insulin: (json['insulin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comparisonType': comparisonType,
      'glucoseStart': glucoseStart,
      'glucoseEnd': glucoseEnd,
      'insulin': insulin,
    };
  }
}