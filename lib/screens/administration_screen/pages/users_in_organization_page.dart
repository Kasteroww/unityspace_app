import 'package:flutter/material.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_role_enum.dart';
import 'package:unityspace/screens/administration_screen/widgets/user_in_organization_list.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:wstore/wstore.dart';

class UsersInOrganizationPageStore extends WStore {
  WStoreStatus status = WStoreStatus.init;

  Map<int, OrganizationMember?> get members => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationMembersMap,
        keyName: 'members',
      );

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  int get organizationOwnerId => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationOwnerId,
        keyName: 'ownerId',
      );

  Future<void> deleteMember(OrganizationMember member) async {
    await SpacesStore().removeUserFromSpace(member.id);
  }

  Future<void> toggleMemberAdmin(OrganizationMember member) async {
    final isAdmin = getMemberRole(member) == OrganizationRoleEnum.admin;
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

  bool userContainsInSpaces(int memberId) {
    int spacesCount = 0;
    for (final space in spaces.list) {
      final containsItem = space.members.any((member) => member.id == memberId);
      if (containsItem) spacesCount++;
    }
    return (spacesCount != 0);
  }

  bool hasMemberEditingRights(OrganizationMember member) {
    final memberRole = getMemberRole(member);
    if ((UserStore().isOrganizationOwner &&
            memberRole == OrganizationRoleEnum.owner) ||
        (UserStore().isAdmin && memberRole != OrganizationRoleEnum.worker) ||
        (!UserStore().isAdmin && !UserStore().isOrganizationOwner)) {
      return true;
    }
    return false;
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
    return UsersInOrganizationList(
      items: store.members,
      organizationOwner: store.organizationOwnerId,
    );
  }
}
