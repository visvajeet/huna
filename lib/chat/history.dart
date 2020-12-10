import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:huna/constant.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/chat_manager.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:random_color/random_color.dart';

import 'chat_history_model.dart';

class ChatHistoryPage extends StatefulWidget {

  final SIPUAHelper _helper;
  ChatHistoryPage(this._helper, {Key key}) : super(key: key);

  @override
  _ChatHistoryPage createState() => _ChatHistoryPage();
}

class _ChatHistoryPage extends State<ChatHistoryPage> {

  SIPUAHelper get helper => widget._helper;

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<ChatHistoryModel> chats = List<ChatHistoryModel>();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatRoomsAndChatHistory();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
       //body
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (ctx, i) {
         return InkWell(
           onTap: () async {
             print('efe');
             ChatManger().makeChat(context, helper, "1", chats[i].email, chats[i].email);
             },
           child: Card(
              color: Colors.white,
              elevation: 0.5,
              child: Container(
                key: PageStorageKey('myScrollable'),
                child: Container(
                 child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 15, 15.0, 15.0),
                        child: InkWell(
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor:
                            getColor(),
                            child: Text(
                                getFirstLetter(chats[i].email.toString()),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(chats[i].email.toString(),
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          SizedBox(height: 1),
                          Text(getMsg(chats[i].msg.toString()),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: getChatColor(chats[i]))),
                          SizedBox(height: 5),
                          Text(getDayAndTime(chats[i].dateTime.toString()),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87)),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
         );
        },
      ),
    );


  }



  getColor() {

    RandomColor _randomColor = RandomColor();

    var _color = _randomColor
        .randomColor(
        colorSaturation: ColorSaturation.lowSaturation)
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("Color", "");

    return Color(int.parse(_color));
  }

  String getMsg(String string) {
    if(string.contains('~')){
      return string.split('~')[0];
    }else{
      return string;
    }
  }

  Future<void> getChatRoomsAndChatHistory() async {

    var userMail = await   PreferencesManager().getEmail();

    var body = jsonEncode({"User" : userMail,});

    final fetchRoomId = await http.post(FETCH_ROOM_ID,
        headers: {"Content-Type": "application/json"}, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

    if (fetchRoomId.statusCode == 200) {

      Map<String, dynamic> map = jsonDecode(fetchRoomId.body);

      if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); return;}

      if(map['response'] == "SUCCESS") {

        print("CHAT Room");
        print(map);

        if (map['data'].isNotEmpty) {

          var allRoomsIds = (map['data'] as List<dynamic>).map((e) => e["RoomId"]).toList();
          print("ALL ROMS IDS");
          print(allRoomsIds);

          var bodyChatHistory = jsonEncode({
            "loginedUser" : userMail,
            "allRooms" : allRoomsIds
          });

          print("body_chat_history");
          print(bodyChatHistory);


          final fetchChatHistory= await http.post(FETCH_ALL_CHAT,
              headers: {"Content-Type": "application/json"}, body: bodyChatHistory).timeout(Duration(seconds: 60), onTimeout: () {return null;});

          Map<String, dynamic> mapChatHistory = jsonDecode(fetchChatHistory.body);

          if (fetchChatHistory.statusCode == 200) {
            if(mapChatHistory['response'] == "ERROR"){Show.showToast('${mapChatHistory['message']}', false); return;}

            if(mapChatHistory['response'] == "SUCCESS") {
              print("CHAT HISTORY");
              print(mapChatHistory);

              if (mapChatHistory['data'].isNotEmpty) {
                var list = mapChatHistory['data'] as List<dynamic>;
                var chatList = List<ChatHistoryModel>();
                list.forEach((element) {
                  var msgArray = element['msgArray'] as List<dynamic>;
                  print("MSG");
                  print(msgArray.last.Message);

                //  chatList.add( ChatHistoryModel( "" ,  msgArray[0].toString(),  "", 1, "D", 0));

                });
                updateChatHistoryList(chatList);

              }else{

                Show.showToast("No chat history found", false);
              }
            }

          }else{
            Show.showToast("something went wrong. [chat history]", false);
          }

        }else{
          Show.showToast("No chat history found", false);
        }
      }

    }else{
      toast("something went wrong. [Room - ids]");
    }

  }


  updateChatHistoryList(List<ChatHistoryModel> chat){
    setState(() {
      this.chats = chat;
    });
  }

}

getChatColor(ChatHistoryModel chat) {
  if(chat.isRead == 0){
    return Colors.green;
  }else{
    return Colors.black87;
  }
}


