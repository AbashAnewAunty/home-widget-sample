import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    // hello, world
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isLoading = false;

  late Future<void> _init;

  void _incrementCounter() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    await prefs.setInt('count', _counter);

    setState(() {
      _isLoading = false;
    });
  }

  void _clearCounter() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = 0;
    });
    await prefs.setInt('count', 0);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final initCount = prefs.getInt('count');
    _counter = initCount ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _init = _initCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            onPressed: _clearCounter,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder(
          future: _init,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done || _isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
