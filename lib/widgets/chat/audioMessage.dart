import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:workflow/theme/colors.dart';
import 'package:workflow/widgets/chat/waveForm.dart';

Duration parseDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

class AudioMessage extends StatefulWidget {
  /// Creates an audio message widget based on a [types.AudioMessage]
  const AudioMessage({
    Key? key,
    required this.message,
    required this.messageWidth,
  }) : super(key: key);

  static final durationFormat = DateFormat('m:ss', 'en_US');

  /// [types.AudioMessage]
  final types.CustomMessage message;

  /// Maximum message width
  final int messageWidth;

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage>
    with SingleTickerProviderStateMixin {
  final _audioPlayer = FlutterSoundPlayer();
  late AnimationController animationController;
  bool _playing = false;
  bool _audioPlayerReady = false;
  bool _wasPlayingBeforeSeeking = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _initAudioPlayer();
  }

  @override
  Future<void> dispose() async {
    await _audioPlayer.closeAudioSession();
    animationController.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.openAudioSession();
    setState(() {
      _audioPlayerReady = true;
    });
  }

  Future<void> _togglePlaying() async {
    if (!_audioPlayerReady) return;
    if (_playing) {
      await _audioPlayer.pausePlayer();
      setState(() {
        animationController.reverse();
      });
      setState(() {
        _playing = false;
      });
    } else if (_audioPlayer.isPaused) {
      await _audioPlayer.resumePlayer();
      setState(() {
        animationController.forward();
      });
      setState(() {
        _playing = true;
      });
    } else {
      await _audioPlayer.setSubscriptionDuration(
        const Duration(milliseconds: 10),
      );
      setState(() {
        animationController.forward();
      });
      await _audioPlayer.startPlayer(
          fromURI: widget.message.metadata!['uri'],
          whenFinished: () {
            setState(() {
              _playing = false;
            });
          });
      setState(() {
        _playing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = FirebaseAuth.instance.currentUser!;
    final _color = _user.uid == widget.message.author.id
        ? mainColor
        : mainColor.withOpacity(.5);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
              padding: EdgeInsets.zero,
              onPressed: _audioPlayerReady ? _togglePlaying : null,
              icon: _audioPlayer.isStopped
                  ? Icon(
                      Icons.play_arrow,
                      color: fillColor,
                      size: 44,
                    )
                  : AnimatedIcon(
                      progress: animationController,
                      icon: AnimatedIcons.play_pause,
                      color: fillColor,
                      size: 44,
                    )),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(
                left: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: widget.messageWidth.toDouble(),
                    height: 20,
                    child: _audioPlayer.isPlaying || _audioPlayer.isPaused
                        ? StreamBuilder<PlaybackDisposition>(
                            stream: _audioPlayer.onProgress,
                            builder: (context, snapshot) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: WaveForm(
                                      onTap: _togglePlaying,
                                      onStartSeeking: () async {
                                        _wasPlayingBeforeSeeking =
                                            _audioPlayer.isPlaying;
                                        if (_audioPlayer.isPlaying) {
                                          await _audioPlayer.pausePlayer();
                                        }
                                      },
                                      onSeek: snapshot.hasData
                                          ? (newPosition) async {
                                              print(newPosition.toString());
                                              await _audioPlayer
                                                  .seekToPlayer(newPosition);
                                              if (_wasPlayingBeforeSeeking) {
                                                await _audioPlayer
                                                    .resumePlayer();
                                                _wasPlayingBeforeSeeking =
                                                    false;
                                              }
                                            }
                                          : null,
                                      waveForm: List<double>.from(
                                        widget.message.metadata!['waveForm'],
                                      ),
                                      color:
                                          _user.uid == widget.message.author.id
                                              ? fillColor
                                              : fillColor,
                                      duration: snapshot.hasData
                                          ? snapshot.data!.duration
                                          : parseDuration(
                                              widget
                                                  .message.metadata!['length'],
                                            ),
                                      position: snapshot.hasData
                                          ? snapshot.data!.position
                                          : const Duration(),
                                    ),
                                  ),
                                ],
                              );
                            })
                        : WaveForm(
                            onTap: _togglePlaying,
                            waveForm: List<double>.from(
                              widget.message.metadata!['waveForm'],
                            ),
                            color: _user.uid == widget.message.author.id
                                ? fillColor
                                : fillColor,
                            duration: parseDuration(
                              widget.message.metadata!['length'],
                            ),
                            position: const Duration(),
                          ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (_audioPlayer.isPlaying || _audioPlayer.isPaused)
                    StreamBuilder<PlaybackDisposition>(
                        stream: _audioPlayer.onProgress,
                        builder: (context, snapshot) {
                          return Text(
                            AudioMessage.durationFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                snapshot.hasData
                                    ? snapshot.data!.duration.inMilliseconds -
                                        snapshot.data!.position.inMilliseconds
                                    : parseDuration(
                                        widget.message.metadata!['length'],
                                      ).inMilliseconds,
                              ),
                            ),
                            style: TextStyle(color: fillColor),
                            textWidthBasis: TextWidthBasis.longestLine,
                          );
                        })
                  else
                    Text(
                      AudioMessage.durationFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(
                          parseDuration(
                            widget.message.metadata!['length'],
                          ).inMilliseconds,
                        ),
                      ),
                      style: TextStyle(color: fillColor),
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
