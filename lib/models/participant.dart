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
  int homePressed;

  Participant(String name){
    this.name = name;
    // Order of cards: Fireworks, Snowman, Xmas Tree, Santa Claus, Gift
    this.obtainedCards = [false, false, false, false, false];
    this.homePressed = 0;
    this.alreadyCommented = false;

    // Order of snowman Artifacts: Top Hat, Carrot, Snow, Eye1, Eye2
    this.snowmanArtifacts = [false, false, false, false, false];
    this.collectedSnowmanArtifacts = 0;
  }

  void pressedHome(BuildContext context){
    this.homePressed++;
  }

  bool addSnowmanArtificat(int index){
    this.snowmanArtifacts[index] = true;
    this.collectedSnowmanArtifacts++;
    bool allCollected = false;
    for(int i = 0; i < this.snowmanArtifacts.length; i++){
      allCollected = allCollected && this.snowmanArtifacts[index];
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
    DialogTemplate.initLoader(context, "!Lograste algo importante!");
    await (new CFQuery()).updateCollectedCard(card);
    DialogTemplate.terminateLoader();
    DialogTemplate.showMessage(context, "¡Algo mágico acaba de ocurrir!", "Aviso", 10);
  }
}