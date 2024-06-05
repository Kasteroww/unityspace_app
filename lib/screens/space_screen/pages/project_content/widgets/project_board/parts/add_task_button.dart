import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AddTaskButton extends StatefulWidget {
  const AddTaskButton({
    super.key,
  });

  @override
  State<AddTaskButton> createState() => _AddTaskButtonState();
}

class _AddTaskButtonState extends State<AddTaskButton> {
  bool isAddingTask = false;
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return InkWell(
      onTap: () {
        setState(() {
          isAddingTask = true;
        });
      },
      child: ColoredBox(
        color: Colors.blue,
        child: Center(
          child: isAddingTask
              ? TextField(
                  onSubmitted: (value) {
                    setState(() {
                      isAddingTask = false;
                    });
                  },
                )
              : Text('+ ${localization.add_task}'),
        ),
      ),
    );
  }
}
