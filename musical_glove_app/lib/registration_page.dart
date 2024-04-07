import 'package:flutter/material.dart';
import 'text_input.dart';
import 'ble_handler.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String username = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false; // Track loading state

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
      resizeToAvoidBottomInset: false, // Prevent screen resizing when keyboard appears
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(50.0, 40.0, 0.0, 0.0),
                child: Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(0, 176, 143, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(60.0, 16.0, 0.0, 0.0),
                child: Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 18,
                    decorationColor: Color.fromRGBO(13, 13, 13, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InputFields(
              hintText: 'Username',
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(60.0, 16.0, 0.0, 0.0),
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 18,
                    decorationColor: Color.fromRGBO(13, 13, 13, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InputFields(
              hintText: 'Password',
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 100),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(200.0, 135.0, 20.0, 0.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      errorMessage = ''; // Reset error message
                      isLoading = true; // Show spinner
                    });

                    if (_validateInputs(username, password)) {
                      // Send username and password to ESP32
                      String response = await BluetoothHandler.sendUsernameAndPassword('register', username, password);
                      setState(() {
                        isLoading = false; // Hide spinner
                      });
                      if (response == "register_ok") {
                        currentUser = username;
                        // Move to the main menu page
                        Navigator.pushNamed(context, '/songs');
                      } else {
                        // Show error message from server
                        setState(() {
                          errorMessage = response.isNotEmpty ? response : 'Invalid username or password';
                        });
                      }
                    } else {
                      // Show validation error message
                      setState(() {
                        isLoading = false;
                        errorMessage = 'Invalid username or password. Make sure to type only letters and numbers, and that they are not empty';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    padding: const EdgeInsets.all(10), // Padding for the button content
                    elevation: 0, // No shadow
                    backgroundColor: Colors.transparent, // Transparent background color
                    foregroundColor: Colors.white,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(9, 145, 120, 1),
                          Color.fromRGBO(87, 190, 171, 1),
                          Color.fromRGBO(116, 208, 164, 1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      width: 130, // Adjust the width as needed
                      height: 40, // Adjust the height as needed
                      child: isLoading ? const CircularProgressIndicator() : const Text('Next'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs(String username, String password) {
    // Regular expression to match only letters and numbers
    RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');
    RegExp passwordRegex = RegExp(r'^[a-zA-Z0-9]+$');

    if (username.isNotEmpty && password.isNotEmpty) {
      if (!usernameRegex.hasMatch(username)) {
        print('Username can only contain letters and numbers.');
        return false;
      }

      if (!passwordRegex.hasMatch(password)) {
        print('Password can only contain letters and numbers.');
        return false;
      }

      return true;
    }

    return false;
  }
}
