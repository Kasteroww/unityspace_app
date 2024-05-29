import 'package:flutter/material.dart';

class AddDialogDropdownMenu<T> extends StatefulWidget {
  final GlobalKey? fieldKey;
  final String labelText;
  final List<T> listValues;
  final dynamic currentValue;
  final bool autofocus;
  final void Function(dynamic value)? onSaved;
  final void Function(dynamic value)? onChanged;

  const AddDialogDropdownMenu({
    required this.labelText,
    required this.listValues,
    super.key,
    this.currentValue,
    this.fieldKey,
    this.onSaved,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  State<AddDialogDropdownMenu> createState() => _AddDialogDropdownMenuState();
}

class _AddDialogDropdownMenuState extends State<AddDialogDropdownMenu> {
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      setState(() {}); // Перерисовка виджета после изменения состояния
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.labelText),
        DropdownButtonFormField(
          dropdownColor: Colors.white,
          key: widget.fieldKey,
          focusNode: myFocusNode,
          autofocus: widget.autofocus,
          value: widget.currentValue ?? widget.listValues.first,
          onSaved: (value) => widget.onSaved?.call(value),
          onChanged: (value) => widget.onChanged?.call(value),
          style: const TextStyle(
            color: Color(0xFF4C4C4D),
          ),
          decoration: InputDecoration(
            floatingLabelStyle: TextStyle(
              color: myFocusNode.hasFocus
                  ? const Color(0xFF159E5C)
                  : const Color(0xA6111012),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            isDense: true,
            fillColor: const Color(0xFFF4F5F7).withOpacity(0.5),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0x1F212022)),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF85DEAB)),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          items: widget.listValues.map<DropdownMenuItem>((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value.name,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
