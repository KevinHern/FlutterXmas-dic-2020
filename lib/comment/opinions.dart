// Basic Imports
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

// Templates
import 'package:xmas_2020/templates/navbar_template.dart';
import 'package:xmas_2020/templates/dialog_template.dart';
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/form_template.dart';
import 'package:xmas_2020/templates/button_template.dart';

// Models
import 'package:xmas_2020/models/participant.dart';

// Bakckend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xmas_2020/backend/cfquery.dart';

class OpinionScreen extends StatelessWidget {
  final Participant participant;
  final List<String> questions;
  OpinionScreen({Key key, @required this.participant, @required this.questions});

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(
      context,
      'Opiniones',
      new MainOpinionScreen(participant: this.participant, questions: this.questions,),
    );
  }
}

class MainOpinionScreen extends StatefulWidget {
  final Participant participant;
  final List<String> questions;
  MainOpinionScreen({Key key, @required this.participant, @required this.questions}) : super(key: key);

  @override
  MainOpinionState createState() => MainOpinionState(participant: this.participant, questions: this.questions);
}

class MainOpinionState extends State<MainOpinionScreen>{
  final Participant participant;
  final List<String> questions;
  final ScrollController listScrollController = new ScrollController();
  final TextEditingController _opinionController = new TextEditingController();
  final _opinionIcons = ['elf', 'candy_bar', 'penguin', 'bell', 'gingerbread_house', 'sleigh', 'snowstorm'];
  final Random rng = new Random();
  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;
  MainOpinionState({Key key, @required this.participant, @required this.questions});

  String actualQuestion = "question1";
  List<String> questionsIds;
  Map<String, String> questionsDict;

  void initState(){
    super.initState();
    this.questionsIds = [];
    this.questionsDict = {};
    try{
      for(int i = 0; i < this.questions.length; i++){
        List<String> temp = questions[i].split('-');
        questionsIds.add(temp[0]);
        questionsDict[temp[0]] = temp[1];
      }
      this.actualQuestion = questionsIds[0];
    }
    catch(error){
      print(error);
    }

  }

  String mapOption(String option){
    return "Pregunta " + option.split('n')[1];
  }

  Widget _buildFilter() {
    return new Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid
          ),
        ),
        child: new Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: new Center(
            child: new DropdownButton(
              hint: Text(''), // Not necessary for Option 1
              value: this.actualQuestion,
              onChanged: (newValue) {
                setState(() {
                  this.actualQuestion = newValue;
                });
              },
              items: this.questionsIds.map((option) {
                return DropdownMenuItem(
                  child: new Text(this.mapOption(option), style: TextStyle(fontWeight: FontWeight.bold),),
                  value: option,
                );
              }).toList(),
            ),
          ),
        )
    );
  }

  Widget _buildTitle(){
    return new Center(
      child:new Padding(
        padding: new EdgeInsets.only(bottom: 5),
        child: new Text(
          this.questionsDict[this.actualQuestion],
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCommentSpace(){
    return ContainerTemplate.buildContainer(
    new Padding(
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
        child: new Column(
          children: <Widget>[
            this._buildTitle(),
            FormTemplate.buildMultiTextInput(
                this._opinionController, "¿Qué piensas?", Icons.comment, this._iconLabelColor, this._borderColor, this._borderoFocusColor
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ButtonTemplate.buildBasicButton(  // Info Button
                    () async {
                      if(this._opinionController.text.length > 0 && this._opinionController.text.trim().length > 0){
                        DialogTemplate.initLoader(context, "Espera un momento...");
                        bool successful = await (new CFQuery()).publishOpinion(this.participant, this._opinionController.text, this.actualQuestion);
                        await (new CFQuery()).updateCollectedCard('fireworks');
                        DialogTemplate.terminateLoader();

                        if(successful){
                          String additionalInfo = "";
                          if (!participant.obtainedCards[0] && actualQuestion == "question3"){
                            additionalInfo = "\n\n ¡...Y algo mágico acaba de ocurrir!";
                            participant.obtainedCards[0] = true;
                          }
                          DialogTemplate.showMessage(context, "¡Mensaje publicado!\nAhora cualquiera puede ver tu opinion." + additionalInfo, "Aviso", 10);
                        }
                        else DialogTemplate.showMessage(context, "¡Rayos!\nOcurrió un error, inténtalo de nuevo.", "Aviso", 0);
                      }
                      else DialogTemplate.showMessage(context, "¡No seas tímido!\nDinos realmente lo que piensas", "Aviso", 0);
                    },
                    0xFF002FD3,
                    "Publicar",
                    0xFFFFFFFF
                ),
                ButtonTemplate.buildBasicButton(  // Close Button
                    () {
                      this._opinionController.text = "";
                    },
                    0xFFe30224,
                    "Borrar",
                    0xFFFFFFFF
                ),
              ],
            ),
          ],
        ),
      ),
      [0, 15, 0, 0],
      10, 5, 5, 0.15, 10
    );
  }

  Widget _buildOpinionTile(DocumentSnapshot snapshot){
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(snapshot.get('timestamp'));
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(timestamp);
    int generatedInt = rng.nextInt(this._opinionIcons.length);
    return ContainerTemplate.buildContainer(
      new Column(
        children: <Widget>[
          new ListTile(
            leading: new Padding(
              padding: EdgeInsets.only(left: 0,),
              child: new GestureDetector(
                child: new Container(
                  height: 50,
                  width: 50,
                  child: new Image.asset('assets/images/' + this._opinionIcons[generatedInt] + '.png'),
                ),
                onTap: () async {
                  if(generatedInt == 6 && !this.participant.snowmanArtifacts[2]) {
                    // Top hat
                    if(this.participant.addSnowmanArtifacts(2)) await this.participant.addCard(context, 'snowman');
                    else DialogTemplate.showMessage(
                        context,
                        "¡Acabas de conseguir Nieve!\nFaltan por conseguir " + this.participant.getRemainingSnowmanArtifacts().toString() + " piezas para armar el muñeco de nieve.",
                        "Aviso",
                        10
                    );
                  }
                },
              )
            ),
            title: new Wrap(
              children: <Widget>[
                new Text(
                  formattedDate,
                  style: new TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.left,
                ),
                new Text(
                  snapshot.get("user") + " dice: ",
                  style: new TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                )
              ],
            ),
            subtitle: new Text(
              snapshot.get("opinion") + "\n",
              style: new TextStyle(
                fontSize: 17,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),

        ],
      ),
      [10,10,10,10],
      15,
      5, 5, 0.15, 30,
    );
  }

  Widget _buildDisplayOpinions(){
    return new Container(
      decoration: new BoxDecoration(
        border: Border.all(
            width: 1,
            color: Color(0xFFd9b0ff).withOpacity(0.5),
            style: BorderStyle.solid
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      width: double.infinity,
      height: 500,
      // REPLACE THIS LISTVIEW WITH LISTVIEW BUILDER WHEN IMPLEMENTING BACKEND
      child: new StreamBuilder(
        stream: FirebaseFirestore.instance.collection("xmas").doc(this.actualQuestion).collection("opinions").orderBy('timestamp', descending: false).limit(50).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
          } else {
            if (snapshot.data.documents.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return _buildOpinionTile(snapshot.data.documents[index]);
                },
              );
            }
            else {
              return new AlertDialog(
                title: new Text("Aviso"),
                content: new Text("Nadie ha compartido su respuesta.\n¡Se el primero!"),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: new ListView(
        padding: new EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 40),
        children: <Widget>[
          new Padding(padding: EdgeInsets.only(left: 50, right: 50), child: this._buildFilter(),),
          this._buildCommentSpace(),
          new Padding(padding: new EdgeInsets.only(bottom: 5, top: 5), child: ContainerTemplate.buildDivider(0xFFC7C7C7),),
          this._buildDisplayOpinions()
        ],
      ),
    );
  }
}