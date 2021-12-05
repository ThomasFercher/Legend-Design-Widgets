import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legend_design_core/styles/theming/theme_provider.dart';

import 'package:legend_design_core/typography/legend_text.dart';
import 'package:legend_design_core/typography/typography.dart';

import 'package:provider/provider.dart';

class LegendCard extends StatelessWidget {
  const LegendCard({
    this.height,
    this.width,
    this.icon,
    this.subtitle,
    this.title,
    this.value,
    this.children,
    this.iconColor,
  });

  final double? height;
  final double? width;
  final String? title;
  final String? value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: theme.colors.elevations?[1],
      shape: RoundedRectangleBorder(
        borderRadius: theme.sizing.borderRadius[1],
      ),
      color: theme.colors.cardBackgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: height,
            width: width,
            child: Padding(
              padding: EdgeInsets.all(
                18.0,
              ),
              child: Stack(
                children: getContent(height, width, context),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> getContent(height, width, context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context);

    if (children != null)
      return children!;
    else
      return [
        Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LegendText(
                      text: title ?? "",
                      textStyle: theme.typography.h3.copyWith(
                        color: theme.colors.foreground[3],
                      ),
                    ),
                  ),
                  LegendText(
                    text: subtitle ?? "",
                    textStyle: theme.typography.h3.copyWith(
                      color: Colors.greenAccent[400],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: iconColor ?? theme.colors.primaryColor,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: LegendText(
                        text: value ?? "",
                        textStyle: theme.typography.h3.copyWith(
                          color: theme.colors.foreground[3],
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
  }
}
