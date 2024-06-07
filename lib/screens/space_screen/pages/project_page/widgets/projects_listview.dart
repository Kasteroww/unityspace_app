import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/pop_up_projects_button.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ProjectsListview extends StatelessWidget {
  const ProjectsListview({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder(
      store: context.wstore<ProjectsPageStore>(),
      watch: (store) => [
        store.selectedColumn,
        store.projectsByColumn,
      ],
      builder: (context, store) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 24),
                    child: Text(
                      store.isArchivedPage
                          ? localization.an_archive
                          : store.selectedColumn.name,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 14 / 20,
                        color: ColorConstants.grey02,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: store.projectsByColumn.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/project',
                              arguments: {
                                'projectId': store.projectsByColumn[index].id,
                              },
                            );
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorConstants.grey10,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  // Аватарка пользователя со статусом
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.blue,
                                    ),
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // название
                                        Text(
                                          store.projectsByColumn[index].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: ColorConstants.grey01,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        // Доп описание
                                        if (isHaveMemo(
                                          store.projectsByColumn[index],
                                        ))
                                          Text(
                                            store.projectsByColumn[index]
                                                    .memo ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              height: 14 / 12,
                                              color: ColorConstants.grey04,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (store
                                          .projectsByColumn[index].favorite)
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
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool isHaveMemo(Project project) {
    return project.memo != null && project.memo!.isNotEmpty;
  }
}
