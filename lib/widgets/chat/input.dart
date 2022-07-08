import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/audioButton.dart';
import 'package:workflow/widgets/chat/recordButton.dart';

class Input extends StatefulWidget {
  /// Creates [Input] widget
  const Input({
    Key? key,
    this.isAttachmentUploading,
    this.onAttachmentPressed,
    required this.onSendPressed,
    this.onTextChanged,
    this.onTextFieldTap,
    required this.sendButtonVisibilityMode,
    required this.onAudioRecorded,
  }) : super(key: key);

  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;
  final Future<bool> Function({
    required Duration length,
    required String filePath,
    required List<double> waveForm,
    required String mimeType,
  }) onAudioRecorded;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText) onSendPressed;

  /// Will be called whenever the text inside [TextField] changes
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap
  final void Function()? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  @override
  _InputState createState() => _InputState();
}

/// [Input] widget state
class _InputState extends State<Input> with SingleTickerProviderStateMixin {
  bool _recordingAudio = false;
  bool _audioUploading = false;
  final _inputFocusNode = FocusNode();
  bool _sendButtonVisible = false;
  final _textController = TextEditingController();
  final _audioRecorderKey = GlobalKey<AudioRecorderState>();

  @override
  void initState() {
    super.initState();

    _handleSendButtonVisibilityModeChange();
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sendButtonVisibilityMode != oldWidget.sendButtonVisibilityMode) {
      _handleSendButtonVisibilityModeChange();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();

    _textController.dispose();
    super.dispose();
  }

  void _handleNewLine() {
    final _newValue = '${_textController.text}\r\n';
    _textController.value = TextEditingValue(
      text: _newValue,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
  }

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.hidden) {
      _sendButtonVisible = false;
    } else if (widget.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  Widget _audioWidget() {
    if (_audioUploading == true) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: fillColor,
          size: 24,
        ),
      );
    } else {
      return AudioButton(
        onPressed: _toggleRecording,
        recordingAudio: _recordingAudio,
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (!_recordingAudio) {
      setState(() {
        _recordingAudio = true;
      });
    } else {
      final audioRecording =
          await _audioRecorderKey.currentState!.stopRecording();
      if (audioRecording != null) {
        setState(() {
          _audioUploading = true;
        });
        final success = await widget.onAudioRecorded(
          length: audioRecording.duration,
          filePath: audioRecording.filePath,
          waveForm: audioRecording.decibelLevels,
          mimeType: audioRecording.mimeType,
        );
        setState(() {
          _audioUploading = false;
        });
        if (success) {
          setState(() {
            _recordingAudio = false;
          });
        }
      }
    }
  }

  void _cancelRecording() async {
    setState(() {
      _recordingAudio = false;
    });
  }

  Widget _inputBuilder() {
    final _query = MediaQuery.of(context);
    final _buttonPadding =
        EdgeInsets.fromLTRB(24, 20, 24, 20).copyWith(left: 16, right: 16);
    final _safeAreaInsets = kIsWeb
        ? EdgeInsets.zero
        : EdgeInsets.fromLTRB(
            _query.padding.left,
            0,
            _query.padding.right,
            _query.viewInsets.bottom + _query.padding.bottom,
          );
    final _textPadding =
        EdgeInsets.fromLTRB(24, 20, 24, 20).copyWith(left: 0, right: 0).add(
              EdgeInsetsDirectional.fromSTEB(
                widget.onAttachmentPressed != null ? 0 : 24,
                0,
                _sendButtonVisible ? 0 : 24,
                0,
              ),
            );
// _recordingAudio
//                     ? AudioRecorder(
//                         key: _audioRecorderKey,
//                         onCancelRecording: _cancelRecording,
//                         disabled: _audioUploading,
//                       )
//                     :
    return Focus(
      autofocus: true,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: CupertinoColors.tertiarySystemFill,
        child: Container(
          child: Row(
            children: [
              if (widget.onAttachmentPressed != null)
                AttachmentButton(
                  isLoading: widget.isAttachmentUploading ?? false,
                  onPressed: widget.onAttachmentPressed,
                  padding: _buttonPadding,
                ),
              Expanded(
                child: Padding(
                  padding: _textPadding,
                  child: TextField(
                    controller: _textController,
                    cursorColor: fillColor,
                    decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            label: Text('اكتب رسالتك'),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isCollapsed: true)
                        .copyWith(
                      hintStyle: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Vazirmatn',
                              fontWeight: FontWeight.w500,
                              height: 1.5)
                          .copyWith(
                        color: fillColor.withOpacity(0.5),
                      ),
                    ),
                    focusNode: _inputFocusNode,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    onChanged: widget.onTextChanged,
                    onTap: widget.onTextFieldTap,
                    style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Vazirmatn',
                            fontWeight: FontWeight.w500,
                            height: 1.5)
                        .copyWith(
                      color: fillColor,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              Visibility(
                visible: _sendButtonVisible,
                child: SendButton(
                  onPressed: _handleSendPressed,
                  padding: _buttonPadding,
                ),
              ),
              // Visibility(
              //   visible: !_sendButtonVisible,
              //   child: _audioWidget(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return GestureDetector(
      onTap: () => _inputFocusNode.requestFocus(),
      child: isAndroid || isIOS
          ? _inputBuilder()
          : Shortcuts(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.enter):
                    const SendMessageIntent(),
                LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
                    const NewLineIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.enter, LogicalKeyboardKey.shift):
                    const NewLineIntent(),
              },
              child: Actions(
                actions: {
                  SendMessageIntent: CallbackAction<SendMessageIntent>(
                    onInvoke: (SendMessageIntent intent) =>
                        _handleSendPressed(),
                  ),
                  NewLineIntent: CallbackAction<NewLineIntent>(
                    onInvoke: (NewLineIntent intent) => _handleNewLine(),
                  ),
                },
                child: _inputBuilder(),
              ),
            ),
    );
  }
}
