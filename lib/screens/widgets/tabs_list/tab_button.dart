import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/src/theme/theme.dart';

class TabButton extends StatelessWidget {
  final String? iconAsset;
  final String title;
  final bool selected;
  final VoidCallback onPressed;

  const TabButton({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
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
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          height: 32,
          child: Row(
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
              Text(
                title,
                style: textTheme.bodyMedium!.copyWith(
                    color: ColorConstants.grey02, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
