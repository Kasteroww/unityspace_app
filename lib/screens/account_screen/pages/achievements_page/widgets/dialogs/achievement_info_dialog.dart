import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';

Future<void> showAchievementInfoDialog(
  BuildContext context,
) async {
  return showDialog(
    context: context,
    builder: (context) => const AchievementInfoDialog(),
  );
}

class AchievementInfoDialog extends StatelessWidget {
  const AchievementInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AppDialog(
      title: localization.author_regulations,
      buttons: const [],
      children: [
        Center(
          child: SvgPicture.asset(
            AppIcons.crown,
            width: 54,
            height: 54,
          ),
        ),
        Center(
          child: Text(
            localization.received('3 июня в 12:00'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Center(
          child: Text(
            localization.received_desc,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
