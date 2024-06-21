import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AddSpaceButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AddSpaceButtonWidget({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minWidth: double.infinity,
      height: 40,
      elevation: 2,
      color: const Color(0xFF141314),
      onPressed: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.navigatorPlus,
            width: 32,
            height: 32,
            fit: BoxFit.scaleDown,
            theme: SvgTheme(
              currentColor: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            localization.add_space,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
