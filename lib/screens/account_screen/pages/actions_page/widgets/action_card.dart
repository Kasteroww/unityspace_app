import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/src/theme/theme.dart';
import 'package:wstore/wstore.dart';
import 'package:collection/collection.dart';

class ActionCardStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  ActionsErrors error = ActionsErrors.none;
  @override
  ActionCard get widget => super.widget as ActionCard;
  List<OrganizationMember> members = UserStore().organization?.members ?? [];
  String getUserNameById(int id) =>
      members.firstWhereOrNull((member) => member.id == id)?.name ?? '';
}

class ActionCard extends WStoreWidget<ActionCardStore> {
  const ActionCard({
    super.key,
    required this.data,
    required this.isSelected,
  });

  final bool isSelected;
  final ({TaskHistory history, String? taskName}) data;

  String getTaskNameString(({TaskHistory history, String? taskName}) data) {
    return data.taskName ?? data.history.taskName ?? '???';
  }

  String formatHistoryUpdateDate(
      {required String dateString, required String locale}) {
    List<String> dates = dateString.split('/');
    if (dates.length == 1) {
      return formatDateddMMyyyy(
          date: DateTime.parse(dateString), locale: locale);
    } else if (dates.length == 2) {
      return '${formatDateddMMyyyy(date: DateTime.parse(dates[0]), locale: locale)} - ${formatDateddMMyyyy(date: DateTime.parse(dates[1]), locale: locale)}';
    } else {
      throw FormatErrors.incorrectDateFormat;
    }
  }

  String taskChangesTypesToString(
      {required ({TaskHistory history, String? taskName}) data,
      required AppLocalizations localizations}) {
    final history = data.history;
    final type = history.type;
    switch (type) {
      case TaskChangesTypes.createTask:
        return localizations.createTask;
      case TaskChangesTypes.changeDescription:
        return localizations.changeDescription;
      case TaskChangesTypes.changeName:
        return localizations
            .changeName(data.taskName ?? history.taskName ?? '');
      case TaskChangesTypes.changeBlockReason:
        if (history.state != null) {
          return localizations.changeBlockReasonSet(history.state ?? '');
        }
        return localizations.changeBlockReasonRemoved;
      case TaskChangesTypes.overdueTaskNoResponsible:
        return localizations.overdueTaskNoResponsible;
      case TaskChangesTypes.overdueTaskWithResponsible:
        return localizations.overdueTaskWithResponsible;
      case TaskChangesTypes.changeDate:
        if (history.state != null) {
          return localizations.changeDateSet(formatHistoryUpdateDate(
              dateString: history.state!, locale: localizations.localeName));
        }
        return localizations.changeDateRemoved;
      case TaskChangesTypes.changeColor:
        if (history.state != null && history.state != '') {
          return localizations.changeColorSet;
        }
        return localizations.changeColorRemoved;
      case TaskChangesTypes.changeResponsible:
        return localizations.changeResponsible;
      case TaskChangesTypes.changeStatus:
        String statusString = '';
        switch (history.state) {
          case '0':
            statusString = localizations.in_work_status;
          case '1':
            statusString = localizations.done_status;
          case '2':
            statusString = localizations.rejected_status;
        }

        return localizations.changeStatus(statusString);
      case TaskChangesTypes.changeStage:
        if (history.state == 'archive_tasks') {
          return localizations.changeStageArchived(history.projectName ?? '');
        }
        return localizations.changeStageColumn(
            history.state ?? '', history.projectName ?? '');
      case TaskChangesTypes.addTag:
        return localizations.addTag(history.state ?? '');
      case TaskChangesTypes.deleteTag:
        return localizations.deleteTag(history.state ?? '');
      case TaskChangesTypes.sendMessage:
        return localizations.sendMessage(history.state ?? '');
      case TaskChangesTypes.deleteTask:
        return localizations.deleteTask;
      case TaskChangesTypes.addCover:
        return localizations.addCover;
      case TaskChangesTypes.deleteCover:
        return localizations.deleteCover;
      case TaskChangesTypes.changeImportance:
        return localizations.changeImportance(history.state ?? '');
      case TaskChangesTypes.commit:
        return localizations.commit(history.commitName ?? '');
      case TaskChangesTypes.addStage:
        return localizations.addStage(
            history.projectName ?? '', history.state ?? '');
      case TaskChangesTypes.deleteStage:
        return localizations.deleteStage(history.projectName ?? '');
      case TaskChangesTypes.removeMember:
        return localizations.removeMember;
      case TaskChangesTypes.addResponsible:
        return localizations.addResponsible;
      case TaskChangesTypes.removeResponsible:
        return localizations.removeResponsible;
      case TaskChangesTypes.defaultValue:
      default:
        return localizations.unhandledType(history.state ?? '');
    }
  }

  @override
  ActionCardStore createWStore() => ActionCardStore();

  @override
  Widget build(BuildContext context, ActionCardStore store) {
    final AppLocalizations localizations =
        LocalizationHelper.getLocalizations(context);
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: isSelected ? Border.all(color: ColorConstants.main01) : null,
      ),
      child: PaddingAll(
        12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${localizations.task} ${getTaskNameString(data)}',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium!.copyWith(
                      color: ColorConstants.grey04,
                    ),
                  ),
                ),
                const PaddingLeft(12),
                Text(timeFromDateString(data.history.updateDate),
                    style: textTheme.labelSmall!.copyWith(
                      color: ColorConstants.grey04,
                    )),
              ],
            ),
            const PaddingTop(8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 57),
              child: LayoutBuilder(builder: (context, _) {
                final type = data.history.type;
                final state = data.history.state;
                final text = taskChangesTypesToString(
                    data: data, localizations: localizations);
                final taskNumber = data.history.taskId.toString();
                if (type == TaskChangesTypes.changeColor) {
                  if (state != null && state != '') {
                    final Color? color = _getColor(state);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ActionText(
                          '$text ',
                        ),
                        color != null
                            ? Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4))),
                              )
                            : Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                        color: ColorConstants.grey03),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)))),
                      ],
                    );
                  } else {
                    return ActionText(
                      '$text ',
                    );
                  }
                }
                if (type == TaskChangesTypes.createTask) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ActionText(
                        '$text ',
                      ),
                      TapToCopyText(
                        text: '#$taskNumber',
                      ),
                    ],
                  );
                }
                if (type == TaskChangesTypes.addResponsible ||
                    type == TaskChangesTypes.removeResponsible ||
                    type == TaskChangesTypes.changeResponsible ||
                    type == TaskChangesTypes.removeMember) {
                  final name = state != null
                      ? context
                          .wstore<ActionCardStore>()
                          .getUserNameById(int.parse(state))
                      : '???';
                  return ActionText(
                    '$text $name',
                  );
                }
                return ActionText(
                  text,
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Color? _getColor(String state) {
    return HexColor.fromHex(state);
  }
}

class ActionText extends StatelessWidget {
  const ActionText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      style: textTheme.headlineSmall!.copyWith(color: ColorConstants.grey03),
    );
  }
}

class TapToCopyText extends StatefulWidget {
  const TapToCopyText({
    super.key,
    this.style,
    required this.text,
  });

  final TextStyle? style;
  final String text;

  @override
  State<TapToCopyText> createState() => _TapToCopyTextState();
}

class _TapToCopyTextState extends State<TapToCopyText> {
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        LocalizationHelper.getLocalizations(context);
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.text));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.taskNumberCopied)));
      },
      child: MouseRegion(
        onHover: (_) => setIsHovered(true),
        onExit: (_) => {setIsHovered(false)},
        child: Text(widget.text,
            style: textTheme.headlineSmall!.copyWith(
                color: ColorConstants.grey03,
                decoration: isHovered ? TextDecoration.underline : null)),
      ),
    );
  }

  void setIsHovered(bool value) {
    setState(() {
      isHovered = value;
    });
  }
}
