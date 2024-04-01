import 'package:flutter/material.dart';
import 'ble_handler.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/songs');
              },
              child: const Text('Songs'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                BluetoothHandler.sendRequest('P-reference', () => setState(() {}));
              },
              child: const Text('Free Trial'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/statistics');
              },
              child: const Text('Statistics'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add song');
              },
              child: const Text('Add Song'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
