import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_handler.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  var statisticsData = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    retrieveStatisticsData();
  }

  void retrieveStatisticsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Ensure that characteristic is available
      if (characteristic != null) {
        // Send request to ESP to retrieve statistics
        await BluetoothHandler.sendRequest('get_statistics', () => setState(() {}));

        // Listen to responses from ESP device
        characteristic!.setNotifyValue(true);
        characteristic!.value.listen((value) {
          // Handle response from ESP
          setState(() {
            statisticsData = value[0].toString();
            isLoading = false;
          });
        });
      } else {
        print('Characteristic is not available');
      }
    } catch (e) {
      print('Failed to retrieve statistics data: $e');
      setState(() {
        statisticsData = 'Failed to retrieve statistics data';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        backgroundColor: Color(0xFF073050),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Latest Score - " + statisticsData),
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
