import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cryptography/cryptography.dart';
import 'allchats.dart';
import 'dart:convert';


class UserScreen extends StatefulWidget {
  const UserScreen({ Key? key }) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
    User? user = FirebaseAuth.instance.currentUser;

    func(List<int>cipher, List<int>nonce ,String userid, String otheruserid, List<int>aaaa, List<int>bbbb) async {
    final algo00 = Cryptography.instance.x25519();
    final algo = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    SimpleKeyPair kpr = await algo00.newKeyPair();
    SimplePublicKey pkpr = await kpr.extractPublicKey();
    final aprkbytes = Hive.box('chatapp').get('key');
    // final apkbytes = await FirebaseFirestore.instance.collection('key').doc(userid).get();
    // final bpkbytes = await FirebaseFirestore.instance.collection('key').doc(otheruserid).get();
    //List<int> aaaa = apkbytes.data()!['key'].cast<int>(); List<int> bbbb = bpkbytes.data()!['key'].cast<int>();
    SimplePublicKey apk = SimplePublicKey(aaaa, type: pkpr.type);
    SimplePublicKey bpk = SimplePublicKey(bbbb, type: pkpr.type);
     SimpleKeyPair ak = SimpleKeyPairData(aprkbytes, publicKey: apk, type: pkpr.type);
    final s2 = await algo00.sharedSecretKey(keyPair: ak, remotePublicKey: bpk);
    final secbox = SecretBox(cipher, nonce: nonce, mac: Mac.empty);
    final decbox = await algo.decrypt(secbox, secretKey: s2);
    return utf8.decode(decbox);
} 

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton(
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemidentifier) {
              if (itemidentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: user!.getIdToken(),
        builder: (ctx, futuresnapshot){
          if (futuresnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').orderBy('userName').snapshots(),
                builder: (ctx, usersnap){
                  if (usersnap.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  var users = usersnap.data!.docs;
                  Map<String, List<dynamic>>mp = {};
                  for(int i=0; i< users.length; i++)mp[(users[i].data() as dynamic)['userId'].toString()] = (users[i].data() as dynamic)['key'];//==null ? [] : (users[i].data() as dynamic)['key'] ;
                  return Container( 
                        height: 600,
                          child: Column(
                            children: [
                              Container(
                                height: 0,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('chat').doc(user!.uid).collection('newmess').orderBy('createdAt', descending: false).snapshots(),
                                  builder: (ctx, chatSnapshot){
                                    // if (usersnap.connectionState == ConnectionState.waiting)
                                    // return Center(child: CircularProgressIndicator());
                                    var chatDocs = chatSnapshot.data?.docs ?? [];
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance.collection('last').doc(user!.uid).get(),
                                      builder: (ctx, snap){
                                        // if(snap.connectionState == ConnectionState.waiting)
                                        //   return Center(child: CircularProgressIndicator());
                                        Timestamp tme;
                                        if(snap.data?.data() != null)tme = (snap.data!.data() as dynamic)['last'] as Timestamp;
                                        else tme = Timestamp.now();
                            
                                        return ListView.builder(
                                          itemCount: chatDocs.length,
                                          itemBuilder: (ctx, i){
                                            String from = (chatDocs[i].data() as dynamic)['from'].toString();
                                            List<int> cipher = (chatDocs[i].data() as dynamic)['cipher'].cast<int>();
                                            List<int> nonce = (chatDocs[i].data() as dynamic)['nonce'].cast<int>();
                                            Timestamp time00 = (chatDocs[i].data() as dynamic)['createdAt'] as Timestamp;
                                            List<int> aaaa = mp[user!.uid]!.cast<int>();
                                            List<int> bbbb = mp[from]!.cast<int>();
                                            return FutureBuilder(
                                              future: func(cipher, nonce, user!.uid, from, aaaa, bbbb),
                                              builder: (ctx, snapcc){
                                                if(snapcc.connectionState == ConnectionState.done){
                                                String message = snapcc.data.toString();
                                                if(tme.compareTo(time00) < 0){
                                                List<dynamic>mp = [];
                                                if(Hive.box('chatapp').get(from) != null)mp = Hive.box('chatapp').get(from); 
                                                mp.add({
                                                  'message' : message,
                                                  'createdAt' : time00.toString(),
                                                  'sent' : false,
                                                });
                                                Hive.box('chatapp').put(from, mp);
                                                FirebaseFirestore.instance.collection('last').doc(user!.uid).set({'last' : time00});
                                              }}
                                              return SizedBox(height: 0,);
                                              }
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 600, child : AllChats(users, user))
                              //ShrinkWra(child: AllChats(users, user)),
                            ],
                          ),
                  );
                },
          );
        },
      ),
    );
  }
}

// Column(
//           children: [
//             StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('chat').doc(user!.uid).collection('newmess').orderBy('createdAt', descending: false).snapshots(),
//           builder: (ctx, chatSnapshot){
//             var chatDocs = chatSnapshot.data?.docs ?? [];
//             return FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance.collection('last').doc(user!.uid).get(),
//               builder: (con, snap){
//                 if(snap.connectionState == ConnectionState.waiting){
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   Timestamp tme;
//                   if(snap.data!.data() != null)
//                      tme = (snap.data!.data() as dynamic)['last'] as Timestamp;//DateTime.parse((snap.data!.data() as dynamic)['last'].toString());
//                   else tme = Timestamp.now();

//                   return ListView.builder(
//                     itemCount: chatDocs.length,
//                     itemBuilder: (ctx, i){
//                       return FutureBuilder(
//                         future: FirebaseFirestore.instance.collection('key').get(),
//                         builder: (ctx, keysnap){
//                           var keys = keysnap.data;
//                           List<dynamic>akk = (keys[])
//                           List<dynamic>bkk = keys['from'];
//                           String from = (chatDocs[i].data() as dynamic)['from'].toString();
//                           List<int> cipher = (chatDocs[i].data() as dynamic)['cipher'].cast<int>();
//                           List<int> nonce = (chatDocs[i].data() as dynamic)['nonce'].cast<int>(); 
//                           Timestamp time00 = (chatDocs[i].data() as dynamic)['createdAt'] as Timestamp;
//                           return FutureBuilder(
//                             future: func(cipher, nonce, user!.uid, from, keys[user!.uid]['key'], keys[from]['key']),
//                             builder: (ctx, snapp){
//                               return SizedBox.shrink();
//                             },
//                           );
//                         },
//                       );
//                     },
//                   );
//               },
//             );
//           },
//         ),
//         AllChats(),
//           ],
//         );
// StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('chat').doc(user!.uid).collection('newmess').orderBy('createdAt', descending: false).snapshots(),
//           builder: (ctx, chatSnapshot){
//             var chatDocs = chatSnapshot.data?.docs ?? [];
//             return FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance.collection('last').doc(user!.uid).get(),
//               builder: (con, snap){
//                 if(snap.connectionState == ConnectionState.waiting){
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   Timestamp tme;
//                   if(snap.data!.data() != null)
//                      tme = (snap.data!.data() as dynamic)['last'] as Timestamp;//DateTime.parse((snap.data!.data() as dynamic)['last'].toString());
//                   else tme = Timestamp.now();

//                   return Column(
//                     children: [
//                       ListView.builder(itemBuilder: itemBuilder),
                      
//                     ],
//                   );
//               },
//             );
//           },
//         );