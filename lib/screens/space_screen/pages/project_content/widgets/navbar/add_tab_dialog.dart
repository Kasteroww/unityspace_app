import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/add_tab_dialog_fields_column.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showAddTabDialog(
  BuildContext context,
  int? projectId,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AddTabDialog(
        projectId: projectId,
      );
    },
  );
}

enum AddTabDialogTypes { tabDocs, tabLink, tabEmbed }

class AddTabDialogStore extends WStore {
  AddProjectTabErrors addTabError = AddProjectTabErrors.none;
  WStoreStatus statusAddTabDialog = WStoreStatus.init;
  AddTabDialogTypes selectedTab = AddTabDialogTypes.tabLink;
  String name = '';
  String link = '';

  Project? get project => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => store.projectsMap[widget.projectId],
        keyName: 'project',
      );

  bool get isShowProjectReviewTab => computed(
        getValue: () => project?.showProjectReviewTab ?? false,
        keyName: 'showProjectReviewTab',
        watch: () => [project],
      );

  void selectTab(AddTabDialogTypes tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  void setTabName(String tabName) {
    setStore(() {
      name = tabName;
    });
  }

  void setTabLink(String tabLink) {
    setStore(() {
      link = tabLink;
    });
  }

  void addTabDialog() {
    if (statusAddTabDialog == WStoreStatus.loading) return;
    setStore(() {
      statusAddTabDialog = WStoreStatus.loading;
      addTabError = AddProjectTabErrors.none;
    });

    subscribe(
      future: ProjectsStore().createProjectEmbed(),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusAddTabDialog = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'AddTabDialogStore.addTab error: $error stack: $stack',
        );
        setStore(() {
          statusAddTabDialog = WStoreStatus.error;
          addTabError = AddProjectTabErrors.addProjectTabError;
        });
      },
    );
  }

  @override
  AddTabDialog get widget => super.widget as AddTabDialog;
}

class AddTabDialog extends WStoreWidget<AddTabDialogStore> {
  final int? projectId;

  const AddTabDialog({
    required this.projectId,
    super.key,
  });

  @override
  AddTabDialogStore createWStore() => AddTabDialogStore();

  @override
  Widget build(BuildContext context, AddTabDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusAddTabDialog,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.add_tab,
          primaryButtonText: localization.create,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.addTabDialog();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            WStoreBuilder(
              store: store,
              watch: (store) => [store.selectedTab],
              builder: (context, store) {
                final List<(AddTabDialogTypes, String, String)> listTabs = [
                  if (!store.isShowProjectReviewTab)
                    (
                      AddTabDialogTypes.tabDocs,
                      localization.documents,
                      localization.add_tab_enter_docs
                    ),
                  (
                    AddTabDialogTypes.tabLink,
                    localization.link,
                    localization.add_tab_enter_link
                  ),
                  (
                    AddTabDialogTypes.tabEmbed,
                    localization.embed,
                    localization.add_tab_enter_embed
                  ),
                ];
                return Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 200,
                      child: ListView.builder(
                        itemCount: listTabs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: TabButton(
                              title: listTabs[index].$2,
                              selected: listTabs[index].$1 == store.selectedTab,
                              onPressed: () {
                                store.selectTab(listTabs[index].$1);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    AddTabDialogFieldsColumn(
                      listTabs
                          .firstWhere((tab) => tab.$1 == store.selectedTab)
                          .$3,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (error)
              Text(
                store.addTabError == AddProjectTabErrors.addProjectTabError
                    ? localization.add_project_tab_error
                    : '',
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
