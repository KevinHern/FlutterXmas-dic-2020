//Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:xmas_2020/templates/dialog_template.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xmas_2020/backend/cfquery.dart';

class Participant{
  String name;
  List<bool> obtainedCards;
  bool alreadyCommented;
  // For snowman
  List<bool> snowmanArtifacts;
  int collectedSnowmanArtifacts;
  int answeredQuizQuestions;
  // For gift
  int homePressed;
  // For Tree
  bool lightsOn;
  /* For Santa:
    1. Sleigh
    2. Sack
    3. Present
    4. Reindeer
    5. Rope
    6. Santa Hat
    7. Santa
   */
  int santaSequential, numPattern;
  bool mailAvailable, santaQuestActive, simonSaysComplete, launchAvailable;
  final int primaryColor = 0xFF146B3A;
  final int secondaryColor = 0xFF003f13;
  final int yellowColor = 0xFFF8B229;
  final int orangeColor = 0xFFEA4630;
  final int redColor = 0xFFBB2528;

  Participant(String name){
    this.name = name;
    // Order of cards: Fireworks, Snowman, Xmas Tree, Santa Claus, Gift
    this.obtainedCards = [false, false, false, false, false];
    this.homePressed = 0;
    this.alreadyCommented = false;

    // Order of snowman Artifacts: Top Hat, Carrot, Snow, Eye1, Eye2
    this.snowmanArtifacts = [false, false, false, false, false];
    this.collectedSnowmanArtifacts = 0;
    this.answeredQuizQuestions = 0;

    // Tree
    this.lightsOn = false;

    // Santa
    this.santaSequential = 0;
    this.santaQuestActive = false;
    this.simonSaysComplete = false;
    this.numPattern = 0;
    this.launchAvailable = false;
    this.mailAvailable = true;
  }

  void pressedHome(BuildContext context){
    this.homePressed++;
  }

  bool addSnowmanArtifacts(int index){
    this.snowmanArtifacts[index] = true;
    this.collectedSnowmanArtifacts++;
    bool allCollected = true;
    for(int i = 0; i < this.snowmanArtifacts.length; i++){
      allCollected = allCollected && this.snowmanArtifacts[i];
    }
    return allCollected;
  }

  int getRemainingSnowmanArtifacts(){
    return 5 - this.collectedSnowmanArtifacts;
  }

  int mapCard(String card){
    switch(card){
      case 'fireworks':
        return 0;
      case 'snowman':
        return 1;
      case 'tree':
        return 2;
      case 'santa':
        return 3;
      case 'gift':
        return 4;
      default:
        return 0;
    }
  }

  Future addCard(BuildContext context, String card) async {
    this.obtainedCards[this.mapCard(card)] = true;
    DialogTemplate.initLoader(context, "¡Lograste algo importante!");
    await (new CFQuery()).updateCollectedCard(card);
    DialogTemplate.terminateLoader();
    DialogTemplate.showMessage(context, "¡Algo mágico acaba de ocurrir!", "Aviso", 10);
  }

  bool canViewMail(){
    bool allCollected = true;
    for(int i = 0; i < 3; i++){
      allCollected = allCollected && this.obtainedCards[i];
    }
    return allCollected && this.obtainedCards[4] && this.mailAvailable;
  }

  bool allCollected(){
    bool allCollected = true;
    for(int i = 0; i < this.obtainedCards.length; i++){
      allCollected = allCollected && this.obtainedCards[i];
    }
    return allCollected;
  }

  void checkSantaSequential(BuildContext context, int expected, String message){
    if(this.santaSequential == expected){
      this.santaSequential++;
      DialogTemplate.showMessage(
        context,
        message,
        "¡Bien!",
        1,
      );
    }
    else if(this.santaSequential < expected) {
      this.santaSequential = 0;
      DialogTemplate.showMessage(
        context,
        "¡Oh no!\nNo es el orden correcto que debes de encontrar las cosas. Debes de empezar desde 0...\n\n¡Tu puedes!",
        "¡Rayos!",
        0,
      );
    }
    else {
      DialogTemplate.showMessage(
        context,
        "¡Esto ya lo tienes!",
        "Aviso",
        10,
      );
    }
  }
}