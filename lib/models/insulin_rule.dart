class InsulinRuleModel {
  final String comparisonType;
  final double glucoseStart;
  final double? glucoseEnd;
  final double insulin;

  InsulinRuleModel({
    required this.comparisonType,
    required this.glucoseStart,
    this.glucoseEnd,
    required this.insulin,
  });

  factory InsulinRuleModel.fromJson(Map<String, dynamic> json) {
    return InsulinRuleModel(
      comparisonType: json['comparisonType'] as String,
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