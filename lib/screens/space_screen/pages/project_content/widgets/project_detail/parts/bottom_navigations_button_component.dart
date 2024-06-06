import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/localization_helper.dart';

class BottomNavigationButtonComponent extends StatelessWidget {
  const BottomNavigationButtonComponent({required this.focusNode, super.key});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          TextField(
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: '${localization.write_message}...',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.unsubscribe,
                style: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${localization.members}:',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const UserAvatarWidget(
                    id: 1,
                    width: 24,
                    height: 24,
                    fontSize: 18,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
