import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddDialogInputField extends StatefulWidget {
  final GlobalKey? fieldKey;
  final String labelText;
  final String? initialValue;
  final String? iconAssetName;
  final bool autofocus;
  final bool enabled;
  final VoidCallback? onIconTap;
  final void Function(String value)? onSaved;
  final void Function(String value)? onChanged;
  final String Function(String value)? validator;
  final void Function(PointerDownEvent event)? onTapOutside;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const AddDialogInputField({
    required this.labelText,
    super.key,
    this.fieldKey,
    this.initialValue,
    this.iconAssetName,
    this.onIconTap,
    this.onSaved,
    this.onChanged,
    this.onTapOutside,
    this.onEditingComplete,
    this.validator,
    this.textInputAction,
    this.keyboardType,
    this.autofocus = false,
    this.obscureText = false,
    this.enabled = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AddDialogInputField> createState() => _AddDialogInputFieldState();
}

class _AddDialogInputFieldState extends State<AddDialogInputField> {
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
    return TextFormField(
      key: widget.fieldKey,
      focusNode: myFocusNode,
      initialValue: widget.initialValue,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      cursorColor: const Color(0xFF4C4C4D),
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      obscureText: widget.obscureText,
      onEditingComplete: widget.onEditingComplete,
      validator: (value) {
        if (widget.validator == null) return null;
        final result = widget.validator!(value ?? '');
        if (result.isEmpty) return null;
        return result;
      },
      onSaved: (value) => widget.onSaved?.call(value ?? ''),
      onChanged: (value) => widget.onChanged?.call(value),
      onTapOutside: (event) => widget.onTapOutside?.call(event),
      style: const TextStyle(
        color: Color(0xFF4C4C4D),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Color(0x80111012),
          fontSize: 14,
        ),
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
        prefixIcon: widget.iconAssetName == null
            ? null
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onIconTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SvgPicture.asset(
                    widget.iconAssetName!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.scaleDown,
                    theme: SvgTheme(
                      currentColor: myFocusNode.hasFocus
                          ? const Color(0xFF159E5C)
                          : const Color(0xA6111012),
                    ),
                  ),
                ),
              ),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.iconAssetName == null ? 8 : 4,
        ),
      ),
    );
  }
}
