import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_sign_in_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/snackbar_error_content.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/utils/mixins/copy_to_clipboard_mixin.dart';
import 'package:wstore/wstore.dart';

class LoginScreenStore extends WStore with CopyToClipboardMixin {
  @override
  String message = '';
  WStoreStatus status = WStoreStatus.init;
  String errorMessage = '';
  LoginErrors errorType = LoginErrors.none;

  GoogleSignIn googleSignIn = GoogleSignIn();

  void google() {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      status = WStoreStatus.loading;
    });
    //
    subscribe(
      future: _googleSignInAction(),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        logger.d('google sign in error=$error');
        setStore(() {
          status = WStoreStatus.error;
          errorMessage = '$error';
          errorType = LoginErrors.loginWithGoogleError;
        });
      },
    );
  }

  Future<void> _googleSignInAction() async {
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.accessToken != null) {
        await AuthStore().googleAuth(auth.accessToken!);
        await googleSignIn.disconnect();
      } else {
        await googleSignIn.disconnect();
        throw UserAuthErrors.noAccessToken;
      }
    }
  }

  @override
  LoginScreen get widget => super.widget as LoginScreen;
}

class LoginScreen extends WStoreWidget<LoginScreenStore> {
  const LoginScreen({
    super.key,
  });

  @override
  LoginScreenStore createWStore() => LoginScreenStore();

  @override
  Widget build(BuildContext context, LoginScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      backgroundColor: const Color(0xFF111012),
      body: WStoreStringListener(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const MainFormLogoWidget(),
                const SizedBox(height: 32),
                MainFormTextTitleWidget(text: localization.login_with),
                const SizedBox(height: 32),
                Row(
                  children: [
                    WStoreStatusBuilder(
                      store: store,
                      watch: (store) => store.status,
                      builder: (context, status) {
                        final loading = status == WStoreStatus.loading;
                        return MainFormSignInButtonWidget(
                          loading: loading,
                          iconAssetName: AppIcons.google,
                          width: 0,
                          text: ConstantStrings.google,
                          onPressed: () {
                            store.google();
                          },
                        );
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
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  localization.or_with_email,
                  style: TextStyle(
                    fontSize: 14,
                    height: 24 / 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                MainFormButtonWidget(
                  text: localization.enter_email,
                  onPressed: () {
                    Navigator.pushNamed(context, '/email');
                  },
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: MainFormTextButtonWidget(
                    text: localization.dont_have_an_account_register,
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
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
