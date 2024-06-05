import 'package:unityspace/models/model_interfaces.dart';
import 'package:unityspace/utils/helpers.dart';

enum UserRoles implements EnumWithValue {
  reader(0),
  initiator(1),
  member(2);

  @override
  final int value;

  const UserRoles(this.value);
}

UserRoles getUserRole(int role) {
  return getEnumValue(role, enumValues: UserRoles.values);
}
