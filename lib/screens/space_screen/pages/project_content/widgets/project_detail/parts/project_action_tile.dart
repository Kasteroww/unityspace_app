import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/project_detail.dart';

/// Виджет использующийся в bottom sheet на странице [ProjectDetail], при тапе на карточку таска
class ProjectActionTile extends StatelessWidget {
  const ProjectActionTile({
    required this.label,
    required this.trailing,
    this.onTap,
    super.key,
  });

  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
