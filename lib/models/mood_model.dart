class MoodData {
  final String label;
  final String emoji;

  const MoodData({required this.label, required this.emoji});

  static const List<MoodData> all = [
    MoodData(label: 'Mal', emoji: '😡'),
    MoodData(label: 'Triste', emoji: '😔'),
    MoodData(label: 'Neutral', emoji: '😐'),
    MoodData(label: 'Bien', emoji: '😊'),
    MoodData(label: 'Excelente', emoji: '🤩'),
  ];

  static String getEmoji(String? label) {
    if (label == null) return "😶";
    return all
        .firstWhere(
          (m) => m.label == label,
          orElse: () => const MoodData(label: '', emoji: "😶"),
        )
        .emoji;
  }
}
