import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'registration_page.dart';
import 'songs_page.dart';
import 'ble_handler.dart';
import 'statistics_page.dart';
import 'add_song.dart';
import 'gameplay.dart';
import 'free_trial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musical Glove Game',
      theme: ThemeData(
        fontFamily: 'TTNorms',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/songs': (context) => const SongsPage(),
        '/statistics': (context) => const StatisticsPage(),
        '/BT connection': (context) => const BluetoothDeviceListScreen(),
        '/add song': (context) => const AddSongPage(),
        '/free trial': (context) => const FreeTrialPage(),
        '/game': (context) {
          final Map<String, dynamic>? data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return GamePlayPage(data: data ?? {});
        },
      },
    );
  }
}
