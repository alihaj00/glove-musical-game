import 'package:flutter/material.dart';
import 'text_input.dart';
import 'ble_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  errorMessage = ''; // Reset error message
                  isLoading = true; // Show spinner
                });

                if (_validateInputs(username, password)) {
                  // Send username and password to ESP32
                  String response = await BluetoothHandler.sendUsernameAndPassword('login', username, password);
                  setState(() {
                    isLoading = false; // Hide spinner
                  });
                  if (response == "login_ok") {
                  // if (true) {
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
              child: isLoading ? const CircularProgressIndicator() : const Text('Login'),
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
