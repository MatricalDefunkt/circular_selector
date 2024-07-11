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

  Function(int) testSelected(int selectorIndex) {
    return (index) {
      if (kDebugMode) {
        print('Selected: $index of selector $selectorIndex');
      }
    };
  }

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
            child: Stack(alignment: Alignment.center, children: [
              CircularSelector(
                onSelected: testSelected(0),
                childSize: 30.0,
                radiusDividend: 2.5,
                customOffset: Offset(
                  0.0,
                  AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                circleBackgroundColor: const Color.fromARGB(255, 85, 85, 85),
                children: [
                  Text("SCI"),
                  Text("SST"),
                  Text("ENG"),
                  Text("MRT"),
                  Text("HIN"),
                  Text("EVS")
                ],
              ),
              CircularSelector(
                onSelected: testSelected(1),
                childSize: 30.0,
                radiusDividend: 4,
                customOffset: Offset(
                  0.0,
                  AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                circleBackgroundColor: const Color.fromARGB(255, 170, 170, 170),
                children: [
                  Text("1"),
                  Text("2"),
                  Text("3"),
                  Text("4"),
                  Text("5"),
                  Text("6"),
                  Text("7"),
                  Text("8"),
                  Text("9"),
                  Text("10")
                ],
              ),
              CircularSelector(
                onSelected: testSelected(2),
                childSize: 30.0,
                radiusDividend: 7,
                customOffset: Offset(
                  0.0,
                  AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                circleBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
                children: [Text("SSC"), Text("CBSE")],
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
