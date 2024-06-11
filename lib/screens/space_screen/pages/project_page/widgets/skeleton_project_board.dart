import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/widgets/skeleton/skeleton_card.dart';

class SkeletonProjectBoard extends StatelessWidget {
  const SkeletonProjectBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Название доски
              SkeletonBox(
                height: 20,
                width: 259,
                color: ColorConstants.grey08,
              ),
              SizedBox(
                height: 24,
              ),
              //Список с проектами
              Column(
                children: [
                  SkeletonProject(),
                  SizedBox(
                    height: 16,
                  ),
                  SkeletonProject(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonProject extends StatelessWidget {
  const SkeletonProject({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorConstants.grey10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Скелетон аватарки
            Stack(
              alignment: Alignment.center,
              children: [
                const SkeletonBox(
                  height: 32,
                  width: 32,
                  color: ColorConstants.grey08,
                  borderRadius: 16,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: ColorConstants.grey10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SkeletonBox(
                  height: 20,
                  width: 20,
                  borderRadius: 16,
                ),
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  height: 16,
                  width: 259,
                  color: ColorConstants.grey08,
                ),
                SizedBox(
                  height: 8,
                ),
                SkeletonBox(
                  height: 16,
                  width: 88,
                  color: ColorConstants.grey08,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
