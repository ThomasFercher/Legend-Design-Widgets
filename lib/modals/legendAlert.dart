import 'package:flutter/material.dart';
import 'package:legend_design_core/objects/asset_info.dart';
import 'package:legend_design_core/styles/theming/theme_provider.dart';
import 'package:legend_design_core/typography/legend_text.dart';

import 'package:legend_design_core/typography/typography.dart';
import 'package:legend_design_widgets/legendButton/legendButton.dart';
import 'package:legend_design_widgets/legendButton/legendButtonStyle.dart';

import 'package:provider/provider.dart';

class LegendAlert extends StatelessWidget {
  String? message;
  String? buttonMessage;
  Widget? icon;
  IconData? iconData;
  Function? onConfirm;
  LegendButtonStyle? buttonStyle;

  LegendAlert({
    this.message,
    this.buttonMessage,
    this.icon,
    this.iconData,
    this.onConfirm,
    this.buttonStyle,
  });

  LegendAlert.success({this.message}) {
    icon = flareIcon(AssetInfo.successAlert);
    buttonStyle = LegendButtonStyle.confirm();
  }

  LegendAlert.info({this.message}) {
    icon = flareIcon(AssetInfo.successAlert);
    buttonStyle = LegendButtonStyle.normal();
  }

  LegendAlert.danger({this.message}) {
    icon = flareIcon(AssetInfo.successAlert);
    buttonStyle = LegendButtonStyle.danger();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context);
    double height = 140.0;

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: theme.sizing.borderRadius[0],
            ),
            child: Container(
              height: height,
              width: height * 18 / 9,
              padding: EdgeInsets.all(
                theme.sizing.borderInset[0] / 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: icon ?? Icon(iconData),
                    flex: 1,
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LegendText(
                          text: message ?? "No Message",
                          textStyle: theme.typography.h5,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: LegendButton(
                      text: LegendText(
                        text: buttonMessage ?? "OK",
                        textStyle: theme.typography.h5,
                      ),
                      onPressed: () {
                        onConfirm?.call();
                        Navigator.of(context).pop();
                      },
                      style: buttonStyle ?? LegendButtonStyle.normal(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget flareIcon(String flarePath) {
    return /*RiveAnimation.asset(
      flarePath,
      fit: BoxFit.fitWidth,
    );*/
        Container();
  }

  Widget normalIcon() {
    return Container(
      child: Column(
        children: [
          Icon(
            this.iconData,
          ),
          LegendText(text: message ?? "No message provided!")
        ],
      ),
    );
  }
}
