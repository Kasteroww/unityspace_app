import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/screens/widgets/round_checkbox.dart';
import 'package:unityspace/service/data_exceptions.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showDuplicateReglamentDialog({
  required BuildContext context,
  required Reglament reglament,
  required SpaceColumn selectedColumn,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return DuplicateReglamentDialog(
        reglament: reglament,
        selectedColumn: selectedColumn,
      );
    },
  );
}

class DuplicateReglamentDialogStore extends WStore {
  bool isNeedToCopyQuestions = false;
  WStoreStatus status = WStoreStatus.init;

  late SpaceColumn selectedColumn;
  late Reglament selectedReglament;
  String error = '';
  String reglamentName = '';

  void setReglamentName(String value) {
    setStore(() {
      reglamentName = value;
    });
  }

  void changeCopyQuestionsStatus() {
    setStore(() {
      isNeedToCopyQuestions = !isNeedToCopyQuestions;
    });
  }

  double findNewOrder(Reglament selectedReglament) {
    double newOrder = 0;
    final newReglaments = ReglamentsStore().reglaments ?? [];
    final filteredByOrderReglaments = newReglaments
        .where((reg) => reg.reglamentColumnId == selectedColumn.id)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final currentReglamentIndex = filteredByOrderReglaments
        .indexWhere((reg) => reg.id == selectedReglament.id);

    if (currentReglamentIndex == filteredByOrderReglaments.length - 1) {
      newOrder = selectedReglament.order + 1;
    } else {
      final prevOrder = selectedReglament.order;
      final nextOrder =
          filteredByOrderReglaments[currentReglamentIndex + 1].order;
      newOrder = (prevOrder + nextOrder) / 2;
    }

    return newOrder;
  }

  Future<void> duplicateReglament(AppLocalizations localization) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = '';
    });

    if (reglamentName.isEmpty) {
      setStore(() {
        error = localization.empty_reglament_name_error;
        status = WStoreStatus.error;
      });
      return;
    }
    try {
      await tryDuplicateReglament(
        title: reglamentName,
        copyQuestions: isNeedToCopyQuestions,
        selectedReglament: selectedReglament,
      );
      setStore(() {
        status = WStoreStatus.loaded;
        error = '';
      });
    } catch (e, stack) {
      logger.d('''
          on DuplicateReglamentDialog loadData error=$e\nstack=$stack
        ''');
      setStore(() {
        status = WStoreStatus.error;
        error = localization.problem_uploading_data_try_again;
      });
      throw LoadDataException(
        'on Duplicate reglament excetpion',
        e,
        stack,
      );
    }
  }

  Future<void> tryDuplicateReglament({
    required String title,
    required bool copyQuestions,
    required Reglament selectedReglament,
  }) async {
    try {
      await ReglamentsStore()
          .getReglamentContent(reglamentId: selectedReglament.id);

      final duplicatedReglament = DuplicatedReglament(
        name: title.trim(),
        reglamentColumnId: selectedReglament.reglamentColumnId,
        order: findNewOrder(selectedReglament),
        content: ReglamentsStore().fullReglament?.content ?? '',
        required: selectedReglament.required,
      );

      final duplicatedRes = await ReglamentsStore().createReglament(
        name: duplicatedReglament.name,
        columnId: duplicatedReglament.reglamentColumnId,
        content: duplicatedReglament.content,
        order: duplicatedReglament.order,
      );

      if (copyQuestions) {
        await ReglamentsStore()
            .getReglamentQuestions(reglamentId: selectedReglament.id);
        final questions = ReglamentsStore().questions ?? [];

        if (questions.isNotEmpty) {
          for (final question in questions) {
            final dupQuestion = await ReglamentsStore().createReglamentQuestion(
              reglamentId: duplicatedRes.id,
              name: question.name,
            );

            for (final answer in question.answers) {
              final dupAnswer = await ReglamentsStore().createReglamentAnswer(
                reglamentId: duplicatedRes.id,
                questionId: dupQuestion.id,
                name: answer.name,
              );
              if (answer.isRight) {
                await ReglamentsStore().changeIsRightReglamentAnswerProperty(
                  reglamentId: duplicatedRes.id,
                  questionId: dupQuestion.id,
                  answerId: dupAnswer.id,
                  isRight: true,
                );
              }
            }
          }
        }
        if (duplicatedReglament.required) {
          await ReglamentsStore().changeReglamentRequiredProperty(
            reglamentId: duplicatedRes.id,
            required: duplicatedReglament.required,
          );
        }
      }
    } catch (e, stack) {
      LoadDataException(
        'on try Duplicate reglament excetpion',
        e,
        stack,
      );
    }
  }

  void initValues({
    required Reglament selectedReglament,
    required SpaceColumn selectedColumn,
  }) {
    this.selectedColumn = selectedColumn;
    this.selectedReglament = selectedReglament;
    reglamentName = selectedReglament.name;
  }

  @override
  DuplicateReglamentDialog get widget =>
      super.widget as DuplicateReglamentDialog;
}

class DuplicateReglamentDialog
    extends WStoreWidget<DuplicateReglamentDialogStore> {
  final Reglament reglament;
  final SpaceColumn selectedColumn;

  const DuplicateReglamentDialog({
    required this.selectedColumn,
    required this.reglament,
    super.key,
  });

  @override
  DuplicateReglamentDialogStore createWStore() =>
      DuplicateReglamentDialogStore()
        ..initValues(
          selectedReglament: reglament,
          selectedColumn: selectedColumn,
        );

  @override
  Widget build(BuildContext context, DuplicateReglamentDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builder: (context, status) {
        return AppDialogWithButtons(
          title: localization.duplicate_reglament,
          primaryButtonLoading: status == WStoreStatus.loading,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () async {
            FocusScope.of(context).unfocus();
            await store.duplicateReglament(
              localization,
            );
            if (store.status == WStoreStatus.loaded && context.mounted) {
              Navigator.pop(context);
            }
          },
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              initialValue: store.reglamentName,
              autocorrect: false,
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                store.setReglamentName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              labelText: '${localization.reglament_name}:',
            ),
            const SizedBox(
              height: 10,
            ),
            WStoreBuilder(
              store: store,
              watch: (store) => [
                store.isNeedToCopyQuestions,
              ],
              builder: (context, store) {
                return InkWell(
                  onTap: store.changeCopyQuestionsStatus,
                  child: Row(
                    children: [
                      RoundCheckbox(
                        size: 25,
                        isChecked: store.isNeedToCopyQuestions,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(localization.questions),
                    ],
                  ),
                );
              },
            ),
            if (store.error.isNotEmpty)
              Text(
                store.error,
                style: const TextStyle(
                  color: Color(0xFFD83400),
                ),
              ),
          ],
        );
      },
    );
  }
}
