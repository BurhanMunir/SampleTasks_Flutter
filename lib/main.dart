import 'package:flutter/material.dart';
import 'package:sample_tasks/ui/views/adress_view_map.dart';
import 'package:sample_tasks/ui/views/audio_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioPage(),
    );
  }
}
