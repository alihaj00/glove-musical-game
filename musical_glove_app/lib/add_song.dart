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
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      notesController.text += notes[index] + ",";
                      selectedNotes = notesController.text;
                    });
                  },
                  child: Text(notes[index]),
                );
              },
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
    selectedNotes = selectedNotes + "finish";
    final splitted = selectedNotes.split(",");
    if (splitted[splitted.length-1] != "finish") {
      return false;
    }
    for (int i =0; i< splitted.length-1; i++) {
      if (!notes.contains(splitted[i]) && splitted[i] != null) {
        return false;
      }
    }
    return true;
  }
}

void main() {
  runApp(MaterialApp(
    home: AddSongPage(),
  ));
}
