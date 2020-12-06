import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DialogTemplate {
  static ProgressDialog progress;

  static void showMessage(BuildContext context, String message, String title, int iconOption){
    String iconPath;
    switch(iconOption){
    // Bad = ball_red.png
      case 0:
        iconPath = 'assets/images/ball_red.png';
        break;
      // Good = ball_green.png
      case 1:
        iconPath = 'assets/images/ball_green.png';
        break;
      // Info = star.png
      case 10:
        iconPath = 'assets/images/star.png';
        break;
    }
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 40,
                  width: 40,
                  child: new Image.asset(iconPath),
                ),
                new Padding(
                  padding: new EdgeInsets.only(left: 15),
                  child: new Text(title),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new SingleChildScrollView(
              child: new Text(message),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/snowflake_green.png'),
                ),
              ),
            ],
          );
        }
    );
  }

  static void initLoader(BuildContext context, String message) {
    progress = new ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
    );
    progress.style(
        message: message,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    progress.show();
  }

  static void terminateLoader() async {
    if(progress.isShowing() && progress != Null) {
      await progress.hide().timeout(new Duration(milliseconds: 500));
    }
  }
}