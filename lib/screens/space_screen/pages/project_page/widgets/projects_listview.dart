import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unityspace/screens/dialogs/add_project_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/pop_up_projects_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ProjectsListview extends StatelessWidget {
  const ProjectsListview({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder(
      store: context.wstore<ProjectsPageStore>(),
      watch: (store) => [
        store.selectedColumn,
        store.projectsByColumn,
        store.isArchivedPage,
      ],
      builder: (context, store) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: width,
                height: height,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                constraints: BoxConstraints(
                  maxWidth: (Platform.isAndroid || Platform.isIOS)
                      ? width * 0.95
                      : width * 0.75,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          store.isArchivedPage
                              ? localization.an_archive
                              : store.selectedColumn.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: store.projectsByColumn.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              store.projectsByColumn[index].name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle:
                                store.projectsByColumn[index].memo.isNotEmpty
                                    ? Text(
                                        store.projectsByColumn[index].memo,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                            trailing: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (store.projectsByColumn[index].favorite)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                  )
                                else
                                  Container(),
                                PopUpProjectsButton(
                                  project: store.projectsByColumn[index],
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      ),
                    ),
                    if (store.isArchivedPage)
                      Container()
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TabButton(
                                title: '+ ${localization.add_project}',
                                selected: false,
                                onPressed: () {
                                  showAddProjectDialog(
                                    context,
                                    store.selectedColumn.id,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
