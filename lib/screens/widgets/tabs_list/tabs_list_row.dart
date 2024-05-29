import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';

class TabsListRow extends StatefulWidget {
  final List<TabButton> children;

  const TabsListRow({
    required this.children,
    super.key,
  });

  @override
  State<TabsListRow> createState() => _TabsListRowState();
}

class _TabsListRowState extends State<TabsListRow> {
  late List<GlobalKey> tabsKeys;

  @override
  void initState() {
    super.initState();
    tabsKeys = List.generate(widget.children.length, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedTab = widget.children.indexWhere((tab) => tab.selected);
      if (selectedTab == -1) return;
      final selectedTabContext = tabsKeys[selectedTab].currentContext;
      if (selectedTabContext != null) {
        Scrollable.ensureVisible(
          selectedTabContext,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant TabsListRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length > tabsKeys.length) {
      final int delta = widget.children.length - tabsKeys.length;
      tabsKeys.addAll(List<GlobalKey>.generate(delta, (_) => GlobalKey()));
    } else if (widget.children.length < tabsKeys.length) {
      tabsKeys.removeRange(widget.children.length, tabsKeys.length);
    }
    final selectedTab = widget.children.indexWhere((tab) => tab.selected);
    final selectedTabOld = oldWidget.children.indexWhere((tab) => tab.selected);
    if (selectedTab != selectedTabOld) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedTab == -1) return;
        final selectedTabContext = tabsKeys[selectedTab].currentContext;
        if (selectedTabContext != null) {
          Scrollable.ensureVisible(
            selectedTabContext,
            duration: const Duration(milliseconds: 300),
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16),
          ...widget.children.expand(
            (tab) => [
              SizedBox(
                key: tabsKeys[widget.children.indexOf(tab)],
                child: tab,
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
