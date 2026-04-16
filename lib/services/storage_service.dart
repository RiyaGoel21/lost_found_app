import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../models/item_model.dart';

class StorageService {
  static const _usersKey = 'lf_users';
  static const _itemsKey = 'lf_items';
  static const _sessionKey = 'lf_session';

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─────────────────────────────────────────
  // 🔹 IMAGE PICK + UPLOAD (FIREBASE)
  // ─────────────────────────────────────────

  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1000,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      print("Image picking error: $e");
      return null;
    }
  }

  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      final fileName =
      DateTime.now().millisecondsSinceEpoch.toString();

      final ref = _storage
          .ref()
          .child('items/$userId/$fileName.jpg');

      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // 🔹 USERS (LOCAL - OPTIONAL)
  // ─────────────────────────────────────────

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
    return users.any(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
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

  static Future<UserModel?> loginUser(
      String email, String password) async {
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

  // ─────────────────────────────────────────
  // 🔹 SESSION (OPTIONAL)
  // ─────────────────────────────────────────

  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionKey,
      jsonEncode(user.toJson()),
    );
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

  // ─────────────────────────────────────────
  // 🔹 ITEMS (LOCAL - NOT NEEDED WITH FIRESTORE)
  // ─────────────────────────────────────────

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
    items.insert(0, item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }

  static Future<void> markItemAsFound(String itemId) async {
    final items = await getItems();
    final index = items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final oldItem = items[index];
      final updatedItem = ItemModel(
        id: oldItem.id,
        title: oldItem.title,
        type: 'found',
        category: oldItem.category,
        location: oldItem.location,
        description: oldItem.description,
        imagePath: oldItem.imagePath,
        postedBy: oldItem.postedBy,
        email: oldItem.email,
        date: oldItem.date,
      );
      items[index] = updatedItem;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _itemsKey,
        jsonEncode(items.map((i) => i.toJson()).toList()),
      );
    }
  }
}