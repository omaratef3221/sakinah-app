import 'dart:convert';
import 'package:flutter/services.dart';

/// In-memory cache for JSON assets that are read repeatedly. Keeps decode work
/// off the main thread on the critical path (e.g. opening a dua dialog).
class AssetDataCache {
  AssetDataCache._();

  static final Map<String, dynamic> _cache = {};
  static final Map<String, Future<dynamic>> _inFlight = {};

  static Future<dynamic> loadJson(String path) async {
    if (_cache.containsKey(path)) return _cache[path];
    if (_inFlight.containsKey(path)) return _inFlight[path];

    final future = rootBundle.loadString(path).then((raw) {
      final decoded = json.decode(raw);
      _cache[path] = decoded;
      _inFlight.remove(path);
      return decoded;
    });
    _inFlight[path] = future;
    return future;
  }
}
