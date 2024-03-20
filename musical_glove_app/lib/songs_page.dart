import 'package:flutter/material.dart';
import 'ble_handler.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  String selectedSong = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RadioListTile(
              title: const Text('Song 1'),
              value: 'song1',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            RadioListTile(
              title: const Text('Song 2'),
              value: 'song2',
              groupValue: selectedSong,
              onChanged: (value) {
                setState(() {
                  selectedSong = value as String;
                });
              },
            ),
            RadioListTile(
              title: const Text('Song 3'),
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
                    const SnackBar(
                      content: Text('Please select a song.'),
                    ),
                  );
                }
              },
              child: const Text('Hear the song'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (selectedSong.isNotEmpty) {
                  // Send the selected song to the ESP
                  BluetoothHandler.sendSongToESP(selectedSong, 'play', () => setState(() {}));
                } else {
                  // Inform the user to select a song
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a song.'),
                    ),
                  );
                }
              },
              child: const Text('start play the game'),
            ),
            const SizedBox(height: 10),
            // Back Button
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
