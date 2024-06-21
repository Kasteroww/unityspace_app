import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AddTaskButton extends StatelessWidget {
  final int? focusedIndex;
  final int buttonIdex;
  final void Function(String name) onSubmitted;
  final void Function() onTapButton;
  const AddTaskButton({
    required this.buttonIdex,
    required this.onTapButton,
    required this.focusedIndex,
    required this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return InkWell(
      onTap: onTapButton,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: focusedIndex == buttonIdex
              ? TextField(
                  autocorrect: false,
                  autofocus: true,
                  onSubmitted: (value) {
                    onSubmitted(value);
                  },
                )
              : Text('+ ${localization.add_task}'),
        ),
      ),
    );
  }
}
