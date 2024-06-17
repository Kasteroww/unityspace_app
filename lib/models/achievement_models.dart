import 'package:unityspace/service/exceptions/data_exceptions.dart';

enum AchievementTypes { firstReglament }

extension AchievementTypesExtension on String {
  AchievementTypes toAchievementType() {
    switch (this) {
      case 'first_reglament':
        return AchievementTypes.firstReglament;
      default:
        throw FormatException('Unknown achievement type: $this');
    }
  }
}

class AchievementResponse {
  final String? name;
  final String? text;
  final AchievementTypes type;

  AchievementResponse({
    required this.name,
    required this.text,
    required this.type,
  });

  factory AchievementResponse.fromJson(Map<String, dynamic> json) {
    try {
      return AchievementResponse(
        name: json['name'] as String?,
        text: json['text'] as String?,
        type: (json['type'] as String).toAchievementType(),
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}
