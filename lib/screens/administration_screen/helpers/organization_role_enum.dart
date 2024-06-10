enum OrganizationRoleEnum {
  owner(1),
  admin(2),
  worker(3),
  invite(4);

  final int value;
  const OrganizationRoleEnum(this.value);
}
