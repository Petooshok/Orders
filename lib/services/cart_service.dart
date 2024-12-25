import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение всех товаров в корзине через Stream
  Stream<List<Map<String, dynamic>>> getCartItems() {
    return _firestore.collection('cart').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Удаление товара из корзины
  Future<void> removeFromCart(String documentId) async {
    try {
      await _firestore.collection('cart').doc(documentId).delete();
    } catch (e) {
      print('Error removing item from cart: $e');
      rethrow;
    }
  }

  // Обновление количества товара в корзине
  Future<void> updateCartItemQuantity(String documentId, int quantity) async {
    try {
      await _firestore.collection('cart').doc(documentId).update({
        'quantity': quantity,
      });
    } catch (e) {
      print('Error updating item quantity: $e');
      rethrow;
    }
  }

  // Очистка корзины
  Future<void> clearCart() async {
    try {
      final snapshot = await _firestore.collection('cart').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  // Добавление товара в корзину
  Future<void> addToCart(String documentId, int quantity) async {
    try {
      await _firestore.collection('cart').doc(documentId).set({
        'documentId': documentId,
        'quantity': quantity,
      });
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }
}
