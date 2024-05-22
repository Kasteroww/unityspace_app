import 'package:flutter/material.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 126,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(230, 230, 230, 1),
                      borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromRGBO(230, 230, 230, 1),
                      ),
                      height: 16,
                      width: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromRGBO(230, 230, 230, 1),
                      ),
                      height: 16,
                      width: 84,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(204, 204, 204, 1),
                      borderRadius: BorderRadius.circular(4)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
