import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services_2/auth/login_or_register.dart';
import '/pages/chat_page.dart';
import '/services_2/auth/auth_service_2.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      );
    }).catchError((error) {
      // Обработка ошибок, если выход не удался
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                'MANgo100',
                style: TextStyle(fontSize: 24, color: Color(0xFFECDBBA)),
              ),
            ),
            backgroundColor: const Color(0xFF2D4263),
            actions: [
              IconButton(
                onPressed: signOut,
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFFECDBBA),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF191919),
          body: authService.currentUser != null
              ? DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Чаты'),
                          Tab(text: 'Заказы'),
                        ],
                        labelColor: Color(0xFFECDBBA),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFFECDBBA),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildUserList(),
                            _buildOrderList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        );
      },
    );
  }

  Widget _buildUserList() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.currentUser == null) {
          return const Center(
            child: Text(
              'Вы не авторизованы',
              style: TextStyle(color: Color(0xFFECDBBA)),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'Error',
                style: TextStyle(color: Color(0xFFECDBBA)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFECDBBA),
                ),
              );
            }

            final users = snapshot.data!.docs;

            if (_auth.currentUser!.email != 'mari.vas.04@mail.ru') {
              return ListView(
                children: users
                    .where((x) => x['email'] == 'mari.vas.04@mail.ru')
                    .map<Widget>((doc) => _buildUserListItem(doc))
                    .toList(),
              );
            } else {
              return ListView(
                children: users
                    .where((doc) => doc['email'] != _auth.currentUser!.email)
                    .map<Widget>((doc) => _buildUserListItem(doc))
                    .toList(),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser == null) {
      return Container(); // Если пользователь вышел, не показываем элементы
    }

    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(
          data['email'],
          style: const TextStyle(color: Color(0xFFECDBBA)),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'],
                receiverUserId: data['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

Widget _buildOrderList() {
  final orderService = OrderService();
  final userId = 'userId1'; // Замените на реальный ID пользователя

  return StreamBuilder<QuerySnapshot>(
    stream: orderService.getUserOrders(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFECDBBA), // Цвет индикатора загрузки
          ),
        );
      }
      if (snapshot.hasError) {
        return Center(
          child: Text(
            'Ошибка: ${snapshot.error}',
            style: const TextStyle(
              color: Color(0xFFECDBBA), // Цвет текста ошибки
              fontSize: 16,
            ),
          ),
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Text(
            'У вас пока нет заказов',
            style: const TextStyle(
              color: Color(0xFFECDBBA), // Цвет текста
              fontSize: 18,
              fontFamily: 'Tektur', // Ваш шрифт
            ),
          ),
        );
      }

      final orders = snapshot.data!.docs;

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFF2D4263), // Цвет фона карточки
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                'Заказ от ${order['timestamp'].toDate()}',
                style: const TextStyle(
                  color: Color(0xFFECDBBA), // Цвет текста заголовка
                  fontSize: 18,
                  fontFamily: 'Tektur', // Ваш шрифт
                ),
              ),
              subtitle: Text(
                'Итого: ${order['totalPrice']} рублей',
                style: const TextStyle(
                  color: Color(0xFFECDBBA), // Цвет текста подзаголовка
                  fontSize: 16,
                ),
              ),
              iconColor: Color(0xFFECDBBA), // Цвет иконки раскрытия
              collapsedIconColor: Color(0xFFECDBBA), // Цвет иконки свернутого состояния
              children: List<Map<String, dynamic>>.from(order['items']).map((item) {
                return ListTile(
                  title: Text(
                    item['title'],
                    style: const TextStyle(
                      color: Color(0xFFECDBBA), // Цвет текста названия товара
                      fontSize: 16,
                      fontFamily: 'Tektur', // Ваш шрифт
                    ),
                  ),
                  subtitle: Text(
                    '${item['price']} x ${item['quantity']} = ${item['price'] * item['quantity']} рублей',
                    style: const TextStyle(
                      color: Color(0xFFECDBBA), // Цвет текста подзаголовка
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    },
  );
}
  }
