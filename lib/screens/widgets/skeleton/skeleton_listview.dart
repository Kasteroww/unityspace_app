import 'package:flutter/material.dart';

class SkeletonListView extends StatelessWidget {
  const SkeletonListView({
    required this.skeletonCard,
    super.key,
  });

  final Widget skeletonCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 15,
            width: 139,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(229, 231, 235, 1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return skeletonCard;
              },
            ),
          ),
        ],
      ),
    );
  }
}
