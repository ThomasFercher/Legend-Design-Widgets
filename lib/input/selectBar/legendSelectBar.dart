import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:legend_design_core/styles/theming/colors/legend_color_theme.dart';
import 'package:legend_design_core/styles/theming/sizing/legend_sizing.dart';
import 'package:legend_design_core/styles/theming/theme_provider.dart';

import 'package:legend_design_widgets/input/selectBar/selectProvider.dart';
import 'package:provider/provider.dart';
import 'legendSelectOption.dart';
import 'legendselectButton.dart';

class LegendSelectBar extends StatelessWidget {
  final List<LegendSelectOption> options;
  final void Function(LegendSelectOption selected) onSelected;
  final MainAxisAlignment? aligment;
  final double? iconSize;
  final bool? isCard;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;

  LegendSelectBar({
    required this.options,
    required this.onSelected,
    required this.aligment,
    this.color,
    this.iconSize,
    this.isCard,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
  });

  List<Widget> getOptions(BuildContext context) {
    List<Widget> widgets = [];

    for (LegendSelectOption o in options) {
      Widget w = new LegendSelectButton(
        option: o,
        size: iconSize ?? 24,
        onClick: (selOption) {
          Provider.of<LegendSelectProvider>(context, listen: false)
              .selectOption(o);
          onSelected(selOption);
        },
      );
      widgets.add(w);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    LegendColorTheme theme = Provider.of<ThemeProvider>(context).colors;
    LegendSizing sizing = Provider.of<ThemeProvider>(context).sizing;

    return ListenableProvider<LegendSelectProvider>(
      create: (c) => new LegendSelectProvider(options.first),
      builder: (context, snapshot) {
        return Padding(
          padding: margin ?? EdgeInsets.all(4.0),
          child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(sizing.borderInset[0] / 2),
            decoration: isCard ?? false
                ? BoxDecoration(
                    borderRadius: borderRadius ?? sizing.borderRadius[0],
                    color: color ?? Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: Offset(
                          0,
                          1,
                        ),
                      ),
                    ],
                  )
                : null,
            child: Row(
              mainAxisAlignment: aligment ?? MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getOptions(context),
            ),
          ),
        );
      },
    );
  }
}
