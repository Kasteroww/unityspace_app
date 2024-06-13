import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/space_members_page/widgets/space_member_card.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class SpaceMembersPageStore extends WStore {
  // GENERAL
  SpaceMembersErrors error = SpaceMembersErrors.none;
  SpacesStore spacesStore = SpacesStore();
  int spaceId = 0;

  bool isLinkEnabled = false;

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
                value: store.isLinkEnabled,
                onChanged: (bool value) {
                  store.isLinkEnabled = value;
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text:
                        'https://www.app.unityspace.ru/join/3ae45004-6b94-479a-8032-3fc9f1ec7532',
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
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const SpaceMemberCard(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
