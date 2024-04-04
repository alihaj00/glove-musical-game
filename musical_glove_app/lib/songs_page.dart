import 'dart:convert';
import 'package:flutter/material.dart';
import 'ble_handler.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({Key? key}) : super(key: key);

  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  String selectedSong = '';
  String selectedDifficulty = 'Easy';
  // late Future<List<String>> _songsFuture = _getSongs();
  late Future<List<String>> _songsFuture = _getSongs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Musical Glove',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(0, 176, 143, 1),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<String>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
          return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _songsFuture = _getSongs(); // Trigger songs fetching again
                      });
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            List<String> songs = snapshot.data ?? [];
            return Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 40.0, 0.0, 0.0),
                    child: Text(
                      'Choose song and Difficulty:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(90, 90, 90, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 4.0, 0.0, 22.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ToggleButton(
                        text: 'Easy',
                        isSelected: selectedDifficulty == 'Easy',
                        onTap: () {
                          setState(() {
                            selectedDifficulty = 'Easy';
                          });
                        },
                      ),
                      ToggleButton(
                        text: 'Medium',
                        isSelected: selectedDifficulty == 'Medium',
                        onTap: () {
                          setState(() {
                            selectedDifficulty = 'Medium';
                          });
                        },
                      ),
                      ToggleButton(
                        text: 'Hard',
                        isSelected: selectedDifficulty == 'Hard',
                        onTap: () {
                          setState(() {
                            selectedDifficulty = 'Hard';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: songs.length + 1, // Add one for the "add song" card
                    itemBuilder: (BuildContext context, int index) {
                      if (index == songs.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.pushNamed(context, '/add song');
                              // Reload songs list when returning from the "add song" page
                              if (result == true) {
                                // Reload songs list
                                setState(() {
                                  _songsFuture = _getSongs();
                                });
                              }
                            },
                            child: Card(
                              color: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: const ListTile(
                                title: Center(
                                  child: Column(
                                    children: [
                                      Text('Add Song', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Icon(Icons.add),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      String song = songs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Material(
                            color: selectedSong == song ? Colors.blue.withOpacity(0.3) : Colors.grey[300],
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedSong = song;
                                });
                              },
                              child: ListTile(
                                title: Text(song),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    BluetoothHandler.sendSongActionToESP(song, 'hear', () => setState(() {}));
                                  },
                                  child: const Icon(Icons.volume_up),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0), // Add space between the list and the bottom navigation bar
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8, // Add elevation for better visual separation
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          height: kBottomNavigationBarHeight + 32.0, // Add extra space for button
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to statistics page
                  Navigator.pushNamed(context, '/statistics');
                },
                child: Text('Statistics'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedSong.isNotEmpty && selectedDifficulty.isNotEmpty) {
                    // Do something when both song and difficulty are selected
                    // For example, navigate to the game screen
                    final data = {
                      "selectedSong": selectedSong,
                      "selectedDifficulty": selectedDifficulty
                      // Add other data you want to pass to the gameplay page
                    };
                    Navigator.pushNamed(context, '/game',  arguments: data);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a song and difficulty.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Adjust the button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0), // Make button round
                  ),
                ),
                child: Text('Start Play'),
              ),
              TextButton(
                onPressed: () {
                  BluetoothHandler.sendRequest('P-reference', () => setState(() {}));
                },
                child: const Text('Trial'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getSongs() async {
    // return ['song1', 'song2'];
    try {
      String response = await BluetoothHandler.getSongListFromESP(() => setState(() {}));
      dynamic decodedResponse = jsonDecode(response);
      List<String> songs = [];
      decodedResponse.forEach((key, value) {
        if (value is String) {
          songs.add(value);
          print(value);
        }
      });
      return songs;
    } catch (e) {
      // If an error occurs, throw it to be caught by the FutureBuilder
      throw Exception('Failed to load songs: $e');
    }
  }
}

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: isSelected ? 20 : 16,
          ),
        ),
      ),
    );
  }
}
