import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/task_location/widgets/task_location_card.dart';

class TaskLocationComponent extends StatelessWidget {
  const TaskLocationComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          TaskLocationCard(
            title: 'Разработка Spaces',
            icon: Icons.language,
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.black,
            size: 15,
          ),
          TaskLocationCard(
            title: 'Пространства',
            icon: Icons.folder_copy_outlined,
          ),
        ],
      ),
    );
  }
}
