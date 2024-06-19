import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:circular_selector/circular_selector.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circular Selector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Circular Selector Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    GlobalKey circularSelectorGlobalKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: CircularSelector(
            onSelected: (int index) {
              if (kDebugMode) {
                print('Selected: $index');
              }
            },
            customOffset: const Offset(0.0, 30.0),
            childSize: 50.0,
            radiusDividend: 2.5,
            key: circularSelectorGlobalKey,
            children: CircularSelector.getTestContainers(8, 50.0),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('CircularSelector test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify initial state
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);

    final text1InitialPosition = tester.getCenter(find.text("1"));
    final text4InitialPosition = tester.getCenter(find.text("4"));

    // Tap on the '4' text
    await tester.tapAt(tester.getCenter(find.text("4")));

    // Allow the animation to proceed and intermediate frames to be processed
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Retrieve final positions after animation
    final text1FinalPosition = tester.getCenter(find.text("1"));
    final text4FinalPosition = tester.getCenter(find.text("4"));

    // LABEL 1: Tests if the initial position of text1 is equal to the final position of text4.
    expect(text1InitialPosition, equals(text4FinalPosition),
        reason: 'Text positions are not equal');

    // Tests if the initial position of text1 is not equal to the final position of text1.
    expect(text1InitialPosition, isNot(equals(text1FinalPosition)),
        reason: 'Text positions are equal');

    // Tests if the initial position of text4 is not equal to the final position of text4.
    expect(text4InitialPosition, isNot(equals(text4FinalPosition)),
        reason: 'Text positions are equal');

    // Passed all tests
  });
}
