import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:master_diploma/helpers/DatabaseClientModel.dart';

import 'generated/codegen_loader.g.dart';
import 'generated/locale_keys.g.dart';
import 'helpers/DatabaseHelper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ru'),
        assetLoader: const CodegenLoader(),
        child: const MyApp()
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
  late DatabaseHandler handler;

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
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert Dialog'),
            content: const Text(''),
            actions: <Widget> [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                }
              )
            ],
          );
        }
    );
  }

  _textList() {

  }

  Future<int> addTestTextDB() async {
    TextDB text = TextDB(name: 'test', date: '01.01.2001', text: 'test text');
    List<TextDB> listOfText = [text];
    return await handler.insertText(listOfText);
  }

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initDB().whenComplete(() async {
      await addTestTextDB();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget> [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
              )
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => {
            SystemNavigator.pop()
            },
          )
        ],
      ),
      body: const Center(
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
            const DrawerHeader(
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
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('О приложении'),
              onTap: () {
                _aboutWindow();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выход'),
              onTap: () {
                SystemNavigator.pop();
              },
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        shape: const CircleBorder(),
        icon: Icons.menu,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera),
            label: 'Камера',
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onTap: () => _getImagePhoto()
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder),
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
        title: const Text(LocaleKeys.setting_title).tr(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.add_chart),
                    title: const Text(LocaleKeys.setting_choose_language).tr(),
                  ),
                  ListTile(
                    title: const Text(LocaleKeys.setting_russian_language).tr(),
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
                    title: const Text(LocaleKeys.setting_english_language).tr(),
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
                    context.setLocale(const Locale('ru'));
                    Navigator.pop(context);
                  }
                  else {
                    context.setLocale(const Locale('en'));
                    Navigator.pop(context);
                  }
                },
                child: const Text(LocaleKeys.setting_save_button).tr()
            ),
            ElevatedButton(
                onPressed: () {
                  _cancel(context);
                },
                child: const Text(LocaleKeys.setting_cancel_button).tr()
            ),
          ],
        ),
      ),
    );
  }
}
