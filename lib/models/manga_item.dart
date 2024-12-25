class MangaItem {
  final String documentId; // Идентификатор документа в Firestore
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final List<String> additionalImages;
  final String format;
  final String publisher;
  final String chapters;
  final int quantity; // Количество товара в корзине

  MangaItem({
    required this.documentId,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.additionalImages,
    required this.format,
    required this.publisher,
    required this.chapters,
    this.quantity = 1, // По умолчанию количество 1
  });

  // Конвертация в Map для Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'imagePath': imagePath,
      'title': title,
      'description': description,
      'price': price,
      'additionalImages': additionalImages,
      'format': format,
      'publisher': publisher,
      'chapters': chapters,
      'quantity': quantity,
    };
  }

  // Конвертация из Firestore документа
factory MangaItem.fromFirestore(Map<String, dynamic> data, String documentId) {
  return MangaItem(
    documentId: documentId,
    imagePath: data['imagePath'] ?? '',
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    price: data['price'] ?? '',
    additionalImages: List<String>.from(data['additionalImages'] ?? []),
    format: data['format'] ?? '',
    publisher: data['publisher'] ?? '',
    chapters: data['chapters'] ?? '',
    quantity: data['quantity'] ?? 1,
  );
}

  // Создание копии объекта с измененным количеством
  MangaItem copyWith({int? quantity}) {
    return MangaItem(
      documentId: documentId,
      imagePath: imagePath,
      title: title,
      description: description,
      price: price,
      additionalImages: additionalImages,
      format: format,
      publisher: publisher,
      chapters: chapters,
      quantity: quantity ?? this.quantity,
    );
  }

  // Переопределение методов для сравнения объектов
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaItem &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;
}