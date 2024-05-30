import 'package:unityspace/models/i_base_model.dart';

class ColorType implements Nameable {
  final String colorHex;

  @override
  final String name;

  const ColorType({required this.colorHex, required this.name});

  ColorType copyWith({
    String? colorHex,
    String? name,
  }) {
    return ColorType(
      colorHex: colorHex ?? this.colorHex,
      name: name ?? this.name,
    );
  }
}
