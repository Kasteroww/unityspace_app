import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/project_action_tile.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ColorComponent extends StatelessWidget {
  final Color? color;
  const ColorComponent({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ProjectActionTile(
      label: localization.color,
      trailing: Row(
        children: [
          if (color != null)
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              width: 25,
              height: 25,
            )
          else
            const Icon(Icons.color_lens_outlined),
          const SizedBox(width: 5),
          const Text(
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
