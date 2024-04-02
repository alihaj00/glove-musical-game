import 'package:flutter/material.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({Key? key}) : super(key: key);

  @override
  AddSongPageState createState() => AddSongPageState();
}

class AddSongPageState extends State<AddSongPage> {
  String selectedSongName = '';
  String selectedNotes = '';
  TextEditingController notesController = TextEditingController();
  List<String> notes = ['do', 're', 'me', 'fa', 'sol', 'la', 'ci', 'Pause'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Song'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: IconButton(
                          icon: Icon(Icons.music_note, size: 50), // Icon for note button
                          onPressed: () {
                            setState(() {
                              notesController.text += notes[index] + ",";
                              selectedNotes = notesController.text;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          notes[index],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Song Name',
              ),
              onChanged: (value) {
                setState(() {
                  selectedSongName = value;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Song Notes',
              ),
              controller: notesController,
              onChanged: (value) {
                setState(() {
                  selectedNotes  = value;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                if(validateInputsNotes(selectedNotes)) {
                  // Save button functionality
                  print('Song Name: $selectedSongName');
                  print('Song Notes: $selectedNotes');
                }
                else {
                  print('Invalid notes format. Please be rigorous about notes name separated by comma');
                }
                // Here you can add the functionality to save the song
              },
              child: Text('Save'),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  bool validateInputsNotes(String selectedNotes) {
    String toSplit = selectedNotes;
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
    }
    return true;
  }
}

