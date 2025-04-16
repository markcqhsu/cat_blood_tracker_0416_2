class GlucoseEntry {
  final DateTime dateTime;
  final int bloodGlucose;
  final double insulinDose;
  final double? weight;

  GlucoseEntry({
    required this.dateTime,
    required this.bloodGlucose,
    required this.insulinDose,
    this.weight,
  });
}
