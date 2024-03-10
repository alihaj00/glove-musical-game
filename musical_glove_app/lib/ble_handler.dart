import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState
    extends State<BluetoothDeviceListScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? esp32Device;
  BluetoothCharacteristic? characteristic;
  bool isSending = false;
  String responseMessage = '';
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scanForDevices() async {
    esp32Device = null;
    isScanning = true;
    setState(() {});

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == 'ESP32_BT') {
          setState(() {
            esp32Device = r.device;
            isScanning = false;
          });
          break;
        }
      }
    });

    // Stop scanning after 4 seconds
    await Future.delayed(Duration(seconds: 4));
    flutterBlue.stopScan();
    if (esp32Device == null) {
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.properties.write) {
            this.characteristic = characteristic;
          }
        });
      });
    } catch (e) {
      print('Failed to connect to the device: $e');
    }
  }

  Future<void> _sendHello() async {
    if (characteristic != null) {
      try {
        setState(() {
          isSending = true;
        });
        await characteristic!.write(utf8.encode('hello'), withoutResponse: true);
        // Wait for a response
        await Future.delayed(Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        setState(() {
          responseMessage = response;
        });
      } catch (e) {
        print('Failed to send hello: $e');
      } finally {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _scanForDevices,
              child: Text('Scan'),
            ),
          ),
          SizedBox(height: 20),
          if (isScanning)
            CircularProgressIndicator()
          else if (esp32Device == null)
            Text('The ESP is not found')
          else
            Column(
              children: [
                ListTile(
                  title: Text(
                    esp32Device!.name ?? 'Unknown device',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(esp32Device!.id.toString()),
                  trailing: StreamBuilder<BluetoothDeviceState>(
                    stream: esp32Device!.state,
                    initialData: BluetoothDeviceState.disconnected,
                    builder: (context, snapshot) {
                      if (snapshot.data == BluetoothDeviceState.connected) {
                        return Icon(Icons.bluetooth_connected, color: Colors.green);
                      } else {
                        return Icon(Icons.bluetooth_disabled, color: Colors.red);
                      }
                    },
                  ),
                  onTap: () {
                    _connectToDevice(esp32Device!);
                  },
                ),
                if (characteristic != null)
                  ElevatedButton(
                    onPressed: isSending ? null : _sendHello,
                    child: Text('Send Hello'),
                  ),
                if (responseMessage.isNotEmpty)
                  Text('Response: $responseMessage'),
              ],
            ),
        ],
      ),
    );
  }
}
