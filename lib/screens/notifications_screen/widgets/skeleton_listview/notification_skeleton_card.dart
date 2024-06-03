import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/skeleton/skeleton_card.dart';

class NotificationSkeletonCard extends StatelessWidget {
  const NotificationSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      children: [
        SkeletonBox(height: 14, width: 126),
        SizedBox(height: 8),
        Row(
          children: [
            SkeletonBox(height: 16, width: 16),
            SizedBox(width: 8),
            SkeletonBox(height: 16, width: 84),
          ],
        ),
        SizedBox(height: 8),
        SkeletonBox(
          height: 32,
          width: double.infinity,
          color: Color.fromRGBO(204, 204, 204, 1),
        ),
      ],
    );
  }
}
