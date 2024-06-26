import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/widgets/circular_progress_indicator_with_percentage/circular_progress_indicator_with_percentage.dart';
import 'package:unityspace/screens/widgets/member_list.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';

class ProjectCardInfo extends StatelessWidget {
  const ProjectCardInfo({required this.projectWithUsersOnline, super.key});

  final ProjectWithUsersOnline projectWithUsersOnline;

  @override
  Widget build(BuildContext context) {
    final color = _getForegroundColor(projectWithUsersOnline.project.color);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
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
                      projectWithUsersOnline.project.taskCount,
                      projectWithUsersOnline.project.allTaskCount,
                    ),
                    strokeWidth: 2,
                    size: 32,
                    foregroundColor: color,
                    backgroundColor: ColorConstants.grey10,
                    child: projectWithUsersOnline.project.responsibleId != null
                        ? UserAvatarWidget(
                            id: projectWithUsersOnline.project.responsibleId!,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // название
                        Text(
                          projectWithUsersOnline.project.name,
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
                        if (_isHaveMemo(
                          projectWithUsersOnline.project,
                        ))
                          Text(
                            projectWithUsersOnline.project.memo ?? '',
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
                ],
              ),
            ),
          ),
        ),
        // Список карточек тех, кто в этом проекте онлайн
        // пока не подключен сокет отображается только список
        // из ответственного
        Positioned(
          top: 4,
          right: 8,
          child: MembersList(userIds: projectWithUsersOnline.userIds),
        ),
      ],
    );
  }

  bool _isHaveMemo(Project project) {
    return project.memo != null && project.memo!.isNotEmpty;
  }

  double _calculatePercents(int taskCount, int allTaskCount) {
    final int completedTasksCount = allTaskCount - taskCount;
    return (completedTasksCount / allTaskCount) * 100;
  }

  Color _getForegroundColor(Color? color) {
    const defaultColor = Color(0xFF606062);
    return color ?? defaultColor;
  }
}
