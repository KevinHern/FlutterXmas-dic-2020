import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonTemplate {
  static buildBasicButton(Function onTap, int backgroundColor, String text, int textColor){
    return new RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      //padding: new EdgeInsets.only(left: 20, right: 20),
      onPressed: onTap,
      color: new Color(backgroundColor),
      textColor: Colors.white,
      child: Text(text,
          style: TextStyle(fontSize: 18)),
    );
  }

  static buildFixedButton(Function onTap, int backgroundColor, String text, int textColor, List<double> size){
    return new RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      //padding: new EdgeInsets.only(left: 20, right: 20),
      onPressed: onTap,
      textColor: Colors.white,
      child: new Center(
          child: Text(text,
            style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
      ),
    );
  }
}