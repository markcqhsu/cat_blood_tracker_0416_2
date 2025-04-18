class InsulinRuleModel {
  final String? catId;
  final String comparisonType;
  final double glucoseStart;
  final double? glucoseEnd;
  final double insulin;

  InsulinRuleModel({
    this.catId,
    required this.comparisonType,
    required this.glucoseStart,
    this.glucoseEnd,
    required this.insulin,
  });

  factory InsulinRuleModel.fromJson(Map<String, dynamic> json) {
    return InsulinRuleModel(
      catId: json['catId'] as String?,
      comparisonType: json['comparisonType'] as String,
      glucoseStart: (json['glucoseStart'] as num).toDouble(),
      glucoseEnd:
          json['glucoseEnd'] != null
              ? (json['glucoseEnd'] as num).toDouble()
              : null,
      insulin: (json['insulin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catId': catId,
      'comparisonType': comparisonType,
      'glucoseStart': glucoseStart,
      'glucoseEnd': glucoseEnd,
      'insulin': insulin,
    };
  }
}
