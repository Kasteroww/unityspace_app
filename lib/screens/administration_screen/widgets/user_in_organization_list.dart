import 'package:flutter/material.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_role_enum.dart';
import 'package:unityspace/screens/administration_screen/widgets/user_in_organization_info_card.dart';

/// Список дней уведомлений
class UsersInOrganizationList extends StatelessWidget {
  final Map<int, OrganizationMember?> items;
  final int organizationOwner;

  const UsersInOrganizationList({
    required this.items,
    required this.organizationOwner,
    super.key,
  });

  OrganizationRoleEnum role(OrganizationMember member) {
    if (member.id == organizationOwner) {
      return OrganizationRoleEnum.owner;
    } else {
      return member.isAdmin
          ? OrganizationRoleEnum.admin
          : OrganizationRoleEnum.worker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final member = items.values.elementAt(index);
        if (member != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: UserInOrganizationInfoCard(
                organizationMember: member,
                role: role(member),
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
