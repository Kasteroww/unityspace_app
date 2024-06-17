import 'package:flutter/material.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/login_by_email_screen/login_by_email_screen.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_input_field.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_widget.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class LoginByEmailForm extends StatelessWidget {
  final bool loading;

  const LoginByEmailForm({
    required this.loading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MainFormWidget(
      additionalButtonText: localization.another_way_to_log_in,
      onAdditionalButton: () {
        Navigator.of(context).pop();
      },
      submitButtonText: localization.login,
      onSubmit: () {
        FocusScope.of(context).unfocus();
        // загрузка и вход
        context.wstore<LoginByEmailScreenStore>().login();
      },
      submittingNow: loading,
      children: (submit) => [
        Center(
          child: MainFormTextTitleWidget(text: localization.login_by_email),
        ),
        const SizedBox(height: 32),
        MainFormInputField(
          enabled: !loading,
          autofocus: true,
          labelText: localization.your_email,
          iconAssetName: AppIcons.email,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          validator: (text) {
            if (text.isEmpty) return localization.the_field_is_not_filled_in;
            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(text)) {
              return localization.enter_correct_email;
            }
            return '';
          },
          onSaved: (value) {
            context.wstore<LoginByEmailScreenStore>().email = value;
          },
        ),
        const SizedBox(height: 16),
        WStoreValueBuilder<LoginByEmailScreenStore, bool>(
          watch: (store) => store.showPassword,
          builder: (context, showPassword) {
            return MainFormInputField(
              enabled: !loading,
              labelText:
                  '${localization.password_must_be_at_least_8_characters})',
              iconAssetName:
                  showPassword ? AppIcons.passwordHide : AppIcons.passwordShow,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !showPassword,
              autocorrect: false,
              enableSuggestions: false,
              onIconTap: () {
                context.wstore<LoginByEmailScreenStore>().toggleShowPassword();
              },
              onEditingComplete: () {
                submit();
              },
              validator: (text) {
                if (text.isEmpty) {
                  return localization.the_field_is_not_filled_in;
                }
                if (text.length < 8) {
                  return localization
                      .password_must_be_not_less_than_8_characters;
                }
                return '';
              },
              onSaved: (value) {
                context.wstore<LoginByEmailScreenStore>().password = value;
              },
            );
          },
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: MainFormTextButtonWidget(
            text: localization.forgot_password,
            onPressed: () {
              Navigator.pushNamed(context, '/restore');
            },
          ),
        ),
      ],
    );
  }
}
