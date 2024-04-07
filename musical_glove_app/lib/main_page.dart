import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome To',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                fontFamily: 'TTNorms'
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Musical Glove',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(0, 176, 143, 1),
                fontFamily: 'LeckerliOne'
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/glove_main_page.jpg', // Adjust the path to match your image file
              width: 350, // Adjust the width as needed
              height: 350, // Adjust the height as needed
            ),
            const SizedBox(height: 40),
            FractionallySizedBox(
              widthFactor: 0.9, // Adjust this value as needed for the desired width
              child: Container(
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
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the button
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Transparent background color
                      elevation: 0, // No shadow
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Login'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.9, // Adjust this value as needed for the desired width
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(177, 177, 179, 1),
                      Color.fromRGBO(191, 191, 191, 1),
                      Color.fromRGBO(158, 164, 177, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the button
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Transparent background color
                      elevation: 0, // No shadow
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Register'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.9, // Adjust this value as needed for the desired width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/BT connection');
                },
                child: const Text('Connect To Glove'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
