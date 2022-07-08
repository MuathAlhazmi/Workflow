import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:workflow/theme/colors.dart';

class AudioButton extends StatelessWidget {
  /// Creates audio button widget
  const AudioButton({
    Key? key,
    required this.onPressed,
    required this.recordingAudio,
  }) : super(key: key);

  /// Callback for audio button tap event
  final void Function() onPressed;

  final bool recordingAudio;

  @override
  Widget build(BuildContext context) {
    return recordingAudio
        ? SendButton(onPressed: onPressed)
        : IconButton(
            icon: Icon(
              Icons.mic_none,
              color: fillColor,
              size: 30,
            ),
            padding: EdgeInsets.zero,
            onPressed: onPressed,
          );
  }
}
