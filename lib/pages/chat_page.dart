import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/components/chat_bubble.dart';
import '/components/my_text_field.dart';
import '/services_2/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserEmail;
  const ChatPage({super.key, required this.receiverUserEmail, required this.receiverUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserId,
        _messageController.text
      );

      //clear the controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Чатик в MANgo100', // Изменено на "Чатик в MANgo100"
            style: TextStyle(color: Color(0xFFECDBBA)), // Цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF2D4263), // Цвет AppBar
      ),
      backgroundColor: const Color(0xFF191919), // Цвет фона
      body: Column(
        children: [
          //message
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildMessageInput(),

          const SizedBox(height: 25,)
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserId,
        _firebaseAuth.currentUser!.uid
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'error: ${snapshot.error.toString()}',
            style: const TextStyle(color: Color(0xFFECDBBA)), // Цвет текста
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Loading..',
            style: TextStyle(color: Color(0xFFECDBBA)), // Цвет текста
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      }
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the messages to right or left
    var alignment = (data['senderID'] == _firebaseAuth.currentUser!.uid)
      ? Alignment.centerRight
      : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderID'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderID'] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
          children: [
            Text(
              data['senderEmail'],
              style: const TextStyle(color: Color(0xFFECDBBA)), // Цвет текста
            ),
            const SizedBox(height: 5,),
            ChatBubble(
              message: data['message'],
              isRight: data['senderID'] == _firebaseAuth.currentUser!.uid,
            )
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Enter Message',
              obscureText: false,
            ),
          ),

          //send button
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
              color: Color(0xFFC84B31), // Цвет иконки
            ),
          )
        ],
      ),
    );
  }
}