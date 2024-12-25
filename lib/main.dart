import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:menu/services_2/auth/auth_gate_2.dart';
import 'package:menu/services_2/auth/auth_service_2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pages/home_page.dart';
import 'pages/manga_selected.dart';
import 'pages/cart_page.dart'; // Импортируем страницу корзины
import 'pages/login_page_2.dart'; // Импортируем страницу входа
import 'pages/register_page_2.dart'; // Импортируем страницу регистрации
import 'pages/chats_1.dart'; // Импортируем страницу профиля
import 'providers/favorite_provider.dart';
import 'providers/cart_provider.dart'; // Импортируем CartProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAwOuFDrto2gYncI1zrmu3KjdL7pRwbagE', 
      appId: '1:400252487630:android:999893b2e211fed8824d9f', 
      messagingSenderId: '400252487630', 
      projectId: 'fir-auth-a0d78'
    )
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), 
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Размер дизайна для мобильных устройств
      builder: (context, child) {
        return MaterialApp(
          title: 'MANgo100',
          theme: ThemeData(
            fontFamily: 'Russo One',
            scaffoldBackgroundColor: const Color.fromRGBO(45, 66, 99, 1),
            appBarTheme: const AppBarTheme(
              color: Color.fromRGBO(45, 66, 99, 1),
              iconTheme: IconThemeData(color: Color(0xFFECDBBA)),
              titleTextStyle: TextStyle(
                color: Color(0xFFECDBBA),
                fontFamily: 'Russo One',
                fontSize: 20,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromRGBO(45, 66, 99, 1), // Темно-синий фон
              selectedItemColor: Color.fromRGBO(200, 75, 49, 1),
              unselectedItemColor: Color(0xFFECDBBA),
            ),
          ),
          home: const AuthGate2(),
          onUnknownRoute: (settings) {
            return MaterialPageRoute(builder: (context) => const MainPage(initialIndex: 0)); // Перенаправление на домашнюю страницу при ошибке маршрута
          },
          routes: {
            '/login': (context) => const LoginPage2(),
            '/register': (context) => const RegisterPage2(),
            '/profile': (context) => const Chats(), // Обновляем маршрут на новую страницу
            '/home': (context) => const MainPage(initialIndex: 0),
            '/manga_selected': (context) => const MainPage(initialIndex: 1),
            '/cart': (context) => const MainPage(initialIndex: 2),
          },
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({super.key, required this.initialIndex});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    HomePage(),
    MangaSelectedPage(),
    CartPage(),
    Chats(), // Обновляем страницу профиля на новую страницу
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Проверяем, авторизован ли пользователь
    if (authService.currentUser == null) {
      return LoginPage2(); // Если пользователь не авторизован, перенаправляем на страницу входа
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final totalCartItems = cartProvider.cartItems.fold(0, (sum, item) => sum + cartProvider.getItemQuantity(item));

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
            backgroundColor: Color.fromRGBO(45, 66, 99, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
            backgroundColor: Color.fromRGBO(45, 66, 99, 1),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center, // Центрируем элементы
              children: [
                Icon(Icons.shopping_cart), // Кнопка корзины
                if (totalCartItems > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(200, 75, 49, 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$totalCartItems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Корзина',
            backgroundColor: Color.fromRGBO(45, 66, 99, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
            backgroundColor: Color.fromRGBO(45, 66, 99, 1),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(200, 75, 49, 1),
        unselectedItemColor: const Color(0xFFECDBBA),
        onTap: _onItemTapped,
      ),
    );
  }
}