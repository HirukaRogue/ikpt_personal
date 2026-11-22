import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GalleryManager {
  static final GalleryManager _instance = GalleryManager._internal();
  factory GalleryManager() => _instance;
  GalleryManager._internal();

  Future<File> _getSaveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/found_places.json');
  }

  // Saves a place as "unlocked"
  Future<void> unlockPlace(String placeName) async {
    final file = await _getSaveFile();
    Set<String> foundPlaces = {};

    if (await file.exists()) {
      final content = await file.readAsString();
      foundPlaces = Set<String>.from(jsonDecode(content));
    }

    foundPlaces.add(placeName);
    await file.writeAsString(jsonEncode(foundPlaces.toList()));
  }

  // Returns the list of names of unlocked places
  Future<List<String>> getUnlockedPlaceNames() async {
    final file = await _getSaveFile();
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      return List<String>.from(jsonDecode(content));
    } catch (e) {
      return [];
    }
  }
}
