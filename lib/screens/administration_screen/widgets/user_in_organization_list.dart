import 'package:flutter/material.dart';
import 'package:unityspace/screens/administration_screen/pages/users_in_organization_page.dart';
import 'package:unityspace/screens/administration_screen/widgets/user_in_organization_info_card.dart';

/// Список дней уведомлений
class UsersInOrganizationList extends StatelessWidget {
  final List<OrganizationMemberInfo> items;
  final int organizationOwner;

  const UsersInOrganizationList({
    required this.items,
    required this.organizationOwner,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final member = items[index];
        return Padding(
          key: ValueKey(items[index].id),
          padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: UserInOrganizationInfoCard(
              organizationMember: member,
            ),
          ),
        );
      },
    );
  }
}
