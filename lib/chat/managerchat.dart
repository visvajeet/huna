//import 'package:flutter/material.dart';;
//import 'chat_model.dart';
//import 'database_helper.dart';
//import 'history.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      theme: ThemeData(primarySwatch: Colors.blue),
//      home: MyHomePage(),
//    );
//  }
//}
//
//class MyHomePage extends StatelessWidget {
//
//
//  DatabaseHelper databaseHelper = DatabaseHelper();
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Saving data'),
//      ),
//      body: Row(
//        //mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: RaisedButton(
//              child: Text('Read'),
//              onPressed: () {
//                 readChatHistory();
//              },
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: RaisedButton(
//              child: Text('Save'),
//              onPressed: () {
//                addChatHistory(context);
//              },
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//
//  _deleteChat() async{
//    int id = await databaseHelper.deleteChatByUuId(500);
//    print('deleted row: $id');
//  }
//
//  _saveChat() async {
//
//    int id = await databaseHelper.insertChat(ChatMessage("hi 2","text","",1,500));
//
//     print('inserted row: $id');
//
//  }
//
//
//  _readChat() async {
//
//  var chats = await databaseHelper.getChatByUUid(500);
//
//  for (int i = 0; i < chats.length; i++) {
//
//    print(chats[i].msg);
//
//  }
//
//  }
//
//  readChatHistory() async {
//
//
//    var chats = await databaseHelper.getChatHistory();
//
//    for (int i = 0; i < chats.length; i++) {
//
//      print(chats[i].msg);
//      print(chats[i].uuid);
//
//    }
//
//  }
//
//  addChatHistory(BuildContext context) {
//
//
//   // databaseHelper.updateChatHistory("hello 780", 800);
//
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => ChatScreen()),
//    );
//
//  }
//
//}