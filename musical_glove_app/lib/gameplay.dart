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
  String userPrint = '';
  bool showContent = false;
  String note = '';
  int correctHits = 0;
  List<int>? highlighted = [10];
  List<String> successStrings = ['perfect', 'good', 'not_bad'];
  List<String> nextNotes = ['']; // Example notes, replace with actual notes
  List<bool?> hitFeedback = List.filled(4, null); // List to store hit feedback
  double progress = 0.0;
  Timer? progressTimer;

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
          setState(() {
            highlighted = [-1];
          });
          if (receiveddata == 'fail' || successStrings.contains(receiveddata)) {
            // code to highlight the circles
            print(receiveddata);
            bool hitValue = successStrings.contains(receiveddata)
                ? true
                : false;
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
            setState(() {
              userPrint = MapUserPrint(receiveddata);
            });
          } else if (receiveddata == 'not_bad') {
            setState(() {
              userPrint = MapUserPrint(receiveddata);
            });
          }else {
            hitFeedback = List.filled(4, null);
            nextNotes = receiveddata.split(",");
            setState(() {
              note = nextNotes[0];
              setState(() {
                highlighted = MapNoteIndexes(note);
              });
            });
            if (note == 'END') {
              // Calculate and show the result
              showResult(correctHits);
            } else {
              // Restart progress timer when new notes are received
              progress = 0.0;
              progressTimer?.cancel();
              startProgressTimer();
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
                // Navigate back to the previous page
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
        // Here you can apply BThandler.sendSongToESP
        BluetoothHandler.sendSongActionToESP(widget.data['selectedSong'],
            'play_${MapDifficulty(widget.data['selectedDifficulty'])}', () =>
                setState(() {}));
        // Now, initiate receiving notes from ESP
        receiveNotesFromESP();
        // Start progress timer
        startProgressTimer();
      });
    });
  }

  void startProgressTimer() {
    // Determine progress duration based on difficulty
    double progressDuration = 2.0; // Default duration for easy difficulty
    switch (widget.data['selectedDifficulty']) {
      case 'Medium':
        progressDuration = 1.5;
        break;
      case 'Hard':
        progressDuration = 1.0;
        break;
    }
    // Set up progress timer
    progressTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        progress += 0.5 / progressDuration; // Update progress
        if (progress >= 1.0) {
          progress = 0.0; // Reset progress when reaching 100%
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up resources
    BluetoothHandler.dispose();
    progressTimer?.cancel(); // Cancel progress timer
    super.dispose();
  }

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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              LinearProgressIndicator(value: progress),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: showContent
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Text(
                          userPrint,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                                (index) => CircleWidget(
                              key: UniqueKey(),
                              // Add UniqueKey to force rebuild
                              number: index + 1,
                              highlighted: highlighted!.contains(index),
                              hitFeedback: hitFeedback[index],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    )
                        : CountdownTimer(),
                  ),
                ),
              ),
            ],
          ),
          if (showContent)
            Positioned(
              left: 0,
              bottom: 0,
              child: Image.asset(
                'assets/glove_gameplay.jpg',
                width: MediaQuery.of(context).size.width * 0.9, // Set width to screen width
                height: 600, // Adjust the height as needed
                fit: BoxFit.fill, // Ensure the image fills the width of the screen
              ),
            ),
        ],
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.highlighted ? Colors.blue : circleColor,
      ),
      child: Center(
        child: Text(
          '${widget.number}',
          style: const TextStyle(
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

String MapUserPrint(String ESPReponse) {
  switch (ESPReponse) {
    case 'perfect':
      return 'Perfect!';
    case 'good':
      return 'Good!';
    case 'not_bad':
      return 'Not Bad';
    case 'fail':
      return "Next time you'll get it!";
    case 'not_time':
      return "Patience! Too late or too early...";
  }
  return '';
}