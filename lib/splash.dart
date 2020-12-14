import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:huna/auth/login.dart';
import 'package:huna/chat/chat_model.dart';
import 'package:huna/constant.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/home.dart';
import 'package:huna/libraries/sip_ua/logger.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/utils/show.dart';
import 'package:random_color/random_color.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';

import 'auth/login.dart';
import 'database/database_helper.dart';
import 'libraries/sip_ua/sip_ua_helper.dart';

class SplashPage extends StatefulWidget {
  final SIPUAHelper _helper;

  SplashPage(this._helper, {Key key}) : super(key: key);

  @override
  _SplashPage createState() => _SplashPage();
}

class _SplashPage extends State<SplashPage> implements SipUaHelperListener {
  SIPUAHelper get helper => widget._helper;

  int retryAttempt = 0;
  bool isProgressVisible = true;
  bool isRetryVisible = false;

  @override
  void initState() {
    super.initState();
    helper.addSipUaHelperListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => checkNext(context));
  }

  @override
  deactivate() {
    super.deactivate();
    helper.removeSipUaHelperListener(this);
  }

  void startConnect() {
    retryAttempt = retryAttempt + 1;

    if (retryAttempt > 3) {
      helper.unregister(true);
      PreferencesManager().clearPref();
      Phoenix.rebirth(context);
    }

    ///Show.showToast("Connecting ..", false);
    setState(() {
      isProgressVisible = true;
      isRetryVisible = false;
    });

    var pref = PreferencesManager();

    Future.wait([
      pref.getDisplayName(),
      pref.getName(),
      pref.getPassword(),
      pref.getDomain(),
      pref.getRole(),
      pref.isContactSavedFirstTime()
    ]).then((value) => {getContactsAndRegister(value)});
  }

  void showLoading() {
    setState(() {
      isProgressVisible = true;
      isRetryVisible = false;
    });
  }

  void hideLoading() {
    setState(() {
      isProgressVisible = false;
      isRetryVisible = true;
    });
  }

  showRetryDialog(){
    Alert(
      context: context,
      type: AlertType.error,
      title: "Error!",
      desc: "Something went wrong, Please try again",
      buttons: [
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () =>{
            Navigator.pop(context),
            showLoading(),
            startConnect()
          },

          width: 120,
        )
      ],
    ).show();
  }

  getContactsAndRegister(List<Object> currentUser) async {
    var displayName = currentUser[0];
    var name = currentUser[1] as String;
    var password = currentUser[2];
    var domain = currentUser[3];
    var role = currentUser[4];

    var isContactSavedFirstTime = currentUser[5];

    /*  if(isContactSavedFirstTime){
      registerSip(name, name+DOMAIN_, password, displayName, WSS);
      return;
    }
*/
   // var body = {'domain': '$domain', 'role': '$role'};

    var token = await PreferencesManager().getToken();

    final response = await http
        .get(FETCH_ORG_USER, headers: {"Authorization": token})
        .timeout(Duration(seconds: 60), onTimeout: () {
      hideLoading();
      return null;
    });

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> map = jsonDecode(response.body);

      if (map['response'] == "ERROR") {
        Show.showToast('${map['message']}', false);
        hideLoading();
      } else {
        print("CONTACTS");
        print(response.body);

        if (map['data'].isNotEmpty) {
          RandomColor _randomColor = RandomColor();
          var data = map['data'] as List<dynamic>;
          Batch batch;

          DatabaseHelper().database.then((value) => {
                batch = value.batch(),
                data.forEach((element) {
                  var _color = _randomColor
                      .randomColor(
                          colorSaturation: ColorSaturation.lowSaturation)
                      .toString()
                      .replaceAll("(", "")
                      .replaceAll(")", "")
                      .replaceAll("Color", "");
                  if (element['UserID'] != name) {
                    batch.insert(
                        CONTACT_TABLE,
                        ContactsModel(
                                name,
                                element['UserID'],
                                element['FullName'],
                                'empty',
                                _color,
                                element['UserEmail'],
                                1,
                              element['profileImage']== null ? "" : element['profileImage'],
                        )
                            .toMap(),
                        conflictAlgorithm: ConflictAlgorithm.replace);
                  }

                  /*if (chatList.isEmpty) {
                    if (element['UserID'] != name) {
                      DatabaseHelper().updateChatHistory("Start new chat",
                          int.parse(element['UserID']), element['FullName'],
                          isRead: 1);
                    }
                  }*/
                }),
                batch.commit().then((value) => {
                      PreferencesManager().saveIsContactSavedFirstTime(true),
                      registerSip(
                          name, name + DOMAIN_, password, displayName, WSS)
                    })
              });
        } else {
          registerSip(name, name + DOMAIN_, password, displayName, WSS);
          throw Exception('No contacts');
        }
      }
    } else {
      hideLoading();
      throw Exception('Failed to get contact list of org');
    }
  }

  void checkNext(BuildContext context) {
    new Future.delayed(const Duration(seconds: 1), () {
      var pref = PreferencesManager();
      var name = pref.getName();

      name.then((value) {
        if (value.isEmpty) {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoginPage(helper)));
             // MaterialPageRoute(builder: (context) => CallScreenPageTwo()));
          return;
        } else {
          startConnect();
          return;
        }
      });
    });
  }

  Widget loading() {
    return SpinKitFadingCube(
      color: colorAccent,
      size: 30.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: colorOrange,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              image:  AssetImage('assets/images/bg.jpg'),),
              Container(
                color: colorOrangeTrans,
                height: double.infinity,
                width: double.infinity,),
          Visibility(
            visible: false,
            child: Image(
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              image:  AssetImage('assets/images/layer_2.jpg'),),
          ),

            Container(
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              child: AvatarGlow(
                glowColor: Colors.white,
                endRadius: 125.0,
                duration: Duration(milliseconds: 1500),
                repeat: true,
                animate: isProgressVisible,
                showTwoGlows: true,
                repeatPauseDuration: Duration(milliseconds: 100),
                child: Material(
                  elevation: 2.0,
                  shape: CircleBorder(
                    side: BorderSide(width: 2, color: Colors.white),
                  ),

                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child:  Image(
                      image: AssetImage('assets/images/huna_small.png'),
                      fit: BoxFit.scaleDown,
                      width: double.infinity,
                      height: 65,),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Image(
                height: 43,
                fit : BoxFit.cover,
                image:  AssetImage('assets/images/huna_name.png'),),

              SizedBox(height: 6,),
              Image(
                fit: BoxFit.cover,
                height: 20,
                image:  AssetImage('assets/images/nmcc.png'),),
                  SizedBox(height: 25,),
              ],)

            )
        ],),
      ),
    );
  }

  @override
  void callStateChanged(Call call, CallState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {
    this.setState(() {
      if (state.state == RegistrationStateEnum.REGISTERED) {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage(helper)));
      } else {
        setState(() {
          isProgressVisible = false;
          isRetryVisible = true;
        });
      }
      ;
    });
  }

  @override
  void transportStateChanged(TransportState state) {}

  void registerSip(String userName, domain, password, displayName, wss) {

    print("SIP");
    print(userName);
    print(domain);
    print(password);
    print(displayName);
    print(wss);



    UaSettings settings = UaSettings();
    settings.webSocketUrl = wss;
    settings.uri = domain;
    settings.authorizationUser = userName;
    settings.password = password;
    settings.displayName = displayName;
    settings.userAgent = 'Dart SIP Client v1.0.0';
    helper.start(settings);
  }
}
