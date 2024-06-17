import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/login_by_email_screen/widgets/login_by_email_form.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/snackbar_error_content.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/mixins/copy_to_clipboard_mixin.dart';
import 'package:wstore/wstore.dart';

class LoginByEmailScreenStore extends WStore with CopyToClipboardMixin {
  @override
  String message = '';
  bool showPassword = false;
  WStoreStatus status = WStoreStatus.init;
  LoginErrors errorType = LoginErrors.none;
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
        LoginErrors errorText = LoginErrors.loginError;
        if (error is AuthIncorrectCredentialsHttpException) {
          errorMessage = '${error.message}';
          errorText = LoginErrors.invalidEmailOrPassword;
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
                          content: SnackBarErrorContent(
                            errorType: store.errorType,
                            errorMessage: store.errorMessage,
                            onTap: () {
                              store.copy(
                                text: store.errorMessage,
                                successMessage: localization.copied,
                                errorMessage: localization.copy_error,
                              );
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
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
