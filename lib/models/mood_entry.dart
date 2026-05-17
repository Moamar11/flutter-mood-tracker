import 'dart:ui';

/// Represents the different mood types a user can log.
enum MoodType {
  ecstatic,
  happy,
  neutral,
  sad,
  awful,
}

/// A single logged mood entry with a timestamp.
class MoodEntry {
  final String id;
  final MoodType mood;
  final DateTime timestamp;
  final String? note;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood.index,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        mood: MoodType.values[json['mood'] as int],
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
      );

  // ---------------------------------------------------------------------------
  // Convenience helpers
  // ---------------------------------------------------------------------------

  /// Display label for the mood.
  String get label {
    switch (mood) {
      case MoodType.ecstatic:
        return 'Ecstatic';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.awful:
        return 'Awful';
    }
  }

  /// Primary accent color for the mood.
  Color get color {
    switch (mood) {
      case MoodType.ecstatic:
        return const Color(0xFFFFD700);   // gold
      case MoodType.happy:
        return const Color(0xFF4CAF50);   // green
      case MoodType.neutral:
        return const Color(0xFF42A5F5);   // blue
      case MoodType.sad:
        return const Color(0xFF7E57C2);   // purple
      case MoodType.awful:
        return const Color(0xFFEF5350);   // red
    }
  }

  /// Lighter version used for backgrounds.
  Color get lightColor {
    switch (mood) {
      case MoodType.ecstatic:
        return const Color(0xFFFFF9C4);
      case MoodType.happy:
        return const Color(0xFFC8E6C9);
      case MoodType.neutral:
        return const Color(0xFFBBDEFB);
      case MoodType.sad:
        return const Color(0xFFD1C4E9);
      case MoodType.awful:
        return const Color(0xFFFFCDD2);
    }
  }

  /// Short emoji-free icon character for compact display.
  String get icon {
    switch (mood) {
      case MoodType.ecstatic:
        return '★';
      case MoodType.happy:
        return '♥';
      case MoodType.neutral:
        return '●';
      case MoodType.sad:
        return '◆';
      case MoodType.awful:
        return '▼';
    }
  }
}
