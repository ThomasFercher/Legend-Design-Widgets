import 'package:flutter/material.dart';

class LegendCustomFlexLayout extends StatelessWidget {
  final LegendFlexItem item;
  final List<Widget> widgets;

  final double height;

  List<Widget> alignedWidgets = [];

  LegendCustomFlexLayout({
    required this.item,
    required this.widgets,
    required this.height,
  });

  Widget getChildren(
    LegendFlexItem item, {
    double? height,
    double? width,
  }) {
    Widget widget;

    switch (item.type) {
      case LegendFlexLayoutType.COLUMN:
        List<Widget> columnWidgets = [];

        if (item.childrenIndex != null) {
          int i = 0;
          for (int index in item.childrenIndex!) {
            columnWidgets.add(
              Expanded(
                child: widgets[index],
                flex: item.childrenFlex?[i] ?? 1,
              ),
            );

            i++;
          }
        }

        if (item.hasChildren) {
          for (LegendFlexItem item in item.children!) {
            columnWidgets.add(
              Expanded(
                child: getChildren(item),
                flex: item.flex ?? 1,
              ),
            );
          }
        }

        widget = Container(
          height: height,
          child: Column(
            children: columnWidgets,
          ),
        );

        break;
      case LegendFlexLayoutType.ROW:
        List<Widget> rowWidgets = [];

        if (item.childrenIndex != null) {
          int i = 0;
          for (int index in item.childrenIndex!) {
            rowWidgets.add(
              Expanded(
                child: widgets[index],
                flex: item.childrenFlex?[i] ?? 1,
              ),
            );
            i++;
          }
        }

        if (item.hasChildren) {
          for (LegendFlexItem item in item.children!) {
            print(item.flex);
            rowWidgets.add(
              Flexible(
                child: getChildren(item),
                flex: item.flex ?? 1,
              ),
            );
          }
        }

        widget = Container(
          height: height,
          child: Row(
            children: rowWidgets,
          ),
        );

        break;
    }

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getChildren(
        item,
        height: height,
      ),
    );
  }
}

enum LegendFlexLayoutType {
  COLUMN,
  ROW,
}

class LegendFlexItem {
  final List<LegendFlexItem>? children;
  final List<int>? childrenIndex;
  final List<int>? childrenFlex;
  final int? flex;
  late final LegendFlexLayoutType type;

  bool get hasChildren => children != null;

  LegendFlexItem({
    this.children,
    required this.type,
    this.childrenIndex,
    this.childrenFlex,
    this.flex,
  });

  factory LegendFlexItem.column({
    List<LegendFlexItem>? children,
    List<int>? childrenIndex,
    List<int>? childrenFlex,
    int? flex,
  }) {
    return LegendFlexItem(
      children: children,
      childrenIndex: childrenIndex,
      type: LegendFlexLayoutType.COLUMN,
      childrenFlex: childrenFlex,
      flex: flex,
    );
  }

  factory LegendFlexItem.row({
    List<LegendFlexItem>? children,
    List<int>? childrenIndex,
    List<int>? childrenFlex,
    int? flex,
  }) {
    return LegendFlexItem(
      children: children,
      childrenIndex: childrenIndex,
      type: LegendFlexLayoutType.ROW,
      childrenFlex: childrenFlex,
      flex: flex,
    );
  }
}
