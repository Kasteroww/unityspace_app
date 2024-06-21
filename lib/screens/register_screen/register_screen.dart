import 'package:flutter/material.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_input_field.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_button_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_widget.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wstore/wstore.dart';

class RegisterScreenStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  RegistrationErrors registrationError = RegistrationErrors.none;
  String email = '';
  String password = '';
  bool showPassword = false;

  void toggleShowPassword() {
    setStore(() {
      showPassword = !showPassword;
    });
  }

  void register() {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      status = WStoreStatus.loading;
    });
    //
    subscribe(
      future: AuthStore().register(email, password),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        RegistrationErrors currentError = RegistrationErrors.createAccountError;
        if (error is AuthUserAlreadyExistsHttpException) {
          currentError = RegistrationErrors.emailAlreadyExists;
        }
        if (error is AuthIncorrectEmailHttpException) {
          currentError = RegistrationErrors.incorrectEmail;
        }
        if (error is TooManyRequests500HttpException) {
          currentError = RegistrationErrors.overloadedService;
        }
        setStore(() {
          status = WStoreStatus.error;
          registrationError = currentError;
        });
      },
    );
  }

  @override
  RegisterScreen get widget => super.widget as RegisterScreen;
}

class RegisterScreen extends WStoreWidget<RegisterScreenStore> {
  const RegisterScreen({
    super.key,
  });

  @override
  RegisterScreenStore createWStore() => RegisterScreenStore();

  String getLocalizationError({
    required RegistrationErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case RegistrationErrors.emailAlreadyExists:
        return localization.exist_email_error;
      case RegistrationErrors.createAccountError:
        return localization.create_account_error;
      case RegistrationErrors.incorrectEmail:
        return localization.incorrect_email_error;
      case RegistrationErrors.overloadedService:
        return localization.overloaded_service_error;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, RegisterScreenStore store) {
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
              MainFormTextTitleWidget(text: localization.creating_account),
              const SizedBox(height: 32),
              Expanded(
                child: WStoreStatusBuilder(
                  store: store,
                  watch: (store) => store.status,
                  builder: (context, status) {
                    final loading = status == WStoreStatus.loading;
                    return RegisterByEmailForm(loading: loading);
                  },
                  onStatusLoaded: (context) {
                    // переходим на экран подтверждения
                    Navigator.pushNamed(
                      context,
                      '/confirm',
                      arguments: store.email,
                    );
                  },
                  onStatusError: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          getLocalizationError(
                            error: store.registrationError,
                            localization: localization,
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
    );
  }
}

class RegisterByEmailForm extends StatelessWidget {
  final bool loading;

  const RegisterByEmailForm({
    required this.loading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MainFormWidget(
      additionalButtonText: localization.you_already_have_account_login,
      onAdditionalButton: () {
        Navigator.of(context).pop();
      },
      submitButtonText: localization.create_account,
      onSubmit: () {
        FocusScope.of(context).unfocus();
        // загрузка и вход
        context.wstore<RegisterScreenStore>().register();
      },
      submittingNow: loading,
      children: (submit) => [
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
            context.wstore<RegisterScreenStore>().email = value;
          },
        ),
        const SizedBox(height: 12),
        WStoreValueBuilder<RegisterScreenStore, bool>(
          watch: (store) => store.showPassword,
          builder: (context, showPassword) {
            return MainFormInputField(
              enabled: !loading,
              labelText:
                  '${localization.come_up_with_a_new_password_with_length_at_least_8_characters})',
              iconAssetName:
                  showPassword ? AppIcons.passwordHide : AppIcons.passwordShow,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !showPassword,
              autocorrect: false,
              enableSuggestions: false,
              onIconTap: () {
                context.wstore<RegisterScreenStore>().toggleShowPassword();
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
                context.wstore<RegisterScreenStore>().password = value;
              },
            );
          },
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: MainFormTextButtonWidget(
            text: localization.by_registering_accept_privacy_policy,
            onPressed: () async {
              final url = Uri.parse(ConstantLinks.privacyPolicyUrl);
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ),
      ],
    );
  }
}
