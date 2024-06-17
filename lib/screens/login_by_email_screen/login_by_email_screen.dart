import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/login_by_email_screen/widgets/login_by_email_form.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
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
        if (error is AuthIncorrectCredentialsHttpException) {
          errorMessage = '${error.message}';
          errorText = LoginByEmailErrors.invalidEmailOrPassword;
        } else if (error is HttpException) {
          errorMessage = '${error.message}';
        } else {
          errorMessage = '$error';
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

  String _getLocalizedErrorMessage({
    required LoginByEmailErrors error,
    required AppLocalizations localization,
    required String errorMessage,
  }) {
    switch (error) {
      // Если какая то ошибка связанная с входом,
      // то выводится и ссобщение и локализованное обозначение проблемы
      case LoginByEmailErrors.loginError:
        return '${localization.login_error} \n$errorMessage';
      // Если неправильный логин и пароль,
      // то выводится только локализованное сообщение
      case LoginByEmailErrors.invalidEmailOrPassword:
        return localization.invalid_email_or_password;
      default:
        // Если выводится неизвестная ошибка, то выводится только errorMessage
        return errorMessage;
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
                      final copyErrorMessage = _getLocalizedErrorMessage(
                        error: store.errorType,
                        localization: localization,
                        errorMessage: store.errorMessage,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 5),
                          content: InkWell(
                            onTap: () {
                              store.copy(
                                text: copyErrorMessage,
                                successMessage: localization.copied,
                                errorMessage: localization.copy_error,
                              );
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                            child: Text(
                              '$copyErrorMessage\n${localization.tap_to_copy_error}',
                            ),
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
