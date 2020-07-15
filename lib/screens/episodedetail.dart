import 'package:cettalks1/widgets/bottomplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import '../widgets/audioplayertask.dart';
import '../models/pastep.dart';

class EpisodeDetail extends StatelessWidget {
  static const routeName = '/episodedetail';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List;
    final currEp = args[0] as PastEp;

    var currMedia = <MediaItem>[
      MediaItem(
          id: currEp.audiLocation,
          artUri: currEp.artUrl,
          title: currEp.program,
          album: currEp.epName,
          artist: currEp.rjs,
          duration: Duration(seconds: currEp.duration))
    ];

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          BlurHash(hash: 'L35;~?IVD\$s;.AoIM_fk9Zt7t7WB'),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
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
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 280,
                          height: 280,
                          child: Hero(
                            tag: currEp.artUrl,
                            child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(currEp.artUrl),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        ButtonTheme(
                          minWidth: 120,
                          height: 45,
                          child: StreamBuilder<ScreenState>(
                              stream: _screenStateStream,
                              builder: (context, snapshot) {
                                final screenState = snapshot.data;

                                final state = screenState?.playbackState;
                                final processingState =
                                    state?.processingState ??
                                        AudioProcessingState.none;

                                final playing = state?.playing ?? false;
                                if (processingState ==
                                    AudioProcessingState.none) {
                                  return RaisedButton(
                                    onPressed: () async {
                                      // Navigator.of(context).pushNamed(
                                      //     NowPlayingScreen.routeName,
                                      //     arguments: currEp);
                                      await AudioService.start(
                                        androidStopForegroundOnPause: true,
                                        backgroundTaskEntrypoint:
                                            _audioPlayerTaskEntrypoint,
                                        androidNotificationChannelName:
                                            'CETalks',
                                        androidNotificationColor: 0x00000000,
                                        androidNotificationIcon:
                                            'mipmap/ic_launcher',
                                        androidEnableQueue: true,
                                      );

                                      await AudioService.updateQueue(currMedia);
                                    },
                                    shape: StadiumBorder(),
                                    color: Colors.yellow[300],
                                    child: Text('Play'),
                                  );
                                } else if (processingState !=
                                    AudioProcessingState.ready) {
                                  return RaisedButton(
                                    onPressed: () {},
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.yellow[300]),
                                      ),
                                    ),
                                    shape: StadiumBorder(),
                                    color: Colors.yellow[300],
                                  );
                                } else if (playing &&
                                    AudioService.currentMediaItem.id ==
                                        currEp.audiLocation) {
                                  return RaisedButton(
                                    onPressed: () {
                                      AudioService.pause();
                                    },
                                    shape: StadiumBorder(),
                                    color: Colors.yellow[300],
                                    child: Text('Pause'),
                                  );
                                } else if (AudioService.currentMediaItem.id ==
                                        currEp.audiLocation &&
                                    processingState != null) {
                                  return RaisedButton(
                                    onPressed: () {
                                      // Navigator.of(context).pushNamed(
                                      //     NowPlayingScreen.routeName,
                                      //     arguments: currEp);
                                      AudioService.play();
                                    },
                                    shape: StadiumBorder(),
                                    color: Colors.yellow[300],
                                    child: Text('Resume'),
                                  );
                                } else {
                                  return RaisedButton(
                                    onPressed: () async {
                                      // Navigator.of(context).pushNamed(
                                      //     NowPlayingScreen.routeName,
                                      //     arguments: currEp);
                                      await AudioService.updateQueue(currMedia);
                                    },
                                    shape: StadiumBorder(),
                                    color: Colors.yellow[300],
                                    child: Text('Play'),
                                  );
                                }
                              }),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currEp.epName,
                            style: GoogleFonts.lato(
                                color: Theme.of(context).accentColor,
                                fontSize: 19,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(currEp.rjs,
                              style: GoogleFonts.roboto(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w400)),
                        ),
                        SizedBox(height: 15),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currEp.description,
                            style: GoogleFonts.lato(color: Colors.white70),
                          ),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  StreamBuilder(
                      stream: _screenStateStream,
                      builder: (context, snapshot) {
                        final screenState = snapshot.data;

                        final mediaItem = screenState?.mediaItem;
                        if (mediaItem == null)
                          return Container();
                        else if (mediaItem.id ==
                            'https://streaming.radio.co/s8c7294f48/listen')
                          return Container();
                        else
                          return BottomPlayer();
                      })
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
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
