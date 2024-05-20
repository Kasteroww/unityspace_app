import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';

class MainFormWidget extends StatefulWidget {
  final String submitButtonText;
  final VoidCallback onSubmit;
  final VoidCallback? onAdditionalButton;
  final String additionalButtonText;
  final bool submittingNow;
  final List<Widget> Function(VoidCallback submit) children;

  const MainFormWidget({
    super.key,
    required this.submitButtonText,
    required this.onSubmit,
    required this.submittingNow,
    required this.children,
    this.onAdditionalButton,
    this.additionalButtonText = '',
  });

  @override
  State<MainFormWidget> createState() => _MainFormWidgetState();
}

class _MainFormWidgetState extends State<MainFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void submit() {
    FormState? formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 6),
                ...widget.children(submit),
                MainFormButtonWidget(
                  loading: widget.submittingNow,
                  text: widget.submitButtonText,
                  onPressed: submit,
                ),
                if (widget.onAdditionalButton != null &&
                    widget.additionalButtonText.isNotEmpty)
                  const SizedBox(height: 4),
                if (widget.onAdditionalButton != null &&
                    widget.additionalButtonText.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: MainFormTextButtonWidget(
                      text: widget.additionalButtonText,
                      onPressed: widget.onAdditionalButton!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
