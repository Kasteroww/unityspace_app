import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/theme/theme.dart';

class ColumnButton extends StatelessWidget {
  final String? iconAsset;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ColumnButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: isSelected ? null : onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border(
              bottom: isSelected
                  ? const BorderSide(
                      width: 2,
                      color: ColorConstants.main,
                    )
                  : BorderSide.none,
            ),
          ),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color.fromRGBO(29, 27, 32, 1),
                  height: 14 / 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
