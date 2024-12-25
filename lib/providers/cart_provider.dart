import 'dart:async';
import 'package:flutter/material.dart';
import '../models/manga_item.dart';

class CartProvider with ChangeNotifier {
  final List<MangaItem> _cartItems = [];
  final StreamController<List<MangaItem>> _cartItemsController = StreamController.broadcast();

  List<MangaItem> get cartItems => List.unmodifiable(_cartItems);
  Stream<List<MangaItem>> get cartItemsStream => _cartItemsController.stream;

  // Метод для добавления товара в корзину
  void addToCart(MangaItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (element) => element.documentId == item.documentId,
    );

    if (existingItemIndex != -1) {
      // Если товар уже есть в корзине, увеличиваем его количество
      final existingItem = _cartItems[existingItemIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      _cartItems[existingItemIndex] = updatedItem;
    } else {
      // Если товара нет в корзине, добавляем его с количеством 1
      _cartItems.add(item.copyWith(quantity: 1));
    }
    _cartItemsController.add(_cartItems);
    notifyListeners();
  }

  // Метод для удаления товара из корзины
  void removeFromCart(MangaItem item) {
    _cartItems.removeWhere((element) => element.documentId == item.documentId);
    _cartItemsController.add(_cartItems);
    notifyListeners();
  }

  // Метод для очистки корзины
  void clearCart() {
    _cartItems.clear();
    _cartItemsController.add(_cartItems);
    notifyListeners();
  }

  // Метод для получения количества конкретного товара
  int getItemQuantity(MangaItem item) {
    final existingItem = _cartItems.firstWhere(
      (element) => element.documentId == item.documentId,
      orElse: () => MangaItem(
        documentId: '', // Возвращаем пустой объект
        imagePath: '',
        title: '',
        description: '',
        price: '',
        additionalImages: [],
        format: '',
        publisher: '',
        chapters: '',
        quantity: 0,
      ),
    );
    return existingItem.quantity;
  }

  // Метод для увеличения количества товара
  void increaseQuantity(MangaItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (element) => element.documentId == item.documentId,
    );

    if (existingItemIndex != -1) {
      final existingItem = _cartItems[existingItemIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      _cartItems[existingItemIndex] = updatedItem;
      _cartItemsController.add(_cartItems);
      notifyListeners();
    }
  }

  // Метод для уменьшения количества товара
  void decreaseQuantity(MangaItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (element) => element.documentId == item.documentId,
    );

    if (existingItemIndex != -1) {
      final existingItem = _cartItems[existingItemIndex];
      if (existingItem.quantity > 1) {
        final updatedItem = existingItem.copyWith(quantity: existingItem.quantity - 1);
        _cartItems[existingItemIndex] = updatedItem;
      } else {
        _cartItems.removeAt(existingItemIndex); // Удаляем товар, если количество равно 1
      }
      _cartItemsController.add(_cartItems);
      notifyListeners();
    }
  }

  // Метод для расчета общей стоимости корзины
  int getTotalPrice() {
    return _cartItems.fold(0, (total, item) {
      final itemPrice = int.tryParse(item.price.replaceAll(' рублей', '')) ?? 0;
      return total + (itemPrice * item.quantity);
    });
  }

  @override
  void dispose() {
    _cartItemsController.close();
    super.dispose();
  }
}