import 'package:flutter/material.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_input_field.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_widget.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/mixins/copy_to_clipboard_mixin.dart';
import 'package:wstore/wstore.dart';

class LoginByEmailScreenStore extends WStore with CopyToClipboardMixin {
  @override
  String message = '';
  WStoreStatus status = WStoreStatus.init;
  bool showPassword = false;
  LoginByEmailErrors errorType = LoginByEmailErrors.none;
  String errorMessage = '';

  String email = '';
  String password = '';

  void toggleShowPassword() {
    setStore(() {
      showPassword = !showPassword;
    });
  }

  void login() {
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
      onError: (error, stack) {
        LoginByEmailErrors errorText = LoginByEmailErrors.loginError;
        if (error is AuthIncorrectCredentialsServiceException) {
          errorMessage = '${error.message} \n$stack';
          errorText = LoginByEmailErrors.invalidEmailOrPassword;
        } else if (error is ServiceException) {
          errorMessage = '${error.message} \n$stack';
        } else {
          errorMessage = '$error \n$stack';
        }
        setStore(() {
          status = WStoreStatus.error;
          errorType = errorText;
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

  String getErrorLocalization({
    required LoginByEmailErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case LoginByEmailErrors.loginError:
        return localization.login_error;
      case LoginByEmailErrors.invalidEmailOrPassword:
        return localization.invalid_email_or_password;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, LoginByEmailScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      backgroundColor: const Color(0xFF111012),
      body: SafeArea(
        child: WStoreStringListener(
          store: store,
          watch: (store) => store.message,
          reset: (store) => store.message = '',
          onNotEmpty: (context, message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
              ),
            );
          },
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
                          duration: const Duration(seconds: 5),
                          content: InkWell(
                            onTap: () {
                              store.copy(
                                text: store.errorMessage,
                                successMessage: localization.copied,
                                errorMessage: localization.copy_error,
                              );
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                            child: Text('${getErrorLocalization(
                              error: store.errorType,
                              localization: localization,
                            )}'
                                '\n${localization.tap_to_copy_error}'
                                '\n${store.errorMessage}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
