import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    // Load the JSON file from the assets folder based on the current locale
    String jsonString =
    await rootBundle.loadString('assets/locale/${locale.languageCode}.json');

    // Decode the JSON
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert dynamic map to Map<String, String>
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return true;
  }

  String? translate(String key) {
    return _localizedStrings?[key];
  }
}
