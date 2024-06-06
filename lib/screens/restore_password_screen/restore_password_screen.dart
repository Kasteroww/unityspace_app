import 'package:flutter/material.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_input_field.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_subtitle_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_title_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_widget.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class RestorePasswordScreenStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  RestorePasswordErrors restorePasswordError = RestorePasswordErrors.none;
  String email = '';

  void again() {
    if (status != WStoreStatus.loaded) return;
    //
    setStore(() {
      status = WStoreStatus.init;
    });
  }

  void restore() {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      status = WStoreStatus.loading;
    });
    //
    subscribe(
      future: AuthStore().restorePasswordByEmail(email),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        RestorePasswordErrors currentError = RestorePasswordErrors.restoreError;
        if (error is AuthIncorrectCredentialsServiceException) {
          currentError = RestorePasswordErrors.accountDoesNotExist;
        }
        setStore(() {
          status = WStoreStatus.error;
          restorePasswordError = currentError;
        });
      },
    );
  }

  @override
  RestorePasswordScreen get widget => super.widget as RestorePasswordScreen;
}

class RestorePasswordScreen extends WStoreWidget<RestorePasswordScreenStore> {
  const RestorePasswordScreen({
    super.key,
  });

  @override
  RestorePasswordScreenStore createWStore() => RestorePasswordScreenStore();

  String getErrorLocalization({
    required RestorePasswordErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case RestorePasswordErrors.restoreError:
        return localization.restore_password_error;
      case RestorePasswordErrors.accountDoesNotExist:
        return localization.nonexistent_account;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, RestorePasswordScreenStore store) {
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
              MainFormTextTitleWidget(text: localization.recover_password),
              const SizedBox(height: 32),
              Expanded(
                child: WStoreStatusBuilder(
                  store: store,
                  watch: (store) => store.status,
                  builder: (context, status) {
                    final loading = status == WStoreStatus.loading;
                    return RestorePasswordForm(loading: loading);
                  },
                  builderLoaded: (context) {
                    return const SentPasswordForm();
                  },
                  onStatusError: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          getErrorLocalization(
                            error: store.restorePasswordError,
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

class RestorePasswordForm extends StatelessWidget {
  final bool loading;

  const RestorePasswordForm({
    required this.loading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MainFormWidget(
      additionalButtonText: localization.remember_login,
      onAdditionalButton: () {
        Navigator.of(context).pop();
      },
      submitButtonText: localization.recover_password,
      onSubmit: () {
        FocusScope.of(context).unfocus();
        // загрузка и вход
        context.wstore<RestorePasswordScreenStore>().restore();
      },
      submittingNow: loading,
      children: (submit) => [
        MainFormTextSubtitleWidget(
          text: localization.we_will_send_you_password_recovery_message,
        ),
        const SizedBox(height: 12),
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
            context.wstore<RestorePasswordScreenStore>().email = value;
          },
        ),
      ],
    );
  }
}

class SentPasswordForm extends StatelessWidget {
  const SentPasswordForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MainFormWidget(
      additionalButtonText: localization.didnt_receive_an_email_resend,
      onAdditionalButton: () {
        context.wstore<RestorePasswordScreenStore>().again();
      },
      submitButtonText: localization.login_by_email,
      onSubmit: () {
        Navigator.of(context).pop();
      },
      submittingNow: false,
      children: (submit) => [
        MainFormTextSubtitleWidget(
          text: localization.letter_has_been_sent_to_your_email,
        ),
      ],
    );
  }
}
