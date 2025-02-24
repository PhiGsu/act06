import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    // Provide the model to all widgets within the app. We're using
    // ChangeNotifierProvider because that's a simple way to rebuild
    // widgets when a model changes. We could also just use
    // Provider, but then we would have to listen to Counter ourselves.
    //
    // Read Provider's docs to learn about all the available providers.
    ChangeNotifierProvider(
      // Initialize the model in the builder. That way, Provider
      // can own Counter's lifecycle, making sure to call `dispose`
      // when not needed anymore.
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

/// Simplest possible model, with just one field.
///
/// [ChangeNotifier] is a class in `flutter:foundation`. [Counter] does
/// _not_ depend on Provider.
class Counter with ChangeNotifier {
  int value = 0;
  String message = "You're a child!";
  Color background = Colors.lightBlue;

  void increment(int change) {
    if (value + change < 0 || value + change > 99) return;
    value += change;

    _updateProperties();
    notifyListeners();
  }

  void setValue(int newValue) {
    value = newValue;
    _updateProperties();
    notifyListeners();
  }

  void _updateProperties() {
    if (value < 13) {
      message = "You're a child!";
      background = Colors.lightBlue;
    } else if (value < 20) {
      message = "Teenager time!";
      background = Colors.lightGreen;
    } else if (value < 31) {
      message = "You're a young adult!";
      background = Colors.yellow;
    } else if (value < 51) {
      message = "You're an adult now!";
      background = Colors.orange;
    } else {
      message = "Golden years!";
      background = Colors.grey;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Counter>(
        builder: (context, counter, child) => Scaffold(
              backgroundColor: counter.background,
              appBar: AppBar(
                title: const Text('Age Counter'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(counter.message),
                    Text("I am ${counter.value} years old",
                        style: Theme.of(context).textTheme.headlineMedium),
                    FloatingActionButton(
                        onPressed: () {
                          // You can access your providers anywhere you have access
                          // to the context. One way is to use Provider.of<Counter>(context).
                          // The provider package also defines extension methods on the context
                          // itself. You can call context.watch<Counter>() in a build method
                          // of any widget to access the current state of Counter, and to ask
                          // Flutter to rebuild your widget anytime Counter changes.
                          //
                          // You can't use context.watch() outside build methods, because that
                          // often leads to subtle bugs. Instead, you should use
                          // context.read<Counter>(), which gets the current state
                          // but doesn't ask Flutter for future rebuilds.
                          //
                          // Since we're in a callback that will be called whenever the user
                          // taps the FloatingActionButton, we are not in the build method here.
                          // We should use context.read().
                          var counter = context.read<Counter>();
                          counter.increment(1);
                        },
                        child: const Text("Increase Age")),
                    FloatingActionButton(
                      onPressed: () {
                        counter.increment(-1);
                      },
                      child: const Text("Reduce Age")),
                    Slider(
                      min: 0,
                      max: 99,
                      value: counter.value.toDouble(),
                      onChanged: (x) => counter.setValue(x.toInt()),
                      activeColor: getProgressBarColor(counter.value),
                    )
                    // Consumer looks for an ancestor Provider widget
                    // and retrieves its model (Counter, in this case).
                    // Then it uses that model to build widgets, and will trigger
                    // rebuilds if the model is updated.
                  ],
                ),
              ),
            ));
  }

  Color getProgressBarColor(int value) {
    if (value < 34) {
      return Colors.green;
    } else if (value < 67) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
