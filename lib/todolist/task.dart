import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/todo/subTask.dart';

class Task extends StatefulWidget {
  final String id;
  const Task({Key? key, required this.id}) : super(key: key);

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  void initState() {
    super.initState();
  }

  bool a = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Todo')
            .doc(widget.id)
            .collection('SubTask')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: getExpenseItems(snapshot, context, widget.id),
            );
          }
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: fillColor,
              size: 100,
            ),
          );
        });
  }
}

getExpenseItems(
  AsyncSnapshot<QuerySnapshot> snapshot,
  context,
  id,
) {
  return snapshot.data!.docs.map((doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 60,
        child: SubTaskCard(
          isCompleted: doc['isCompleted'],
          key: UniqueKey(),
          title: doc['title'],
          docId: id,
          id: doc.id,
        ),
      ),
    );
  }).toList();
}
