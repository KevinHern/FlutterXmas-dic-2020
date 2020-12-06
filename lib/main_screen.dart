// Basic Imports
import 'package:flutter/material.dart';
import 'package:xmas_2020/templates/dialog_template.dart';

// Routes
import 'package:xmas_2020/profile/profile_screen.dart';
import 'package:xmas_2020/comment/opinions.dart';

// Templates
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/navbar_template.dart';
import 'package:xmas_2020/templates/fade_template.dart';

// Models
import 'package:xmas_2020/models/navbar.dart';
import 'package:xmas_2020/models/participant.dart';

// Backend
import 'package:xmas_2020/backend/cfquery.dart';

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
  bool isActive;
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
              Icons.feedback,
              "Curiosidades",
                  () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => LogScreen()));

              }
          ),
        ],
      ),
    );
  }

  Widget defaultScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildContainer(
            new Padding(
              padding: new EdgeInsets.all(10),
              child: new Column(
                children: <Widget>[
                  new Text(
                    "Caza Navideña",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 30,
                        color: new Color(0xFF002FD3)
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
                  new Text(
                    "¡Bienvenido!\nEsta es una aplicación diseñada para la competencia Navideña Flutter Guatemala 2020. Esta app consiste en que debes"
                    + " de coleccionar 5 cartas navideñas las cuales se obtienen al completar diversos retos. Espero disfrutes esta pequeña aventura. ¡Chispudo!",
                    style: new TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            [30, 0, 30, 30], 25,
            15, 15, 0.15, 30,
          ),
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

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.menu, Icons.person], ["Menu", "Perfil"]),
      navOnTap,
      NavBarTemplate.buildFAB(
          Icons.home,
            () async {
            this.participant.homePressed++;
            if(this.participant.homePressed > 50 && !this.participant.obtainedCards[4]) {

            }
            setState(() {
              this.navBar.setBoth(1);
            });
          },
          "main_screen_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
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