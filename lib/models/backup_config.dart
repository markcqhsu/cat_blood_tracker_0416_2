class BackupConfig {
  bool autoBackup;
  String frequency; // 'Daily', 'Weekly', 'Monthly'
  String location;

  BackupConfig({
    this.autoBackup = false,
    this.frequency = 'Daily',
    this.location = 'Internal Storage',
  });
}
