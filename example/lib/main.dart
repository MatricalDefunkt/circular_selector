import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:circular_selector/circular_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circular Selector Demo',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Circular Selector Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CircularSelector(
              onSelected: (int index) {
                if (kDebugMode) {
                  print('Selected: $index');
                }
              },
              childSize: 30.0,
              radiusDividend: 2.5,
              customOffset: Offset(
                0.0,
                AppBar().preferredSize.height,
              ),
              children: CircularSelector.getTestContainers(20, 30.0),
            ),
          ),
        ]),
      ),
    );
  }
}
