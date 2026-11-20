import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  SharedPreferences? _prefs;

  bool isLoggedIn = false;
  String username = '';
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  List<Character> characters = [];
  List<Character> favorites = [];
  List<Character> consumed = [];
  int currentPage = 1;
  bool hasMore = true;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    username = _prefs?.getString('username') ?? '';
    isLoggedIn = _prefs?.getBool('loggedIn') ?? false;
    favorites = _readCharacters('favorites');
    consumed = _readCharacters('consumed');
    notifyListeners();
  }

  List<Character> _readCharacters(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> login(String user, String password) async {
    if (user.trim().isEmpty || password.trim().isEmpty) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 450));
    final savedUser = _prefs?.getString('accountUser');
    final savedPassword = _prefs?.getString('accountPassword');
    if (savedUser == null) {
      await _prefs?.setString('accountUser', user.trim());
      await _prefs?.setString('accountPassword', password);
    } else if (savedUser != user.trim() || savedPassword != password) {
      errorMessage = 'Usuário ou senha incorretos. Use a conta cadastrada neste aparelho.';
      isLoading = false;
      notifyListeners();
      return false;
    }
    username = user.trim();
    isLoggedIn = true;
    await _prefs?.setString('username', username);
    await _prefs?.setBool('loggedIn', true);
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    isLoggedIn = false;
    await _prefs?.setBool('loggedIn', false);
    notifyListeners();
  }

  Future<void> loadInitialCharacters() async {
    if (characters.isNotEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await api.fetchCharacters(page: 1);
      characters = (data['results'] as List)
          .map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
      currentPage = 1;
      hasMore = data['info']?['next'] != null;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCharacters() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();
    try {
      final nextPage = currentPage + 1;
      final data = await api.fetchCharacters(page: nextPage);
      final newItems = (data['results'] as List)
          .map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
      characters = [...characters, ...newItems];
      currentPage = nextPage;
      hasMore = data['info']?['next'] != null;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Character character) async {
    final exists = favorites.any((item) => item.id == character.id);
    if (exists) {
      favorites.removeWhere((item) => item.id == character.id);
    } else {
      favorites.add(character);
    }
    await _saveList('favorites', favorites);
    notifyListeners();
  }

  Future<void> toggleConsumed(Character character) async {
    final exists = consumed.any((item) => item.id == character.id);
    if (exists) {
      consumed.removeWhere((item) => item.id == character.id);
    } else {
      consumed.add(character);
    }
    await _saveList('consumed', consumed);
    notifyListeners();
  }

  bool isFavorite(int id) => favorites.any((item) => item.id == id);
  bool isConsumed(int id) => consumed.any((item) => item.id == id);

  Future<void> _saveList(String key, List<Character> list) async {
    await _prefs?.setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
