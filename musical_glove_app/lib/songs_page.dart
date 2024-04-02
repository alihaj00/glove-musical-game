import 'package:flutter/material.dart';
import 'ble_handler.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({Key? key}) : super(key: key);

  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  String selectedSong = '';
  String selectedDifficulty = '';

  @override
  Widget build(BuildContext context) {
    List<String> songs = ['Song 1', 'Song 2', 'Song 3'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Song And Difficulty'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                text: 'Difficult',
                isSelected: selectedDifficulty == 'Difficult',
                onTap: () {
                  setState(() {
                    selectedDifficulty = 'Difficult';
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length + 1, // Add one for the "add song" card
              itemBuilder: (BuildContext context, int index) {
                if (index == songs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/add song');
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
                            child: const Icon(Icons.play_arrow),
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
                    Navigator.pushNamed(context, '/game');
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
