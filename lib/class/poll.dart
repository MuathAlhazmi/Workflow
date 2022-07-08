import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  String id;
  String title;
  List<String> options;
  Timestamp createdAt;
  bool isAuth;
  int voteValue;
  int voteCount;
  bool dismissed;
  bool finished;
  List<int> optionsVoteCount;

  Poll({
    required this.id,
    required this.title,
    required this.options,
    required this.createdAt,
    this.isAuth = false,
    required this.voteValue,
    required this.optionsVoteCount,
    this.voteCount = 0,
    this.dismissed = false,
    this.finished = true,
  });
  int get totalCount =>
      optionsVoteCount.fold(0, (prev, element) => prev + element);

  Poll.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        title = (doc.data as dynamic)!['title'] ?? '',
        options = (doc.data as dynamic)!['options'] != null
            ? (doc.data as dynamic)!['title'].cast<String>()
            : [],
        createdAt = (doc.data as dynamic)!['createdAt'] ?? '',
        isAuth = (doc.data as dynamic)!['isAuth'] ?? false,
        voteValue = (doc.data as dynamic)!['voteValue'] ?? '',
        voteCount = (doc.data as dynamic)!['voteCount'] ?? 0,
        dismissed = (doc.data as dynamic)!['dismissed'] ?? false,
        optionsVoteCount = (doc.data as dynamic)!['optionsVoteCount'] != null
            ? (doc.data as dynamic)!['optionsVoteCount'].cast<int>()
            : [],
        finished = (doc.data as dynamic)!['finished'] ?? true;
  Map<String, dynamic> genericToJson() => {
        'title': title,
        'options': options,
        'createdAt': createdAt,
        'optionsVoteCount': optionsVoteCount,
        'voteCount': voteCount,
      };

  Map<String, dynamic> userToJson() => {
        'isAuth': isAuth,
        'voteValue': voteValue,
        'dismissed': dismissed,
        'finished': finished,
      };
  List<dynamic> mapQueryPoll(QuerySnapshot query) {
    return query.docs.map((doc) {
      if ((doc.data as dynamic)!['dismissed'] != null &&
          (doc.data as dynamic)!['dismissed'] as bool) {
        return null;
      }

      return Poll.fromFirestore(doc);
    }).toList();
  }
}

class PollUser {
  String id;
  PollUser({
    required this.id,
  });

  Future<void> addPoll(Poll poll) async {
    final ref = FirebaseFirestore.instance;

    final pollRef = await ref.collection('polls').add(poll.genericToJson());

    await ref
        .collection('users/$id/polls')
        .doc(pollRef.id)
        .set(poll.userToJson());
  }

  Future<void> vote(Poll poll, int value) async {
    final ref = FirebaseFirestore.instance;

    await ref.collection('users/$id/polls').doc(poll.id).set({
      'isAuth': poll.isAuth,
      'voteValue': value,
      'finished': false,
    });

    await ref.collection('polls').doc(poll.id).update({
      'voteCount': poll.voteCount + 1,
      'optionsVoteCount': poll.optionsVoteCount
        ..replaceRange(value, value + 1, [poll.optionsVoteCount[value] + 1])
    });

    await Future<void>.delayed(const Duration(seconds: 5));
    return ref.collection('users/$id/polls').doc(poll.id).update({
      'finished': true,
    });
  }
}
