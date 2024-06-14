import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_members_editing_rights_enum.dart';
import 'package:unityspace/screens/space_screen/pages/space_members_page/widgets/space_member_card.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

enum SpaceMemberRoleEnum { reader, initiator, participant }

class SpaceMemberInfo {
  int id;
  String name;
  String email;
  SpaceMemberRoleEnum role;

  SpaceMemberInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  int getRoleId() {
    switch (role) {
      case SpaceMemberRoleEnum.participant:
        return 2;
      case SpaceMemberRoleEnum.initiator:
        return 1;
      case SpaceMemberRoleEnum.reader:
        return 0;
    }
  }
}

class SpaceMembersPageStore extends WStore {
  SpaceMembersErrors error = SpaceMembersErrors.none;

  SpacesStore spacesStore = SpacesStore();
  UserStore userStore = UserStore();

  Space? get space => computedFromStore(
        store: spacesStore,
        getValue: (store) => store.spaces[widget.spaceId],
        keyName: 'space',
      );
  User? get user => computedFromStore(
        store: userStore,
        getValue: (store) => store.user,
        keyName: 'user',
      );

  int? get organizationOwnerId => computedFromStore(
        store: userStore,
        getValue: (store) => store.organizationOwnerId,
        keyName: 'ownerId',
      );

  List<SpaceMemberInfo> get spaceMembersForDisplay => computed(
        getValue: () {
          return space!.members
              .map(
                (member) => SpaceMemberInfo(
                  id: member.id,
                  name: member.name,
                  email: member.email,
                  role: SpaceMemberRoleEnum.values[member.role],
                ),
              )
              .toList();
        },
        watch: () => [user, space],
        keyName: 'orgMembers',
      );

  Future<void> copyInviteLink() async {
    await Clipboard.setData(
      ClipboardData(
        text: getShareLink(),
      ),
    );
  }

  Future<void> setSpaceIviteLinkActive(bool isActive) async {
    final spaceId = space?.id;
    if (spaceId == null) return;
    await spacesStore.setSpaceIviteLinkActive(
      spaceId: spaceId,
      isActive: isActive,
    );
  }

  OrganizationMembersEditingRightsEnum getUserEditRights({
    SpaceMemberInfo? member,
  }) {
    final userRole = spaceMembersForDisplay
        .firstWhere((member) => member.id == user?.id)
        .role;
    final userIsOwnerOrAdmin = userStore.isOwnerOrAdmin;
    final userIsParticipant = userRole == SpaceMemberRoleEnum.participant;
    if (member == null) {
      if (userIsOwnerOrAdmin || userIsParticipant) {
        return OrganizationMembersEditingRightsEnum.full;
      }
      return OrganizationMembersEditingRightsEnum.none;
    } else {
      final isCurrentUser = member.id == user?.id;
      if (userIsOwnerOrAdmin && !isCurrentUser) {
        return OrganizationMembersEditingRightsEnum.full;
      } else if (userIsParticipant || userIsOwnerOrAdmin) {
        return OrganizationMembersEditingRightsEnum.delete;
      }
      return OrganizationMembersEditingRightsEnum.none;
    }
  }

  Future<void> removeMemberFromSpace(int memberId) async {
    if (space == null) return;
    final uniqueSpaceUsersCount =
        await spacesStore.removeUserFromSpace(memberId, space!.id);
    if (uniqueSpaceUsersCount != null) {
      userStore.setUniqueSpaceUsersCountLocally(uniqueSpaceUsersCount);
    }
  }

  Future<void> setSpaceMemberRole(
    final int memberId,
    final int role,
  ) async {
    if (space == null) return;
    await spacesStore.setSpaceMemberRole(memberId, space!.id, role);
  }

  bool isShareLinkActive() {
    return space?.shareLink.active ?? false;
  }

  String getShareLink() {
    return '${ConstantStrings.spaceInviteUrl}${space?.shareLink.token}';
  }

  @override
  SpaceMembersPage get widget => super.widget as SpaceMembersPage;
}

class SpaceMembersPage extends WStoreWidget<SpaceMembersPageStore> {
  const SpaceMembersPage({
    required this.spaceId,
    super.key,
  });

  final int spaceId;

  @override
  SpaceMembersPageStore createWStore() => SpaceMembersPageStore();

  @override
  Widget build(BuildContext context, SpaceMembersPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder<SpaceMembersPageStore>(
      store: store,
      watch: (store) => [store.space],
      builder: (context, store) {
        return Column(
          children: [
            if (store.getUserEditRights() ==
                OrganizationMembersEditingRightsEnum.full)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(localization.invitationsViaLink),
                    Switch(
                      value: store.isShareLinkActive(),
                      onChanged: (bool value) {
                        store.setSpaceIviteLinkActive(value);
                      },
                    ),
                  ],
                ),
              ),
            if (store.isShareLinkActive() &&
                store.getUserEditRights() ==
                    OrganizationMembersEditingRightsEnum.full)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: store.getShareLink(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: ColorConstants.grey01,
                        backgroundColor: ColorConstants.grey08,
                      ),
                      onPressed: () => {
                        store.copyInviteLink(),
                      },
                      child: Text(localization.copy),
                    ),
                  ],
                ),
              ),
            if (store.getUserEditRights() ==
                OrganizationMembersEditingRightsEnum.full)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: ColorConstants.grey01,
                          backgroundColor: ColorConstants.grey08,
                        ),
                        onPressed: () => {},
                        child: Text(localization.inviteNewMember),
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: ListView.builder(
                itemCount: store.spaceMembersForDisplay.length,
                itemBuilder: (BuildContext context, int index) {
                  final member = store.spaceMembersForDisplay[index];
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                    child: ClipRRect(
                      key: ValueKey(member.id),
                      borderRadius: BorderRadius.circular(8),
                      child: SpaceMemberInfoCard(spaceMember: member),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
