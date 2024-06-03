import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/theme/theme.dart';

class ColumnButton extends StatelessWidget {
  final String? iconAsset;
  final String title;
  final bool selected;
  final VoidCallback onPressed;

  const ColumnButton({
    required this.title,
    required this.selected,
    required this.onPressed,
    super.key,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      color: ColorConstants.background,
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
                  color: ColorConstants.grey02,
                  fontWeight: FontWeight.w500,
                  decoration:
                      selected ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
