import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:huna/constant.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/splash.dart';
import 'package:huna/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:phone_state_i/phone_state_i.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer_util.dart';
import 'call/callscreen.dart';
import 'call/callscreen_ravi.dart';
import 'chat/chat_model.dart';
import 'database/database_helper.dart';
import 'home.dart';
import 'libraries/sip_ua/sip_ua_helper.dart';
import 'overlay_pip/overlay_handler.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Phoenix(
      child: EasyLocalization(
          supportedLocales: [Locale('en')],
          path: 'assets/translations',
          fallbackLocale: Locale('en'),
          child: MyApp()),
    ),
  );
}

typedef PageContentBuilder = Widget Function(
    [SIPUAHelper helper, Object arguments]);

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}


class _MyAppState extends State<MyApp> implements SipUaHelperListener {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  final SIPUAHelper _helper = SIPUAHelper();

  @override
  void initState() {
    super.initState();
    _watchAllPhoneCallEvents();
    _helper.addSipUaHelperListener(this);

  }

  _watchAllPhoneCallEvents() {

    phoneStateCallEvent.listen((PhoneStateCallEvent event) {

      print('Call is Incoming/Connected' + event.stateC);

      if(event.stateC == "true"){
        try {
          _helper.findCall(CURRENT_CALL_ID).hold();
        } catch (e) {print(e);}
      }

      if(event.stateC == "false"){
        try {
          _helper.findCall(CURRENT_CALL_ID).unhold();
        } catch (e) {print(e);}
      }

    });


  }

  @override
  deactivate() {
    super.deactivate();
    // _helper.removeSipUaHelperListener(this);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
  //  callscreen

    Map<String, PageContentBuilder> routes = {'/callscreen': ([SIPUAHelper helper, Object arguments]) => CallScreenPage(helper, arguments as Call,"Unknown"),};

    // ignore: missing_return
    Route<dynamic> generateRoute(RouteSettings settings) {

      final String name = settings.name;
      final PageContentBuilder pageContentBuilder = routes[name];

      if (pageContentBuilder != null) {
        if (settings.arguments != null) {
          final Route route = MaterialPageRoute<Widget>(
              settings: RouteSettings(name: name),
              builder: (context) => pageContentBuilder(_helper, settings.arguments));
          return route;
        } else {
          final Route route = MaterialPageRoute<Widget>(
              settings: RouteSettings(name: name),
              builder: (context) => pageContentBuilder(_helper));
          return route;
        }
      }
    }

    return LayoutBuilder(                           //return LayoutBuilder
      builder: (context, constraints) {
        return OrientationBuilder(                  //return OrientationBuilder
          builder: (context, orientation) {
            //initialize SizerUtil()
            SizerUtil().init(constraints, orientation);  //initialize SizerUtil
            return  ChangeNotifierProvider<OverlayHandlerProvider>(
                create: (_) => OverlayHandlerProvider(),
                child : OverlaySupport(
                  child: MaterialApp(
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    title: 'Huna',
                    onGenerateRoute: generateRoute,
                    navigatorKey: navigatorKey,
                    theme: ThemeData(
                      fontFamily: 'SF Pro',
                      primaryColor: Colors.white,
                    ),
//      debugShowCheckedModeBanner: false,
                    //home: HomePage(_helper),
                    debugShowCheckedModeBanner: false,

                    // home: IncomingCallScreen(CallInfoModel('','Ravi','')),
                    //home: OutgoingCallScreen(CallInfoModel('','Ravi',''),true),
                    home: SplashPage(_helper),
                  ),
                ));
          },
        );
      },
    );





  }

  @override
  Future<void> callStateChanged(Call call, CallState callState)  async {

    CURRENT_CALL_ID = call.id;

    print(callState.state.toString());

    if (callState.state == CallStateEnum.CALL_INITIATION) {

      print(' CURRENT_CALL_ID'+ call.id);

      if (call.direction == "INCOMING") {
      } else {
        print("INSIDE MAIN");

      }
    }

    if (callState.state == CallStateEnum.STREAM) {}

    if (callState.state == CallStateEnum.ENDED) {
     // hideOverlayNotification('CALL_UI');
     // call.hangup();

    }

    if (callState.state == CallStateEnum.FAILED) {
     // hideOverlayNotification('CALL_UI');
    //  call.hangup();
    }
  }


  @override
  void onNewMessage(SIPMessageRequest msg) {
   // onNewMgs(msg);
  }

 /* *//*Future<void> onNewMgs(SIPMessageRequest msg) async {

    var jsonMSg = json.decode(msg.request.body.toString());

    var senderId = jsonMSg["senderId"].toString() ?? "00";
    var senderName = jsonMSg["senderName"].toString() ?? "00";
    var textMsg = jsonMSg["msg"].toString() ?? "";

    var asteriskName = await Future.value(PreferencesManager().getName());

    await DatabaseHelper().updateChatHistory(textMsg, int.parse(senderId), senderName);
    await DatabaseHelper().insertChat(ChatMessage(asteriskName,textMsg, "text", "url", 1, int.parse(senderId), senderName, getDateWithTime()));

    showNotification(senderName, textMsg, senderId);
    SoundPlayer.playChatSound();*//*

  }*/

  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}


  void hideOverlayNotification(String key){

    showSimpleNotification(
      Container(width: 0,height: 0,),
      key: Key(key),
      elevation: 0,
      duration: Duration(milliseconds: 500),
      autoDismiss: true,
      slideDismiss: true,
      background: Colors.transparent,
    );

  }

  void showNotification(senderName, textMsg, String senderId) {

    if (MSG_TARGET != senderId)
      showSimpleNotification(
        Text("New Message From $senderName\n$textMsg"),
        background: Colors.cyan,
        key: Key('MESSAGE_UI')
      );
  }


}
