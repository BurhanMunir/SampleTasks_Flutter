import 'package:flutter/material.dart';
import 'package:sample_tasks/ui/views/signature_view.dart';
import 'package:sample_tasks/ui/views/webview_pdf.dart';

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
      home: WebViewPdf(),
    );
  }
}
