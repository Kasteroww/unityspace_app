import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainFormInputField extends StatefulWidget {
  final String labelText;
  final String iconAssetName;
  final bool autofocus;
  final bool enabled;
  final VoidCallback? onIconTap;
  final void Function(String value)? onSaved;
  final void Function(String value)? onChanged;
  final String Function(String value)? validator;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const MainFormInputField({
    required this.labelText,
    required this.iconAssetName,
    super.key,
    this.onIconTap,
    this.onSaved,
    this.onChanged,
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
  State<MainFormInputField> createState() => _MainFormInputFieldState();
}

class _MainFormInputFieldState extends State<MainFormInputField> {
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
      focusNode: myFocusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      cursorColor: Colors.white,
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
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: myFocusNode.hasFocus
              ? Colors.white
              : Colors.white.withOpacity(0.5),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        isDense: true,
        prefixIcon: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onIconTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              widget.iconAssetName,
              width: 24,
              height: 24,
              fit: BoxFit.scaleDown,
              theme: SvgTheme(
                currentColor: myFocusNode.hasFocus
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
        fillColor: Colors.white.withOpacity(0.03),
        filled: true,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
  }
}
