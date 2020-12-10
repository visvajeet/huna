import 'package:flutter/src/widgets/framework.dart';
import 'package:huna/call/calls_model.dart';
import 'package:huna/call/callscreen.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/overlay_pip/overlay_service.dart';
import 'package:huna/utils/utils.dart';
import 'package:random_color/random_color.dart';

import '../constant.dart';

class CallManager {

  Future<void> makeCall(SIPUAHelper helper, String id, {bool isVideoCall = false}) async {

    ContactsModel contactModel;
    int isSaved;
    String name;
    String number;
    String color;
    RandomColor _randomColor = RandomColor();

    var asteriskName = await Future.value(PreferencesManager().getName());

    DatabaseHelper().getContact(id).then((value) async => {
          if (value.isEmpty)
            {
              isSaved = 0,
              name = id,
              number = id,
              color = _randomColor
                  .randomColor(colorSaturation: ColorSaturation.lowSaturation)
                  .toString()
                  .replaceAll("(", "")
                  .replaceAll(")", "")
                  .replaceAll("Color", "")
            }
          else
            {
              contactModel = ContactsModel.fromMapObject(value[0]),
              isSaved = 1,
              name = contactModel.name,
              number = contactModel.number,
              color = contactModel.color,
            },


          await DatabaseHelper().insertCall(CallsModel(asteriskName,id,isSaved, name, number, CallType.OUTGOING.toString(),
              getDateWithTime(), "", color, "", "")),
      
          PreferencesManager().saveCurrentCallerName(name).then((value) =>
          {
            call(helper,id,isVideoCall)
          })
        });


  }

  void call(helper ,id,isVideoCall){
    try {
      helper.findCall(CURRENT_CALL_ID).hangup();
      helper.call(id, !isVideoCall);
    } catch (e) {
      print(e);
      helper.call(id, !isVideoCall);
    }
  }

  Future<void> incomingCall(Call call, SIPUAHelper helper, BuildContext ct) async {

    String id = call.remote_identity;

    ContactsModel contactModel;
    int isSaved;
    String name;
    String number;
    String color;
    RandomColor _randomColor = RandomColor();

    var asteriskName = await Future.value(PreferencesManager().getName());
    DatabaseHelper().getContact(id).then((value) async => {


          if (value.isEmpty)
            {
              isSaved = 0,
              name = id,
              number = id,
              color = _randomColor
                  .randomColor(colorSaturation: ColorSaturation.lowSaturation)
                  .toString()
                  .replaceAll("(", "")
                  .replaceAll(")", "")
                  .replaceAll("Color", "")
            }
          else
            {
              contactModel = ContactsModel.fromMapObject(value[0]),
              isSaved = 1,
              name = contactModel.name,
              number = contactModel.number,
              color = contactModel.color,
            },

           await DatabaseHelper().insertCall(CallsModel(asteriskName,id,isSaved, name, number, CallType.INCOMING.toString(), getDateWithTime(), "", color, ""
           ,contactModel.email)),

          PreferencesManager().saveCurrentCallerName(name).then((value) =>
            {

              OverlayService().addVideosOverlay(ct, CallScreenPage(helper,call,name))
             // navigatorKey.currentState.pushNamed('/callscreen', arguments: call)

            })
    });
  }

  @override
  void callStateChanged(Call call, CallState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}
}
