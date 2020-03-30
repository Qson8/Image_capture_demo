import 'package:flutter/material.dart';
import 'package:image_capture_demo/qs_home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QSHomePage(),
    );
  }
}
