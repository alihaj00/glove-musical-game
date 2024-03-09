import 'package:flutter/material.dart';
import 'text_input.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
            SizedBox(height: 10),
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
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Invalid username or password',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                if (_validateInputs(username, password)) {
                  Navigator.pushNamed(context, '/main menu');
                } else {
                  setState(() {
                    hasError = true;
                  });
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
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
