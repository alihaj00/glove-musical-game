import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'registration_page.dart';
import 'songs_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musical Glove Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/songs': (context) => SongsPage(),
      },
    );
  }
}
