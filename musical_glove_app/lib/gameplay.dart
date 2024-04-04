import 'dart:async';
import 'package:flutter/material.dart';
import 'ble_handler.dart';
import 'dart:convert';

class GamePlayPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const GamePlayPage({Key? key, required this.data}) : super(key: key);

  @override
  _GamePlayPageState createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  String formerdata = '';
  bool showContent = false;
  String note = '';
  int correctHits = 0;
  int currentNoteIndex = 0;
  List<String> songNotes = ['1', '2', '3', '4']; // Example notes, replace with actual notes
  List<bool?> hitFeedback = List.filled(4, null); // List to store hit feedback

  @override
  void initState() {
    super.initState();
    // Start the countdown
    startCountdown();
  }

  void receiveNotesFromESP() async {
    bool firsttime = true;
    correctHits = 0;
    await BluetoothHandler.setupNotifications();
    BluetoothHandler.getCharacteristicStream().listen((List<int> data) {
      if (!firsttime) {
        print('data: ' + data.toString());
        List<String> nextNotes = [];
        String receiveddata = utf8.decode(data);
        if (receiveddata != formerdata) {
          if (receiveddata == 'fail' || receiveddata == 'success') {
            // code ti highlight the circles
            print('fail or success : ' + receiveddata);
            if (receiveddata == 'success') {
              correctHits++;
            }
          }
          else {
            nextNotes = receiveddata.split(",");
            print('notes: ' + receiveddata);
            setState(() {
              note = nextNotes[0];
              currentNoteIndex++;
            });
            print('note: ' + note);
            if (note == 'END') {
              // Handle 'END' note
              print('---Ended----');
              // Calculate and show the result
              showResult(correctHits);
            }
          }
        }
        print('------formerdata $formerdata = receiveddata $receiveddata-----');
        formerdata = receiveddata;
      }
      firsttime = false;
    });
  }

  bool? receivedHitFeedback() {
    // Example logic to determine if the hit is correct or not
    // Replace this with the logic to get feedback from ESP
    // For example, if the feedback is 'C' for correct and 'W' for wrong
    String feedback = ''; // Get feedback from ESP
    if (feedback == 'C') {
      return true;
    } else if (feedback == 'W') {
      return false;
    }
    return null;
  }

  int calculateCorrectHits() {
    // Compare the notes received with the expected notes and count the correct hits
    int correctHits = 0;
    for (int i = 0; i < songNotes.length; i++) {
      if (i < songNotes.length && songNotes[i] == note) {
        correctHits++;
      }
    }
    return correctHits;
  }

  void showResult(int correctHits) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Well Done!'),
          content: Text('Number of Correct Hits: $correctHits'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to previous page
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void startCountdown() {
    // Start the countdown
    Timer(Duration(seconds: 3), () {
      setState(() {
        showContent = true; // Show content after countdown
        print('sending start');
        // Here you can apply BThandler.sendSongToESP
        BluetoothHandler.sendSongActionToESP(widget.data['selectedSong'], 'play_${MapDifficulty(widget.data['selectedDifficulty'])}', () => setState(() {}));
        // Now, initiate receiving notes from ESP
        receiveNotesFromESP();
      });
    });
  }

  @override
  void dispose() {
    // Clean up resources
    BluetoothHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Play'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: showContent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                            (index) => CircleWidget(
                          number: index + 1,
                          highlighted: 2 == index,
                          hitFeedback: hitFeedback[index],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (currentNoteIndex + 1) / songNotes.length,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ],
                )
              : CountdownTimer(),
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({Key? key}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    // Start the countdown
    startCountdown();
  }

  void startCountdown() {
    // Update the countdown every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--; // Decrease the countdown
      });
      if (_countdown <= 0) {
        timer.cancel(); // Stop the timer when countdown reaches 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _countdown.toString(),
        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  final int number;
  final bool highlighted;
  final bool? hitFeedback;

  const CircleWidget({Key? key, required this.number, this.highlighted = false, this.hitFeedback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color circleColor = Colors.grey;
    if (hitFeedback != null) {
      circleColor = hitFeedback! ? Colors.green : Colors.red;
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? Colors.blue : circleColor,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

String MapDifficulty(String difficulty) {
  switch (difficulty) {
    case 'Easy':
      return '1';
    case 'Medium':
      return '2';
    case 'Hard':
      return '3';
  }
  return '';
}
