import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import './utils/theme.dart';
import './screens/myhomepage.dart';
import './screens/teampage.dart';
import './screens/confessions.dart';
import './screens/dedications.dart';
import './screens/tellus.dart';
import './screens/programs.dart';

import './screens/episodedetail.dart';
import './screens/nowplaying.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    return MaterialApp(
      title: 'CETalks',
      theme: cetalksTheme,
      home: MyHomePage(),
      routes: {
        TeamPage.routeName: (ctx) => TeamPage(),
        Confessions.routeName: (ctx) => Confessions(),
        Dedications.routeName: (ctx) => Dedications(),
        Programs.routeName: (ctx) => Programs(),
        TellUs.routeName: (ctx) => TellUs(),
        EpisodeDetail.routeName: (ctx) => EpisodeDetail(),
        NowPlayingScreen.routeName: (ctx) => NowPlayingScreen()
      },
    );
  }
}
