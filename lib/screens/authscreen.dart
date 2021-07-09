import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/authform.dart';
import 'package:cryptography/cryptography.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(String email, String password, String username,
      bool isLogin, BuildContext ctx) async {
    UserCredential userCredential;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        
      await FirebaseFirestore.instance.collection('last').doc(userCredential.user!.uid).set({'last' : Timestamp.now()});
      final algo = Cryptography.instance.x25519();
      SimpleKeyPair kk = await algo.newKeyPair();
      SimplePublicKey kkp = await kk.extractPublicKey();
      await Hive.box('chatapp').put('key', await kk.extractPrivateKeyBytes());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'userName': username,
        'email': email,
        'userId' : userCredential.user!.uid,
        'key' : kkp.bytes
        //'image_url': url,
      });
      //FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({'key' : kkp.bytes});
      }

      
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials!';
      if (err.message != null) message = err.message!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          //backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
         // backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthForm(_isLoading, _submitAuthForm),
    );
  }
}
