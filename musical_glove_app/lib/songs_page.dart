import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_handler.dart';

class SongsPage extends StatefulWidget {
  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  String selectedSong = '';

  Future<void> _sendSongToESP(String selectedSong, String action) async {
    if (characteristic != null) {
      try {
        setState(() {
          isSending = true;
        });
        await characteristic!.write(utf8.encode(selectedSong + "_" + action), withoutResponse: true);
        // Wait for a response
        await Future.delayed(Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        setState(() {
          // responseMessage = response;
        });
      } catch (e) {
        print('Failed to send the song: $e');
      } finally {
        setState(() {
          isSending = false;
        });
      }
    }
  }

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
              value: 'Song1',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            RadioListTile(
              title: Text('Song 2'),
              value: 'Song2',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            RadioListTile(
              title: Text('Song 3'),
              value: 'Song3',
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
                  _sendSongToESP(selectedSong, 'hear');
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
                  _sendSongToESP(selectedSong, 'play');
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
