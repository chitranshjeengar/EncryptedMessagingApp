import 'package:chatapp/screens/messagescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AllChats extends StatefulWidget {
  final users; final User? user;
  AllChats(this.users, this.user);

  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
                itemCount: widget.users.length,
                itemBuilder: (ctx, index) {
                  //snap.data!.docs.remove('newmess');  
                  if((widget.users[index].data() as dynamic)['userId'].toString() == widget.user!.uid)
                      return SizedBox.shrink();
                  return ChatTile(
                  (widget.users[index].data() as dynamic)['userName'].toString(), 
                  (widget.users[index].data() as dynamic)['userId'].toString(),
                  widget.user
                  );
                }
    );
  }
}


class ChatTile extends StatelessWidget {
  final String name; final String userId; final User? user;
  ChatTile(this.name, this.userId, this.user);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(this.name),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>MessageScreen(this.userId, this.name, user),
        ));
        }
    );
  }
}