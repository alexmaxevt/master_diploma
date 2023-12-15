// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en = {
  "title_in_toolbar": "OCR",
  "setting_title": "Settings",
  "setting_choose_language": "Choose language",
  "setting_russian_language": "Russian",
  "setting_english_language": "English",
  "setting_save_button": "Save",
  "setting_cancel_button": "Cancel",
  "about_title": "About",
  "about_text": "App for text recognition. Create for master diploma. Completed by a student of the group 21-ZKM-PR1 Evtkhov Maksim",
  "exit_title": "Exit",
  "camera_label": "Camera",
  "text_recognition_title": "Text recognition",
  "text_recognition_added_in_db_title": "Data added in DB",
  "done": "Done",
  "date_text": "Date: ",
  "menu_title": "Menu"
};
static const Map<String,dynamic> ru = {
  "title_in_toolbar": "OCR",
  "setting_title": "Настройки",
  "setting_choose_language": "Выберете язык",
  "setting_russian_language": "Русский",
  "setting_english_language": "Английский",
  "setting_save_button": "Сохранить",
  "setting_cancel_button": "Отменить",
  "about_title": "О программе",
  "about_text": "Приложение для распознания текста. Создано в рамках магистерской диссертации. Выполнил студент группы 21-ЗКМ-ПР1 Евтухов Максим",
  "exit_title": "Выход",
  "camera_label": "Камера",
  "text_recognition_title": "Распознание текста",
  "text_recognition_added_in_db_title": "Данные добавлены в БД",
  "done": "Готово",
  "date_text": "Дата: ",
  "menu_title": "Меню"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ru": ru};
}
