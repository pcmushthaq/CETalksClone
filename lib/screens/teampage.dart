import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/members.dart';

import '../screens/storyview.dart';
import 'package:social_media_widgets/instagram_story_swipe.dart';

Widget buildPanelGrid(BuildContext context, int index, Function handler) {
  var indexList = [];
  for (var i = 0; i < dummyTeam.length; i++) {
    if (indexList.contains(dummyTeam[i].panel)) continue;
    indexList.add(dummyTeam[i].panel);
  }

  return GridView.count(
    shrinkWrap: true,
    padding: EdgeInsets.all(8),
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1,
    children: <Widget>[
      ...indexList.map((tx) {
        return GestureDetector(
          onTap: () => handler(indexList.indexOf(tx)),
          child: Column(children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                image: DecorationImage(
                  image: NetworkImage(tx[2]['thumbUrl']),
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
                tx[1]['panelName'],
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

class TeamPage extends StatefulWidget {
  static const routeName = '/team';

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // @override
  int selectedIndex = 0;

  void selectPage(int currIndex) {
    var panelList = dummyTeam
        .where((element) => element.panel[0]['panelId'] == currIndex)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstagramStorySwipe(
          initialPage: 0,
          children: <Widget>[
            ...panelList.map((e) {
              return Screen(e);
            }).toList(),
          ],
        ),
      ),
    );
    setState(() {
      selectedIndex = currIndex;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: const Text('Team', style: TextStyle(fontSize: 25)),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: Center(
                    child: buildPanelGrid(context, selectedIndex, selectPage)))
          ],
        ));
  }
}
