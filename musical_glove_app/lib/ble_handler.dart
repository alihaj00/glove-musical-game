import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'dart:async';
BluetoothDevice? esp32Device;
BluetoothCharacteristic? characteristic;
bool isSending = false;
String responseMessage = ''; // Static variable for response message
Function? setStateCallback;

class BluetoothHandler {
  static Future<void> connectToDevice(
      BluetoothDevice device, Function setState) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristics in service.characteristics) {
          if (characteristics.properties.write) {
            characteristic = characteristics;
          }
        }
      }
      characteristic?.setNotifyValue(true);
      setState();
    } catch (e) {
      print('Failed to connect to the device: $e');
    }
  }

  static Future<void> sendHello(Function setState) async {
    if (characteristic != null) {
      try {
        isSending = true;
        await characteristic!
            .write(utf8.encode('hello'), withoutResponse: true);
        // Wait for a response
        await Future.delayed(const Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        print(response);
        setState();
      } catch (e) {
        print('Failed to send hello: $e');
      } finally {
        isSending = false;
      }
    }
  }

  static Future<void> sendSongToESP(
      String selectedSong, String action, Function setState) async {
    if (characteristic != null) {
      try {
        isSending = true;
        await characteristic!
            .write(utf8.encode("${selectedSong}_$action"), withoutResponse: true);
        // Wait for a response
        await Future.delayed(const Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        print(response);
      } catch (e) {
        print('Failed to send the song: $e');
      } finally {
        isSending = false;
        setState();
      }
    }
  }

  static Future<void> sendRequest(
      String request, Function setState) async {
    if (characteristic != null) {
      try {
        isSending = true;
        await characteristic!
            .write(utf8.encode(request), withoutResponse: true);
        // Wait for a response
        await Future.delayed(const Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        print(response);
        setState();
      } catch (e) {
        print('Failed to send the request: $e');
      } finally {
        isSending = false;
      }
    }
  }

  static Future<String> sendUsernameAndPassword(String action,
      String username, String password) async {
    if (characteristic != null) {
      try {
        isSending = true;
        // Create a Map to organize data
        Map<String, dynamic> requestData = {
          'action': action,
          'username': username,
          'password': password,
        };
        // Convert the Map to JSON
        String jsonData = jsonEncode(requestData);
        await characteristic!.write(utf8.encode(jsonData), withoutResponse: true);
        // Wait for a response
        await Future.delayed(const Duration(seconds: 2));
        String response = utf8.decode(await characteristic!.read());
        return response.trim();
      } catch (e) {
        print('Failed to send username and password: $e');
        return ''; // Return empty response on failure
      } finally {
        isSending = false;
      }
    } else {
      return ''; // Return empty response if characteristic is null
    }
  }
}

class BluetoothDeviceListScreen extends StatefulWidget {
  const BluetoothDeviceListScreen({super.key});

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

    FlutterBlue flutterBlue = FlutterBlue.instance;

    flutterBlue.startScan(timeout: const Duration(seconds: 4));

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
    await Future.delayed(const Duration(seconds: 10));
    flutterBlue.stopScan();
    if (esp32Device == null) {
      setState(() {
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _scanForDevices,
              child: const Text('Scan'),
            ),
          ),
          const SizedBox(height: 20),
          if (isScanning)
            const CircularProgressIndicator()
          else if (esp32Device == null)
            const Text('The ESP is not found')
          else
            Column(
              children: [
                ListTile(
                  title: Text(
                    esp32Device!.name,
                    style: const TextStyle(
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
                        return const Icon(Icons.bluetooth_connected, color: Colors.green);
                      } else {
                        return const Icon(Icons.bluetooth_disabled, color: Colors.red);
                      }
                    },
                  ),
                  onTap: () {
                    BluetoothHandler.connectToDevice(
                        esp32Device!, () => setState(() {}));
                  },
                ),
                if (characteristic != null)
                  ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () => BluetoothHandler.sendHello(() => setState(() {})),
                    child: const Text('Send Hello'),
                  ),
                if (responseMessage.isNotEmpty)
                  Text('Response: $responseMessage'),
              ],
            ),
          if (devicesList.isNotEmpty)
            Column(
              children: [
                const Text(
                  'Other available devices:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: devicesList.length,
                  itemBuilder: (context, index) {
                    String deviceName = devicesList[index].name.isEmpty
                        ? 'Unknown device'
                        : devicesList[index].name;
                    return ListTile(
                      title: Text(deviceName),
                      subtitle: Text(devicesList[index].id.toString()),
                      onTap: () {
                        BluetoothHandler.connectToDevice(devicesList[index],
                                () => setState(() {}));
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
