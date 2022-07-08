import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:workflow/class/poll.dart' as user;
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/poll/pollOptions.dart';
import 'package:workflow/widgets/other/textfields.dart';

class PollForm extends StatefulWidget {
  String roomId;
  PollForm({required this.roomId});
  @override
  _PollFormState createState() => _PollFormState();
}

class _PollFormState extends State<PollForm> {
  late GlobalKey<FormState> _formKey;

  late TextEditingController _titleController;

  late user.Poll _poll;
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();

    _titleController = TextEditingController();

    _poll = user.Poll(
        createdAt: Timestamp(0, 0),
        id: '',
        options: [],
        title: '',
        voteValue: 0,
        optionsVoteCount: []);
    _isSelected = [true, false];
  }

  void _saveTitleValue(String title) {
    setState(() => _poll.title = title);
  }

  void _saveOptionValue(String option, int index) {
    setState(() {
      _poll.options = [];

      if (index >= _poll.options.length) {
        _poll.options.add(option);
      } else {
        _poll.options[index] = option;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const choicePollOptions = ['الأول', 'الثاتي', 'الثالث', 'الرابع'];

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            heroTag: 'todotag',
            backgroundColor: fillColor,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                _poll.isAuth = true;
              }
              await user.PollUser(id: FirebaseAuth.instance.currentUser!.uid)
                  .addPoll(_poll);

              FirebaseChatCore.instance.sendMessage(
                  types.PartialCustom(metadata: {
                    'id': _poll.id,
                    'title': _poll.title,
                    'options': _poll.options,
                    'createdAt': _poll.createdAt,
                    'optionsVoteCount': _poll.optionsVoteCount,
                    'voteCount': _poll.voteCount,
                    'isAuth': _poll.isAuth,
                    'voteValue': _poll.voteValue,
                    'dismissed': _poll.dismissed,
                    'finished': _poll.finished,
                  }),
                  widget.roomId);
              Navigator.pop(context);
            },
            child: const Icon(Icons.add, color: mainColor),
          ),
          appBar: AppBar(
            title: Text('إضافة تصويت'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: backgroundColor,
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFieldWidget(
                            textController: _titleController,
                            labeltext: 'عنوان التصويت',
                            hinttext: 'عنوان التصويت',
                          ),
                          const SizedBox(height: 16.0),
                          const Divider(),
                          const SizedBox(height: 16.0),
                          PollFormOptions(
                            key: const Key('choice'),
                            optionTitles: choicePollOptions,
                            initialOptions: _poll.options,
                            saveValue: _saveOptionValue,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
