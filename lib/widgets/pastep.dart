import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/pastep.dart';
import '../screens/episodedetail.dart';
import '../widgets/bottomplayer.dart';

List<PastEp> pastEpisodes = [];

Widget buildPastEpList(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.vertical -
        200,
    child: ListView.builder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, EpisodeDetail.routeName,
                arguments: [pastEpisodes[index], pastEpisodes, index]);
          },
          child: Card(
            margin: EdgeInsets.all(5),
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Container(
                  width: 55,
                  height: 55,
                  child: Hero(
                    tag: pastEpisodes[index].artUrl,
                    child: Image(
                      image: NetworkImage(
                        pastEpisodes[index].artUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  pastEpisodes[index].epName,
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(pastEpisodes[index].rjs,
                    style: TextStyle(color: Theme.of(context).accentColor)),
              ),
            ),
          ),
        );
      },
      itemCount: pastEpisodes.length,
    ),
  );
}

@override
Widget buildPastEpisodes(BuildContext context) {
  return Container(
    color: Theme.of(context).primaryColor,
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 85,
        ),
        StreamBuilder(
          stream: Firestore.instance.collection('PastEpisodes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              List pastEpSnapList = snapshot.data.documents;

              pastEpisodes = [];
              for (var i = 0; i < pastEpSnapList.length; i++) {
                var currPastEp = pastEpSnapList[i].data;

                if (currPastEp['artUrl'] == null ||
                    currPastEp['audioLocation'] == null ||
                    currPastEp['program'] == null ||
                    currPastEp['description'] == null ||
                    currPastEp['epName'] == null ||
                    currPastEp['rjs'] == null ||
                    currPastEp['duration'] == null) continue;
                var pastEp = PastEp(
                    duration: currPastEp['duration'],
                    artUrl: currPastEp['artUrl'],
                    audiLocation: currPastEp['audioLocation'],
                    program: currPastEp['program'],
                    description: currPastEp['description'],
                    epName: currPastEp['epName'],
                    rjs: currPastEp['rjs']);
                if (!pastEpisodes.contains(pastEp)) {
                  pastEpisodes.add(pastEp);
                }
              }
            }
            return buildPastEpList(context);
          },
        ),
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
  );
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
