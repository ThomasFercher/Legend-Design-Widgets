import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legend_design_core/styles/layouts/layout_type.dart';
import 'package:legend_design_core/styles/theming/sizing/size_provider.dart';
import 'package:legend_design_core/styles/theming/theme_provider.dart';

import 'package:legend_design_widgets/legendButton/legendButtonStyle.dart';
import 'package:provider/provider.dart';

import '../legendButton/legendButton.dart';

class Modal extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget content;
  final Function onConfirm;
  final Function onCancle;

  const Modal({
    Key? key,
    this.height,
    this.width,
    required this.content,
    required this.onConfirm,
    required this.onCancle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context);
    double maxWidth = MediaQuery.of(context).size.width;
    double padding = 0;

    if (width != null) {
      if (maxWidth - 24 <= width!) {
        padding = 24;
      }
    } else {
      ScreenSize ss = SizeProvider.getScreenSizeFromWidth(maxWidth);
      if (ss == ScreenSize.Small) {
        padding = 24;
      }
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Material(
              borderRadius: theme.sizing.borderRadius[0],
              color: Colors.white,
              child: Container(
                height: height,
                width: width,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: theme.sizing.borderInset[0] / 2,
                        bottom: theme.sizing.borderInset[0] / 2,
                        right: theme.sizing.borderInset[0] / 2,
                        left: theme.sizing.borderInset[0],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Title"),
                          IconButton(
                            splashRadius: 20.0,
                            onPressed: () => {
                              // Maybe Implement with RouterProvider
                              Navigator.pop(context),
                            },
                            icon: Icon(Icons.close),
                            padding: EdgeInsets.all(0),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: content,
                    ),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: theme.sizing.borderInset[0] / 2,
                        bottom: theme.sizing.borderInset[0] / 2,
                        right: theme.sizing.borderInset[0] / 2,
                        left: theme.sizing.borderInset[0],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          LegendButton(
                            onPressed: () {
                              onCancle();
                              Navigator.pop(context);
                            },
                            text: Text("Cancel"),
                            style: LegendButtonStyle.danger(),
                          ),
                          LegendButton(
                            onPressed: () {
                              onConfirm();
                            },
                            text: Text("Confirm"),
                            style: LegendButtonStyle.normal(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
