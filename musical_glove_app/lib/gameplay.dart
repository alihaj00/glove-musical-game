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
  List<int> highlightedCircles = [];
  bool showContent = false;
  String note = '';

  @override
  void initState() {
    super.initState();
    // Start the countdown
    startCountdown();
    }

  void receiveNotesFromESP() async {
    await BluetoothHandler.setupNotifications();
    BluetoothHandler.getCharacteristicStream().listen((List<int> data) {
      String receivedNote = utf8.decode(data);
      setState(() {
        note = receivedNote;
      });
      print(note);
      if (note == 'END') {
        // Handle 'END' note
        print('---Ended----');
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources
    BluetoothHandler.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circle Highlight'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: showContent
              ? Wrap(
            alignment: WrapAlignment.center,
            spacing: 20, // adjust the spacing between circles
            runSpacing: 20,
            children: List.generate(
              4,
                  (index) => CircleWidget(
                number: index + 1,
                highlighted: highlightedCircles.contains(index + 1),
              ),
            ),
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

  const CircleWidget({Key? key, required this.number, this.highlighted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? Colors.green : Colors.grey,
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
  switch(difficulty) {
    case 'Easy':
      return '1';
    case 'Medium':
      return '2';
    case 'Hard':
      return '3';
  }
  return '';
}
