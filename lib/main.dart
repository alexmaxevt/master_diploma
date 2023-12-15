import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPage();
}

class _MyHomePageState extends State<MyHomePage> {
  int cardCount = 0;
  List<int> idList = [];
  List<String> idListString = [];
  List<String> nameList = [];
  List<String> dateList = [];
  List<String> textList = [];
  late DatabaseHandler handler;

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

  Future<List<int>> getId() async {
    List<TextDB> content = await handler.selectText();
    content.forEach((element) {
      int? id = element.id;
      String idValue = '#${element.id}';
      if(id != null)
      {
        idList.add(id);
        idListString.add(idValue);
      }
    });
    return idList;
  }

  Future<List<String>> getName() async {
    List<TextDB> content = await handler.selectText();
    content.forEach((element) {
      String name = element.name;
      nameList.add(name);
    });
    return nameList;
  }

  Future<List<String>> getDate() async {
    List<TextDB> content = await handler.selectText();
    content.forEach((element) {
      String date = element.date;
      dateList.add(date);
    });
    return dateList;
  }

  Future<List<String>> getText() async {
    List<TextDB> content = await handler.selectText();
    content.forEach((element) {
      String text = element.text;
      textList.add(text);
    });
    return textList;
  }

  Future<void> addTestTextDB() async {
    TextDB text = TextDB(id: 0, name: 'test', date: '01.01.2001', text: 'test text');

    return await handler.insertText(text);
  }

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initDB().whenComplete(() async {
      await addTestTextDB();
      await getId();
      await getName();
      await getDate();
      await getText();
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
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: idList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 4.0,
            child: Column(
              children: [
                ListTile(
                  title: Text(idListString[index]),
                  subtitle: Text(nameList[index]),
                ),
                Container(
                  height: 50.0,
                  child: Stack(
                    children: [
                      Text('Дата:'),
                      Text(dateList[index])
                    ],
                  ),
                ),
                Container(
                  child: Text(textList[index]),
                ),
              ],
            ),
          );
      }),
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
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage())
              )
            }
          ),
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

class _ScanPage extends State<ScanPage> {
  String text = "";
  String name = 'text';
  final now = DateTime.now();
  final StreamController<String> controller = StreamController<String>();
  late DatabaseHandler handler;

  void setText(value) {
    controller.add(value);
  }

  Future<void> addTextToDB(String name, String date, String textOCR) {
    handler = DatabaseHandler();
    TextDB text = TextDB(name: name, date: date, text: textOCR);

    return handler.initDB().whenComplete(() async {
      await handler.insertText(text);
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Распознание текста'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ScalableOCR(
                paintboxCustom: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4.0
                  ..color = const Color.fromARGB(153, 102, 160, 241),
                boxLeftOff: 5,
                boxBottomOff: 2.5,
                boxRightOff: 5,
                boxTopOff: 2.5,
                boxHeight: MediaQuery.of(context).size.height / 3,
                getScannedText: (value) {
                  setText(value);
                }
            ),
            StreamBuilder<String>(
              stream: controller.stream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                text = snapshot.data != null ? snapshot.data! : "";
                return Result(text: snapshot.data != null ? snapshot.data! : "");
              },
            ),
            ElevatedButton(
                onPressed: () {
                  addTextToDB(name, now.toString(), text);
                  Fluttertoast.showToast(
                    msg: 'Данные добавлены в БД',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                },
                child: Text('Готово')
            )
          ],
        ),
      ),
    );
  }
}

class Result extends StatelessWidget {
  const Result({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text("Readed text: $text");
  }
}