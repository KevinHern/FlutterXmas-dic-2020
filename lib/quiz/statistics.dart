// Basic Imports
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:progress_dialog/progress_dialog.dart';

// Templates
import 'package:xmas_2020/templates/dialog_template.dart';
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/button_template.dart';

// Models
import 'package:xmas_2020/models/participant.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xmas_2020/backend/cfquery.dart';

class StatisticsScreen extends StatefulWidget{
  final Participant participant;
  StatisticsScreen({Key key, @required this.participant});
  StatisticsScreenState createState() => StatisticsScreenState(participant: this.participant);
}

class StatisticsScreenState extends State<StatisticsScreen>{
  final Participant participant;
  final List<String> questions = [
    '¿La Navidad es alegre?',
    '¿Tamal o Pavo?',
    '¿Estrellitas o Volcanes?',
    '¿Que causa más miedo? ¿Las ametralladoras, las bombas, las abejitas o el torito?',
    '¿Con qué color asocias más a la Navidad?',
    '¿Haces posada en tu casa, asistes a una o no participas?',
    '¿Pasas usualmente la Navidad en tu casa o vas a la de un familiar?',
    '¿Has botado alguna vez el Árbol de Navidad?',

  ];
  List<int> questionsIds;
  StatisticsScreenState({Key key, @required this.participant});
  int actualQuestion;
  Map<String, double> dataMap;
  List<Color> colorList;
  double totalPersonas;
  ProgressDialog progressd;

  @override
  void initState(){
    super.initState();
    this.actualQuestion = 0;
    this.questionsIds = [];
    for(int i = 0; i < questions.length; i++){
      this.questionsIds.add(i);
    }
    this.dataMap = {
      'Absolutamente': 1,
      'Aboslutamente\nen otro color': 1
    };
    totalPersonas = 2;
    this.colorList = [Colors.red];
  }

  String mapOption(int qid){
    return "Pregunta " + (qid + 1).toString();
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
              onChanged: (newValue) async {

                this.actualQuestion = newValue;
                if(this.actualQuestion > 0) {
                  this.progressd = new ProgressDialog(
                    context,
                    type: ProgressDialogType.Normal,
                  );
                  this.progressd.style(
                      message: "Cargando...",
                      borderRadius: 10.0,
                      backgroundColor: Colors.white,
                      progressWidget: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(new Color(0xFF146B3A)),
                      ),
                      elevation: 10.0,
                      insetAnimCurve: Curves.easeInOut,
                      messageTextStyle: TextStyle(
                          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
                  );
                  await DialogTemplate.initLoader(context, "Cargando...");
                  this.dataMap = await (new CFQuery()).getQuestionAnswers(this.actualQuestion - 1);
                  try{
                    this.totalPersonas = this.dataMap.values.reduce((sum, element) => sum + element);
                    await this.progressd.hide();
                  }
                  catch(error){
                    this.totalPersonas = 0;
                    await this.progressd.hide();
                  }
                }
                setState(() {});
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
          this.questions[this.actualQuestion],
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPieChart(){
    return new PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      //colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 32,
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
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
        padding: new EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 40),
        children: <Widget>[
          new Padding(padding: EdgeInsets.only(left: 50, right: 50, bottom: 10), child: this._buildFilter(),),
          ContainerTemplate.buildContainer(
            new Padding(padding: new EdgeInsets.only(top: 5, bottom: 5), child: this._buildTitle(),),
            [0,0,0,0], 15,
            5, 5, 0.15, 30,
          ),
          new Padding(padding: new EdgeInsets.only(bottom: 5, top: 5), child: ContainerTemplate.buildDivider(0xFFC7C7C7),),
          ContainerTemplate.buildContainer(
            new Column(
              children: <Widget>[
                new Padding(padding: new EdgeInsets.only(top: 10, bottom: 10), child: this._buildPieChart(),),
                new Visibility(
                  visible: this.actualQuestion > 0,
                  child: new Padding(
                    padding: new EdgeInsets.only(bottom: 10),
                    child: new Text(this.totalPersonas.toInt().toString() + " personas han contestado esta pregunta."),
                  ),
                ),

              ],
            ),
            [0,0,0,0], 15,
            5, 5, 0.15, 30,
          ),
        ],
      ),
    );
  }
}