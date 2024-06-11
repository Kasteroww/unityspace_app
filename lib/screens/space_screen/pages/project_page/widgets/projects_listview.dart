import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/pop_up_projects_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_info_top.dart';
import 'package:unityspace/screens/widgets/circular_progress_indicator_with_percentage/circular_progress_indicator_with_percentage.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/extensions/color_extension.dart';
import 'package:wstore/wstore.dart';

class ProjectsListview extends StatelessWidget {
  const ProjectsListview({super.key});

  @override
  Widget build(BuildContext context) {
    return WStoreBuilder(
      store: context.wstore<ProjectsPageStore>(),
      watch: (store) => [
        store.selectedColumn,
        store.projectsByColumn,
      ],
      builder: (context, store) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                ProjectInfoTop(
                  archiveProjectsCount: store.archiveProjectsCount,
                  columnName: store.selectedColumn.name,
                  isInArchive: store.isArchivedPage,
                  onArchiveButtonTap: () => store.selectArchive(),
                ),
                Flexible(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 22,
                        top: 20,
                      ),
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 16,
                        ),
                        shrinkWrap: true,
                        itemCount: store.projectsByColumn.length,
                        itemBuilder: (BuildContext context, int index) {
                          final project = store.projectsByColumn[index];
                          final color = _getForegroundColor(project.color);
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
                                    CircularProgressIndicatorWithPercentage(
                                      percentage: _calculatePercents(
                                        project.taskCount,
                                        project.allTaskCount,
                                      ),
                                      strokeWidth: 2,
                                      size: 32,
                                      foregroundColor: color,
                                      backgroundColor: ColorConstants.grey10,
                                      child: project.responsibleId != null
                                          ? UserAvatarWidget(
                                              id: project.responsibleId!,
                                              width: 22,
                                              height: 22,
                                              fontSize: 12,
                                              radius: 15,
                                            )
                                          : SvgPicture.asset(
                                              'assets/icons/folder.svg',
                                              colorFilter: ColorFilter.mode(
                                                color,
                                                BlendMode.srcIn,
                                              ),
                                            ),
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
                                              height: 20 / 16,
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
                                    PopUpProjectsButton(
                                      project: store.projectsByColumn[index],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isHaveMemo(Project project) {
    return project.memo != null && project.memo!.isNotEmpty;
  }

  double _calculatePercents(int taskCount, int allTaskCount) {
    final int completedTasksCount = allTaskCount - taskCount;
    return (completedTasksCount / allTaskCount) * 100;
  }

  Color _getForegroundColor(String? hexColor) {
    const defaultColor = Color(0xFF606062);
    if (hexColor != null) {
      if (hexColor.isEmpty) {
        return defaultColor;
      }
      return HexColor.fromHex(
            hexColor,
          ) ??
          defaultColor;
    } else {
      return defaultColor;
    }
  }
}
