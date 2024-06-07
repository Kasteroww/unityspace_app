import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AddStageButton extends StatelessWidget {
  final void Function(String name) onSubmitted;
  final void Function() onTapButton;
  final bool isAddingStage;
  const AddStageButton({
    required this.onTapButton,
    required this.isAddingStage,
    required this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 12),
        child: InkWell(
          onTap: onTapButton,
          child: isAddingStage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: TextField(
                      autofocus: true,
                      onSubmitted: (value) {
                        onSubmitted(value);
                      },
                    ),
                  ),
                )
              : Text('+ ${localization.add_column}'),
        ),
      ),
    );
  }
}
