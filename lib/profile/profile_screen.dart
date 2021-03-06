// Basic Imports
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

// Models
import 'package:xmas_2020/models/participant.dart';
import 'package:xmas_2020/templates/button_template.dart';


// Templates
import 'package:xmas_2020/templates/container_template.dart';
import 'package:xmas_2020/templates/dialog_template.dart';

// Backend
import 'package:xmas_2020/backend/cfquery.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final Participant participant;
  ProfileScreen({Key key, @required this.participant}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState(participant: this.participant);
}

class ProfileScreenState extends State<ProfileScreen> {
  Color _iconColor;
  final Participant participant;
  final List<String> _icons = ['fireworks', 'snowman', 'tree', 'santa', 'gift'];
  final List<String> _profilePics = ['snowflake', 'reindeer', 'fireplace', 'top_hat', 'gingerbread_man', 'ball_blue', 'carrot', 'sock', 'cherry', ];
  final Random rng = new Random();
  ProfileScreenState({Key key, @required this.participant});

  @override
  void initState(){
    super.initState();
    this._iconColor = new Color(this.participant.orangeColor).withOpacity(0.60);
  }

  Widget _profilePicture(){
    int generatedInt = rng.nextInt(this._profilePics.length);
    return new Center(
      child: CircleAvatar(
        radius: 100,
        backgroundColor: new Color(this.participant.yellowColor),
        child: new CircleAvatar(
          radius: 90,
          backgroundColor: new Color(this.participant.redColor),
          //backgroundImage: NetworkImage(this.employee.getProfilePicURL()),
          child: new GestureDetector(
            child: new Image.asset('assets/images/' + this._profilePics[generatedInt] + '.png'),
            onTap: () async {
              if(generatedInt == 3 && !this.participant.snowmanArtifacts[0]) {
                // Top hat
                if(this.participant.addSnowmanArtifacts(0)) await this.participant.addCard(context, 'snowman');
                else DialogTemplate.showMessage(
                  context,
                  "¡Acabas de conseguir el Sombrero!\nFaltan por conseguir " + this.participant.getRemainingSnowmanArtifacts().toString() + " piezas para armar el muñeco de nieve.",
                  "Aviso",
                  10
                );
              }
              else if(generatedInt == 6 && !this.participant.snowmanArtifacts[1]){
                // Carrot
                if(this.participant.addSnowmanArtifacts(1)) await this.participant.addCard(context, 'snowman');
                else DialogTemplate.showMessage(
                    context,
                    "¡Acabas de conseguir la Zanahoria!\nFaltan por conseguir " + this.participant.getRemainingSnowmanArtifacts().toString() + " piezas para armar el muñeco de nieve.",
                    "Aviso",
                    10
                );
              }
              else if(generatedInt == 1 && this.participant.santaQuestActive){
                this.participant.checkSantaSequential(
                  context, 3,
                  "(4) ¡Los renos definitivamente no deben faltar!\nPero antes de continuar, debemos visitar el taller de santa; ¡algo está pasando!",
                );
              }
            },
          ),
        ),
      ),
    );
  }

  String mapIndexToName(int index){
    switch(index){
      case 0:
        return "Fuegos Artificiales";
      case 1:
        return "Muñeco de Nieve";
      case 2:
        return "Ábol de Navidad";
      case 3:
        return "Santa Claus";
      case 4:
        return "Regalo";
      default:
        return "Hacker!!!!!!";
    }
  }

  Widget _buildCard(int index){
    return new Card(
      child: new ListTile(
        leading: new Container(
          height: 50,
          width: 50,
          child: new Image.asset('assets/images/' + this._icons[index] + (this.participant.obtainedCards[index]? "_obtained.png" : "_unobtained.png")),
        ),
        title: new Text(this.mapIndexToName(index)),
        subtitle: new Text(this.participant.obtainedCards[index]? "¡Conseguido!" : "Aun está escondido..."),
        trailing: new Icon(this.participant.obtainedCards[index]? Icons.info : Icons.lock, color: new Color(0x00000000),),
        onTap: () async {
          String title, message;
          title = "¡Pista!";
          int iconOption = 0;

          switch(index){
            // Fireworks
            case 0:
              if(this.participant.obtainedCards[index]){
                title = "Fuegos Artificiales";
                DialogTemplate.initLoader(context, "Cargando Carta...");
                message = "Conocidos tambíen como 'cuetes'. "
                    + "Las estrellitas, los volcancitos, los chiltepitos, los canchinflines y las ametralladoras ... ¡son cuetes inolvidables!\n"
                    + "Cuando es la medianoche, es el momento más alegre para los niños y jóvenes ya que es la hora de quemar todos los cuetes que se compraron "
                    + "en el mercado, tiendas o puestos de barrio unos días atrás. Es como las luces campero pero en todo el país."
                    + "\nSi sobran cuetes, no volverán a ver la luz hasta nuevo año..."
                    + "\n\n" + (await (new CFQuery()).getCollectedCard('fireworks')).toString() + " chapin(es) han conseguido esta carta.";
                DialogTemplate.terminateLoader();
                iconOption = 1;
              }
              else message = "Los fuegos artificiales son vistos por todos...";
              break;

            // Snowman
            case 1:
              if(this.participant.obtainedCards[index]){
                title = "Muñeco de Nieve";
                DialogTemplate.initLoader(context, "Cargando Carta...");
                message = "Los muñecos de nieve en Guatemala son muy raros de ver - ¡pero los muñecos de alambre son muy populares!.\n"
                    + "Muchos soñamos con ver la nieve, jugar con ella y especialmente hacer un muñeco de nieve. En nuestro país no cae nieve "
                    + "como en otros países (exceptuando ciertos lugares), pero eso no impide a que el chapín busque soluciones alternativas.\n\nComo lo chispudos que somos, "
                    + "no hacemos muñecos de nieve como tal, sino que hacemos muñecos de barro, de alambre, incluso de papel para ponerlos afuera "
                    + "o adentro de nuestras casas."
                    + "\n\n" + (await (new CFQuery()).getCollectedCard('snowman')).toString() + " chapin(es) han conseguido esta carta.";
                DialogTemplate.terminateLoader();
                iconOption = 1;
              }
              else message = "¿Quieres un muñeco de nieve?\n¡Debes de construirlo!";
              break;

            //Xmas Tree
            case 2:
              if(this.participant.obtainedCards[index]){
                title = "Árbol de Navidad";
                DialogTemplate.initLoader(context, "Cargando Carta...");
                message = "Este adorno de decoración es muy típico de encontrar en las casas de los chapines.\n"
                    + "Todos los que queremos colocar un arbolito de navidad pasamos mucho tiempo tratando de encontrar las bombillas, "
                    + " lucecitas y la estrella que se coloca en la punta.\n\n¡El momento más alegre es cuando abrimos todos los regalos y las canastas navideñas!"
                    + "\nNo hay que olvidar la gran polvazón..."
                    + "\n\n" + (await (new CFQuery()).getCollectedCard('tree')).toString() + " chapin(es) han conseguido esta carta.";
                DialogTemplate.terminateLoader();
                iconOption = 1;
              }
              else message = "Hace falta encender algo...\nSolo recuerdo este acertijo:\nEn el fondo de la pregunta, deslizar hacia el cielo y revelará 2 tesoros.";
              break;

            // Santa Claus
            case 3:
              if(this.participant.obtainedCards[index]){
                title = "Santa Claus";
                DialogTemplate.initLoader(context, "Cargando Carta...");
                message = "¡Este personaje icónico de la navidad siempre estará en nuestros corazones!\n\n"
                    + "Desde pequeños, siempre soñábamos con ver a Santa Claus ya sea en persona o montado en su trineo y con renos (¡Rudolf incluído!)."
                    + " Nos ilusionábamos mucho al ver a Santa Claus en un centro comercial y era divertido contarle sobre todos los regalos que queríamos "
                    + "para Navidad.\nY ese hombre hacía su trabajo muy bien, porque muchos de los regalos que le pedimos los encontrábamos debajo del Árbol de Navidad"
                    + "... claro, solo si nos portamos bien durante todo el año."
                + "\n\n" + (await (new CFQuery()).getCollectedCard('santa')).toString() + " chapin(es) han conseguido esta carta.";
                DialogTemplate.terminateLoader();
                iconOption = 1;
              }
              else message = "¡Ayudemos a a que Santa se aliste para entregar los regalos!\nLos elfos nos dicen que debemos hacer todo en orden...\n¿De qué estarán hablando?\n\nNota: Debes de conseguir las otra 4 cartas antes de conseguir esta.";
              break;

            // Gift
            case 4:
              if(this.participant.obtainedCards[index]){
                title = "Regalos";
                DialogTemplate.initLoader(context, "Cargando Carta...");
                message = "Lo que todos esperamos. Los regalos son pequeños pedazos de felicidad envueltos en papeles muy coloridos.\n"
                    + "Estos pueden ser juguetes, videojuegos, comida (las famosas canastas navideñas) e incluso ropa o sartenes.\n\n"
                    + "Es cierto... para recibir hay que dar - significa que es momento de ir al mercado o a un centro comercial para escoger los regalos de nuestros familiares"
                    + "...\n¡y puede ser muy agotador! (y falta envolverlos...)"
                    + "\n\n" + (await (new CFQuery()).getCollectedCard('gift')).toString() + " chapin(es) han conseguido esta carta.";
                DialogTemplate.terminateLoader();
                iconOption = 1;
              }
              else message = "¿Puede Santa visitar más de 50 casas en una hora?";
              break;
          }
          if(this.participant.santaQuestActive && index == 3) {
            this.participant.checkSantaSequential(
              context, 6,
              "(7) ¡Muy bien hecho!\nLe diste su gorro y ahora Santa se dirige rápidamente a su trineo.\n¡Vamos a ver qué sucede!",
            );
            this.participant.mailAvailable = false;
            this.participant.launchAvailable = true;
          }
          else if(this.participant.santaQuestActive && index == 4)
            this.participant.checkSantaSequential(
              context, 2,
              "(3) ¡Guardar los regalos!\nRealmente eres muy bueno. Ya metimos los regalos en el saco pero el trineo no puede moverse por sí solo...",
            );
          else DialogTemplate.showMessage(context, message, title, iconOption);
        },
      ),
    );
  }

  Widget _profileInfo(){
    return new ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Divider(
          color: new Color(this.participant.secondaryColor).withOpacity(0.25),
          thickness: 1,
        ),
      ),
      itemCount: this.participant.obtainedCards.length,
      padding: EdgeInsets.all(5.0),
      itemBuilder: (context, index) {
        return this._buildCard(index);
      },
    );
  }

  Widget _profile(){
    return new ListView(
      padding: EdgeInsets.only(top: 50),
      children: <Widget>[
        new Padding(padding: EdgeInsets.only(bottom: 10), child: this._profilePicture(),),
        new Text(
          this.participant.name,
          style: new TextStyle(
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        ContainerTemplate.buildContainer(
          this._profileInfo(),
          [30, 9, 30, 10],
          20,
          15,
          15,
          0.15,
          30,
        ),
        new Padding(
          padding: new EdgeInsets.only(bottom: 100, left: 30, right: 30),
          child: ButtonTemplate.buildBasicButton(
                () async {
              if(this.participant.allCollected()){
                const url = 'https://www.dropbox.com/s/c9m2ouhw4szmp91/LastMessage.png';
                if (await canLaunch(url)) {
                  await launch(url);
                  } else {
                    DialogTemplate.showMessage(context, "No se pudo abrir el navegador Browser, aquí te dejo el link para que lo ingreses manualmente\n\n:", "Aviso", 0);
                  }
              }
              else DialogTemplate.showMessage(context, "Debes de coleccionar todas las cartas para descubrir el secreto", "¡Todavía No!", 0);
            },
            this.participant.redColor,
            this.participant.allCollected()? "¡Desbloqueado!" : "Bloqueado...", 0xFFFFFFFF,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return this._profile();
  }
}