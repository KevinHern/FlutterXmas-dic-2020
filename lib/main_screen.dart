// Basic Imports
import 'package:flutter/material.dart';
import 'package:xmas_2020/templates/dialog_template.dart';

// Routes
import 'package:xmas_2020/profile/profile_screen.dart';
import 'package:xmas_2020/comment/opinions.dart';
import 'package:xmas_2020/quiz/quiz_main_screen.dart';
import 'package:xmas_2020/workshop/workshop_main_screen.dart';

// Templates
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/navbar_template.dart';
import 'package:xmas_2020/templates/fade_template.dart';

// Models
import 'package:xmas_2020/models/navbar.dart';
import 'package:xmas_2020/models/participant.dart';

// Backend
import 'package:xmas_2020/backend/cfquery.dart';
import 'package:url_launcher/url_launcher.dart';

class Screen extends StatelessWidget {
  final Participant participant;
  final bool isActive;
  Screen({Key key, @required this.participant, @required this.isActive});

  @override
  Widget build(BuildContext context) {
    return MainScreen(participant: this.participant, isActive: this.isActive,);
  }
}

class MainScreen extends StatefulWidget {
  final Participant participant;
  final bool isActive;
  MainScreen({Key key, @required this.participant, @required this.isActive}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState(participant: this.participant, isActive: this.isActive);
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final Participant participant;
  bool isActive, landedWidget = false;
  //Option option;
  NavBar navBar;
  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;
  FadeAnimation _fadeAnimation;

  @override
  void initState(){
    super.initState();
    navBar = new NavBar(1, 1);
    this._fadeAnimation = new FadeAnimation(this);
  }

  MainScreenState({Key key, @required this.participant, @required this.isActive});

  Widget manyOptionsScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildTileOption(
            Icons.content_copy,
            "Encuesta\nNavideña",
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainQuizScreen(participant: this.participant)));
            },
          ),
          ContainerTemplate.buildTileOption(
            Icons.question_answer,
            "Opiniones",
            () async {
              DialogTemplate.initLoader(context, "Espera un momento...");
              try {
                List<dynamic> dynamList = (await (new CFQuery()).getQuestionsIds());
                List<String> questionsIds = dynamList.cast<String>();
                List<String> questions = [];
                for(int i = 0; i < questionsIds.length; i++) {
                  questions.add(questionsIds[i] + "-" + (await (new CFQuery()).getQuestionTitle(questionsIds[i])));
                }
                DialogTemplate.terminateLoader();
                Navigator.push(context, MaterialPageRoute(builder: (context) => OpinionScreen(participant: this.participant, questions: questions,)));
              }
              catch(error){
                DialogTemplate.terminateLoader();
                DialogTemplate.showMessage(context, "¡Ooops!\nOcurrió un error, intenta de nuevo.", "Aviso", 0);
                print(error);
              }

            },
          ),
          ContainerTemplate.buildTileOption(
              (this.participant.santaSequential == 4)? Icons.report : Icons.check_box,
              "Taller",
              () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => LogScreen()));
                if(this.participant.santaSequential == 4 && this.participant.santaQuestActive)
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WorkshopScreen(participant: this.participant,)));
                else
                  DialogTemplate.showMessage(context, "Todo parece estar tranquilo en el taller de Santa...", "Aviso", 10);
              }
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(){
    return ContainerTemplate.buildContainer(
      new Padding(
        padding: new EdgeInsets.all(10),
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Text(
                "Caza Navideña",
                style: new TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30,
                    color: new Color(this.participant.yellowColor)
                ),
                textAlign: TextAlign.center,
              ),
              new Padding(
                padding: new EdgeInsets.only(bottom: 5, top: 5),
                child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
              ),
              new Text(
                "Kevin Hernández",
                style: new TextStyle(fontSize: 18), textAlign: TextAlign.center,
              ),
              new Padding(
                padding: new EdgeInsets.only(bottom: 5, top: 5),
                child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
              ),
              new Column(
                children: <Widget>[
                  new Text(
                    "¡Bienvenido!\nEsta es una aplicación diseñada para la competencia Navideña Flutter Guatemala 2020. Esta app consiste en que debes"
                        + " de coleccionar 5 cartas navideñas las cuales se obtienen al completar diversos retos. Espero disfrutes esta pequeña aventura. ¡Chispudo!\n",
                    style: new TextStyle(fontSize: 15),
                  ),
                  new GestureDetector(
                    onTap: () async {
                      const url = 'https://www.instagram.com/kevinh.92/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        DialogTemplate.showMessage(context, "No se pudo abrir el navegador Browser, aquí te dejo el link para que lo ingreses manualmente\n\n:", "Aviso", 0);
                      }
                    },
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          height: 35,
                          width: 35,
                          child: new Image.asset('assets/images/instagram.png'),
                        ),
                        new Text("@kevinh.92", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ),
      [30, 40, 30, 20], 25,
      15, 15, 0.15, 30,
    );
  }

  Widget defaultScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              new GestureDetector(
                onTap: (){
                  this.participant.checkSantaSequential(
                    context, 5,
                    "(6) ¡Tenemos el gorro perdido de Santa!\nSolo falta encontrar al personaje más importante de la Navidad.",
                  );
                  setState(() {
                  });
                },
                child: new Container(
                  padding: new EdgeInsets.only(bottom: 20),
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/images/santa_hat.png'),
                ),
              ),
              (this.participant.santaQuestActive && this.participant.santaSequential == 5)?
                new Draggable(
                  data: 'FLutter',
                  feedback: this._buildBoard(),
                  child: this._buildBoard(),
                  childWhenDragging: new Container(),
                ) :
              this._buildBoard(),
            ],
          ),
          new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              new Visibility(
                visible: this.participant.canViewMail(),
                child: new Center(
                  child: ContainerTemplate.buildFixedContainer(
                    new GestureDetector(
                      child: new Container(
                        width: 75,
                        height: 75,
                        child: Image.asset('assets/images/mail.png'),
                      ),
                      onTap: () {
                        this.participant.santaQuestActive = true;
                        DialogTemplate.showMessage(
                          context,
                          "¡Has recibido una nota de Santa!\nDice lo siguiente:\n\n"
                              + "\"¡Muy bien hecho " + this.participant.name + "!\nHas recolectado 4 cartas"
                              + " y te hace falta una. Ayúdame a alistar mi trineo y te la daré.\n¡Sé que lo lograrás Jo Jo Jo!\""
                              + "\n\n\n¿Estas listo? Debes de preparar su trineo, en la parte de atrás de la nota tiene inscrito el número 7",
                          "¡Sorpresa!",
                          10,
                        );
                      },
                    ),
                    [0, 0, 0, 50], 25,
                    15, 15, 0.15, 30,
                    100, 100,
                  ),
                ),
              ),
              new Visibility(
                visible: this.participant.launchAvailable,
                child: new Center(
                  child: ContainerTemplate.buildFixedContainer(
                    new GestureDetector(
                      child: new Container(
                        width: 75,
                        height: 75,
                        child: Image.asset('assets/images/alert.png'),
                      ),
                      onTap: () async {
                        try{
                          this.participant.launchAvailable = false;
                          this.participant.mailAvailable = false;
                          this.participant.santaQuestActive = false;
                          await DialogTemplate.showFinalMessage(context, 10);
                          await this.participant.addCard(context, 'santa');
                          setState(() {});
                        }
                        catch(error){
                          DialogTemplate.showMessage(context, "Algo salió mal, ¡pero apúrate que tienes que ver lo último!", "Title", 0);
                        }
                      },
                    ),
                    [0, 0, 0, 0], 25,
                    15, 15, 0.15, 30,
                    100, 100,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget returnScreen() {
    Widget to_show;
    switch(this.navBar.getPageIndex()) {
      case 0:
        to_show = this.manyOptionsScreen();
        break;
      case 1:
        to_show = this.defaultScreen();
        break;
      case 2:
        to_show = ProfileScreen(participant: this.participant,);
        break;
      default:
        to_show = new Container();
        break;
    }
    return to_show;
  }

  void navOnTap(index){
    setState(() {
      this.navBar.setBoth(index);
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 40,
                  width: 40,
                  child: new Image.asset('assets/images/star.png'),
                ),
                new Padding(
                  padding: new EdgeInsets.only(left: 15),
                  child: new Text('Advertencia'),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new SingleChildScrollView(
              child: new Text('Si sales ahorita de la aplicación perderás todo tu progreso.\n¿Estás seguro que quieres salir?'),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/snowflake_green.png'),
                ),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/snowflake_red.png'),
                ),
              ),
            ],
          );
        }
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: NavBarTemplate.buildBottomNavBar(
        this.navBar,
        NavBarTemplate.buildTripletItems([Icons.menu, Icons.person], ["Menu", "Perfil"]),
        navOnTap,
        NavBarTemplate.buildFAB(
            Icons.home,
                () async {
              this.participant.homePressed++;
              if(this.participant.homePressed > 50 && !this.participant.obtainedCards[4]) {
                this.participant.addCard(context, 'gift');
              }
              setState(() {
                this.navBar.setBoth(1);
              });
            },
            "main_screen_fab"
        ),
        this._fadeAnimation.fadeNow(this.returnScreen()),
      ),
    );
  }
}

/*

Ideas:
- Card Hunter
	* 5 cards: Snowman, xmas tree, fireworks, Santa Claus, gift,
		- Fireworks: publish a comment on "What makes you happy on Xmas?"
		- Snowman: Collect 3 snowballs, a carrot and pebles
		- Xmas Tree: Turn on Dark mode then Light mode
		- Gift: Tap the home menu a total of 25 times then go to profile screen
		- Santa Claus: Tap on "December 25"
- Screens:
	1. Welcome screen
		* Welcome message
	2. Comment space
		*
	3. Quiz section
		* 5 random questions
	4. Profile Screen
		* Profile picture
		4.2 Card collection
			- Clicking on the not collected cards to give hints
			- Congrats Button → LInk →  Image
	6. FAQ Zone
		* Brief explanations of cool Guatemalan stuff
 */