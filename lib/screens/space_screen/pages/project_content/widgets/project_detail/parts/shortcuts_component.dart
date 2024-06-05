import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/project_action_tile.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ShortcutsComponent extends StatelessWidget {
  const ShortcutsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ProjectActionTile(
      label: localization.shortcuts,
      trailing: const Row(
        children: [
          Icon(Icons.link),
          SizedBox(width: 5),
          Text(
            '-',
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