import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.height,
    required this.width,
    this.color = const Color.fromRGBO(230, 230, 230, 1),
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: color,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
