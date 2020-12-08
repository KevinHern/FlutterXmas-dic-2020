// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Models
import 'package:xmas_2020/models/participant.dart';
import 'package:xmas_2020/models/navbar.dart';

// Routes
import 'questions.dart';
import 'statistics.dart';

// Templates
import 'package:xmas_2020/templates/dialog_template.dart';
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/navbar_template.dart';
import 'package:xmas_2020/templates/fade_template.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xmas_2020/backend/cfquery.dart';

class MainQuizScreen extends StatefulWidget {
  final Participant participant;
  MainQuizScreen({Key key, @required this.participant}) : super(key: key);

  @override
  MainQuizScreenState createState() => MainQuizScreenState(participant: this.participant);
}

class MainQuizScreenState extends State<MainQuizScreen> with SingleTickerProviderStateMixin {
  NavBar navBar;
  final Participant participant;
  FadeAnimation _fadeAnimation;

  @override
  void initState(){
    super.initState();
    navBar = new NavBar(1, 1);
    _fadeAnimation = new FadeAnimation(this);
  }

  MainQuizScreenState({@required this.participant});

  Widget defaultScreen() {
    return new Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ContainerTemplate.buildFixedContainer(
            new Padding(
              padding: new EdgeInsets.all(10),
              child: new SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    new Text(
                      "Sección\nde Encuesta",
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: new Color(this.participant.yellowColor)
                      ),
                      textAlign: TextAlign.center,
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(bottom: 5, top: 5),
                      child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
                    ),
                    new Text(
                      "En esta sección podrás contestar 5 ->preguntas<- rápidas. Todas son de selección múltiple.\n\nAdicionalmente podrás ver las estadísticas de lo que han opinado otros chapines.\n¡Diviértete!",
                      style: new TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              )
            ),
            [30, 0, 30, 30], 25,
            15, 15, 0.15, 30,
            double.infinity, 290
          ),
          new DraggableScrollableSheet(
            minChildSize: 0.3,
            maxChildSize: 0.3,
            initialChildSize: 0.3,
            builder: (context, scrollController){
              return new SingleChildScrollView(
                controller: scrollController,
                child: new Container(
                  height: 300,
                  child: ContainerTemplate.buildFixedContainer(
                      new ListTile(
                        leading: new GestureDetector(
                          child: new Container(
                            width: 50,
                            height: 50,
                            child: (this.participant.santaQuestActive)? new Image.asset('assets/images/sack.png') : new Image.asset('assets/images/coal.png'),
                          ),
                          onTap: () async {
                            if(!this.participant.snowmanArtifacts[3]) {
                              // Top hat
                              if(this.participant.addSnowmanArtifacts(3)) await this.participant.addCard(context, 'snowman');
                              else DialogTemplate.showMessage(
                                  context,
                                  "¡Acabas de conseguir el Ojo #1!\nFaltan por conseguir " + this.participant.getRemainingSnowmanArtifacts().toString() + " piezas para armar el muñeco de nieve.",
                                  "Aviso",
                                  10
                              );
                            }
                            else if(this.participant.santaQuestActive) {
                              this.participant.checkSantaSequential(
                                context, 1,
                                "(2) ¡Perfecto!\n¿Qué podremos hacer con el saco?",
                              );
                            }
                          },
                        ),
                        title: new Text("Encender luces"),
                        trailing: new Switch(
                          value: this.participant.lightsOn,
                          onChanged: (value){
                            this.participant.lightsOn = value;
                            if(this.participant.lightsOn && !this.participant.obtainedCards[2]){
                              this.participant.addCard(context, 'tree');
                            }
                            setState(() {

                            });
                          },
                          activeTrackColor: Colors.blueGrey,
                          activeColor: Colors.blue,
                        ),
                      ),
                      [30, 170, 30, 70],
                      10, 15, 5, 0.15, 30,
                      100, 50
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    switch(this.navBar.getPageIndex()) {
      case 0:
        return new StatisticsScreen(participant: this.participant,);
      case 1:
        return defaultScreen();
      case 2:
        //return new SearchPeople(issuer: this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"), issuerPowers: this.employee.getPowers(),);
        return new QuestionsScreen(participant: this.participant,);
      default:
        return new Container();
    }
  }

  void navOnTap(index){
    setState(() {
      this.navBar.setBoth(index);
      this.navBar.setOnMainScreen(index == 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.show_chart, Icons.bubble_chart], ["Estadisticas", "Encuesta"]),
      navOnTap,
      NavBarTemplate.buildFAB(
          this.navBar.isOnMainScreen()? Icons.home : Icons.keyboard_return,
              () {
            if(this.navBar.isOnMainScreen()) Navigator.of(context).pop();
            else setState(() {
              this.navBar.setBoth(1);
              this.navBar.setOnMainScreen(true);
            });
          },
          "client_main_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
    );
  }
}