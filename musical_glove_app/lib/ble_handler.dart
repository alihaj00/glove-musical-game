import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

final FlutterBlue flutterBlue = FlutterBlue.instance;
BluetoothDevice? esp32Device;
BluetoothCharacteristic? characteristic;
bool isSending = false;

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState
    extends State<BluetoothDeviceListScreen> {

  String responseMessage = '';
  bool isScanning = false;
  List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scanForDevices() async {
    esp32Device = null;
    isScanning = true;
    devicesList.clear(); // Clear the list of discovered devices
    setState(() {});

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == 'ESP32') {
          setState(() {
            esp32Device = r.device;
            isScanning = false;
          });
          break;
        } else {
          if (!devicesList.contains(r.device)) {
            setState(() {
              devicesList.add(r.device);
            });
          }
        }
      }
    });

    // Stop scanning after 10 seconds
    await Future.delayed(Duration(seconds: 10));
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
        service.characteristics.forEach((characteristics) {
          if (characteristics.properties.write) {
            characteristic = characteristics;
          }
        });
      });
      characteristic?.setNotifyValue(true);
      var stream = characteristic?.value.listen((event) {
          print(event[0]);
        }
      );
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
          if (devicesList.isNotEmpty)
            Column(
              children: [
                Text(
                  'Other available devices:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: devicesList.length,
                  itemBuilder: (context, index) {
                    String deviceName = devicesList[index].name.isEmpty ? 'Unknown device' : devicesList[index].name;
                    return ListTile(
                      title: Text(deviceName),
                      subtitle: Text(devicesList[index].id.toString()),
                      onTap: () {
                        _connectToDevice(devicesList[index]);
                      },
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
