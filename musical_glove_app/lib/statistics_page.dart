import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_handler.dart'; // Import your Bluetooth handler here

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic> statisticsData = {};
  late String currentSongName;
  late String currentDifficulty;
  bool isLoading = true;
  int selectedSongIndex = 0; // New variable to keep track of the selected song index

  @override
  void initState() {
    super.initState();
    currentSongName = '';
    currentDifficulty = 'easy';
    statisticsData = {};
    retrieveStatisticsData();
  }

  void retrieveStatisticsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Ensure that characteristic is available
      if (characteristic != null) {
        // Send request to ESP to retrieve statistics
        await BluetoothHandler.sendRequest('get_statistics', () => setState(() {}));

        // Listen to responses from ESP device
        await Future.delayed(const Duration(seconds: 1));
        List<int> responseBytes = await characteristic!.read();

        setState(() {
          statisticsData = json.decode(utf8.decode(responseBytes));
          currentSongName = statisticsData.keys.elementAt(selectedSongIndex); // Update currentSongName based on selected index
          isLoading = false;
        });
      } else {
        print('Characteristic is not available');
      }
    } catch (e) {
      print('Failed to retrieve statistics data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> songNames = statisticsData.keys.toList(); // Convert to list
    songNames = songNames.toSet().toList(); // Remove duplicates
    List<String> difficultyLevels = ['easy', 'medium', 'hard'];

    List<Map<String, dynamic>> getUsers() {
      List<Map<String, dynamic>> userList = [];
      if (statisticsData.containsKey(currentSongName) &&
          statisticsData[currentSongName].containsKey(currentDifficulty)) {
        var userData = statisticsData[currentSongName][currentDifficulty];
        userData.forEach((username, highScore) {
          if (username!= 'song_played' && username != '') {
            userList.add({
              'username': username,
              'high_score': highScore,
            });
          }
        });
      }
      userList.sort((a, b) => int.parse(b['high_score'].toString()).compareTo(int.parse(a['high_score'].toString())));
      return userList;
    }

    List<Map<String, dynamic>> users = getUsers();

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
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          children: [
            // Selector for song name with arrows
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  color: Color.fromRGBO(105, 105, 105, 1),
                ),
                SizedBox(width: 8), // Add some spacing
                Text(
                  'statistics',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(105, 105, 105, 1),
                      fontFamily: 'LeckerliOne'
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedSongIndex = (selectedSongIndex - 1) % songNames.length;
                      if (selectedSongIndex < 0) selectedSongIndex = songNames.length - 1;
                      currentSongName = songNames[selectedSongIndex];
                    });
                  },
                ),
                Text(
                  currentSongName,
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      selectedSongIndex = (selectedSongIndex + 1) % songNames.length;
                      currentSongName = songNames[selectedSongIndex];
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Custom toggle buttons for difficulty selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: difficultyLevels.map((difficulty) {
                bool isSelected = currentDifficulty == difficulty;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentDifficulty = difficulty;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      difficulty,
                      style: TextStyle(
                        fontSize: isSelected ? 18 : 16, // Increase font size for selected difficulty
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold text for selected difficulty
                        color: isSelected ? Colors.black : Colors.grey, // Change color for selected difficulty
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
              height: MediaQuery.of(context).size.height * 0.4, // Adjust the height as needed
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true, // Ensure ListView takes only the space it needs
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0), // Match the card's border radius
                          gradient: currentUser == users[index]['username']
                              ? const LinearGradient(
                            colors: [
                              Color.fromRGBO(101, 179, 213, 1.0),
                              Color.fromRGBO(100, 206, 220, 1.0),
                              Color.fromRGBO(98, 206, 186, 1.0),
                            ],
                          )
                              : null, // No gradient for other users
                        ),
                        child: ListTile(
                          leading: Text('${index + 1}'), // Rank
                          title: Text(users[index]['username']),
                          trailing: Text('${users[index]['high_score']}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
