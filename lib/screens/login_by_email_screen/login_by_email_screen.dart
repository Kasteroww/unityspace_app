import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_input_field.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_widget.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginByEmailScreenStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  bool showPassword = false;
  String loginError = '';
  String email = '';
  String password = '';

  void toggleShowPassword() {
    setStore(() {
      showPassword = !showPassword;
    });
  }

  void login(AppLocalizations localizations) {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      status = WStoreStatus.loading;
    });
    //
    subscribe(
      future: AuthStore().login(email, password),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        String errorText =
            localizations.login_error;
        if (error == ConstantStrings.invalidEmailOrPassword) {
          errorText = localizations.invalid_email_or_password;
        }
        setStore(() {
          status = WStoreStatus.error;
          loginError = errorText;
        });
      },
    );
  }

  @override
  LoginByEmailScreen get widget => super.widget as LoginByEmailScreen;
}

class LoginByEmailScreen extends WStoreWidget<LoginByEmailScreenStore> {
  const LoginByEmailScreen({
    super.key,
  });

  @override
  LoginByEmailScreenStore createWStore() => LoginByEmailScreenStore();

  @override
  Widget build(BuildContext context, LoginByEmailScreenStore store) {
    return Scaffold(
      backgroundColor: const Color(0xFF111012),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const MainFormLogoWidget(),
              const SizedBox(height: 24),
              Expanded(
                child: WStoreStatusBuilder(
                  store: store,
                  watch: (store) => store.status,
                  builder: (context, status) {
                    final loading = status == WStoreStatus.loading;
                    return LoginByEmailForm(loading: loading);
                  },
                  onStatusError: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(store.loginError),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginByEmailForm extends StatelessWidget {
  final bool loading;

  const LoginByEmailForm({
    super.key,
    required this.loading,
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
        context.wstore<LoginByEmailScreenStore>().login(localization);
      },
      submittingNow: loading,
      children: (submit) => [
        Center(
            child: MainFormTextTitleWidget(text: localization.login_by_email)),
        const SizedBox(height: 32),
        MainFormInputField(
          enabled: !loading,
          autofocus: true,
          labelText: localization.your_email,
          iconAssetName: ConstantIcons.email,
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
                  '${localization.password} (${localization.at_least_8_characters})',
              iconAssetName: showPassword
                  ? ConstantIcons.passwordHide
                  : ConstantIcons.passwordShow,
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
                  return '${localization.password_must_be} ${localization.at_least_8_characters}';
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
