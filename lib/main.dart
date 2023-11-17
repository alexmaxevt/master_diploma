import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'generated/codegen_loader.g.dart';
import 'generated/locale_keys.g.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: Locale('ru'),
        assetLoader: CodegenLoader(),
        child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(title: 'OCR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
    XFile? photoPicked = await picker.pickVideo(source: ImageSource.camera);
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
        context: this.context,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
              )
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text('О приложении'),
              onTap: () {
                _aboutWindow();
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Выход'),
              onTap: () {
                SystemNavigator.pop();
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
  int? selectedOption;

  _cancel(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.setting_title).tr(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.add_chart),
                    title: Text(LocaleKeys.setting_choose_language).tr(),
                  ),
                  ListTile(
                    title: Text(LocaleKeys.setting_russian_language).tr(),
                    leading: Radio<int> (
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                      activeColor: Colors.deepOrangeAccent,
                    ),
                  ),
                  ListTile(
                    title: Text(LocaleKeys.setting_english_language).tr(),
                    leading: Radio<int> (
                      value: 2,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                      activeColor: Colors.deepOrangeAccent,
                    ),
                  ),
                ]
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if(selectedOption == 1) {
                    context.setLocale(Locale('ru'));
                    Navigator.pop(context);
                  }
                  else {
                    context.setLocale(Locale('en'));
                    Navigator.pop(context);
                  }
                },
                child: Text(LocaleKeys.setting_save_button).tr()
            ),
            ElevatedButton(
                onPressed: () {
                  _cancel(context);
                },
                child: Text(LocaleKeys.setting_cancel_button).tr()
            ),
          ],
        ),
      ),
    );
  }
}
