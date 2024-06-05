import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/project_action_tile.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ImportanceComponent extends StatelessWidget {
  const ImportanceComponent({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ProjectActionTile(
      label: localization.importance,
      trailing: Row(
        children: [
          const Icon(Icons.flag),
          const SizedBox(width: 5),
          Text(
            task.importance.localize(localization: localization),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}