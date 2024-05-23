import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/localization_helper.dart';

class MainFormLogoWidget extends StatelessWidget {
  const MainFormLogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Row(
      children: [
        const Spacer(),
        SvgPicture.asset(
          ConstantIcons.appIcon,
          width: 42,
          height: 42,
        ),
        const SizedBox(width: 10),
        Text(
          localization.spaces,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
