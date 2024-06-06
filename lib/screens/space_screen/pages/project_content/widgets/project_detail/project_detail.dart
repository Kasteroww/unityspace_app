import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/add_field_button_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/bottom_navigations_button_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/color_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/date_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/importance_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/messages_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/responsible_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/shortcuts_component.dart';

class ProjectDetail extends StatefulWidget {
  const ProjectDetail({required this.task, super.key});

  final Task task;

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Task get task => widget.task;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    task.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
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
                const AddFieldButtonComponent(),
                const MessagesComponent(),
                BottomNavigationButtonComponent(
                  focusNode: _focusNode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
