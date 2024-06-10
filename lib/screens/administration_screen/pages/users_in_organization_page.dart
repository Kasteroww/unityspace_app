import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_members_editing_rights_enum.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_role_enum.dart';
import 'package:unityspace/screens/administration_screen/widgets/user_in_organization_list.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class OrganizationMemberInfo {
  final int id;
  final String name;
  final String spaces;
  final OrganizationRoleEnum role;
  final String email;
  final DateTime? lastActivityDate;

  OrganizationMemberInfo({
    required this.id,
    required this.name,
    required this.spaces,
    required this.role,
    required this.email,
    required this.lastActivityDate,
  });
}

class UsersInOrganizationPageStore extends WStore {
  WStoreStatus status = WStoreStatus.init;

  OrganizationMembers get members => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationMembers,
        keyName: 'members',
      );

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  int? get organizationOwnerId => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationOwnerId,
        keyName: 'ownerId',
      );

  List<OrganizationMemberInfo> get orgMembersForDisplay => computed(
        getValue: () {
          return generateMembersInfo();
        },
        watch: () => [members, spaces],
        keyName: 'orgMembers',
      );

  List<OrganizationMemberInfo> generateMembersInfo() {
    final List<int> userIds = [];
    for (final space in spaces.list) {
      for (final member in space.members) {
        if (!userIds.contains(member.id)) {
          userIds.add(member.id);
        }
      }
    }
    final membersInfo = members.list
        .where((member) => userIds.contains(member.id) || member.isAdmin)
        .map(
          (member) => OrganizationMemberInfo(
            id: member.id,
            name: member.name,
            spaces: getMemberSpaces(member.id),
            role: getMemberRole(member),
            email: member.email,
            lastActivityDate: member.lastActivityDate,
          ),
        )
        .toList();
    membersInfo.sort((a, b) => a.role.value.compareTo(b.role.value));
    final invitedMembers = spaces.list.expand(
      (space) => space.invites.map(
        (invite) => OrganizationMemberInfo(
          id: invite.id,
          name: invite.email,
          spaces: space.name,
          role: OrganizationRoleEnum.invite,
          email: '',
          lastActivityDate: null,
        ),
      ),
    );
    membersInfo.addAll(invitedMembers);
    return membersInfo;
  }

  Future<void> deleteMember(OrganizationMemberInfo member) async {
    if (member.role != OrganizationRoleEnum.invite) {
      final uniqueSpaceUsersCount =
          await SpacesStore().removeUserFromSpace(member.id);
      if (uniqueSpaceUsersCount != null) {
        UserStore().setUniqueSpaceUsersCountLocally(uniqueSpaceUsersCount);
      }
    } else {
      for (final space in spaces.list) {
        final index =
            space.invites.indexWhere((invite) => invite.id == member.id);
        if (index != -1) {
          final uniqueSpaceUsersCount =
              await SpacesStore().removeInviteFromSpace(space.id, member.id);
          UserStore().setUniqueSpaceUsersCountLocally(uniqueSpaceUsersCount);
          return;
        }
      }
    }
  }

  Future<void> toggleMemberAdmin(OrganizationMemberInfo member) async {
    final isAdmin = member.role == OrganizationRoleEnum.admin;
    await UserStore().setIsAdmin(member.id, !isAdmin);
  }

  String getMemberSpaces(int memberId) {
    final List<String> spaceNames = [];
    for (final space in spaces.list) {
      final containsItem = space.members.any((member) => member.id == memberId);
      if (containsItem) {
        spaceNames.add(space.name);
      }
    }
    return spaceNames.join(', ');
  }

  OrganizationMembersEditingRightsEnum hasMemberEditingRights(
    OrganizationRoleEnum role,
  ) {
    if (UserStore().isOrganizationOwner && role != OrganizationRoleEnum.owner) {
      return OrganizationMembersEditingRightsEnum.full;
    } else if ((UserStore().isAdmin && role == OrganizationRoleEnum.worker) ||
        (UserStore().isAdmin && role == OrganizationRoleEnum.invite)) {
      return OrganizationMembersEditingRightsEnum.delete;
    } else {
      return OrganizationMembersEditingRightsEnum.none;
    }
  }

  OrganizationRoleEnum getMemberRole(OrganizationMember member) {
    if (member.id == organizationOwnerId) {
      return OrganizationRoleEnum.owner;
    } else {
      return member.isAdmin
          ? OrganizationRoleEnum.admin
          : OrganizationRoleEnum.worker;
    }
  }

  @override
  UsersInOrganizationPage get widget => super.widget as UsersInOrganizationPage;
}

class UsersInOrganizationPage
    extends WStoreWidget<UsersInOrganizationPageStore> {
  const UsersInOrganizationPage({
    super.key,
  });

  @override
  UsersInOrganizationPageStore createWStore() => UsersInOrganizationPageStore();

  @override
  Widget build(BuildContext context, UsersInOrganizationPageStore store) {
    final owner = store.organizationOwnerId;
    final localization = LocalizationHelper.getLocalizations(context);
    if (owner == null) {
      return const SizedBox.shrink();
    }
    return WStoreBuilder(
      store: store,
      watch: (store) => [store.orgMembersForDisplay],
      builder: (context, store) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.twoUsers,
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${localization.total_members}: ${store.orgMembersForDisplay.length}',
                  ),
                ],
              ),
            ),
            Expanded(
              child: UsersInOrganizationList(
                items: store.orgMembersForDisplay,
                organizationOwner: owner,
              ),
            ),
          ],
        );
      },
    );
  }
}
