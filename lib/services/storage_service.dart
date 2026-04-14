import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';

class StorageService {
  static const _usersKey    = 'lf_users';
  static const _itemsKey    = 'lf_items';
  static const _sessionKey  = 'lf_session';

  // ── USERS ──────────────────────────────────────────────────

  static Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  static Future<bool> emailExists(String email) async {
    final users = await getUsers();
    return users.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }

  static Future<void> registerUser(UserModel user) async {
    final users = await getUsers();
    users.add(user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  static Future<UserModel?> loginUser(String email, String password) async {
    final users = await getUsers();
    try {
      return users.firstWhere(
            (u) =>
        u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // ── SESSION ────────────────────────────────────────────────

  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── ITEMS ──────────────────────────────────────────────────

  static Future<List<ItemModel>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();
  }

  static Future<void> addItem(ItemModel item) async {
    final items = await getItems();
    items.insert(0, item); // newest first
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }
}