import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Создание заказа
  Future<void> createOrder(String userId, int totalPrice, List<Map<String, dynamic>> items) async {
    final order = {
      'userId': userId,
      'totalPrice': totalPrice,
      'items': items,
      'timestamp': DateTime.now(),
    };

    await _firestore.collection('orders').add(order);
  }

  // Получение заказов пользователя
  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}