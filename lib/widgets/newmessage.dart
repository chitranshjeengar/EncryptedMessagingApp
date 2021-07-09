import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cryptography/cryptography.dart';

class NewMessage extends StatefulWidget {
final String otherUserId; final User? user;
NewMessage(this.otherUserId, this.user);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    final algo00 = Cryptography.instance.x25519();
    final algo = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    SimpleKeyPair kpr = await algo00.newKeyPair();
    SimplePublicKey pkpr = await kpr.extractPublicKey();
    final aprkbytes = Hive.box('chatapp').get('key');
    final apkbytes = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();
    final bpkbytes = await FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).get();
    List<int> aaaa = apkbytes.data()!['key'].cast<int>(); List<int> bbbb = bpkbytes.data()!['key'].cast<int>();
    SimplePublicKey apk = SimplePublicKey(aaaa, type: pkpr.type);
    SimplePublicKey bpk = SimplePublicKey(bbbb, type: pkpr.type);
    SimpleKeyPair ak = SimpleKeyPairData(aprkbytes, publicKey: apk, type: pkpr.type);
    final s1 = await algo00.sharedSecretKey(keyPair: ak, remotePublicKey: bpk);

    FocusScope.of(context).unfocus();
    _controller.clear();
    if(_enteredMessage.trim()!=''){
    // final mess = utf8
    final secbox = await algo.encrypt(utf8.encode(_enteredMessage), secretKey: s1);
    await FirebaseFirestore.instance.collection('chat').doc(widget.otherUserId).collection('newmess').add(
    {
      'from' : widget.user!.uid,
      'cipher': secbox.cipherText,
      'nonce' : secbox.nonce,
      'createdAt': Timestamp.now(),
    });
//    await FirebaseFirestore.instance.collection('last').doc(widget.otherUserId).set({'last' : DateTime.now()});
    List<dynamic>mp = [];
    if(Hive.box('chatapp').get(widget.otherUserId)!=null)mp=Hive.box('chatapp').get(widget.otherUserId); 
    mp.add({
      'message' : _enteredMessage,
      'createdAt' : Timestamp.now().toString(),
      'sent' : true,
    });
    print(mp);
    Hive.box('chatapp').put(widget.otherUserId, mp);
    }
    _enteredMessage = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(
              Icons.send,
            ),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}