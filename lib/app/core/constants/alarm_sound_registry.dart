class AlarmSoundRegistry {
  static const String classic = 'classic';
  static const String digitalAlarm = 'digital_alarm';
  static const String gentleBell = 'gentle_bell';
  static const String piano = 'piano';
  static const String pop = 'pop';

  static const List<String> availableSounds = [
    classic,
    digitalAlarm,
    gentleBell,
    piano,
    pop,
  ];

  static String getDisplayName(String soundId) {
    switch (soundId) {
      case digitalAlarm:
        return 'Digital Alarm';
      case gentleBell:
        return 'Gentle Bell';
      case piano:
        return 'Piano';
      case pop:
        return 'Pop';
      case classic:
      default:
        return 'Classic';
    }
  }
}
