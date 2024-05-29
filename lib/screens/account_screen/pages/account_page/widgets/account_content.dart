import 'package:flutter/material.dart';

class AccountContentWidget extends StatelessWidget {
  final Widget avatar;
  final List<Widget> children;

  const AccountContentWidget({
    required this.avatar,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 496) {
          return Column(
            children: [
              avatar,
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE5E7EB),
                indent: 12,
                endIndent: 12,
              ),
              ...children.expand(
                (child) => [
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 12),
            avatar,
            const SizedBox(width: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    if (children.isNotEmpty)
                      ...children
                          .expand(
                            (child) => [
                              child,
                              const SizedBox(height: 16),
                            ],
                          )
                          .take(children.length * 2 - 1),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
