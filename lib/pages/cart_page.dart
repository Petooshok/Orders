import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/cart_provider.dart';
import '../models/manga_item.dart';
import 'manga_details_screen.dart'; // Импортируем страницу с описанием
import '../services/cart_service.dart'; // Импортируем CartService
import '../services/order_service.dart'; // Импортируем OrderService

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartService = CartService();
    final orderService = OrderService();

    return Scaffold(
      body: Container(
        color: const Color(0xFF191919), // Темно-черный фон
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(context), // Добавляем заголовок
              Expanded(
                child: StreamBuilder<List<MangaItem>>(
                  stream: cartProvider.cartItemsStream, // Используем поток из CartProvider
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Ошибка: ${snapshot.error}'));
                    }
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Корзина пуста',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFFECDBBA),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final cartItems = snapshot.data!;
                    return ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return _buildSlidableCartItemCard(context, item, cartProvider, cartService);
                      },
                    );
                  },
                ),
              ),
              if (cartProvider.cartItems.isNotEmpty) _buildTotalPrice(cartProvider),
              if (cartProvider.cartItems.isNotEmpty) _buildActionButtons(context, cartProvider, cartService, orderService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        'MANgo100',
        style: TextStyle(
          fontSize: isMobile ? 30.0 : 40.0,
          color: const Color(0xFFECDBBA),
          fontFamily: 'Tektur',
        ),
      ),
    );
  }

  Widget _buildSlidableCartItemCard(BuildContext context, MangaItem item, CartProvider cartProvider, CartService cartService) {
    return Slidable(
      key: Key(item.documentId),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              cartProvider.removeFromCart(item);
              cartService.removeFromCart(item.documentId);
            },
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFFC84B31),
            icon: Icons.delete,
            label: 'Удалить',
          ),
        ],
      ),
      child: _buildCartItemCard(context, item, cartProvider.getItemQuantity(item), cartProvider, cartService),
    );
  }

  Widget _buildCartItemCard(BuildContext context, MangaItem item, int quantity, CartProvider cartProvider, CartService cartService) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Адаптивные размеры для карточки
    final cardWidth = isMobile ? screenWidth * 0.9 : screenWidth * 0.25;
    final imageWidth = isMobile ? screenWidth * 0.3 : screenWidth * 0.09; // Уменьшаем размер изображения для компьютера
    final imageHeight = imageWidth * 1.3; // Сохранение пропорций изображения

    // Адаптивные размеры текста
    final titleFontSize = isMobile ? 22.0 : 20.0;
    final formatFontSize = isMobile ? 18.0 : 16.0;
    final priceFontSize = isMobile ? 20.0 : 18.0;
    final quantityFontSize = isMobile ? 18.0 : 16.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(
              title: item.title,
              price: item.price,
              documentId: item.documentId, // Добавляем documentId
              additionalImages: item.additionalImages,
              description: item.description,
              format: item.format,
              publisher: item.publisher,
              imagePath: item.imagePath,
              chapters: item.chapters,
              onDelete: () => cartProvider.removeFromCart(item),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFECDBBA),
          borderRadius: BorderRadius.circular(35), // Сделаем карточку более прямоугольной
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                item.imagePath,
                fit: BoxFit.cover,
                width: imageWidth,
                height: imageHeight, // Адаптивная высота изображения
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Ошибка загрузки изображения'));
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? 'No title',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: const Color(0xFF2D4263),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.format ?? 'No format',
                      style: TextStyle(
                        fontSize: formatFontSize,
                        color: const Color(0xFF2D4263),
                        fontFamily: 'Tektur',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${item.price ?? '0'} x $quantity = ${int.tryParse(item.price?.replaceAll(' рублей', '') ?? '0')! * quantity} рублей',
                      style: TextStyle(
                        fontSize: priceFontSize,
                        color: const Color(0xFF2D4263),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildIconButton(
                          icon: Icons.remove,
                          onTap: () {
                            cartProvider.decreaseQuantity(item);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: quantityFontSize,
                            color: const Color(0xFF2D4263),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          icon: Icons.add,
                          onTap: () {
                            cartProvider.increaseQuantity(item);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPrice(CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Итого: ${cartProvider.getTotalPrice()} рублей',
        style: const TextStyle(
          fontSize: 24.0,
          color: Color(0xFFECDBBA),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFC84B31),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFECDBBA),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CartProvider cartProvider, CartService cartService, OrderService orderService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            cartProvider.clearCart();
            cartService.clearCart();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC84B31),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Icon(
            Icons.delete_forever,
            color: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            int totalPrice = cartProvider.getTotalPrice();

            // Создаем заказ
            await orderService.createOrder(
              'userId1', // Замените на реальный ID пользователя
              totalPrice,
              cartProvider.cartItems.map((item) {
                return {
                  'productId': item.documentId,
                  'title': item.title,
                  'price': int.tryParse(item.price.replaceAll(' рублей', ''))!,
                  'quantity': cartProvider.getItemQuantity(item),
                };
              }).toList(),
            );

            // Очищаем корзину
            cartProvider.clearCart();

            // Показываем уведомление
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Заказ оформлен')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC84B31),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Icon(
            Icons.attach_money,
            color: Color(0xFFECDBBA),
          ),
        ),
      ],
    );
  }
}