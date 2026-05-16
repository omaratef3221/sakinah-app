import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sentinel meaning "follow the device language".
const _kSystemDefault = 'system';
const _kLocalePrefKey = 'app_locale_v1';

/// Languages we support. `null` for [Locale] = follow system; otherwise
/// the user has explicitly picked one in Settings and we honor it across
/// restarts.
enum AppLanguage {
  system,
  english,
  arabic;

  String get prefValue => switch (this) {
        AppLanguage.system => _kSystemDefault,
        AppLanguage.english => 'en',
        AppLanguage.arabic => 'ar',
      };

  static AppLanguage fromPref(String? raw) {
    return switch (raw) {
      'en' => AppLanguage.english,
      'ar' => AppLanguage.arabic,
      _ => AppLanguage.system,
    };
  }
}

/// The user's currently selected [AppLanguage] enum. Single source of
/// truth for language preference; persisted across launches.
final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>(
  (ref) => AppLanguageNotifier(),
);

/// Resolved [Locale] to feed into MaterialApp. Derived from
/// [appLanguageProvider] so any change to the picker re-themes the app.
final localeProvider = Provider<Locale?>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return switch (lang) {
    AppLanguage.english => const Locale('en'),
    AppLanguage.arabic => const Locale('ar'),
    AppLanguage.system => _resolveSystemLocale(),
  };
});

/// Languages we ship today. Used to populate the picker AND to clamp
/// the system locale to something we actually have translations for.
const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('ar'),
];

/// True when the resolved locale is RTL. Used by widgets that need to
/// adapt independent of [Directionality] (e.g. choosing a font).
bool isRtlLocale(Locale? locale) {
  if (locale == null) return false;
  return locale.languageCode == 'ar' ||
      locale.languageCode == 'fa' ||
      locale.languageCode == 'he' ||
      locale.languageCode == 'ur';
}

/// Resolves [AppLanguage.system] to whichever supported locale most
/// closely matches the device's preferred language. Defaults to English
/// when the device language isn't supported.
Locale _resolveSystemLocale() {
  final preferred = PlatformDispatcher.instance.locales;
  for (final candidate in preferred) {
    for (final supported in supportedAppLocales) {
      if (candidate.languageCode == supported.languageCode) {
        return supported;
      }
    }
  }
  return const Locale('en');
}

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier() : super(AppLanguage.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLanguage.fromPref(prefs.getString(_kLocalePrefKey));
  }

  Future<void> set(AppLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalePrefKey, lang.prefValue);
    state = lang;
  }
}
