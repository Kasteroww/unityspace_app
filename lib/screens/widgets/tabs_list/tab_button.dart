import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/theme/theme.dart';

class TabButton extends StatelessWidget {
  final String? iconAsset;
  final String title;
  final bool selected;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const TabButton({
    required this.title,
    required this.selected,
    required this.onPressed,
    this.onLongPress,
    super.key,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      color: selected ? ColorConstants.main01 : ColorConstants.grey09,
      child: InkWell(
        onTap: selected ? null : onPressed,
        onLongPress: onLongPress,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconAsset != null)
                SvgPicture.asset(
                  iconAsset!,
                  width: 16,
                  height: 16,
                  theme: const SvgTheme(
                    currentColor: ColorConstants.grey02,
                  ),
                ),
              if (iconAsset != null) const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: textTheme.bodyMedium!.copyWith(
                    color: ColorConstants.grey02,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
