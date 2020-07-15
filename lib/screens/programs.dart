import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_widgets/instagram_story_swipe.dart';

import './errorscreen.dart';
import './programview.dart';

class Programs extends StatefulWidget {
  static const routeName = '/programs';

  @override
  _ProgramsState createState() => _ProgramsState();
}

class _ProgramsState extends State<Programs> {
  var episodes = [];
  var programs = [];

  void selectStory(String program) async {
    QuerySnapshot epSnaps = await Firestore.instance
        .collection('Programs/$program/Episodes')
        .getDocuments();
    setState(() {
      List epSnapList = (epSnaps.documents);
      episodes = [];
      for (var i = 0; i < epSnapList.length; i++) {
        var currEp = epSnapList[i].data;
        if (currEp['ImageUrl'] == null ||
            currEp['EpNo'] == null ||
            currEp['Name'] == null) continue;
        if (episodes.contains(currEp)) continue;
        episodes.add(currEp);
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstagramStorySwipe(
          initialPage: 0,
          children: <Widget>[
            if (episodes.isEmpty) ErrorScreen(),
            ...episodes.map((e) {
              return ScreenProg(e);
            }).toList(),
          ],
        ),
      ),
    );

    return;
  }

  Widget buildProgramGrid(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.6,
      children: <Widget>[
        ...programs.map((tx) {
          return GestureDetector(
            onTap: () => selectStory(tx['Name']),
            child: Column(children: <Widget>[
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  image: DecorationImage(
                    image: NetworkImage(tx['ThumbUrl']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  border: Border.all(
                    color: Theme.of(context).accentColor,
                    width: 1.25,
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Container(
                child: Text(
                  tx['Name'],
                  style: GoogleFonts.lato(color: Theme.of(context).accentColor),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ]),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Programs', style: TextStyle(fontSize: 25)),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('Programs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List docSnapList = snapshot.data.documents;
            programs = [];
            for (var i = 0; i < docSnapList.length; i++) {
              var currProgram = docSnapList[i].data;
              if (currProgram['ThumbUrl'] == null ||
                  currProgram['ID'] == null ||
                  currProgram['Name'] == null) continue;
              if (!programs.contains(currProgram)) {
                programs.add(currProgram);
              }
            }
          }

          return buildProgramGrid(context);
        },
      ),
    );
  }
}
