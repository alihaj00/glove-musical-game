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
  List<String> adminUsers = ['anas', 'uriel', 'ali'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Musical Glove',
              style: TextStyle(
                fontFamily: 'LeckerliOne',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(0, 176, 143, 1),
              ),
            ),
            SizedBox(width: 8), // Add some spacing between the title and logo
            Image.asset(
              'assets/glove_main_page.jpg', // Path to your logo image file
              height: 48, // Adjust the height as needed
              width: 48, // Adjust the width as needed
            ),
          ],
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
                      bool isAdminUser = adminUsers.contains(currentUser);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: selectedSong != song
                              ? Material(
                            color: Colors.grey[300],
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedSong = song;
                                });
                              },
                              child: ListTile(
                                title: Text(song),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      isAdminUser
                                          ? Container(
                                        // Container for the delete button
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Color.fromRGBO(182, 6, 6, 1.0)),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirm Delete'),
                                                  content: Text('Are you sure you want to delete this song?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        // Perform delete operation
                                                        BluetoothHandler.sendSongActionToESP(song, 'delete', () => setState(() {}));
                                                        setState(() {
                                                          songs.removeAt(index); // Assuming index is the position of the song in the list
                                                        });
                                                        Navigator.of(context).pop(); // Close the dialog
                                                      },
                                                      child: Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            padding: EdgeInsets.zero, // Remove padding
                                            shape: CircleBorder(), // Make the button circular
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.delete, color: Color.fromRGBO(182, 6, 6, 1.0)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(), // Empty SizedBox if user is not admin
                                SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Color.fromRGBO(182, 6, 6, 1.0)),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      BluetoothHandler.sendSongActionToESP(song, 'hear', () => setState(() {}));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      padding: EdgeInsets.zero, // Remove padding
                                      shape: CircleBorder(), // Make the button circular
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.volume_up, color: Color.fromRGBO(182, 6, 6, 1.0)),
                                      ],
                                    ),
                                  ),
                                ),
                                ]
                              )
                            ),
                          ),
                        )
                              : Container(
                              decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(101, 179, 213, 1.0),
                                  Color.fromRGBO(100, 206, 220, 1.0),
                                  Color.fromRGBO(98, 206, 186, 1.0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedSong = song;
                                });
                              },
                              child: ListTile(
                                  title: Text(song),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        isAdminUser
                                            ? Container(
                                          // Container for the delete button
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Color.fromRGBO(182, 6, 6, 1.0)),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Confirm Delete'),
                                                    content: Text('Are you sure you want to delete this song?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(); // Close the dialog
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          // Perform delete operation
                                                          BluetoothHandler.sendSongActionToESP(song, 'delete', () => setState(() {}));
                                                          setState(() {
                                                            songs.removeAt(index); // Assuming index is the position of the song in the list
                                                          });
                                                          Navigator.of(context).pop(); // Close the dialog
                                                        },
                                                        child: Text('Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              elevation: 0,
                                              padding: EdgeInsets.zero, // Remove padding
                                              shape: CircleBorder(), // Make the button circular
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete, color: Color.fromRGBO(182, 6, 6, 1.0)),
                                              ],
                                            ),
                                          ),
                                        )
                                        : SizedBox(), // Empty SizedBox if user is not admin
                                        SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Color.fromRGBO(182, 6, 6, 1.0)),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              BluetoothHandler.sendSongActionToESP(song, 'hear', () => setState(() {}));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              elevation: 0,
                                              padding: EdgeInsets.zero, // Remove padding
                                              shape: CircleBorder(), // Make the button circular
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.volume_up, color: Color.fromRGBO(182, 6, 6, 1.0)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                  )
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
        elevation: 8,
        color: Color.fromRGBO(240, 255, 251, 0.63),
        child: Container(
          height: kBottomNavigationBarHeight,
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
      floatingActionButton: SizedBox(
        width: 120,
        height: 120,
        child: FloatingActionButton(
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
                  content: Text('Please select a song and difficulty. '),
                ),
              );
            }
          },
          backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
          elevation: 8.0,
          shape: CircleBorder(),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.play_arrow, size: 40),
              SizedBox(height: 8.0),
              Text('Play', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<List<String>> _getSongs() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      String response = await BluetoothHandler.getSongListFromESP(() => setState(() {}));
      dynamic decodedResponse = jsonDecode(response);
      List<String> songs = [];

      if (decodedResponse != null && decodedResponse is Map<String, dynamic>) {
        // Check if the decoded response is not null and is a Map
        decodedResponse.forEach((key, value) {
          if (value is String) {
            songs.add(value);
            print(value);
          }
        });
      }

      return songs;
    } catch (e) {
      // If an error occurs, throw it to be caught by the FutureBuilder
      throw Exception('Failed to load songs. Please Hit try again in few seconds');
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
