import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState extends State<BluetoothDeviceListScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  Future<void> _scanForDevices() async {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });

    // Stop scanning after 4 seconds
    await Future.delayed(Duration(seconds: 4));
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Musical Gloves'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _scanForDevices,
            child: Text('Connect'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name ?? 'Unknown device'),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () {
                    // Handle device selection here
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}