import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_sign_in_button_widget.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

class LoginScreenStore extends WStore {
  WStoreStatus statusGoogle = WStoreStatus.init;
  String googleError = '';
  GoogleSignIn googleSignIn = GoogleSignIn();

  void google(String googleLoginError) {
    if (statusGoogle == WStoreStatus.loading) return;
    //
    setStore(() {
      statusGoogle = WStoreStatus.loading;
    });
    //
    subscribe(
      future: _googleSignInAction(),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusGoogle = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        logger.d('google sign in error=$error');
        setStore(() {
          statusGoogle = WStoreStatus.error;
          googleError = googleLoginError;
        });
      },
    );
  }

  Future<void> _googleSignInAction() async {
    GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      GoogleSignInAuthentication auth = await account.authentication;
      if (auth.accessToken != null) {
        await AuthStore().googleAuth(auth.accessToken!);
        googleSignIn.disconnect();
      } else {
        googleSignIn.disconnect();
        throw UserAuthErrors.noAccessToken;
      }
    }
  }

  // Future<void> _yandexSignInAction() async {
  //   final flutterLoginYandexPlugin = FlutterLoginYandex();
  //   final response = await flutterLoginYandexPlugin.signIn();
  //   if (response!=null) {
  //     final token = response['token'] as String?;
  //     if (token == null) {
  //       throw 'no token';
  //     }
  //     logger.d('yandex token=$token');
  //   }
  // }

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
      body: SafeArea(
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
                    watch: (store) => store.statusGoogle,
                    builder: (context, status) {
                      final loading = status == WStoreStatus.loading;
                      return MainFormSignInButtonWidget(
                        loading: loading,
                        iconAssetName: ConstantIcons.google,
                        width: 0,
                        text: ConstantStrings.google,
                        onPressed: () {
                          store.google(localization.google_login_error);
                        },
                      );
                    },
                    onStatusError: (context) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(store.googleError),
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
    );
  }
}
