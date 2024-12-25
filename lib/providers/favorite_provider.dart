import 'dart:async';
import 'package:flutter/material.dart';
import '../models/manga_item.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  List<MangaItem> _favoriteItems = [];
  StreamController<List<MangaItem>> _favoriteItemsStreamController = StreamController<List<MangaItem>>.broadcast();

  // Получение списка избранных товаров
  List<MangaItem> get favoriteItems => _favoriteItems;

  // Получение потока избранных товаров
  Stream<List<MangaItem>> get favoriteItemsStream => _favoriteItemsStreamController.stream;

  // Конструктор
  FavoriteProvider() {
    loadFavorites(); // Загрузка избранных товаров при создании провайдера
  }

  // Добавление товара в избранное
  Future<void> addToFavorites(MangaItem item) async {
    _favoriteItems.add(item);
    await _favoriteService.addToFavorites(item.documentId);
    updateStream();
  }

  // Удаление товара из избранного
  Future<void> removeFromFavorites(MangaItem item) async {
    _favoriteItems.remove(item);
    await _favoriteService.removeFromFavorites(item.documentId);
    updateStream();
  }

  // Проверка, находится ли товар в избранном
  bool isFavorite(MangaItem item) {
    return _favoriteItems.any((favorite) => favorite.documentId == item.documentId);
  }

  // Загрузка избранных товаров из Firestore
  Future<void> loadFavorites() async {
    final favoriteItems = await _favoriteService.getFavoriteItems();
    _favoriteItems = favoriteItems.map((item) {
      return MangaItem.fromFirestore(item, item['documentId']);
    }).toList();
    updateStream();
  }

  // Обновление потока данных
  void updateStream() {
    _favoriteItemsStreamController.add(_favoriteItems);
    notifyListeners();
  }

  // Освобождение ресурсов
  @override
  void dispose() {
    _favoriteItemsStreamController.close();
    super.dispose();
  }
}