import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  // State Variables
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ar');
  double _fontSizeDetails = 1.0; // Scale factor: 0.8 to 1.2
  double _fontSizeNews = 1.0;
  bool _notificationsEnabled = true;
  bool _matchNotifications = true;
  bool _newsNotifications = true;
  String _matchSortOrder =
      'tournament'; // tournament, time, important, favorite

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get fontSizeDetails => _fontSizeDetails;
  double get fontSizeNews => _fontSizeNews;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get matchNotifications => _matchNotifications;
  bool get newsNotifications => _newsNotifications;
  String get matchSortOrder => _matchSortOrder;

  // Constructor: Load prefs
  SettingsController() {
    _loadSettings();
  }

  // Loading Settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final isDark = prefs.getBool('isDark') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Language
    final langCode = prefs.getString('languageCode') ?? 'ar';
    _locale = Locale(langCode);

    // Font Size
    _fontSizeDetails = prefs.getDouble('fontSizeDetails') ?? 1.0;
    _fontSizeNews = prefs.getDouble('fontSizeNews') ?? 1.0;

    // Notifications
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _matchNotifications = prefs.getBool('matchNotifications') ?? true;
    _newsNotifications = prefs.getBool('newsNotifications') ?? true;

    // Sorting
    _matchSortOrder = prefs.getString('matchSortOrder') ?? 'tournament';

    notifyListeners();
  }

  // --- Actions ---

  // Theme
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
  }

  // Language
  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  // Font Size
  Future<void> setFontSizeDetails(double scale) async {
    _fontSizeDetails = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeDetails', scale);
  }

  Future<void> setFontSizeNews(double scale) async {
    _fontSizeNews = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeNews', scale);
  }

  // Notifications
  Future<void> toggleMasterNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }

  Future<void> toggleMatchNotifications(bool value) async {
    _matchNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('matchNotifications', value);
  }

  Future<void> toggleNewsNotifications(bool value) async {
    _newsNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newsNotifications', value);
  }

  // Sorting
  Future<void> setMatchSortOrder(String order) async {
    _matchSortOrder = order;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('matchSortOrder', order);
  }
}
