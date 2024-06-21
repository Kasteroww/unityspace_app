import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';

class NavigatorMenuCurrentUser extends StatelessWidget {
  final String name;
  final bool selected;
  final bool license;
  final int currentUserId;
  final VoidCallback onTap;

  const NavigatorMenuCurrentUser({
    required this.name,
    required this.selected,
    required this.onTap,
    required this.license,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          children: [
            UserAvatarWidget(
              id: currentUserId,
              width: 36,
              height: 35,
              fontSize: 16,
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: ColorConstants.grey09,
                    fontSize: 16,
                    height: 21 / 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (license)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      SvgPicture.asset(
                        AppIcons.navigatorLicense,
                        width: 20,
                        height: 20,
                        fit: BoxFit.scaleDown,
                        theme: const SvgTheme(
                          currentColor: Color(0xFF85DEAB),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
