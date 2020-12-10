import 'dart:convert';

import 'package:adhara_socket_io/manager.dart';
import 'package:adhara_socket_io/options.dart';
import 'package:adhara_socket_io/socket.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:huna/chat/chat_history_model.dart';
import 'package:huna/chat/receivedmessagewidget.dart';
import 'package:huna/chat/sentmessagewidget.dart';
import 'package:huna/constant.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:random_color/random_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_model.dart';
import 'chat_room_model.dart';
import 'global.dart';
import 'mycircleavatar.dart';
import 'package:http/http.dart' as http;


class ChatScreen extends StatefulWidget {


  final ChatRoom chatRoom;

  final SIPUAHelper _helper;
  ChatScreen(this._helper, this.chatRoom, {Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
  
}

class _ChatScreenState extends State<ChatScreen> {

  SIPUAHelper get helper => widget._helper;

  var socketUrl = "http://60826934a68b.ngrok.io";

  SocketIO mSocket;

  List<ChatMessages> chats = List<ChatMessages>();
  var count = 0;

  final _chat = TextEditingController();
  final _controller = ScrollController();

  var userNameChatToSend = "";


  void initState() {
    super.initState();

     userNameChatToSend = widget.chatRoom.user1;
     connectSocket(widget.chatRoom.roomId);
   // MSG_TARGET = widget.chatHistoryModel.uuid.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) => loadMessages(context));

    getAllChat();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed');
        Navigator.pop(context, true);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black54),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 15,
                backgroundColor: colorAccent,
                child: AutoSizeText(
                    getFirstLetter(widget.chatRoom.user1),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white)),
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.chatRoom.user1,
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.clip,
                  ),
//                Text(
//                  "Online",
//                  style: Theme.of(context).textTheme.subtitle.apply(
//                        color: myGreen,
//                      ),
//                )
                ],
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.phone),
            //  onPressed: () { CallManager().makeCall(helper, widget.chatHistoryModel.uuid.toString(), isVideoCall: false);},
            ),
            IconButton(
              icon: Icon(Icons.videocam),
            //  onPressed: () { CallManager().makeCall(helper, widget.chatHistoryModel.uuid.toString(), isVideoCall: true);},
            ),

          ],
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      padding: const EdgeInsets.only(top: 15,bottom: 80,left: 15,right: 15),
                      itemCount: chats.length,
                      itemBuilder: (ctx, i) {
                        if (chats[i].from == widget.chatRoom.user1) {
                          return ReceivedMessagesWidget(chat: chats[i]);
                        } else {
                          return SentMessageWidget(chat: chats[i]);
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15.0),
                    height: 61,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35.0),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                    color: Colors.grey)
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.face), onPressed: () {
                                      emojiPicker();
                                }),
                                Expanded(
                                  child: TextField(
                                    controller: _chat,
                                    decoration: InputDecoration(
                                        hintText: "Type Something...",
                                        border: InputBorder.none),
                                  ),
                                ),

                                IconButton(
                                  icon: Icon(Icons.attach_file),
                                  onPressed: () {
                                    showPicker();
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(color: myGreen, shape: BoxShape.circle),
                          child: InkWell(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onTap: () {
                              if(_chat.text.trim().isNotEmpty)
                              onSend(_chat.text);
                              setState(() {
                                //_showBottom = true;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            Container(),
          ],
        ),
      ),
    );
  }

  void showPicker() async {

    FilePickerResult result = await FilePicker.platform.pickFiles();
    if(result != null) {
      PlatformFile file = result.files.first;
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      var message = "${file.name}~${file.extension}~fileUrl";
      var asteriskName = await Future.value(PreferencesManager().getName());
     // await  DatabaseHelper().updateChatHistory(message, int.parse(widget.chatHistoryModel.uuid.toString()),widget.chatHistoryModel.name,isRead: 1);
    //  await  DatabaseHelper().insertChat(ChatMessage(asteriskName,message,"text","url",0,int.parse(widget.chatHistoryModel.uuid.toString()), widget.chatHistoryModel.name,getDateWithTime()));
      loadMessages(context);
      try {
        SoundPlayer.playChatSound();
      } catch (e) {}

    } else {}

  }


  void onSend(String message) async {

    _chat.text = "";
    print("Sending");

    var pref = PreferencesManager();

    var value;

    await Future.wait([
      pref.getDisplayName(),
      pref.getName(),
    ]).then((val) => {value = val});


    var chat = ChatMessages(
      firstPerson: widget.chatRoom.user1,
      secondPerson: widget.chatRoom.user2,
      message: message,
      from : widget.chatRoom.user2,
      seenStatus: "0",
      deletedStatus: "0",
      createdOn: getDateWithTimeForChat()

    );



    addChat(chat);
    saveChat(chat);
    sendMessageSocket(message, widget.chatRoom.roomId, widget.chatRoom.user2, widget.chatRoom.user1);


    var asteriskName = await Future.value(PreferencesManager().getName());
   // await  DatabaseHelper().updateChatHistory(message, int.parse(widget.chatHistoryModel.uuid.toString()),widget.chatHistoryModel.name,isRead: 1);

    loadMessages(context);

    try {
      SoundPlayer.playChatSound();
    } catch (e) {}


   // helper.sendMessage(widget.chatHistoryModel.uuid.toString(), msg().toString());



//    print(message.toJson());
//
//    var msg = message.text;
//
//   helper.sendMessage(target, msg);
//

//    setState(() {
//      messages = [...messages, message];
//      print(messages.length);
//    });


  }


  loadMessages(BuildContext context) {

    print("fetching");

      setState(() {
      //  this.chats = chatList;
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      });
  //  });
  }

  getAllChat() async {

    print("FETCH CHAT API CALL...");

    var body = jsonEncode({
      "firstPerson" : widget.chatRoom.user2,
      "secondPerson" : widget.chatRoom.user1
    });

    final fetchChat = await http.post(FETCH_CHAT,
        headers: {"Content-Type": "application/json"}, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

    if (fetchChat.statusCode == 200) {

      print(fetchChat.body);
      Map<String, dynamic> map = jsonDecode(fetchChat.body);

      if (map['response'] == "ERROR") {
        Show.showToast('${map['message']}', false);

      } else {
        print("CHAT");
        print(fetchChat.body);
        if (map['data'].isNotEmpty) {

          RandomColor _randomColor = RandomColor();
          var data = map['data'] as List<dynamic>;

          data.forEach((element) {
            chats.add(ChatMessages(
              from: element["SentBy"],
              createdOn:  element["CreatedOn"],
              seenStatus: element["seenStatus"],
              deletedStatus: element["deletedStatus"],
              message: element["message"],
            ));
          });

          var duplicates = chats.toSet().toList();
          updateChatList(duplicates);


        }else{
          print("CHAT_EMP");
        }
      }


    }else{
      toast("error while getting list");
    }

  }

  Future<void> updateChatList(List<ChatMessages> list) async {

    setState(() {
      this.chats = list;
      this.count = list.length;
    });
  }

  Future<void> addChat(ChatMessages chat) async {

    var newChat = this.chats;
    newChat.add(chat);

    setState(() {
      this.chats = newChat;
      this.count = newChat.length;
    });
  }

   saveChat(ChatMessages chat) async {

     print("CHAT SAVE API CALL...");

     var body = jsonEncode({

       "firstPerson" : chat.secondPerson,
       "secondPerson" : chat.firstPerson,
       "message" : chat.message,
       "createdOn" : chat.createdOn,
       "from" : chat.from,
       "seenStatus" : "0",
       "deletedStatus" : "0",
       "deletedBy" : ""

     });

     print("CHAT OBJECT");
     print(body);

     final fetchChat = await http.post(SAVE_CHAT,
         headers: {"Content-Type": "application/json"}, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

     if (fetchChat.statusCode == 200) {

       Map<String, dynamic> map = jsonDecode(fetchChat.body);

       if (map['response'] == "ERROR") {
         Show.showToast('${map['message']}', false);

         print("ERROR SAVE CHAT API CALL...");
         print(map['message']);

       } else {
         print("CHAT_SAVE");
       }

     }else{
       toast("error while save chat");
     }
  }

  @override
  void callStateChanged(Call call, CallState state) {
  }


  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}

//  void ShowBannerMessage(String msgFrom,String message) {
//
//    showSimpleNotification(
//      Text("New Message From ${msgFrom} \n ${message}"),
//      background: Colors.green,
//    );
//  }

  void sendMessageSocket(String message, String roomId,String fromEmail,String toEmail) {

    var data = ({
      "message": message,
      "room": roomId,
      "from": fromEmail,
      "to":toEmail,
    });

    if(mSocket !=null){mSocket.emitWithAck("message", [data]);
    }else{print("Socket is null");}

  }

    void connectSocket(String roomId){

      print("Connecting socket..");

      void joinRooms(List<String>roomIdArray) {

        for (var i = 0; i < roomIdArray.length; i++) {

          var obj = {
            "room": roomIdArray[i]
          };
          mSocket.emit("join", [obj]);

        }
      }

      Future<void> startSocket(List<String>roomIdArray) async {

        var URI = socketUrl;

        SocketIO socket = await SocketIOManager().createInstance(SocketOptions(
          //Socket IO server URI
            URI,
            //Enable or disable platform channel logging
            enableLogging: false,
            transports: [Transports.WEB_SOCKET /*, Transports.POLLING*/
            ] //Enable required transport
        ));


        socket.onConnect((data) {
          print("Socket Connected Done Successfully!!!!!");
          mSocket = socket;
          joinRooms(roomIdArray);

        });

        socket.onConnectError((data) {
          print("Socket connection error.."+data.toString());
        });

        socket.on("newMessage", (data) {
          print("New Message Received :) ");

         /* var data = ({
            "message": message,
            "room": roomId,
            "from": fromEmail,
            "to":toEmail,
          });*/

          var chat = ChatMessages(
            message: data["message"],
            from: data["from"],
            createdOn: getDateWithTimeForChat()
          );
          addChat(chat);
          print(data);
        });

        socket.connect();

      }

      startSocket([roomId]);
    }

  Widget emojiPicker() {

     return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        print(emoji);
      },
    );
  }
}

