import 'package:flutter/material.dart';
import 'package:image_capture_demo/qs_home_model.dart';
import 'package:image_capture_demo/qs_home_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<MineInviteModel>(
        create: (context) => MineInviteModel(),
        child: SafeArea(top: false, bottom: false, child: QSHomePage()),
      ),
    );
  }
}
