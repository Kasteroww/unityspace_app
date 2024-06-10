import 'package:collection/collection.dart';
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

enum AddTabDialogTypes { categoryDocs, categoryLink, categoryEmbed }

class AddTabDialogStore extends WStore {
  AddProjectTabErrors addTabError = AddProjectTabErrors.none;
  WStoreStatus statusAddTabDialog = WStoreStatus.init;
  AddTabDialogTypes selectedCategory = AddTabDialogTypes.categoryLink;
  String name = '';
  String url = '';

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

  void selectCategory(AddTabDialogTypes tab) {
    setStore(() {
      selectedCategory = tab;
    });
  }

  void setTabName(String tabName) {
    setStore(() {
      name = tabName;
    });
  }

  void setTabLink(String tabLink) {
    setStore(() {
      url = tabLink;
    });
  }

  Future<void> _createProjectEmbed() {
    return ProjectsStore().createProjectEmbed(
      projectId: project!.id,
      name: name,
      url: url,
      category: selectedCategory == AddTabDialogTypes.categoryLink
          ? ProjectEmbedTypes.categoryLink.value
          : ProjectEmbedTypes.categoryEmbed.value,
    );
  }

  Future<void> _showProjectReviewTab() {
    return ProjectsStore()
        .showProjectReviewTab(projectId: project!.id, show: true);
  }

  bool isSelectedCategoryDocs() =>
      selectedCategory == AddTabDialogTypes.categoryDocs;

  void addTabDialog() {
    if (statusAddTabDialog == WStoreStatus.loading) return;
    setStore(() {
      statusAddTabDialog = WStoreStatus.loading;
      addTabError = AddProjectTabErrors.none;
    });

    if (project == null) {
      setStore(() {
        statusAddTabDialog = WStoreStatus.loading;
        addTabError = AddProjectTabErrors.addProjectTabError;
      });
      return;
    }

    if (selectedCategory != AddTabDialogTypes.categoryDocs &&
        (name.isEmpty || url.isEmpty)) {
      setStore(() {
        addTabError = AddProjectTabErrors.valueIsEmpty;
        statusAddTabDialog = WStoreStatus.error;
      });
      return;
    }

    subscribe(
      future: isSelectedCategoryDocs()
          ? _showProjectReviewTab()
          : _createProjectEmbed(),
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
              watch: (store) => [store.selectedCategory],
              builder: (context, store) {
                final List<(AddTabDialogTypes, String, String)> listTabs = [
                  if (!store.isShowProjectReviewTab)
                    (
                      AddTabDialogTypes.categoryDocs,
                      localization.documents,
                      localization.add_tab_enter_docs
                    ),
                  (
                    AddTabDialogTypes.categoryLink,
                    localization.link,
                    localization.add_tab_enter_link
                  ),
                  (
                    AddTabDialogTypes.categoryEmbed,
                    localization.embed,
                    localization.add_tab_enter_embed
                  ),
                ];

                return SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listTabs
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: TabButton(
                                    title: e.$2,
                                    selected: e.$1 == store.selectedCategory,
                                    onPressed: () => store.selectCategory(e.$1),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AddTabDialogFieldsColumn(
                          tabDescription: listTabs
                              .firstWhereOrNull(
                                (tab) => tab.$1 == store.selectedCategory,
                              )
                              ?.$3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (error)
              Text(
                switch (store.addTabError) {
                  AddProjectTabErrors.none => '',
                  AddProjectTabErrors.valueIsEmpty =>
                    localization.value_cannot_be_empty,
                  AddProjectTabErrors.addProjectTabError =>
                    localization.add_project_tab_error,
                },
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
