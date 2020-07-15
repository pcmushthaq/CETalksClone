import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class NowPlayingScreen extends StatefulWidget {
  static const routeName = '/nowplaying';

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  @override
  Widget build(BuildContext context) {
    var _close = false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewPadding.vertical,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          BlurHash(hash: 'L35;~?IVD\$s;.AoIM_fk9Zt7t7WB'),
          StreamBuilder(
            stream: _screenStateStream,
            builder: (ctx, snapshot) {
              if (_close) {
                Navigator.of(context).pop();
              }
              final screenState = snapshot.data;
              //final queue = screenState?.queue;
              final mediaItem = screenState?.mediaItem;
              final state = screenState?.playbackState;
              final processingState =
                  state?.processingState ?? AudioProcessingState.none;
              print(processingState);
              if (processingState == AudioProcessingState.stopped) {
                _close = true;
              }

              if ((processingState != AudioProcessingState.ready ||
                      mediaItem == null) &&
                  processingState != AudioProcessingState.buffering) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return positionIndicator(mediaItem, state);
            },
          ),
        ]),
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    final processingState = state?.processingState ?? AudioProcessingState.none;
    final playing = state?.playing ?? false;

    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = processingState != AudioProcessingState.none
            ? snapshot.data ?? state.currentPosition.inMilliseconds.toDouble()
            : 0.0;
        double duration = mediaItem?.duration?.inMilliseconds?.toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 56,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Now Playing',
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.95)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Text(mediaItem.title,
                                style: GoogleFonts.lato(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 15)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: 280,
                height: 280,
                child: Hero(
                  tag: mediaItem.artUri,
                  child: Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(mediaItem.artUri),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                mediaItem.album,
                style: GoogleFonts.lato(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Center(
              child: Text(
                mediaItem.artist,
                style: GoogleFonts.lato(color: Theme.of(context).accentColor),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  child: Icon(
                    Icons.replay_10,
                    color: Theme.of(context).accentColor,
                    size: 28,
                  ),
                  onTap: () {
                    AudioService.rewind();
                  },
                ),
                Center(
                    child: playing
                        ? GestureDetector(
                            child: Icon(
                              Icons.pause_circle_filled,
                              size: 80,
                              color: Theme.of(context).accentColor,
                            ),
                            onTap: () {
                              AudioService.pause();
                            },
                          )
                        : GestureDetector(
                            child: Icon(
                              Icons.play_circle_filled,
                              size: 80,
                              color: Theme.of(context).accentColor,
                            ),
                            onTap: () async {
                              print(processingState);

                              AudioService.play();
                            },
                          )),
                GestureDetector(
                  child: Icon(
                    Icons.forward_10,
                    color: Theme.of(context).accentColor,
                    size: 28,
                  ),
                  onTap: () {
                    AudioService.fastForward();
                  },
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            if (processingState == AudioProcessingState.completed)
              Container()
            else if (duration != null)
              Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.white,
                min: 0.0,
                max: duration,
                value: seekPos ?? max(0.0, min(position, duration)),
                onChanged: (value) {
                  _dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  AudioService.seekTo(Duration(milliseconds: value.toInt()));

                  seekPos = value;
                  _dragPositionSubject.add(null);
                },
              ),
            if (processingState != AudioProcessingState.none)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${_printDuration(state.currentPosition)}",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    Text(
                      "${_printDuration(mediaItem.duration)}",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 10,
            )
          ],
        );
      },
    );
  }
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

Stream<ScreenState> get _screenStateStream =>
    Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            ScreenState(queue, mediaItem, playbackState));
