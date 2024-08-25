import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device ID Sender',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _deviceId = '';
  String _responseMessage = '';
  String _message = '';

  Future<void> _sendDeviceIdToSlack() async {
    String? deviceId;
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    const androidId = AndroidId();

    if (Theme.of(context).platform == TargetPlatform.android) {
      deviceId = await androidId.getId();
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      deviceId = (await deviceInfo.iosInfo).identifierForVendor;
    } else {
      deviceId = 'Unsupported platform';
    }

    String platformName = Theme.of(context).platform.toString().split('.').last;
    const String webhookUrl =
        'https://hooks.slack.com/services/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';

    final String message =
        'Platform: $platformName\nDevice ID: $deviceId\nUserId: {유저 이메일}';

    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': message}),
      );

      setState(() {
        _deviceId = deviceId ?? 'Unknown';
        _message = message;
        _responseMessage = response.statusCode == 200
            ? 'Message sent success'
            : 'Failed to send: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message Test to Slack'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_deviceId.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device ID:',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(_deviceId, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  Text('Message Sent:',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(_message, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                ],
              ),
            ElevatedButton(
              onPressed: _sendDeviceIdToSlack,
              child: const Text('Send Message to Slack'),
            ),
            const SizedBox(height: 20),
            if (_responseMessage.isNotEmpty)
              Text(
                _responseMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
