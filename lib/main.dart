import 'helper/authenticate.dart';
import 'helper/helperfunctions.dart';
import 'views/menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn;

  @override
  void initState() {
    // getLoggedInState();
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        print('saiu');
        setState(() {
          userIsLoggedIn = false;
        });
      } else {
        print('entrou');

        setState(() {
          userIsLoggedIn = true;
        });
      }
    });
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff1F1F1F),
        accentColor: Color(0xff007EF4),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn != null
          ? userIsLoggedIn
              ? Menu()
              : Authenticate()
          : Container(
              child: Center(
                child: Authenticate(),
              ),
            ),
    );
  }
}
