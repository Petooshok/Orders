import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Добавление товара в избранное
  Future<void> addToFavorites(String mangaId) async {
    await _firestore.collection('favorites').doc(mangaId).set({
      'mangaId': mangaId,
    });
  }

  // Удаление товара из избранного
  Future<void> removeFromFavorites(String mangaId) async {
    await _firestore.collection('favorites').doc(mangaId).delete();
  }

  // Получение всех товаров в избранном
  Future<List<Map<String, dynamic>>> getFavoriteItems() async {
    final snapshot = await _firestore.collection('favorites').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}