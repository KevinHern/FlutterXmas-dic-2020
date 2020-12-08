
// Basic Imports
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Models
import 'package:xmas_2020/models/participant.dart';

// Templates
import 'package:xmas_2020/templates/dialog_template.dart';

// Routes
import 'package:xmas_2020/main_screen.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _nameController = new TextEditingController();
  bool _hidePassword = true;
  final _formkey = GlobalKey<FormState>();
  final Color primaryColor = new Color(0xFFBB2528);
  bool isInLogin = true;


  Widget _buildEmailInput(){
    return new Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(32.0),
          color: new Color(0xFFFFFFFF).withOpacity(0.75)
      ),
      child: new TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        autofocus: false,
        decoration: InputDecoration(
          prefixIcon: new Icon(Icons.person),
          hintText: 'Nombre o Apodo',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        controller: this._nameController,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.center,
      height: 130,
      width: 150,
      child: Column(
        children: <Widget>[
          Text(
            "Flutter Guatemala",
            style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: this.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Caza Navideña 2020",
            style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: this.primaryColor),
          ),
        ],
      ),
    );
  }


  Widget _buildStartButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {
          if(this._formkey.currentState.validate() && this._nameController.text.length < 26) {
            Participant participant = new Participant(this._nameController.text);
            Firebase.initializeApp();
            Navigator.push(context, MaterialPageRoute(builder: (context) => Screen(participant: participant,)));
          }
          else {
            DialogTemplate.showMessage(context, "Ingresa un nombre no vacío y que use un máximo de 25 caracteres", "Aviso", 10);
          }
        },
        color: new Color(0xFFF8B229),
        textColor: Colors.white,
        child: Text("¡Empezar!",
            style: TextStyle(fontSize: 18, color: Colors.black),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: new Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, new Color(0xFF146B3A)]
            ),
          ),
          child: new Center(
            child: new Form(
              key: this._formkey,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  this._buildHeader(),
                  SizedBox(height: 48.0),
                  this._buildEmailInput(),
                  SizedBox(height: 24.0),
                  this._buildStartButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}