import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Поток изменения состояния авторизации
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Текущий пользователь
  User? get currentUser => _firebaseAuth.currentUser;

  // Метод для входа
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // Уведомляем слушателей об изменении состояния
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Метод для выхода
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners(); // Уведомляем слушателей об изменении состояния
  }

  // Метод для регистрации
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Добавляем документ в Firestore
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      notifyListeners(); // Уведомляем слушателей об изменении состояния
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}