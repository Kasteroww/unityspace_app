import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AccountItemWidget extends StatelessWidget {
  final String text;
  final String value;
  final String iconAssetName;
  final VoidCallback onTapChange;
  final VoidCallback? onTapValue;
  final VoidCallback? onLongTapValue;

  const AccountItemWidget({
    super.key,
    required this.text,
    required this.value,
    required this.iconAssetName,
    required this.onTapChange,
    this.onTapValue,
    this.onLongTapValue,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    const titleColor = Color(0x99111012);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 12),
            SvgPicture.asset(
              iconAssetName,
              width: 18,
              height: 18,
              theme: const SvgTheme(currentColor: titleColor),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size(40, 40)),
              ),
              onPressed: onTapChange,
              child: Text(
                localization.change,
              ),
            ),
          ],
        ),
        TextButton(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
              const Size(double.infinity, 40),
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            alignment: Alignment.centerLeft,
          ),
          onPressed: onTapValue,
          onLongPress: onLongTapValue,
          child: FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xCC111012),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 32 / 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
