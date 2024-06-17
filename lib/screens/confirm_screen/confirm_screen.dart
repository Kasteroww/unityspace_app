import 'package:flutter/material.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_input_field.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_logo_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_text_subtitle_widget.dart';
import 'package:unityspace/screens/widgets/main_form/main_form_widget.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ConfirmScreenStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  ConfirmEmailErrors confirmError = ConfirmEmailErrors.none;
  String code = '';

  void confirm() {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      status = WStoreStatus.loading;
    });
    //
    subscribe(
      future: AuthStore().confirmEmail(widget.email, code),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        ConfirmEmailErrors currentError = ConfirmEmailErrors.confirmEmailError;
        if (error is AuthIncorrectConfirmationCodeHttpException) {
          currentError = ConfirmEmailErrors.incorrectCode;
        }
        setStore(() {
          status = WStoreStatus.error;
          confirmError = currentError;
        });
      },
    );
  }

  @override
  ConfirmScreen get widget => super.widget as ConfirmScreen;
}

class ConfirmScreen extends WStoreWidget<ConfirmScreenStore> {
  final String email;

  const ConfirmScreen({
    required this.email,
    super.key,
  });

  @override
  ConfirmScreenStore createWStore() => ConfirmScreenStore();

  String getErrorLocalization({
    required ConfirmEmailErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case ConfirmEmailErrors.confirmEmailError:
        return localization.confirm_email_error;
      case ConfirmEmailErrors.incorrectCode:
        return localization.incorrect_code_error;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, ConfirmScreenStore store) {
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
              MainFormTextSubtitleWidget(
                text: localization.to_complete_the_registration,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: WStoreStatusBuilder(
                  store: store,
                  watch: (store) => store.status,
                  builder: (context, status) {
                    final loading = status == WStoreStatus.loading;
                    return ConfirmForm(loading: loading);
                  },
                  onStatusError: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          getErrorLocalization(
                            error: store.confirmError,
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

class ConfirmForm extends StatelessWidget {
  final bool loading;

  const ConfirmForm({
    required this.loading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MainFormWidget(
      additionalButtonText: localization.not_right_email_register_new,
      onAdditionalButton: () {
        Navigator.of(context).pop();
      },
      submitButtonText: localization.confirm,
      onSubmit: () {
        FocusScope.of(context).unfocus();
        // загрузка и вход
        context.wstore<ConfirmScreenStore>().confirm();
      },
      submittingNow: loading,
      children: (submit) => [
        MainFormInputField(
          enabled: !loading,
          autofocus: true,
          labelText: localization.enter_code,
          iconAssetName: AppIcons.code,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          autocorrect: false,
          validator: (text) {
            if (text.isEmpty) return localization.the_field_is_not_filled_in;
            if (!RegExp(r'\d{4,}').hasMatch(text)) {
              return localization.enter_correct_code;
            }
            return '';
          },
          onEditingComplete: () {
            submit();
          },
          onSaved: (value) {
            context.wstore<ConfirmScreenStore>().code = value;
          },
        ),
      ],
    );
  }
}
