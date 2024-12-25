import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manga_item.dart'; // Импортируем модель MangaItem

class MangaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение всех манг
  Stream<List<MangaItem>> getMangaItems() {
    return _firestore.collection('mangaItems').snapshots().map((snapshot) {
      print('Загружено документов: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        if (doc.exists && doc.data() != null) {
          return MangaItem.fromFirestore(doc.data()!, doc.id);
        } else {
          return MangaItem(
            documentId: doc.id,
            imagePath: '',
            title: '',
            description: '',
            price: '',
            additionalImages: [],
            format: '',
            publisher: '',
            chapters: '',
          );
        }
      }).toList();
    });
  }

  // Получение одной манги по ID
  Future<MangaItem?> getMangaItemById(String id) async {
    final doc = await _firestore.collection('mangaItems').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return MangaItem.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Добавление новой манги
  Future<void> addMangaItem(MangaItem mangaItem) async {
    await _firestore.collection('mangaItems').add(mangaItem.toFirestore());
    print('Товар успешно добавлен в Firestore');
  }

  // Обновление манги
  Future<void> updateMangaItem(String id, MangaItem mangaItem) async {
    await _firestore.collection('mangaItems').doc(id).update(mangaItem.toFirestore());
    print('Товар успешно обновлен в Firestore');
  }

  // Удаление манги
  Future<void> deleteMangaItem(String id) async {
    await _firestore.collection('mangaItems').doc(id).delete();
    print('Товар успешно удален из Firestore');
  }
}
