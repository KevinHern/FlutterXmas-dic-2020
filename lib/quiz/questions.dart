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

class QuestionsScreen extends StatefulWidget{
  final Participant participant;
  QuestionsScreen({Key key, @required this.participant});
  QuestionScreenState createState() => QuestionScreenState(participant: this.participant);
}

class QuestionScreenState extends State<QuestionsScreen>{
  final Participant participant;
  final List<String> questions = [
    '¿Tamal o Pavo?',
    '¿Estrellitas o Volcanes?',
    '¿Que causa más miedo? ¿Las ametralladoras, las bombas, las abejitas o el torito?',
    '¿Con qué color asocias más a la Navidad?',
    '¿Haces posada en tu casa, asistes a una o no participas?',
    '¿Pasas usualmente la Navidad en tu casa o vas a la de un familiar?',
    '¿Has botado alguna vez el Árbol de Navidad?',

  ];
  QuestionScreenState({Key key, @required this.participant});
  int actualQuestion;
  
  @override 
  void initState(){
    super.initState();
    this.actualQuestion = this.participant.answeredQuizQuestions;
  }
  
  Widget _buildTitle(){
    return new Center(
      child:new Padding(
        padding: new EdgeInsets.only(bottom: 5, top: 5),
        child: new Text(
          this.questions[this.actualQuestion],
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<String> mapQuestionToOptions(int question){
    switch(question){
      case 0:
        return ['Tamal', 'Pavo'];
      case 1:
        return ['Estrellitas', 'Volcanes'];
      case 2:
        return ['El tracka tracka boom', 'Bombas', 'Abejitas', 'El Torito'];
      case 3:
        return ['Rojo', 'Verde', 'Amarillo', 'Blanco'];
      case 4:
        return ['En mi casa', 'Asisto a una', 'No participo', '¿Qué es posada?'];
      case 5:
        return ['En mi casa', 'En la casa de un Familiar'];
      case 6:
        return ['... Sí', '¡Nope!'];
      default:
        return ['You hacker!'];
    }
  }

  Widget _buildOptions(List<String> options){
    List<Widget> buttons = [];
    for(int i = 0; i < options.length; i++){
      buttons.add(
          new Padding(
            padding: EdgeInsets.all(10),
            child: ButtonTemplate.buildBasicButton(
              () async {
                try{
                  DialogTemplate.initLoader(context, "Enviando Respuesta...");
                  await (new CFQuery()).updateQuizQuestionAnswer(this.actualQuestion, i);
                  this.actualQuestion++;
                  this.participant.answeredQuizQuestions++;
                  DialogTemplate.terminateLoader();
                  setState(() {});
                }
                catch(error){
                  DialogTemplate.terminateLoader();
                  DialogTemplate.showMessage(context, "¡Ooops!\nOcurrió un error, intenta otra vez", "Aviso", 10);
                }
              },
              0x00AA0000,
              options[i],
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
    return (this.participant.answeredQuizQuestions >= this.questions.length)?
        new Container(
          height: 270,
          width: double.infinity,
          child: new AlertDialog(
            title: new Text("Aviso"),
            content: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 15),
                    child: new Text("¡Haz contestado todas la preguntas!\nTe invito a ver las estadísticas."),
                  ),
                  (!this.participant.snowmanArtifacts[4])?
                  new GestureDetector(
                    child: new Container(
                      width: 50,
                      height: 50,
                      child: new Image.asset('assets/images/coal.png'),
                    ),
                    onTap: () async {
                      if(this.participant.addSnowmanArtifacts(4)) await this.participant.addCard(context, 'snowman');
                      else DialogTemplate.showMessage(
                          context,
                          "¡Acabas de conseguir el Ojo #2!\nFaltan por conseguir " + this.participant.getRemainingSnowmanArtifacts().toString() + " piezas para armar el muñeco de nieve.",
                          "Aviso",
                          10
                      );
                      setState(() {});
                    },
                  )
                      :
                  new Container(),
                ],
              ),
            ),
          ),
        ) :
        new Center(
            child: ContainerTemplate.buildContainer(
              new ListView(
                scrollDirection: Axis.vertical,
                padding: new EdgeInsets.only(left: 10, right: 10),
                children: <Widget>[
                  this._buildTitle(),
                  ContainerTemplate.buildDivider(0xAAAAAAFF),
                  new Center(
                    child: this._buildOptions(this.mapQuestionToOptions(this.actualQuestion)),
                  ),
                ],
              ),
              [30, 30, 30, 90], 25,
              15, 15, 0.15, 30,
            )
        );
  }
}