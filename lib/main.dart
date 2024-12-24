import 'package:flutter/material.dart';
import 'package:time_split/views/auth/start_view.dart';
// Yolunu projene göre düzenle

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Split',
      debugShowCheckedModeBanner: false,
      home: const StartView(),
    );
  }
}
