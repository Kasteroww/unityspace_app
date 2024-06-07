import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/columns_list/column_button.dart';

class ColumnsListRow extends StatefulWidget {
  final List<ColumnButton> children;

  const ColumnsListRow({
    required this.children,
    super.key,
  });

  @override
  State<ColumnsListRow> createState() => _ColumnsListRowState();
}

class _ColumnsListRowState extends State<ColumnsListRow> {
  late List<GlobalKey> columnsKeys;

  @override
  void initState() {
    super.initState();
    columnsKeys = List.generate(widget.children.length, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedColumn =
          widget.children.indexWhere((column) => column.isSelected);
      if (selectedColumn == -1) return;
      final selectedColumnContext = columnsKeys[selectedColumn].currentContext;
      if (selectedColumnContext != null) {
        Scrollable.ensureVisible(
          selectedColumnContext,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ColumnsListRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length > columnsKeys.length) {
      final int delta = widget.children.length - columnsKeys.length;
      columnsKeys.addAll(List<GlobalKey>.generate(delta, (_) => GlobalKey()));
    } else if (widget.children.length < columnsKeys.length) {
      columnsKeys.removeRange(widget.children.length, columnsKeys.length);
    }
    final selectedColumn =
        widget.children.indexWhere((column) => column.isSelected);
    final selectedColumnOld =
        oldWidget.children.indexWhere((column) => column.isSelected);
    if (selectedColumn != selectedColumnOld) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedColumn == -1) return;
        final selectedColumnContext =
            columnsKeys[selectedColumn].currentContext;
        if (selectedColumnContext != null) {
          Scrollable.ensureVisible(
            selectedColumnContext,
            duration: const Duration(milliseconds: 300),
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.children.expand(
          (column) => [
            SizedBox(
              key: columnsKeys[widget.children.indexOf(column)],
              child: column,
            ),
          ],
        ),
      ],
    );
  }
}
