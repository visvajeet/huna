import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huna/call/calls_model.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constant.dart';

String getDayAndTime(String date) {

  DateFormat dateFormat = DateFormat("dd-MMMM-yyyy HH:mm:ss");
  DateTime dateTime = dateFormat.parse(date);
  return DateFormat('EEEE').format(dateTime) + " "  + DateFormat('h:mm a').format(dateTime);

}


String getDateWithTime() {
  return DateFormat("dd-MMMM-yyyy HH:mm:ss").format(DateTime.now());
}

//12/3 1:05 PM
String getDateWithTimeForChat() {
  return DateFormat("MM/dd hh:mm aa").format(DateTime.now()).toUpperCase();
}


String getFirstLetter(String title) {
  if(title.length > 1){
    return title.substring(0, 1).toUpperCase();
  }else {
    return title;
  }

}


Icon getIconOfCallType(CallsModel call, {double size = 25}) {

  if(call.callType == CallType.MISSED.toString() ){
    return  Icon(Icons.phone_missed, color: Colors.red, size: size);
  }else if(call.callType == CallType.OUTGOING.toString() ) {
    return  Icon(Icons.call_made, color: Colors.lightBlue, size: size);
  }
  else if(call.callType == CallType.INCOMING.toString() ) {
    return  Icon(Icons.call_received, color: Colors.green, size: size);
  }
  else {
    return  Icon(Icons.do_not_disturb, color: Colors.blueGrey, size: size);
  }
}


Text getNameOfCallType(CallsModel call) {

  if(call.callType == CallType.MISSED.toString() ){
    return  Text('missed_call'.tr(), style: TextStyle(fontSize: 14, color: Colors.black54),);
  }else if(call.callType == CallType.OUTGOING.toString() ) {
    return  Text('outgoing_call'.tr(), style: TextStyle(fontSize: 14, color: Colors.black54),);
  }
  else if(call.callType == CallType.INCOMING.toString() ) {
    return  Text('incoming_call'.tr(), style: TextStyle(fontSize: 14, color: Colors.black54),);
  }
  else {
    return  Text('rejected_call'.tr(), style: TextStyle(fontSize: 14, color: Colors.black54),);
  }
}

