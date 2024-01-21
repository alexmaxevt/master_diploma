import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master_diploma/helpers/DatabaseClientModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cr_file_saver/file_saver.dart';

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

class SelectAndRecognizeImage extends StatefulWidget {
  const SelectAndRecognizeImage({super.key});

  @override
  State<StatefulWidget> createState() => _SelectAndRecognizeImage();
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
            title: const Text(LocaleKeys.about_title).tr(),
            content: const Text(LocaleKeys.about_text).tr(),
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
      backgroundColor: Colors.lightGreen,
      body:RefreshIndicator(
        onRefresh: () async {
          Completer<Null> completer = Completer<Null>();
          await Future.delayed(const Duration(seconds: 2)).then((value) => completer.complete());
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage(title: 'OCR')),
            );
          });
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: idList.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              background: Container(
                color: Colors.red,
              ),
              key: ValueKey<int>(idList[index]),
              child: Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(idListString[index]),
                      subtitle: Text(nameList[index]),
                    ),
                    Container(
                      height: 100.0,
                      child: Column(
                        children: [
                          Text(LocaleKeys.date_text).tr(),
                          Text(dateList[index])
                        ],
                      ),
                    ),
                    Container(
                      child: Text(textList[index]),
                    ),
                  ],
                ),
              ),
              onDismissed: (DismissDirection direction) {
                setState(() {
                  handler.initDB().whenComplete(() async {
                    await handler.deleteText(index);
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage(title: 'OCR')),
                  );
                });
              },
            );
          }
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
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(LocaleKeys.setting_title).tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text(LocaleKeys.about_title).tr(),
              onTap: () {
                _aboutWindow();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text(LocaleKeys.exit_title).tr(),
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
            label: 'Распознать изображение',
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectAndRecognizeImage())
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
      backgroundColor: Colors.lightGreen,
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

class _SelectAndRecognizeImage extends State<SelectAndRecognizeImage> {
  File? image;
  int? selectedOption;
  String text = '';
  late DatabaseHandler handler;
  String name = 'text';
  final date = DateTime.now();
  final pdf = pw.Document(deflate: zlib.encode);
  String path = '';
  bool isDisabledSaveButton = true;
  bool isDisabledSavePDFButton = true;
  bool isLanguageSelected = false;
  static const _tempFileName = 'TempOCRFile.pdf';
  static const _testWithDialogFileName = 'OCRFile.pdf';

  _getImageSource(ImageSource imageSource) async {
    XFile? file = await ImagePicker().pickImage(
        source: imageSource,
        maxHeight: 1800,
        maxWidth: 1800
    );
    if(file != null) {
      setState(() {
        image = File(file.path);
      });
    }
  }

  _scan() async {
    String? imagePath = (image?.path != null) ? image?.path : '';
    if(selectedOption == 1) {
      text = await FlutterTesseractOcr.extractText(imagePath!, language: 'rus');
    }
    if(selectedOption == 2) {
      text = await FlutterTesseractOcr.extractText(imagePath!, language: 'eng');
    }
  }

  Future _savePDF() async {
    _onCheckPermission();
    final folder = await getTemporaryDirectory();
    final filePath = '${folder.path}/$_tempFileName';
    String? file;
    try {
      file = await CRFileSaver.saveFileWithDialog(SaveFileDialogParams(
        sourceFilePath: filePath,
        destinationFileName: _testWithDialogFileName,
      ));
      if(_checkIsTempFileExists()) {
        log('Saved to $file');
      }
      else
      {
        log('Not saved to $file');
      }
    }
    catch (err) {
      log('Error: $err');
    }
  }

  Future<void> addTextToDB(String name, String date, String textOCR) {
    handler = DatabaseHandler();
    TextDB text = TextDB(name: name, date: date, text: textOCR);

    return handler.initDB().whenComplete(() async {
      await handler.insertText(text);
    });
  }

  _cropImage() async {
    if(image != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
          sourcePath: image!.path,
          aspectRatioPresets:
          [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop',
                cropGridColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(title: 'Crop')
          ]);
      if (cropped != null) {
        setState(() {
          image = File(cropped.path);
        });
      }
    }
  }

  _disabledSaveButton() {
    if(text != '') {
      isDisabledSaveButton = false;
    }
    else {
      isDisabledSaveButton = true;
    }
  }

  _disableSavePDFButton() {
    if(text != '') {
      isDisabledSavePDFButton = false;
    }
    else {
      isDisabledSavePDFButton = true;
    }
  }

  _disableScanButton() {
    if(selectedOption == null) {
      isLanguageSelected = false;
    }
    else {
      isLanguageSelected = true;
    }
  }

  _toastError() {
    return Fluttertoast.showToast(
      msg: 'Текст не распознан',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  _pressSaveButton(String name, String date, String textOCR) {
    _disabledSaveButton();
    if(!isDisabledSaveButton) {
      addTextToDB(name, date, textOCR);
      Fluttertoast.showToast(
        msg: 'Текст сохранен в БД',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    else {
      _toastError();
    }
  }

  _pressSavePDFButton() {
    _disableSavePDFButton();
    if(!isDisabledSavePDFButton) {
      _createPDF(text);
      Fluttertoast.showToast(
        msg: 'Текст сохранен в PDF',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    else {
      _toastError();
    }
  }

  _pressScanButton() {
    _disableScanButton();
    if (isLanguageSelected) {
      _scan();
      Fluttertoast.showToast(
        msg: 'Текст распознан',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    else
    {
      _toastError();
    }
  }

  _onCheckPermission() async {
    final granted = await CRFileSaver.requestWriteExternalStoragePermission();

    log('requestWriteExternalStoragePermission: $granted');
  }

  _checkIsTempFileExists() async {
    final folder = await getTemporaryDirectory();
    final filePath = '${folder.path}/$_tempFileName';
    final file = File(filePath);

    return file.exists();
  }

  _createPDF(String ocrText) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(ocrText),
            ); // Center
          }
      )
    );
    final folder = await getTemporaryDirectory();
    final filePath = '${folder.path}/$_tempFileName';
    await File(filePath).writeAsBytes(await pdf.save());
    _savePDF();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Выберете источник изображения'),
        ),
        backgroundColor: Colors.lightGreen,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      _getImageSource(ImageSource.camera);
                    },
                    child: Text ('Камера')
                ),
                ElevatedButton(
                    onPressed: () {
                      _getImageSource(ImageSource.gallery);
                    },
                    child: Text('Выбрать из галереи')
                ),
                if (image != null) Image.file(image!),
                Card(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.add_chart),
                          title: const Text('Выберете язык распознания').tr(),
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
                        ElevatedButton(
                            onPressed: () {
                              _cropImage();
                            },
                            child: Text('Изменить область')
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pressScanButton();
                            },
                            child: Text('Распознать текст')
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pressSaveButton(name, date.toString(), text);
                            },
                            child: Text('Сохранить')
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pressSavePDFButton();
                            },
                            child: Text('Сохранить PDF')
                        )
                      ]
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}