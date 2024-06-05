interface class Identifiable {
  final int id;

  Identifiable({required this.id});
}

interface class Nameable {
  final String name;

  Nameable({required this.name});
}

/// интерфейс для enums, обязывающий их иметь хотя бы один параметр
/// нужен для работы дженерика getEnumValue
interface class EnumWithValue {
  final Object value;

  EnumWithValue(this.value);
}
