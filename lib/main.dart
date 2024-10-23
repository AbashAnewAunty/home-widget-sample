import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String prefKey1 = "textList";

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final now = DateTime.now();
    final text1 = now.toString();
    final text2 = "background task: $task"; //simpleTask will be emitted here.
    final pref = await SharedPreferences.getInstance();
    final textList = pref.getStringList(prefKey1) ?? [];
    textList.add("------");
    textList.add(text1);
    textList.add(text2);
    await pref.setStringList(prefKey1, textList);
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: workdmanger初期化は非同期しないと動作しない
  await Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true,
  );
  await Workmanager().registerOneOffTask("be.tramckrijte.workmanagerExample.taskId", "simpleTask");
  await Workmanager().registerOneOffTask("be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", "simpleTask2");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  List<String> _textList = ['befor initState'];
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
    final textList = prefs.getStringList(prefKey1) ?? ["text is empty"];
    _counter = initCount ?? 0;

    final now = DateTime.now();
    final text1 = now.toString();
    final text2 = "appStart: $text1";
    textList.add("--------");
    textList.add(text2);
    prefs.setStringList(prefKey1, textList);
    _textList = [...textList];
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: _textList.length,
                          itemBuilder: (context, index) {
                            return Text(
                              _textList[index],
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ),
                  )
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
