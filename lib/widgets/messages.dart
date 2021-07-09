import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Messages extends StatefulWidget {
  final String otherUserId; final String otherUsername;
  Messages(this.otherUserId, this.otherUsername);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('chatapp').listenable(), 
      builder: (context, box, widgetw){
        List<dynamic>mp = [];
        if(Hive.box('chatapp').get(widget.otherUserId) != null)
          mp = Hive.box('chatapp').get(widget.otherUserId);
        if(mp.length == 0)
          return Center(child: Text('No messages yet'),);
        return ListView.builder(
          //reverse: true,
          itemCount: mp.length,
          itemBuilder: (ctx, index){
            return MessageBubble(
              widget.otherUsername, mp[index]['message'], mp[index]['sent']//, ValueKey(mp[index].)
            );
          },
          );
      }
      );
  }
}

class MessageBubble extends StatelessWidget {
  final String name; final String message; final bool isMe;// final Key key;
  MessageBubble(this.name, this.message, this.isMe);//, this.key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              width: 140,
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isMe ? "Me" : name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).accentTextTheme.headline6!.color,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).accentTextTheme.headline6!.color,
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    clipBehavior: Clip.antiAlias,
    );
  }
}
