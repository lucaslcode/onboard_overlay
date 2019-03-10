import 'dart:async';
import 'package:flutter/material.dart';
import 'onboard_overlay.dart';

void main() => runApp(App());

class App extends StatelessWidget {
@override
Widget build(BuildContext context) => MaterialApp(
home: Home(),
);
}

class Home extends StatefulWidget {
@override
_HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
List<OnboardStep> steps;
StreamController proceed;
int _i = 0;

void initState() {
super.initState();
proceed = StreamController();
steps = [
OnboardStep(key: GlobalKey(), label: "Tap to continue"),
OnboardStep(
key: GlobalKey(),
label: "Tap FAB to increment & continue",
shape: CircleBorder(),
tappable: false,
proceed: proceed.stream,
),
OnboardStep(key: GlobalKey(), label: "Customizable"),
OnboardStep(key: GlobalKey(), label: "Add to any Widget"),
];
WidgetsBinding.instance
.addPostFrameCallback((_) => onboard(steps, context));
}

@override
void dispose() {
proceed.close();
super.dispose();
}

void _increment() {
setState(() {
_i++;
});
proceed.add(null);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(key: steps[3].key),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: <Widget>[
Text(
'You have pushed the button this many times:',
key: steps[0].key,
),
Text(
'$_i',
key: steps[2].key,
style: TextStyle(fontSize: 28),
),
],
),
),
floatingActionButton: FloatingActionButton(
key: steps[1].key,
onPressed: _increment,
child: Icon(Icons.add),
),
);
}
}
