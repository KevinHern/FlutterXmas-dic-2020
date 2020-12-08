// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Models
import 'package:xmas_2020/models/participant.dart';
import 'package:xmas_2020/models/navbar.dart';

// Routes
import 'simon_says.dart';

// Templates
import 'package:xmas_2020/templates/dialog_template.dart';
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/navbar_template.dart';
import 'package:xmas_2020/templates/fade_template.dart';

class WorkshopScreen extends StatefulWidget {
  final Participant participant;
  WorkshopScreen({Key key, @required this.participant}) : super(key: key);

  @override
  WorkshopScreenState createState() => WorkshopScreenState(participant: this.participant);
}

class WorkshopScreenState extends State<WorkshopScreen> with SingleTickerProviderStateMixin {
  NavBar navBar;
  final Participant participant;
  FadeAnimation _fadeAnimation;

  @override
  void initState(){
    super.initState();
    navBar = new NavBar(1, 1);
    _fadeAnimation = new FadeAnimation(this);
  }

  WorkshopScreenState({@required this.participant});

  Widget defaultScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildFixedContainer(
              new Padding(
                padding: new EdgeInsets.all(10),
                child: new SingleChildScrollView(
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        "Taller de Santa",
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
                        "¡Aquí es donde toda la magia ocurre!\nLos elfos son los trabajadores más humildes que puedes conocer y hacen los mejores regalos para todos.",
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
          new Center(
            child: ContainerTemplate.buildFixedContainer(
              new GestureDetector(
                child: new Container(
                  width: 75,
                  height: 75,
                  child: Image.asset('assets/images/elf.png'),
                ),
                onTap: () {
                  this.participant.santaQuestActive = true;
                  if(this.participant.simonSaysComplete)
                    this.participant.checkSantaSequential(
                      context, 4,
                      "¡Gracias por ayudarnos!\nCreo que esta Cuerda (5) te podrá servir para que Santa pueda controlar a los renos.\nSabes... Ahorita acabo escuchar rumores que Santa perdió su gorrito.",
                    );
                  else {
                    DialogTemplate.showMessage(
                      context,
                      "¡Que bueno que llegaste!\n\n"
                          + "Estábamos haciendo regalos pero por alguna extraña razón la magia se nos acabó y no podemos seguir produciendo...\n\n"
                          + "Ayúdanos a superar los retos de Simón Dice para que regrese la magia.\n¡La magia depende de ti!",
                      "¡Ayúdanos!",
                      10,
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
              [0, 0, 0, 0], 25,
              15, 15, 0.15, 30,
              100, 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    switch(this.navBar.getPageIndex()) {
      case 0:
        return new SimonSaysScreen(participant: this.participant,);
        //return new Container();
      case 1:
        return defaultScreen();
      case 2:
      //return new SearchPeople(issuer: this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"), issuerPowers: this.employee.getPowers(),);
        //return new QuestionsScreen(participant: this.participant,);
        return new Container();
      default:
        return new Container();
    }
  }

  void navOnTap(index){
    setState(() {
      if(index == 2) DialogTemplate.showMessage(context, "Area restringida", "Aviso", 0);
      else {
        this.navBar.setBoth(index);
      }
      this.navBar.setOnMainScreen(index == 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.settings_overscan, Icons.call_made], ["Simon Dice", "Restringido"]),
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
          "workshop_main_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
    );
  }
}