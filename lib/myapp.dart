//myapp.dart
import 'package:flutter/material.dart';
import 'package:9-10TeamBuilderApp/page/home.dart';
import 'package:9-10TeamBuilderApp/page/playerselection.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'pokemon'),
    );
  }
}
