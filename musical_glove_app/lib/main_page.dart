import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎵 Musical Glove Game 🎵'),
        backgroundColor: Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Musical 🎵 Glove 🎵 Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[900],
              ),
            ),
            SizedBox(height: 50),
            Image.asset(
              'assets/glove_main_page.jpg', // Adjust the path to match your image file
              width: 350, // Adjust the width as needed
              height: 350, // Adjust the height as needed
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/BT connection');
              },
              child: Text('BT connection'),
            ),
          ],
        ),
      ),
    );
  }
}
