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
          currentSongName = statisticsData.keys.first;
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
          userList.add({
            'username': username,
            'high_score': highScore,
          });
        });
      }
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
            DropdownButton<String>(
              value: currentSongName,
              onChanged: (String? newValue) {
                setState(() {
                  currentSongName = newValue!;
                });
              },
              items: songNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: currentDifficulty,
              onChanged: (String? newValue) {
                setState(() {
                  currentDifficulty = newValue!;
                });
              },
              items: difficultyLevels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Text('${index + 1}'), // Rank
                      title: Text(users[index]['username']),
                      trailing: Text('${users[index]['high_score']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
