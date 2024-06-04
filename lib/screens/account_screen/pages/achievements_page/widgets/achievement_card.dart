import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/account_screen/pages/achievements_page/widgets/dialogs/achievement_info_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        child: InkWell(
          onTap: () => showAchievementInfoDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.crown,
                  width: 34,
                  height: 34,
                ),
                const SizedBox(width: 10),
                Text(localization.author_regulations),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
