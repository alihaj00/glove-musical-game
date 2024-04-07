import 'dart:async';
import 'package:flutter/material.dart';
import 'ble_handler.dart';
import 'dart:convert';

class FreeTrialPage extends StatefulWidget {
  const FreeTrialPage({Key? key}) : super(key: key);

  @override
  _FreeTrialPageState createState() => _FreeTrialPageState();
}

class _FreeTrialPageState extends State<FreeTrialPage> {
  String formerdata = '';
  List<int>? highlighted = [-1];

  @override
  void initState() {
    super.initState();
    receiveNotesFromESP();
  }

  void receiveNotesFromESP() async {
    bool firsttime = true;
    await BluetoothHandler.setupNotifications();
    BluetoothHandler.getCharacteristicStream().listen((List<int> data) {
      if (!firsttime) {
        String receiveddata = utf8.decode(data);
        if (receiveddata != formerdata) {
          setState(() {
            highlighted = [-1];
          });
          setState(() {
            highlighted = MapNoteIndexes(receiveddata);
          });
        }
        formerdata = receiveddata;
      }
      firsttime = false;
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
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Free Trial',
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(105, 105, 105, 1),
                                  fontFamily: 'LeckerliOne'
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info),
                              iconSize: 32,
                              color: Color.fromRGBO(105, 105, 105, 1),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Information'),
                                      content: const SingleChildScrollView(
                                        child: Text(
                                          'This is a free trial, so you may freely try to use the glove. To play a note, touch your thumb with 1 or 2 fingers (just like in the logo!)\n\n'
                                              'In the game, the fingers to touch will be highlighted in blue.\n\n'
                                              'You will have limited time to touch - a progress bar for each touch will appear at the top.\n\n'
                                              'Good Luck, and...\n May The Glove Be With You!',
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              'assets/glove_gameplay.jpg',
              width: MediaQuery.of(context).size.width *
                  0.9, // Set width to screen width
              height: 600, // Adjust the height as needed
              fit: BoxFit.fill, // Ensure the image fills the width of the screen
            ),
          ),
        ],
      ),
    );
  }
}

class CircleWidget extends StatefulWidget {
  final int number;
  final bool highlighted;

  CircleWidget({Key? key, required this.number, this.highlighted = false})
      : super(key: key);

  @override
  _CircleWidgetState createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.highlighted ? Colors.blue : Colors.grey,
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

List<int>? MapNoteIndexes(String note) {
  Map<String, List<int>> NotesToIndexes = {
    'do': [0],
    're': [0, 1],
    'me': [1],
    'fa': [1, 2],
    'sol': [2],
    'la': [2, 3],
    'si': [3],
  };
  for (var noteKey in NotesToIndexes.keys) {
    if (note.contains(noteKey)) {
      return NotesToIndexes[noteKey];
    }
  }
  return [];
}
