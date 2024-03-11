import 'package:flutter/material.dart';
import 'dart:convert';
import 'ble_handler.dart';

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
    retrieveStatisticsData();
  }

  Future<void> _sendRequest(String request) async {
    if (characteristic != null) {
      try {
        setState(() {
          isSending = true;
        });
        await characteristic!.write(utf8.encode(request), withoutResponse: true);
        // Wait for a response
        await Future.delayed(Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        setState(() {
          // responseMessage = response;
        });
      } catch (e) {
        print('Failed to send the song: $e');
      } finally {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  void retrieveStatisticsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Send request to ESP to retrieve statistics
      await _sendRequest('get_statistics');

      // Listen to responses from ESP device
      characteristic!.setNotifyValue(true);
      characteristic!.value.listen((value) {
        // Handle response from ESP
        setState(() {
          statisticsData = utf8.decode(value);
          isLoading = false;
        });
      });
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
