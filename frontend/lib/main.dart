import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(JagaDiriApp());
}

class JagaDiriApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jaga Diri Digital',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MoodCheckScreen(),
    );
  }
}

class MoodCheckScreen extends StatefulWidget {
  @override
  _MoodCheckScreenState createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    scheduleDailyNotification();
  }

  Future<void> sendMood(String mood) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/mood'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mood": mood}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _recommendations = List<String>.from(data["recommendations"]);
      });
    }
  }

  void scheduleDailyNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_mood_check',
      'Daily Mood Check',
      channelDescription: 'Notifikasi harian untuk isi mood kamu',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Hai, bagaimana perasaanmu hari ini?',
      'Yuk, isi mood kamu di Jaga Diri Digital',
      const Time(8, 0, 0),
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cek Mood Harian')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Bagaimana perasaanmu hari ini?"),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Contoh: senang, sedih, stres",
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                sendMood(_controller.text);
              },
              child: Text("Kirim Mood"),
            ),
            SizedBox(height: 20),
            Text("Rekomendasi Aktivitas:", style: TextStyle(fontWeight: FontWeight.bold)),
            ..._recommendations.map((r) => ListTile(title: Text(r))).toList(),
          ],
        ),
      ),
    );
  }
}
