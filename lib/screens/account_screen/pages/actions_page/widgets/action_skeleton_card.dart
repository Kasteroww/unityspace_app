import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/screens/widgets/skeleton/skeleton_card.dart';

class ActionSkeletonCard extends StatelessWidget {
  const ActionSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonBox(height: 14, width: 139),
            SkeletonBox(height: 14, width: 25),
          ],
        ),
        PaddingTop(8),
        SkeletonBox(
          height: 19,
          width: double.infinity,
          color: Color.fromRGBO(204, 204, 204, 1),
        ),
      ],
    );
  }
}
