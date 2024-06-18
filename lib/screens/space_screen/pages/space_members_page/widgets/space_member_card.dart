import 'package:flutter/material.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_members_editing_rights_enum.dart';
import 'package:unityspace/screens/space_screen/pages/space_members_page/space_members_page.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/default_pop_up_button.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/pop_up_menu_child.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class SpaceMemberInfoCard extends StatelessWidget {
  final SpaceMemberInfo spaceMember;

  const SpaceMemberInfoCard({
    required this.spaceMember,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final OrganizationMembersEditingRightsEnum editingRights = context
        .wstore<SpaceMembersPageStore>()
        .getUserEditRights(member: spaceMember);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: UserAvatarWidget(
                      id: spaceMember.id,
                      width: 30,
                      height: 30,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spaceMember.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          spaceMember.email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (editingRights !=
                      OrganizationMembersEditingRightsEnum.none)
                    DefaultPopUpButton(
                      child: Text(
                        spaceMember.role.localize(localization: localization),
                      ),
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          if (editingRights ==
                              OrganizationMembersEditingRightsEnum.full)
                            PopupMenuItem(
                              child: PopupMenuItemChild(
                                text: localization.reader,
                              ),
                              onTap: () {
                                context
                                    .wstore<SpaceMembersPageStore>()
                                    .setSpaceMemberRole(spaceMember.id, 0);
                              },
                            ),
                          if (editingRights ==
                              OrganizationMembersEditingRightsEnum.full)
                            PopupMenuItem(
                              child: PopupMenuItemChild(
                                text: localization.initiator,
                              ),
                              onTap: () {
                                context
                                    .wstore<SpaceMembersPageStore>()
                                    .setSpaceMemberRole(spaceMember.id, 1);
                              },
                            ),
                          if (editingRights ==
                              OrganizationMembersEditingRightsEnum.full)
                            PopupMenuItem(
                              child: PopupMenuItemChild(
                                text: localization.participant,
                              ),
                              onTap: () {
                                context
                                    .wstore<SpaceMembersPageStore>()
                                    .setSpaceMemberRole(spaceMember.id, 2);
                              },
                            ),
                          PopupMenuItem(
                            child: PopupMenuItemChild(
                              text: localization.delete,
                            ),
                            onTap: () {
                              context
                                  .wstore<SpaceMembersPageStore>()
                                  .removeMemberFromSpace(spaceMember.id);
                            },
                          ),
                        ];
                      },
                    ),
                  if (context
                          .wstore<SpaceMembersPageStore>()
                          .getUserEditRights() ==
                      OrganizationMembersEditingRightsEnum.none)
                    Text(
                      spaceMember.role.localize(localization: localization),
                    ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
