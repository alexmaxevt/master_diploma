import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        '/setting': (BuildContext context) => SettingsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingPageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _getImagePhoto() async {
    File file;
    var picker = ImagePicker();
    XFile? photoPicked = await picker.pickImage(source: ImageSource.camera);
    if (photoPicked == null) return;
    setState(() {
      file = File(photoPicked.path);
    });
  }

  _getImageSrc() async {
    File file;
    var picker = ImagePicker();
    XFile? photoPicked = await picker.pickImage(source: ImageSource.gallery);
    if (photoPicked == null) return;
    setState(() {
      file = File(photoPicked.path);
    });
  }

  _aboutWindow() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert Dialog'),
            content: const Text(''),
            actions: <Widget> [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                }
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => {

            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => {
              SystemNavigator.pop()
            },
          )
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget> [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text(
                'Drawer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Настройки'),
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text('О приложении'),
              onTap: () {
                _aboutWindow();
              },
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        shape: CircleBorder(),
        icon: Icons.menu,
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera),
            label: 'Камера',
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onTap: () => _getImagePhoto()
          ),
          SpeedDialChild(
            child: Icon(Icons.folder),
            label: 'Открыть изображение',
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            onTap: () => _getImageSrc()
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _SettingPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
        leading: IconButton(
          onPressed: () {

          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
    );
  }

}
