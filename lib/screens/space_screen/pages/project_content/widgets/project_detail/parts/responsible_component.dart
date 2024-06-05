import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/project_action_tile.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ResponsibleComponent extends StatelessWidget {
  const ResponsibleComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ProjectActionTile(
      label: localization.responsible,
      trailing: const Row(
        children: [
          UserAvatarWidget(
            id: 1,
            width: 24,
            height: 24,
            fontSize: 15,
          ),
          SizedBox(width: 5),
          Text(
            'Диёр Ханазаров',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}