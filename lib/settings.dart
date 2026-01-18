import 'dart:math';

import 'package:flutter/material.dart';
import 'constants.dart';
import 'data.dart';

class SettingsPage extends StatefulWidget {
  final Cache cache;

  const SettingsPage({super.key, required this.cache});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, TextEditingController> _controllers = {
    'host-ip': TextEditingController(text: 'localhost:5050'),
    // 'port': TextEditingController(text: '5000'),
  };
  bool loading = false;
  bool success = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getHost() {
    final ip = _controllers['host-ip']?.text;
    // final port = _controllers['port']?.text;
    return '$ip';
  }

  void _uploadData() async {
    setState(() {
      loading = true;
      success = false;
    });

    bool resp = false;
    final host = _getHost();

    if (host.isEmpty) {
      print("Host ID is empty. Cannot upload data.");
      return;
    } else {
      print("Uploading data to host: $host");
      final response = await widget.cache.getDataLoader().savePlansToHost(host);
      resp = response["success"] ?? false;
      errorMessage = response["message"] ?? "";
    }
    setState(() {
      loading = false;
      success = resp;
    });
  }

  void _downloadData() async {
    setState(() {
      loading = true;
      success = false;
    });

    final host = _getHost();
    bool resp = false;

    if (host.isEmpty) {
      print("Host ID is empty. Cannot download data.");
      return;
    } else {
      print("Downloading data from host: $host");
      resp = await widget.cache.loadDataFromHost(host);
    }

    setState(() {
      loading = false;
      success = resp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: gradientStart,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final Map<String, String> values = {
              for (var entry in _controllers.entries)
                entry.key: entry.value.text,
            };
            Navigator.of(context).pop(values);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    final label = _controllers.keys.elementAt(index);
                    final controller = _controllers[label]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Label Column
                          Expanded(
                            flex: 2,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // Input Field Column
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.upload,
                          color: loading ? Colors.grey : textColor),
                      onPressed: loading ? null : () => _uploadData(),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.download,
                          color: loading ? Colors.grey : textColor),
                      onPressed: loading ? null : () => _downloadData(),
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : (success
                            ? const Icon(Icons.check_circle, color: textColor)
                            : IconButton(
                                icon: const Icon(Icons.error, color: textColor),
                                onPressed: () {
                                  final snackBar = SnackBar(
                                    content: Text(errorMessage.isNotEmpty
                                        ? errorMessage
                                        : 'Operation failed. Please try again.'),
                                    backgroundColor: Colors.red,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                              )),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    // Return the entered values as a dictionary
                    final Map<String, String> values = {
                      for (var entry in _controllers.entries)
                        entry.key: entry.value.text,
                    };
                    Navigator.of(context).pop(values);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientStart,
                  ),
                  child: const Text('Save Settings'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


Future<Map<String, String>> openSettings(BuildContext context, cache) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SettingsPage(cache: cache),
    ),
  );

  if (result != null && result is Map<String, String>) {
    print('Settings updated: $result');
  }

  return result ?? {};
}
