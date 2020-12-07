// Basic Import

// Models
import 'package:xmas_2020/models/participant.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';

class CFQuery {
  final xmasCol = FirebaseFirestore.instance.collection("xmas");
  final miscellaneous = FirebaseFirestore.instance.collection("miscellaneous");
  final quiz = FirebaseFirestore.instance.collection("quiz");

  // Opinion Functions Section

  Future getQuestionTitle(String question) async {
    DocumentSnapshot snapshot = await miscellaneous.doc(question).get();
    return snapshot.get('title');
  }

  Future getQuestionsIds() async {
    DocumentSnapshot snapshot = await miscellaneous.doc('questions').get();
    return snapshot.get('xmasquestions');
  }

  // Quiz Functions Section
  Future updateQuizQuestionAnswer(int question, int answer) async {
    int code = await FirebaseFirestore.instance
        .runTransaction<int>((transaction) async {
      final doc = quiz.doc(question.toString());
      DocumentSnapshot snapshot = await transaction.get(doc);

      if (!snapshot.exists) {
        return -1;
      }
      else {
        transaction.update(doc, {
          answer.toString(): snapshot.get(answer.toString()) + 1
        });
        return 1;
      }
    });
    return code;
  }

  Future getQuestionAnswers(int question) async {
    Map<String, double> questionAnswers = {};
    DocumentSnapshot answers = await this.quiz.doc(question.toString()).get();
    switch(question){
      case 0:
        questionAnswers['Tamal'] = answers.get('0').toDouble();
        questionAnswers['Pavo'] = answers.get('1').toDouble();
        break;
      case 1:
        questionAnswers['Estrellas'] = answers.get('0').toDouble();
        questionAnswers['Volcanes'] = answers.get('1').toDouble();
        break;
      case 2:
        questionAnswers['Ametralladoras'] = answers.get('0').toDouble();
        questionAnswers['Bombas'] = answers.get('1').toDouble();
        questionAnswers['Abejitas'] = answers.get('2').toDouble();
        questionAnswers['El Torito'] = answers.get('3').toDouble();
        break;
      case 3:
        questionAnswers['Rojo'] = answers.get('0').toDouble();
        questionAnswers['Verde'] = answers.get('1').toDouble();
        questionAnswers['Amarillo'] = answers.get('2').toDouble();
        questionAnswers['Blanco'] = answers.get('3').toDouble();
        break;
      case 4:
        questionAnswers['En Casa'] = answers.get('0').toDouble();
        questionAnswers['Asisto en una'] = answers.get('1').toDouble();
        questionAnswers['No Participo'] = answers.get('2').toDouble();
        break;
      case 5:
        questionAnswers['En Casa'] = answers.get('0').toDouble();
        questionAnswers['Con un Familiar'] = answers.get('1').toDouble();
        break;
      case 6:
        questionAnswers['...Si'] = answers.get('0').toDouble();
        questionAnswers['No'] = answers.get('1').toDouble();
        break;
      default:
        questionAnswers['Hacker!!!!'] = 1337;
        break;
    }
    return questionAnswers;
  }

  // Cards Functions Section

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