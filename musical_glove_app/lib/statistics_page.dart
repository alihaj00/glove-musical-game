import 'package:flutter/material.dart';
// import 'bt_handler.dart'; // Import your BT handler here

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String statisticsData = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Retrieve statistics data from BT handler
    retrieveStatisticsData();
  }

  void retrieveStatisticsData() {
    // Replace this with your BT handler logic to retrieve statistics
    // For demonstration purposes, we're just showing 'Loading...'
    setState(() {
      isLoading = true;
    });

    // Simulate loading statistics data from BT handler
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        statisticsData = 'Statistics data retrieved successfully!';
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show spinner if loading
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(statisticsData),
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
}
