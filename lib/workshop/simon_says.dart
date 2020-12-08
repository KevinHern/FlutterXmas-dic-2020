// Basic Imports
import 'package:flutter/material.dart';

// Templates
import 'package:xmas_2020/templates/dialog_template.dart';
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/button_template.dart';

// Models
import 'package:xmas_2020/models/participant.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xmas_2020/backend/cfquery.dart';

class SimonSaysScreen extends StatefulWidget{
  final Participant participant;
  SimonSaysScreen({Key key, @required this.participant});
  SimonSaysScreenState createState() => SimonSaysScreenState(participant: this.participant);
}

class SimonSaysScreenState extends State<SimonSaysScreen>{
  final Participant participant;
  final patterns = [
    [4, 3, 2, 1],
    [1, 1, 3, 4, 2],
    [2, 3, 2, 4, 1, 3],
    [1, 1, 3, 2, 4, 1, 4],
    [3, 4, 4, 1, 3, 2, 1, 4]
  ];
  final List<int> colorPressedButtons = [
    0xFF4287f5,
    0xFFf54242,
    0xFFf5e342,
    0xFF42f554
  ];
  final List<int> colorButtons = [
    0xFF92e8f0,
    0xFF92e8f0,
    0xFF92e8f0,
    0xFF92e8f0
  ];
  SimonSaysScreenState({Key key, @required this.participant});
  int indexPattern;
  List<int> actualPattern;
  bool alreadySawPattern, canPress;

  @override
  void initState(){
    super.initState();
    this.alreadySawPattern = false;
    this.indexPattern = 0;
    this.canPress = true;
    this.actualPattern = (this.participant.numPattern < this.patterns.length)? this.patterns[this.participant.numPattern] : [];
  }

  Widget _buildTitle(){
    return new Center(
      child:new Padding(
        padding: new EdgeInsets.only(bottom: 5, top: 5),
        child: new Text(
          "¡Simón Dice!",
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildButtons(){
    List<Widget> buttons = [];
    for(int i = 1; i <= 4; i++){
      buttons.add(
          new Padding(
            padding: EdgeInsets.all(10),
            child: ButtonTemplate.buildBasicButton(
              () async {
                if(this.canPress){
                  setState(() {});
                  this.colorButtons[i-1] = this.colorPressedButtons[i-1];
                  if(this.actualPattern[this.indexPattern] == i){
                    this.indexPattern++;
                    if(this.indexPattern >= this.actualPattern.length) {
                      this.indexPattern = 0;
                      this.alreadySawPattern = false;
                      DialogTemplate.showMessage(context, "¡Lo lograste!\nEres muy bueno en esto :D", "¡Bien Hecho!", 1);
                      if(++this.participant.numPattern >= this.patterns.length) this.participant.simonSaysComplete = true;
                      else this.actualPattern = this.patterns[this.participant.numPattern];
                    }
                  }
                  else {
                    this.indexPattern = 0;
                    this.alreadySawPattern = false;
                    DialogTemplate.showMessage(context, "Te equivocaste :(", "¡Rayos!", 0);
                  }
                  await Future.delayed(Duration(seconds: 1));
                  setState(() {});
                  this.colorButtons[i-1] = 0xFF92e8f0;
                  setState(() {});
                }
              },
              this.colorButtons[i-1],
              "",
              0xFFFFFFFF,
            ),
          )
      );
    }

    return new SingleChildScrollView(
      child: GridView.count(
          shrinkWrap: true,
          padding: new EdgeInsets.all(10),
          crossAxisCount: 2,
          children: buttons
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: ContainerTemplate.buildContainer(
        new ListView(
          scrollDirection: Axis.vertical,
          padding: new EdgeInsets.only(left: 10, right: 10),
          children: <Widget>[
            this._buildTitle(),
            ContainerTemplate.buildDivider(0xAAAAAAFF),
            new Center(
              child: new Visibility(
                child: this._buildButtons(),
                visible: !this.participant.simonSaysComplete,
              ),
            ),
            new Visibility(
              visible: !this.participant.simonSaysComplete,
              child: new Padding(
                padding: new EdgeInsets.only(top: 20),
                child: new Center(
                  child: ButtonTemplate.buildBasicButton(
                        () async {

                      if(!this.alreadySawPattern){
                        this.canPress = false;
                        this.alreadySawPattern = true;
                        for(int i = 0; i < this.actualPattern.length; i++){
                          int button = this.actualPattern[i] - 1;
                          setState(() {});
                          this.colorButtons[button] = this.colorPressedButtons[button];
                          await Future.delayed(Duration(milliseconds: 500));
                          setState(() {});
                          this.colorButtons[button] = 0xFF92e8f0;
                          await Future.delayed(Duration(milliseconds: 250));
                          setState(() {});
                        }
                        this.canPress = true;
                      }

                    },
                    0xFF0000FF,
                    "Mirar Patrón", 0xFFFFFFFF,
                  ),
                ),
              ),
            ),
            new Visibility(
              visible: this.participant.simonSaysComplete,
              child: new Padding(
                padding: new EdgeInsets.only(top: 20),
                child: new AlertDialog(
                  title: new Text("Aviso"),
                  content: new Text("¡Has restaurado la magia!\nVuelve con el elfo, creo que tiene algo para ti...", textAlign: TextAlign.left,),
                ),
              ),
            ),
          ],
        ),
        [30, 30, 30, 120], 25,
        15, 15, 0.15, 30,
      )
    );
  }
}