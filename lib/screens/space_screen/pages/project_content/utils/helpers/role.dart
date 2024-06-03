enum UserRoles {
  reader(0),
  initiator(1),
  member(2);

  final int value;

  const UserRoles(this.value);
}

UserRoles getUserRole(int? role) {
  switch (role) {
    case 0:
      return UserRoles.reader;
    case 1:
      return UserRoles.initiator;
    case 2:
      return UserRoles.member;
    default:
      return UserRoles.reader;
  }
}
