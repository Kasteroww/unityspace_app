import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/widgets/columns_list/column_button.dart';
import 'package:unityspace/screens/widgets/columns_list/columns_list_row.dart';
import 'package:wstore/wstore.dart';

class ProjectColumnsListView extends StatelessWidget {
  const ProjectColumnsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return WStoreBuilder<ProjectsPageStore>(
      watch: (store) => [
        store.selectedColumn,
        store.isArchivedPage,
        store.projectColumns,
      ],
      store: context.wstore(),
      builder: (context, store) {
        return Column(
          children: [
            if (store.isNeedToShowColumns) ...[
              Container(
                color: ColorConstants.background,
                height: 46,
                padding: const EdgeInsets.only(left: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ColumnsListRow(
                      children: [
                        ...store.projectColumns.map(
                          (column) => ColumnButton(
                            title: column.name,
                            onTap: () {
                              store.selectColumn(column);
                            },
                            isSelected: column == store.selectedColumn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                color: ColorConstants.grey09,
              ),
            ],
          ],
        );
      },
    );
  }
}
