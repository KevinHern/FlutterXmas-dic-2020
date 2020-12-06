// Basic Import

// Models
import 'package:xmas_2020/models/participant.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';

class CFQuery {
  final xmasCol = FirebaseFirestore.instance.collection("xmas");
  final miscellaneous = FirebaseFirestore.instance.collection("miscellaneous");

  Future getQuestionTitle(String question) async {
    DocumentSnapshot snapshot = await miscellaneous.doc(question).get();
    return snapshot.get('title');
  }

  Future getQuestionsIds() async {
    DocumentSnapshot snapshot = await miscellaneous.doc('questions').get();
    return snapshot.get('xmasquestions');
  }

  Future updateCollectedCard(String card) async {
    int code = await FirebaseFirestore.instance
        .runTransaction<int>((transaction) async {
      final doc = miscellaneous.doc('cardscollected');
      DocumentSnapshot snapshot = await transaction.get(doc);

      if (!snapshot.exists) {
        return -1;
      }
      else {
        transaction.update(doc, {
          card: snapshot.get(card) + 1
        });
        return 1;
      }
    });
    return code;
  }

  Future getCollectedCard(String card) async {
    int cards = await FirebaseFirestore.instance
        .runTransaction<int>((transaction) async {
      final doc = miscellaneous.doc('cardscollected');
      DocumentSnapshot snapshot = await transaction.get(doc);

      if (!snapshot.exists) {
        return -1;
      }
      else {
        return snapshot.get(card);
      }
    });
    return cards;
  }

  Future getNextComment(String question) async {
    int newCommentId = await FirebaseFirestore.instance
        .runTransaction<int>((transaction) async {
      final doc = miscellaneous.doc(question);
      DocumentSnapshot snapshot = await transaction.get(doc);

      if (!snapshot.exists) {
        return -1;
      }
      else {
        transaction.update(doc, {
          'nextcomment': snapshot.get('nextcomment') + 1
        });
        return snapshot.get('nextcomment');
      }
    });

    return newCommentId;
  }

  Future publishOpinion(Participant participant, String opinion, String question) async {
    final opinionsCol = xmasCol.doc(question).collection("opinions");
    try {
      int newCommentId = await this.getNextComment(question);
      await opinionsCol.doc(newCommentId.toString()).set({
        'user': participant.name,
        'opinion': opinion,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      return true;
    }
    catch(error){
      return false;
    }
  }


}