import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AddFieldButtonComponent extends StatefulWidget {
  const AddFieldButtonComponent({super.key});

  @override
  State<AddFieldButtonComponent> createState() => _AddFieldButtonComponentState();
}

class _AddFieldButtonComponentState extends State<AddFieldButtonComponent> {
  bool showTextField = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return showTextField
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              focusNode: _focusNode,
              onSubmitted: (String value) => showIsActive(false),
            ),
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: InkWell(
                  onTap: () {
                    showIsActive(true);
                    _focusNode.requestFocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add),
                        const SizedBox(width: 5),
                        Text(localization.add_desc),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void showIsActive(bool value) {
    setState(() {
      showTextField = value;
    });
  }
}
