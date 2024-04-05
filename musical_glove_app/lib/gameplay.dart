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
  List<int>? highlighted = [10];
  List<String> nextNotes = ['']; // Example notes, replace with actual notes
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
        List<String> nextNotes = [''];
        String receiveddata = utf8.decode(data);
        if (receiveddata != formerdata) {
          highlighted = [-1];
          if (receiveddata == 'fail' || receiveddata == 'success') {
            // code ti highlight the circles
            bool hitValue = receiveddata == 'success' ? true : false;
            List<int>? indexes = MapNoteIndexes(note);
            for (var index in indexes!) {
              print(index);
              print(hitValue);
              setState(() {
                hitFeedback[index] = hitValue;
              });
            }
            if (hitValue) {
              correctHits++;
            }
          }
          else {
            hitFeedback =  List.filled(4, null);
            nextNotes = receiveddata.split(",");
            setState(() {
              note = nextNotes[0];
              setState(() {
                highlighted = MapNoteIndexes(note);
              });
              currentNoteIndex++;
            });
            if (note == 'END') {
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
                          key: UniqueKey(), // Add UniqueKey to force rebuild
                          number: index + 1,
                          highlighted: highlighted!.contains(index),
                          hitFeedback: hitFeedback[index],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (currentNoteIndex + 1) / nextNotes.length,
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

class CircleWidget extends StatefulWidget {
  final int number;
  final bool highlighted;
  final bool? hitFeedback;

  CircleWidget({Key? key, required this.number, this.highlighted = false, this.hitFeedback}) : super(key: key);

  @override
  _CircleWidgetState createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget> {
  @override
  Widget build(BuildContext context) {
    Color circleColor = Colors.grey;
    if (widget.hitFeedback != null) {
      circleColor = widget.hitFeedback! ? Colors.green : Colors.red;
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.highlighted ? Colors.blue : circleColor,
      ),
      child: Center(
        child: Text(
          '${widget.number}',
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

List<int>? MapNoteIndexes(String note) {
  Map<String, List<int>> NotesToIndexes = {
    'do': [0],
    're' : [0,1],
    'me': [1],
    'fa': [1,2],
    'sol': [2],
    'la': [2,3],
    'si': [3],
  };
  for (var noteKey in NotesToIndexes.keys) {
    if (note.contains(noteKey)) {
      return NotesToIndexes[noteKey];
    }
  }
  return [];
}
