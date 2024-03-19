import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_handler.dart';

class SongsPage extends StatefulWidget {
  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  String selectedSong = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Songs'),
        backgroundColor: Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RadioListTile(
              title: Text('Song 1'),
              value: 'song1',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            RadioListTile(
              title: Text('Song 2'),
              value: 'song2',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            RadioListTile(
              title: Text('Song 3'),
              value: 'song3',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedSong.isNotEmpty) {
                  // Send the selected song to the ESP
                  BluetoothHandler.sendSongToESP(selectedSong, 'hear', () => setState(() {}));
                } else {
                  // Inform the user to select a song
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a song.'),
                    ),
                  );
                }
              },
              child: Text('Hear the song'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (selectedSong.isNotEmpty) {
                  // Send the selected song to the ESP
                  BluetoothHandler.sendSongToESP(selectedSong, 'play', () => setState(() {}));
                } else {
                  // Inform the user to select a song
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a song.'),
                    ),
                  );
                }
              },
              child: Text('start play the game'),
            ),
            SizedBox(height: 10),
            // Back Button
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
