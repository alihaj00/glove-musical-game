import 'package:flutter/material.dart';
import 'ble_handler.dart';
import 'text_input.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({Key? key}) : super(key: key);

  @override
  AddSongPageState createState() => AddSongPageState();
}

class AddSongPageState extends State<AddSongPage> {
  String selectedSongName = '';
  String selectedNotes = '';
  TextEditingController notesController = TextEditingController();
  List<String> notes = ['do', 're', 'me', 'fa', 'sol', 'la', 'si', 'Pause'];

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SingleChildScrollView( // Wrap with SingleChildScrollView
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: notes.map((note) => _buildNoteButton(note)).toList(),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: InputFields(
              hintText: 'Song Name',
              onChanged: (value) {
                setState(() {
                  selectedSongName = value;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: InputFields(
              hintText: 'Song Notes',
              onChanged: (value) {
                setState(() {
                  selectedNotes = value;
                });
              },
              controller: notesController,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(9, 145, 120, 1),
                    Color.fromRGBO(87, 190, 171, 1),
                    Color.fromRGBO(116, 208, 164, 1),
                  ], // You can adjust the colors here
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  bool validNotes = validateInputsNotes(selectedNotes);
                  bool validName = validateInputsSongName(selectedSongName);
                  if(validNotes && validName) {
                    String response = await BluetoothHandler.saveSongTOESP(selectedSongName,selectedNotes);
                    if (response == 'save_ok') {
                      // Save button functionality
                      print('Song Name: $selectedSongName');
                      print('Song Notes: $selectedNotes');

                      // Pass back a flag indicating a new song has been added
                      Navigator.pop(context, true);
                    }
                    else {
                      showErrorSnackbar(context, response);
                    }
                  }
                  else if (!validName) {
                    showErrorSnackbar(context, 'Invalid song name. Make sure to type only letters and numbers, and that it is not empty.');
                  }
                  else if (!validNotes) {
                    showErrorSnackbar(context, 'Invalid notes format. The notes should not be just Pause . Also, all notes name separated by comma.');
                  }
                  // Here you can add the functionality to save the song
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background color
                  elevation: 0, // No shadow
                  foregroundColor: Colors.white, // Adjust border radius here
                ),
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  bool validateInputsNotes(String selectedNotes) {
    String toSplit = selectedNotes;
    bool AllPause = true;
    // Check if the string ends with a comma
    if (toSplit.endsWith(',')) {
      // Trim the comma from the end of the string
      toSplit = toSplit.substring(0, toSplit.length - 1);
    }
    final splitted = toSplit.split(",");
    for (int i =0; i < splitted.length; i++) {
      if (!notes.contains(splitted[i]) && splitted[i] != null) {
        return false;
      }
      if (splitted[i] != 'Pause') {
        AllPause = false;
      }
    }
    return !AllPause && true;
  }

  bool validateInputsSongName(String selectedSongName) {
    // Regular expression to match only letters and numbers
    RegExp selectedSongNameeRegex = RegExp(r'^[a-zA-Z0-9]+$');

    if (selectedSongName.isNotEmpty) {
      if (!selectedSongNameeRegex.hasMatch(selectedSongName)) {
        return false;
      }
      return true;
    }

    return false;
  }

  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildNoteButton(String note) {
    return Column(
      children: [
        Container(
          width: 100, // Adjust the width here
          height: 100, // Adjust the height here
          child: IconButton(
            icon: Icon(Icons.music_note, size: 50), // Icon for note button
            onPressed: () {
              BluetoothHandler.sendRequest('play_note_$note', () => setState(() {}));
              setState(() {
                notesController.text += '$note,';
                selectedNotes = notesController.text;
              });
            },
          ),
        ),
        Text(
          note,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
