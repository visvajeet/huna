import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:huna/auth/login.dart';
import 'package:huna/call/calls_model.dart';
import 'package:huna/chat/chat_history_model.dart';
import 'package:huna/chat/chat_room_model.dart';
import 'package:huna/chat/main_chat.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/libraries/sip_ua/utils.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:path/path.dart';
import 'package:random_color/random_color.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';

class ChatManger {

  Future<void> makeChat(BuildContext context, SIPUAHelper helper, String number, String name, String email) async {


    Show.showLoading(context);
    var userMail = await   PreferencesManager().getEmail();

    var body = jsonEncode({"User" : userMail,});

    final fetchRoomId = await http.post(FETCH_ROOM_ID,
        headers: {"Content-Type": "application/json"}, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

    if (fetchRoomId.statusCode == 200) {

      Map<String, dynamic> map = jsonDecode(fetchRoomId.body);

      if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); Show.hideLoading(); return;}

      if(map['response'] == "SUCCESS") {

        if (map['data'].isNotEmpty) {

          Show.hideLoading();

          var list = map['data'] as List<dynamic>;
          var currentUser = list.firstWhere((element) => element["User1"] == email, orElse: () => null);

          print(currentUser);

          if(currentUser != null){

            var forChat = {
              "RoomId":  currentUser["RoomId"],
              "User1":   currentUser["User1"],
              "User2":   currentUser["User2"],
            };

            var chatRoom = ChatRoom(forChat["RoomId"],forChat["User1"],forChat["User2"]);

            var asteriskName = await Future.value(PreferencesManager().getName());

            var chat = ChatHistoryModel(asteriskName,"","",int.parse(number),name,0);



            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(helper,chatRoom)));

          }else{
            Show.hideLoading();
            Show.showToast('Seems this contact is not in your contacts list.', false);
          }

        }else{
          Show.hideLoading();
          Show.showToast('No room ids found', false);
        }
      }

    }else{
      Show.hideLoading();
      Show.showToast('Something went wrong, Please try again later', false);
    }


  }

}