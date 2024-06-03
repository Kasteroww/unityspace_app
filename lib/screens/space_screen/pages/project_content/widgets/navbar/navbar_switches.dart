import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavbarSwitches extends StatelessWidget {
  const NavbarSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.wstore<ProjectContentStore>();
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WStoreBuilder(
          store: store,
          watch: (store) => [store.selectedTab, store.currentTabs],
          builder: (context, store) => Row(
            children: [
              TabsListRow(
                children: [
                  ...store.currentTabs.map(
                    (tab) => TabButton(
                      title: switch (tab) {
                        ProjectEmbedTab.tasks => localization.tasks,
                      },
                      onPressed: () {
                        store.selectTab(tab);
                      },
                      selected: tab == store.selectedTab,
                    ),
                  ),
                  ...store.embeddings.map(
                    (tab) => TabButton(
                      title: tab.name,
                      onPressed: () {},
                      selected: false,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.add),
              if (store.selectedTab == ProjectEmbedTab.tasks)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TabButton(
                        onPressed: () {},
                        title: '${localization.completed_today}: 0',
                        selected: false,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.search),
                      const SizedBox(width: 12),
                      const Icon(Icons.filter_alt),
                      const SizedBox(width: 12),
                      const Icon(Icons.more_vert),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum ProjectEmbedTab { tasks }
