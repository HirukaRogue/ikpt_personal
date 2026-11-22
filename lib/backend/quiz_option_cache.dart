import 'dart:convert';
import 'dart:math';

import 'package:iknowthisplace/backend/country.dart';
import 'package:iknowthisplace/backend/places.dart';
import 'package:iknowthisplace/backend/settings_manager.dart';

import 'package:flutter/services.dart' show rootBundle;

class QuizOptionsCache {
  static List<Country>? _allCountriesCache;
  static String? _cachedLanguage;

  static Future<List<Country>> getAllCountries() async {
    final currentLanguage = SettingsManager().language;
    
    if (_allCountriesCache != null && _cachedLanguage == currentLanguage) {
      return _allCountriesCache!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/countries/countries_$currentLanguage.json');
      final List<dynamic> data = json.decode(jsonString);

      _allCountriesCache = data.map((json) => Country.fromJson(json)).toList();
      _cachedLanguage = currentLanguage;

      print('Carregados ${_allCountriesCache!.length} países do JSON ($currentLanguage)');
      return _allCountriesCache!;
    } catch (e) {
      print('Erro ao carregar countries_$currentLanguage.json: $e');
      // Fallback to English
      if (currentLanguage != 'English') {
        try {
          final jsonString = await rootBundle.loadString('assets/data/countries/countries_English.json');
          final List<dynamic> data = json.decode(jsonString);
          _allCountriesCache = data.map((json) => Country.fromJson(json)).toList();
          _cachedLanguage = 'English';
          return _allCountriesCache!;
        } catch (e2) {
          print('Erro ao carregar fallback countries_English.json: $e2');
        }
      }
      
      return [
        Country(
          countryName: 'Unknown',
          countryFlag: 'assets/images/country_flags/4x3/xx.svg',
        ),
      ];
    }
  }

  static final Map<String, List<Country>> _optionsCache = {};

  static Future<List<Country>> getShuffledOptions(Place place) async {
    final key = "${SettingsManager().language}_${place.name.trim().toLowerCase()}";

    if (_optionsCache.containsKey(key)) {
      return List<Country>.from(_optionsCache[key]!);
    }

    final allCountries = await getAllCountries();

    Country? correctCountry;
    try {
      correctCountry = allCountries.firstWhere(
            (c) => c.countryName.toLowerCase() == place.country.toLowerCase(),
        orElse: () => Country(
          countryName: place.country,
          countryFlag: 'assets/images/country_flags/4x3/xx.svg', // fallback
        ),
      );
    } catch (e) {
      correctCountry = Country(
        countryName: place.country,
        countryFlag: 'assets/images/country_flags/4x3/xx.svg',
      );
    }

    final candidates = List<Country>.from(allCountries)
      ..removeWhere((c) => c.countryName == correctCountry!.countryName);

    candidates.shuffle(Random());
    final wrongOnes = candidates.take(3).toList();

    final options = [correctCountry, ...wrongOnes]..shuffle(Random());

    _optionsCache[key] = options;
    return List<Country>.from(options);
  }

  static void clear() {
    _optionsCache.clear();
    _allCountriesCache = null;
    _cachedLanguage = null;
  }
}
