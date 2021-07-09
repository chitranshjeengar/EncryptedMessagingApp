import 'package:chatapp/widgets/newmessage.dart';
import 'package:flutter/material.dart';
import '../widgets/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MessageScreen extends StatefulWidget {
  final String otherUserId; final String otherUsername; final User? user;
  MessageScreen(this.otherUserId, this.otherUsername, this.user );
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
    body: Container(
        child: Column(
          children: [
            Expanded(child: Messages(widget.otherUserId, widget.otherUsername)),
            NewMessage(widget.otherUserId, widget.user),
          ],
        ),
      ),
    );
  }
}
