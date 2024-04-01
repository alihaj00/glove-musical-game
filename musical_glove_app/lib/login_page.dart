import 'package:flutter/material.dart';
import 'text_input.dart';
import 'ble_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  bool hasError = false;
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
                  'Invalid username or password',
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
                  String response = await BluetoothHandler.sendUsernameAndPassword('login' ,username, password);
                  setState(() {
                    isLoading = false; // Hide spinner
                  });
                  if (response == "login_ok") {
                  // if (true) {
                    // Move to the main menu page
                    Navigator.pushNamed(context, '/main menu');
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
    // Implement your validation logic here
    if (username.isNotEmpty && password.isNotEmpty) {
      return true;
    }
    return false;
  }
}
