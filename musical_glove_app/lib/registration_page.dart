import 'package:flutter/material.dart';
import 'text_input.dart';
import 'ble_handler.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String username = '';
  String password = '';
  bool hasError = false;
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: const Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InputFields(
              hintText: 'Username',
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
              hasError: hasError,
            ),
            const SizedBox(height: 10),
            InputFields(
              hintText: 'Password',
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              hasError: hasError,
            ),
            if (hasError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Invalid username or password. Make sure to type only letters and numbers, and that they are not empty',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                if (_validateInputs(username, password)) {
                  setState(() {
                    isLoading = true; // Show spinner
                  });
                  // Send username and password to ESP32
                  String response = await BluetoothHandler.sendUsernameAndPassword('register' ,username, password);
                  setState(() {
                    isLoading = false; // Hide spinner
                  });
                  print(response);
                  if (response == "register_ok") {
                    // Move to the main menu page
                    Navigator.pushNamed(context, '/songs');
                  } else {
                    // Show error message or handle incorrect credentials
                    setState(() {
                      hasError = true;
                    });
                  }
                } else {
                  setState(() {
                    hasError = true;
                  });
                }
              },
              child: isLoading ? const CircularProgressIndicator() : const Text('Registration'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
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