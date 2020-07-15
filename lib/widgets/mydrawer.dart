import 'package:cettalks1/screens/programs.dart';
import 'package:cettalks1/screens/tellus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../screens/teampage.dart';
import '../screens/confessions.dart';
import '../screens/dedications.dart';

class MyDrawer extends StatelessWidget {
  static const String insta = 'https://www.instagram.com/cetalks/';
  static const String fb = 'https://www.facebook.com/CETalks';
  static const String yt =
      'https://www.youtube.com/channel/UCYiLt1pZnf2dslVLSe0WAXQ';
  static const String spotify =
      'https://open.spotify.com/show/5AGpr7Sd0kjciMAFxSuC0y';
  _launchURL(myurl) async {
    if (await canLaunch(myurl)) {
      await launch(myurl);
    } else {
      throw 'Could not launch $myurl';
    }
  }

  Widget buildListTile(
      String title, IconData icon, Function tapHandler, BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      color: title == 'Listen live'
          ? Color.fromRGBO(96, 125, 139, 0.25)
          : Theme.of(context).accentColor,
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
        ),
        title: Text(title, style: GoogleFonts.lato(fontSize: 18)),
        onTap: () {
          // ...
          tapHandler();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //see if the code can be reduced
    return Container(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: (MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top),
        color: Theme.of(context).accentColor,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            color: Theme.of(context).accentColor,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 150,
                  color: Theme.of(context).primaryColor,
                  child: Container(
                      width: 72,
                      height: 61.48,
                      child: Image.asset('assets/images/cetalks.png')),
                  alignment: Alignment.bottomLeft,
                ),
                buildListTile('Listen live', Icons.audiotrack, () {
                  Navigator.pop(context);
                }, context),
                buildListTile('Confessions', Icons.favorite, () {
                  Navigator.of(context).pushNamed(Confessions.routeName);
                }, context),
                buildListTile('Dedications', Icons.call, () {
                  Navigator.of(context).pushNamed(Dedications.routeName);
                }, context),
                buildListTile('Programs', Icons.calendar_today, () {
                  Navigator.of(context).pushNamed(Programs.routeName);
                }, context),
                buildListTile('Tell Us', Icons.chat, () {
                  Navigator.of(context).pushNamed(TellUs.routeName);
                }, context),
                buildListTile('Team', Icons.group, () {
                  Navigator.of(context).pushNamed(TeamPage.routeName);
                }, context),
                Divider(),
                buildListTile('Facebook', FontAwesomeIcons.facebook, () {
                  _launchURL(fb);
                }, context),
                buildListTile('Instagram', FontAwesomeIcons.instagram, () {
                  _launchURL(insta);
                }, context),
                buildListTile('YouTube', FontAwesomeIcons.youtube, () {
                  _launchURL(yt);
                }, context),
                buildListTile('Spotify', FontAwesomeIcons.spotify, () {
                  _launchURL(spotify);
                }, context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
