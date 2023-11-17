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
  "setting_cancel_button": "Cancel"
};
static const Map<String,dynamic> ru = {
  "title_in_toolbar": "OCR",
  "setting_title": "Настройки",
  "setting_choose_language": "Выберете язык",
  "setting_russian_language": "Русский",
  "setting_english_language": "Английский",
  "setting_save_button": "Сохранить",
  "setting_cancel_button": "Отменить"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ru": ru};
}
