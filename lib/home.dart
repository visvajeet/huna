import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:huna/call/call_history.dart';
import 'package:huna/call/callscreen_sip_ua.dart';
import 'package:huna/contacts/contacts.dart';
import 'package:huna/dashboard/dashboard.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/rtc_session.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/splash.dart';
import 'package:huna/utils/show.dart';
import "package:huna/utils/string_extension.dart";
import 'package:huna/utils/utils.dart';
import 'package:huna/webview/webview.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
 
import 'call/callscreen.dart';
import 'call/callscreen_ravi.dart';
import 'chat/history.dart';
import 'constant.dart';
import 'libraries/sip_ua/sip_ua_helper.dart';
import 'manager/call_manager.dart';
import 'overlay_pip/overlay_handler.dart';
import 'overlay_pip/overlay_service.dart';


class HomePage extends StatefulWidget {

  final SIPUAHelper _helper;
  HomePage(this._helper, {Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> implements SipUaHelperListener {

  SIPUAHelper get helper => widget._helper;


  String userName = " ";
  String userEmail = "";
  int currentIndex;
  var pref = PreferencesManager();

  var height = 100;
  var width = 100;



  final PageStorageBucket bucket = PageStorageBucket();


  @override
  deactivate() {
    super.deactivate();
    helper.removeSipUaHelperListener(this);
  }

  @override
  void initState() {
    super.initState();
    helper.addSipUaHelperListener(this);

    currentIndex = 0;
    Future.wait([pref.getDisplayName(), pref.getEmail()])
        .then((value) => {
              setState(() {
                if (value[0].isNotEmpty) {
                  userName = value[0].capitalize();
                }
                if (value[1].isNotEmpty) {
                  userEmail = value[1].capitalize();
                }

              })
            });
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget _getAppBarTitle() {
    switch (currentIndex) {
      case 0:
        return Text('dashboard'.tr());
        break;
      case 1:
        return Text('contacts'.tr());
        break;
      case 2:
        return Text('call'.tr());
        break;
      case 3:
        return Text('chat'.tr());

        break;

      default:
        return Text('');
        break;
    }
  }

  //Bottom Navigation view
  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      elevation: 10,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Icon(Icons.dashboard),
          ),
          title: Text('Dashboard'),
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Icon(Icons.contacts),
          ),
          title: Text('Contacts'),
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Icon(Icons.call),
          ),
          title: Text('Call'),
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Icon(Icons.chat),
          ),
          title: Text('Chat'),
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Icon(Icons.more_horiz),
          ),
          title: Text('More'),
        )
      ],
      currentIndex: currentIndex,
      selectedItemColor: colorAccent,
      onTap: (index) {
        setState(() {
          if (index != 4) {
            currentIndex = index;
          }else{
            print('MORE');
           // OverlayService().addVideosOverlay(context, CallScreenPage(widget._helper,widget._helper.findCall('id')));
          }
        });
      },
    );
  }

  //Side Drawer
  Widget _drawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _drawerHeader(),
        _userStatus(),
        ListTile(
          leading: Icon(Icons.add_circle),
          title: Text('Add Account'),
          onTap: () {
            Show.showToast('feature_not_available_yet'.tr(), false);

          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Show.showToast('feature_not_available_yet'.tr(), false);
          },
        ),
       /* ListTile(
          leading: Icon(Icons.call_to_action),
          title: Text('Conference'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Webview()));},
        ),*/
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Sign out'),
          onTap: () {
            askSignOut();
          },
        ),
      ],
    ));
  }

  //Drawer Header
  _drawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
          color: Colors.black54,
          image: DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.1), BlendMode.dstATop),
              image: AssetImage('assets/images/background.jpeg'))),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: colorAccent,
                child: Text(getFirstLetter(userName),
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.normal,
                        color: Colors.white)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                child: Text(userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    )))
          ],
        ),
      ),
    );
  }

  _userStatus() {
    return ExpansionTile(
        title: Row(children: <Widget>[
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 18,
          ),
          SizedBox(
            width: 10,
          ),
          Text("Available")
        ]),
        children: <Widget>[
          InkWell(
              onTap: () {},
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Available")
                    ]),
              )),
          InkWell(
              onTap: () {},
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Icon(
                        Icons.brightness_1,
                        color: Colors.red[900],
                        size: 18,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Busy")
                    ]),
              )),
          InkWell(
              onTap: () {},
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Icon(
                        Icons.remove_circle,
                        color: Colors.red[900],
                        size: 18,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Do not disturb")
                    ]),
              )),
          InkWell(
              onTap: () {},
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Icon(
                        Icons.access_time,
                        color: Colors.amber[600],
                        size: 18,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Away")
                    ]),
              )),
        ]);
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> pages = [
      DashBoardPage(key: PageStorageKey('Page1'),),
      ContactsPage(helper, key: PageStorageKey('Page2'),),
      CallHistoryPage( helper, key: PageStorageKey('Page3'),),
      ChatHistoryPage(helper, key: PageStorageKey('Page4'),),
    ];


    return WillPopScope(
      onWillPop: () async {
        askExit();
      },
      child: Scaffold(
          appBar: AppBar(title: _getAppBarTitle()),
          body: Center(
            child: PageStorage(
              child: pages[currentIndex],
              bucket: bucket,
            ),
          ),
          bottomNavigationBar: _bottomNavigationBar(),
          drawer: _drawer(),
      ),
    );
  }

  askSignOut() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('are_you_sure_sign_out'.tr()),
            actions: <Widget>[
              new FlatButton(
                child: new Text('no'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('yes'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                  signOut();
                },
              )
            ],
          );
        });
  }
  askExit() {
    return showDialog(
        context: context,
        builder: (ct) {
          return AlertDialog(
            title: Text('are_you_sure_exit'.tr()),
            actions: <Widget>[
              new FlatButton(
                child: new Text('no'.tr()),
                onPressed: () {
                  Navigator.of(ct).pop();
                },
              ),
              new FlatButton(
                child: new Text('yes'.tr()),
                onPressed: () {
                  Navigator.of(ct).pop();
                  onExit();
                },
              )
            ],
          );
        });
  }

  //Sign out
  signOut() {
    var db = DatabaseHelper();

    Future.wait([
      db.deleteAllFromTable(USER_TABLE),
     // db.deleteAllFromTable(CONTACT_TABLE),
    //  db.deleteAllFromTable(CHAT_HISTORY_TABLE),
    //  db.deleteAllFromTable(CHAT_TABLE),
   //   db.deleteAllFromTable(CALL_TABLE)

    ]).then((value) => {
          doSignOut()
        });
  }

  void doSignOut(){

    PreferencesManager().clearPref();
    try {
      helper.unregister(true);
      helper.stop();
    } catch (e) {
      print(e);
      helper.stop();
    }

    if (Platform.isAndroid) {
      SystemNavigator.pop();
    }else {
      Phoenix.rebirth(context);
    }

  }

  void onExit(){
    print('APP TERMINATE');
    widget._helper.removeSipUaHelperListener(this);
    widget._helper.stop();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void callStateChanged(Call call, CallState callState) {

    CURRENT_CALL_ID = call.id;

    if (callState.state == CallStateEnum.CALL_INITIATION) {

      print(' CURRENT_CALL_ID'+ call.id);

      if (call.direction == "INCOMING") {

        
        CallManager().incomingCall(call,widget._helper,context);
        SoundPlayer.playIncomingCallSound();



      } else {
        print("INSIDE MAIN");

        PreferencesManager().getCurrentCallerName().then((value) => {
            OverlayService().addVideosOverlay(context, CallScreenPage(widget._helper,call,value))
        });


        // navigatorKey.currentState.pushNamed('/callscreen', arguments: call);

      }
    }

    if (callState.state == CallStateEnum.ENDED) {
     // SoundPlayer.stopSound();
      Provider.of<OverlayHandlerProvider>(context, listen: false).removeOverlay(context);
      SoundPlayer.earpieceOnOff(false);
      //call.hangup();

    }

    if (callState.state == CallStateEnum.FAILED) {
     // SoundPlayer.stopSound();
      Provider.of<OverlayHandlerProvider>(context, listen: false).removeOverlay(context);
      SoundPlayer.earpieceOnOff(false);
      //call.hangup();
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}


}
