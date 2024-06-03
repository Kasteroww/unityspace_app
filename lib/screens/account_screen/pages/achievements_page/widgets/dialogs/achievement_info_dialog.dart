import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog.dart';

Future<void> showAchievementInfoDialog(
  BuildContext context,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return const AchievementInfoDialog();
    },
  );
}

class AchievementInfoDialog extends StatefulWidget {
  const AchievementInfoDialog({super.key});

  @override
  State<AchievementInfoDialog> createState() => _AchievementInfoDialogState();
}

class _AchievementInfoDialogState extends State<AchievementInfoDialog> {
  @override
  Widget build(BuildContext context) {
    return const AppDialog(
      title: '',
      buttons: [],
      children: [],
    );
  }
}
