import 'package:cettalks1/widgets/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:volume/volume.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';
import '../widgets/audioplayertask.dart';
import '../widgets/pastep.dart';

class Player extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  void initState() {
    super.initState();

    initPlatformState(AudioManager.STREAM_MUSIC);
  }

  void setVol(int i) async {
    await Volume.setVol(i);
  }

  Future<void> initPlatformState(AudioManager am) async {
    await Volume.controlVolume(am);
  }

  PanelController _pc = PanelController();
  var currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      if (_pc.isPanelOpen) {
        _pc.close();
        _pc.show();
      }

      Fluttertoast.showToast(
        msg: 'Press back again to exit',
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: AudioServiceWidget(
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'CETalks',
              ),
              textTheme: Theme.of(context).appBarTheme.textTheme,
            ),
            drawer: MyDrawer(),
            backgroundColor: Theme.of(context).primaryColor,
            body: SlidingUpPanel(
              controller: _pc,
              collapsed: GestureDetector(
                onTap: () {
                  _pc.open();
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25))),
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.expand_less,
                          color: Theme.of(context).accentColor,
                        ),
                        Text(
                          'Our Podcasts',
                          style: GoogleFonts.lato(
                              color: Theme.of(context).accentColor),
                        ),
                      ],
                    ))),
              ),
              header: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25))),
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.expand_more,
                        color: Theme.of(context).accentColor,
                      ),
                      Text(
                        'Our Podcasts',
                        style: GoogleFonts.lato(
                            color: Theme.of(context).accentColor),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Missed the livestream? Catch up here',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ))),
              minHeight: 55,
              maxHeight: MediaQuery.of(context).size.height,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              panel: Center(child: buildPastEpisodes(context)),
              body: RefreshIndicator(
                onRefresh: () => AudioService.stop(),
                //stack plus listview is used to enable refreshindicator
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ListView(),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width: 150,
                                  child: const Image(
                                    image:
                                        AssetImage('assets/images/cetalks.png'),
                                  ),
                                ),
                                SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                      size: 220,
                                      customWidths: CustomSliderWidths(
                                          handlerSize: 8.5,
                                          progressBarWidth: 5),
                                      customColors: CustomSliderColors(
                                          trackColor: Colors.grey,
                                          shadowColor: Colors.white,
                                          progressBarColor: Colors.white),
                                      angleRange: 360,
                                      startAngle: 270),
                                  initialValue: 40,
                                  min: 0,
                                  max: 100,
                                  onChange: (vol) async {
                                    var maxVol = await Volume.getMaxVol;

                                    var k =
                                        (vol.floor() * (maxVol / 100)).toInt() +
                                            1;
                                    setVol(k);
                                  },
                                  innerWidget: (_) {
                                    return StreamBuilder<ScreenState>(
                                        stream: _screenStateStream,
                                        builder: (context, snapshot) {
                                          final streamUrl =
                                              "https://streaming.radio.co/s8c7294f48/listen";
                                          final streamMedia = [
                                            MediaItem(
                                                id:
                                                    "https://streaming.radio.co/s8c7294f48/listen",
                                                album: " ",
                                                title: "CETalks",
                                                artUri:
                                                    'https://i.imgur.com/UZ6f57G.png')
                                          ];
                                          final screenState = snapshot.data;

                                          final state =
                                              screenState?.playbackState;
                                          final processingState =
                                              state?.processingState ??
                                                  AudioProcessingState.none;

                                          final playing =
                                              state?.playing ?? false;
                                          return Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                if (processingState ==
                                                    AudioProcessingState
                                                        .none) ...{
                                                  Center(
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.play_arrow,
                                                      ),
                                                      iconSize: 110.0,
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      onPressed: () {
                                                        Scaffold.of(context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'Buffering...'),
                                                          elevation: 5,
                                                          duration: Duration(
                                                              seconds: 6),
                                                        ));

                                                        AudioService.start(
                                                          androidStopForegroundOnPause:
                                                              true,
                                                          backgroundTaskEntrypoint:
                                                              _audioPlayerTaskEntrypoint,
                                                          androidNotificationChannelName:
                                                              'CETalks',
                                                          androidNotificationColor:
                                                              0x00000000,
                                                          androidNotificationIcon:
                                                              'mipmap/ic_launcher',
                                                          androidEnableQueue:
                                                              true,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                } else if (processingState ==
                                                    AudioProcessingState
                                                        .skippingToNext) ...{
                                                  Center(
                                                      child: SizedBox(
                                                          height: 55,
                                                          width: 55,
                                                          child:
                                                              CircularProgressIndicator()))
                                                } else if (playing &&
                                                    AudioService
                                                            .currentMediaItem
                                                            .id ==
                                                        streamUrl)
                                                  Center(
                                                    child: IconButton(
                                                      icon: Icon(Icons.pause),
                                                      iconSize: 100.0,
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      onPressed:
                                                          AudioService.pause,
                                                    ),
                                                  )
                                                else
                                                  Center(
                                                    child: AudioService
                                                                .currentMediaItem
                                                                .id ==
                                                            streamUrl
                                                        ? IconButton(
                                                            icon: Icon(Icons
                                                                .play_arrow),
                                                            iconSize: 110.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                            onPressed:
                                                                AudioService
                                                                    .play,
                                                          )
                                                        : IconButton(
                                                            icon: Icon(
                                                              Icons.play_arrow,
                                                            ),
                                                            iconSize: 110.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                            onPressed:
                                                                () async {
                                                              Scaffold.of(
                                                                      context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    'Buffering...'),
                                                                elevation: 5,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            6),
                                                              ));

                                                              await AudioService
                                                                  .updateQueue(
                                                                      streamMedia);
                                                            },
                                                          ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 111,
                            )
                          ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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

// NOTE: Your entrypoint MUST be a top-level function.
//Notifications can be tweaked from AudioPLayerTask
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
