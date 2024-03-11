import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_handler.dart';

class MainMenuPage extends StatelessWidget {

  Future<void> _sendRequest(String request) async {
    if (characteristic != null) {
      try {
        await characteristic!.write(utf8.encode(request), withoutResponse: true);
        // Wait for a response
        await Future.delayed(Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
      } catch (e) {
        print('Failed to send the song: $e');
      } finally {
          isSending = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
        backgroundColor: Color(0xFF073050),
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
              child: Text('Songs'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendRequest('P-reference');
              },
              child: Text('Free Trial'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/statistics');
              },
              child: Text('Statistics'),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
