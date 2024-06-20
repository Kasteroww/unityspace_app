import 'package:flutter/material.dart';
import 'package:unityspace/models/groups_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class SpaceGroup extends StatelessWidget {
  const SpaceGroup({
    required this.group,
    required this.currentRoute,
    required this.currentArguments,
    super.key,
  });

  final GroupWithSpaces group;
  final String? currentRoute;
  final Object? currentArguments;

  String getGroupTitle({
    required AppLocalizations localization,
    required String groupName,
  }) {
    switch (groupName) {
      case 'All Spaces':
        return localization.all_spaces;
      case 'Favorite':
        return localization.favorite_spaces;
      default:
        return groupName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<AppNavigationDrawerStore>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (group.groupId != null) {
              store.toggleIsOpen(
                id: group.groupId!,
                isOpen: group.isOpen,
                name: group.name,
              );
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NavigatorMenuListTitle(
                groupId: group.groupId,
                title: getGroupTitle(
                  localization: localization,
                  groupName: group.name,
                ),
                isOpen: group.isOpen,
              ),
            ],
          ),
        ),
        if (group.isOpen)
          ...group.spaces.map(
            (space) => NavigatorMenuItem(
              iconAssetName: AppIcons.navigatorSpace,
              title: space.name,
              selected:
                  currentRoute == '/space' && currentArguments == space.id,
              favorite: space.favorite,
              onTap: () {
                Navigator.of(context).pop();
                if (currentRoute != '/space' || currentArguments != space.id) {
                  Navigator.of(context).pushReplacementNamed(
                    '/space',
                    arguments: {
                      'space': space,
                    },
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}
