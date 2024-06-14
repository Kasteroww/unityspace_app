import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/space_members_page/widgets/popup_menu_members_actions_item.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/localization_helper.dart';

class SpaceMemberInfoCard extends StatelessWidget {
  final SpaceMember spaceMember;

  const SpaceMemberInfoCard({
    required this.spaceMember,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
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
                  PopupMenuButton<PopupMenuMembersActionItem>(
                    elevation: 1,
                    color: Colors.white,
                    child: Text(
                      switch (spaceMember.role) {
                        1 => localization.initiator,
                        2 => localization.participant,
                        int() => localization.reader,
                      },
                    ),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<PopupMenuMembersActionItem>>[
                        PopupMenuItem<PopupMenuMembersActionItem>(
                          child: PopupMenuMembersActionItem(
                            child: Text(
                              localization.reader,
                            ),
                          ),
                          onTap: () {},
                        ),
                        PopupMenuItem<PopupMenuMembersActionItem>(
                          child: PopupMenuMembersActionItem(
                            child: Text(localization.initiator),
                          ),
                          onTap: () {},
                        ),
                        PopupMenuItem<PopupMenuMembersActionItem>(
                          child: PopupMenuMembersActionItem(
                            child: Text(localization.participant),
                          ),
                          onTap: () {},
                        ),
                        PopupMenuItem<PopupMenuMembersActionItem>(
                          child: PopupMenuMembersActionItem(
                            child: Row(
                              children: [
                                Text(localization.delete),
                                const SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset(AppIcons.delete),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                      ];
                    },
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