import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/project_action_tile.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ColorComponent extends StatelessWidget {
  const ColorComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ProjectActionTile(
      label: localization.color,
      trailing: const Row(
        children: [
          Icon(Icons.color_lens_outlined),
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