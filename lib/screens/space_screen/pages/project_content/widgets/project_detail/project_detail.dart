import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/color_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/date_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/importance_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/responsible_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/shortcuts_component.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ProjectDetail extends StatefulWidget {
  const ProjectDetail({required this.task, super.key});

  final Task task;

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  Task get task => widget.task;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 16, right: 20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '#${task.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.copy,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.more_vert_rounded,
                    ),
                  ],
                ),
              ],
            ),
            // Title таска
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const ResponsibleComponent(),
            const SizedBox(height: 10),
            ImportanceComponent(task: task),
            const SizedBox(height: 10),
            const ColorComponent(),
            const SizedBox(height: 10),
            const DateComponent(),
            const SizedBox(height: 10),
            const ShortcutsComponent(),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add),
                          const SizedBox(width: 5),
                          Text(localization.add_desc),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}