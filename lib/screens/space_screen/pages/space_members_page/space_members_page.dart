import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/space_members_page/widgets/space_member_card.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';


class SpaceMembersPageStore extends WStore {
  SpaceMembersErrors error = SpaceMembersErrors.none;

  SpacesStore spacesStore = SpacesStore();

  Space? get space => computedFromStore(
        store: spacesStore,
        getValue: (store) => store.spaces[widget.spaceId],
        keyName: 'space',
      );

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localization.invitationsViaLink),
              Switch(
                value: store.space?.shareLink.active ?? false,
                onChanged: (bool value) {},
              ),
            ],
          ),
        ),
        if (store.space?.shareLink.active ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text:
                          '${ConstantStrings.spaceInviteUrl}${store.space?.shareLink.token}',
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
                  onPressed: () => {},
                  child: Text(localization.copy),
                ),
              ],
            ),
          ),
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
            itemCount: store.space?.members.length,
            itemBuilder: (BuildContext context, int index) {
              final member = store.space?.members[index];
              if (member == null) return null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SpaceMemberInfoCard(spaceMember: member),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
