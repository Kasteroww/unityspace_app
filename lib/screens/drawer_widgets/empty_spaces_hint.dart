import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

class NavigatorMenuEmptySpacesHint extends StatelessWidget {
  final bool isOrganizationOwner;

  const NavigatorMenuEmptySpacesHint({
    required this.isOrganizationOwner,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111012),
        border: Border.all(
          color: const Color(0xFF0C5B35),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Text(
        isOrganizationOwner ? localization.owner_text : localization.empt_text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          height: 1.5,
          fontSize: 16,
        ),
      ),
    );
  }
}
