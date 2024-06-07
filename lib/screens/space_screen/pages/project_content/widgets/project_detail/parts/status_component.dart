import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

class StatusComponent extends StatelessWidget {
  const StatusComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StatusCard(
            title: localization.completed_status,
            icon: Icons.close,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          StatusCard(
            title: localization.rejected_status,
            icon: Icons.check,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          width: 0.3,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            children: [
              Icon(icon),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
