import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/manga_item.dart';
import 'manga_details_screen.dart';
import 'upload_new_volume_page.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart'; // Импортируем CartProvider
import '../services/manga_service.dart'; // Импортируем MangaService

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MangaService _mangaService = MangaService();
  String searchQuery = '';
  String sortBy = 'title';
  String sortOrder = 'asc';
  String? selectedPublisher;
  double minPrice = 0;
  double maxPrice = 1000;

  // Безопасное преобразование строки в число
  double? _parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  // Обновление списка товаров на основе поискового запроса, сортировки и фильтров
  List<MangaItem> _filterMangaItems(List<MangaItem> items) {
    return items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(searchQuery.toLowerCase());
      final descriptionMatch = item.description.toLowerCase().contains(searchQuery.toLowerCase());
      final price = _parsePrice(item.price);
      final priceMatch = price != null && price >= minPrice && price <= maxPrice;
      final publisherMatch = selectedPublisher == null || item.publisher == selectedPublisher;
      return (titleMatch || descriptionMatch) && priceMatch && publisherMatch;
    }).toList();
  }

  // Сортировка
  List<MangaItem> _sortMangaItems(List<MangaItem> items) {
    items.sort((a, b) {
      if (sortBy == 'title') {
        return sortOrder == 'asc' ? a.title.compareTo(b.title) : b.title.compareTo(a.title);
      } else if (sortBy == 'price') {
        final priceA = _parsePrice(a.price) ?? 0;
        final priceB = _parsePrice(b.price) ?? 0;
        return sortOrder == 'asc' ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      }
      return 0;
    });
    return items;
  }

  // Обновление поискового запроса
  void _onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Обновление сортировки
  void _onSortChanged(String sortBy, String sortOrder) {
    setState(() {
      this.sortBy = sortBy;
      this.sortOrder = sortOrder;
    });
  }

  // Обновление фильтров
  void _onFilterChanged(String? publisher, double minPrice, double maxPrice) {
    setState(() {
      selectedPublisher = publisher;
      this.minPrice = minPrice;
      this.maxPrice = maxPrice;
    });
  }

  // Сброс фильтров
  void _resetFilters() {
    setState(() {
      sortBy = 'title';
      sortOrder = 'asc';
      selectedPublisher = null;
      minPrice = 0;
      maxPrice = 1000;
    });
  }

void _navigateToAddProductScreen(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UploadNewVolumePage(
        onItemCreated: (MangaItem? item) {
          if (item != null) {
            // Убираем эту строку, так как добавление уже выполняется в UploadNewVolumePage
            // _mangaService.addMangaItem(item);
          }
        },
      ),
    ),
  );
}

  // Управление избранными элементами
  void _toggleFavorite(BuildContext context, MangaItem item) {
    final provider = Provider.of<FavoriteProvider>(context, listen: false);
    if (provider.favoriteItems.contains(item)) {
      provider.removeFromFavorites(item);
    } else {
      provider.addToFavorites(item);
    }
  }

  // Управление корзиной
  void _toggleCart(BuildContext context, MangaItem item) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    if (provider.cartItems.contains(item)) {
      provider.removeFromCart(item);
    } else {
      provider.addToCart(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context); // Добавляем CartProvider

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(context, isMobile),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildSortAndFilterBar(isMobile),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<MangaItem>>(
                stream: _mangaService.getMangaItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Нет данных о манге'));
                  }

                  final mangaItems = snapshot.data!;
                  final filteredItems = _filterMangaItems(mangaItems);
                  final sortedItems = _sortMangaItems(filteredItems);

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2, // Один столбец на мобильных устройствах, два на десктопах
                      childAspectRatio: isMobile ? 1.6 : 2.3, // Соотношение ширины и высоты
                      crossAxisSpacing: 20, // Расстояние между столбцами
                      mainAxisSpacing: 10, // Расстояние между строками
                    ),
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final productItem = sortedItems[index];
                      return _buildMangaCard(context, productItem, favoriteProvider, cartProvider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Шапка страницы
  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MANgo100',
            style: TextStyle(
              fontSize: isMobile ? 30.0 : 40.0,
              color: const Color(0xFFECDBBA),
              fontFamily: 'Tektur',
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _navigateToAddProductScreen(context),
            child: Container(
              width: isMobile ? 24.0 : 40.0,
              height: isMobile ? 24.0 : 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFFC84B31),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add,
                color: const Color(0xFFECDBBA),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для поисковой строки
  Widget _buildSearchBar() {
    return TextField(
      onChanged: _onSearchQueryChanged,
      decoration: InputDecoration(
        hintText: 'Поиск по названию или описанию',
        hintStyle: TextStyle(color: const Color(0xFFECDBBA)),
        prefixIcon: Icon(Icons.search, color: const Color(0xFFECDBBA)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFECDBBA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFECDBBA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFC84B31)),
        ),
        filled: true,
        fillColor: const Color(0xFF2D4263),
      ),
      style: TextStyle(color: const Color(0xFFECDBBA)),
    );
  }

  // Виджет для сортировки и фильтрации
  Widget _buildSortAndFilterBar(bool isMobile) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showSortDialog(context),
              child: Row(
                children: [
                  Icon(Icons.sort, color: const Color(0xFFECDBBA)),
                  const SizedBox(width: 5),
                  Text('Сортировка', style: TextStyle(color: const Color(0xFFECDBBA))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showFilterDialog(context),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: const Color(0xFFECDBBA)),
                  const SizedBox(width: 5),
                  Text('Фильтр', style: TextStyle(color: const Color(0xFFECDBBA))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Диалоговое окно для сортировки
  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Сортировка', style: TextStyle(color: const Color(0xFF2D4263))),
          backgroundColor: const Color(0xFFECDBBA),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('От А до Я', style: TextStyle(color: const Color(0xFF2D4263))),
                onTap: () {
                  _onSortChanged('title', 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('От Я до А', style: TextStyle(color: const Color(0xFF2D4263))),
                onTap: () {
                  _onSortChanged('title', 'desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('От дешевого к дорогому', style: TextStyle(color: const Color(0xFF2D4263))),
                onTap: () {
                  _onSortChanged('price', 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('От дорогого к дешевому', style: TextStyle(color: const Color(0xFF2D4263))),
                onTap: () {
                  _onSortChanged('price', 'desc');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Диалоговое окно для фильтрации
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Фильтр', style: TextStyle(color: const Color(0xFF2D4263))),
          backgroundColor: const Color(0xFFECDBBA),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Издатель:', style: TextStyle(color: const Color(0xFF2D4263))),
              DropdownButton<String>(
                value: selectedPublisher,
                onChanged: (String? newValue) {
                  if (newValue == null) {
                    _onFilterChanged(null, minPrice, maxPrice);
                  } else {
                    _onFilterChanged(newValue, minPrice, maxPrice);
                  }
                },
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Все', style: TextStyle(color: const Color(0xFF2D4263))),
                  ),
                  ...<String>['Publisher 1', 'Publisher 2', 'Publisher 3']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: const Color(0xFF2D4263))),
                    );
                  }).toList(),
                ],
                dropdownColor: const Color(0xFFECDBBA),
                iconEnabledColor: const Color(0xFF2D4263),
              ),
              const SizedBox(height: 10),
              Text('Цена от:', style: TextStyle(color: const Color(0xFF2D4263))),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0;
                  _onFilterChanged(selectedPublisher, price, maxPrice);
                },
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: const Color(0xFF2D4263)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF2D4263)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFFC84B31)),
                  ),
                ),
                style: TextStyle(color: const Color(0xFF2D4263)),
              ),
              const SizedBox(height: 10),
              Text('Цена до:', style: TextStyle(color: const Color(0xFF2D4263))),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 1000;
                  _onFilterChanged(selectedPublisher, minPrice, price);
                },
                decoration: InputDecoration(
                  hintText: '1000',
                  hintStyle: TextStyle(color: const Color(0xFF2D4263)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF2D4263)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFFC84B31)),
                  ),
                ),
                style: TextStyle(color: const Color(0xFF2D4263)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена', style: TextStyle(color: const Color(0xFF2D4263))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Применить', style: TextStyle(color: const Color(0xFF2D4263))),
            ),
          ],
        );
      },
    );
  }

  // Карточка манги
  Widget _buildMangaCard(BuildContext context, MangaItem productItem, FavoriteProvider favoriteProvider, CartProvider cartProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Плавное уменьшение шрифта, учитывая ширину экрана
    final titleFontSize = (screenWidth * 0.06).clamp(14.0, 26.0);
    final descriptionFontSize = (screenWidth * 0.04).clamp(12.0, 20.0);
    final priceFontSize = (screenWidth * 0.05).clamp(12.0, 24.0);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(
              title: productItem.title,
              price: productItem.price,
              documentId: productItem.documentId, // Передаем documentId
              additionalImages: productItem.additionalImages,
              description: productItem.description,
              format: productItem.format,
              publisher: productItem.publisher,
              imagePath: productItem.imagePath,
              chapters: productItem.chapters,
              onDelete: () {
                _mangaService.deleteMangaItem(productItem.documentId);
              },
            ),
          ),
        );

        if (result != null && result is int) {
          _mangaService.deleteMangaItem(productItem.documentId);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFECDBBA),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Для выравнивания сверху
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    productItem.imagePath,
                    fit: BoxFit.cover,
                    width: isMobile ? screenWidth * 0.3 : 160,
                    height: isMobile ? screenWidth * 0.45 : 280,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Ошибка загрузки изображения'));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Отступ для текста от верхнего края
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productItem.title,
                          style: TextStyle(
                            fontSize: titleFontSize, // Плавное уменьшение шрифта заголовка
                            color: const Color(0xFF2D4263),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          productItem.description, // Используем полное описание
                          style: TextStyle(
                            fontSize: descriptionFontSize, // Плавное уменьшение шрифта описания
                            color: const Color(0xFF2D4263),
                            fontFamily: 'Tektur',
                          ),
                          maxLines: 1, // Ограничение на количество строк (можно установить на 1)
                          overflow: TextOverflow.ellipsis, // Троеточие при переполнении
                        ),
                        const SizedBox(height: 10),
                        Text(
                          productItem.price,
                          style: TextStyle(
                            fontSize: priceFontSize, // Плавное уменьшение шрифта цены
                            color: const Color(0xFF2D4263),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildIconButton(
                icon: favoriteProvider.favoriteItems.contains(productItem) ? Icons.favorite : Icons.favorite_border,
                onTap: () => _toggleFavorite(context, productItem),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: _buildIconButton(
                icon: cartProvider.cartItems.contains(productItem) ? Icons.shopping_cart : Icons.add_shopping_cart,
                onTap: () => _toggleCart(context, productItem),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Общий стиль для кнопок
  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.06).clamp(16.0, 20.0); // Плавное уменьшение размера иконки
    final buttonSize = (screenWidth * 0.1).clamp(32.0, 40.0); // Плавное уменьшение размера кнопки

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Закругляем углы
          color: const Color(0xFFC84B31),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFECDBBA),
          size: iconSize,
        ),
      ),
    );
  }
}
