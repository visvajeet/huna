import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huna/call/dial_pad.dart';
import 'package:huna/constant.dart';
import 'package:huna/contacts/contact_info.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/chat_manager.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

import 'calls_model.dart';

class CallHistoryPage extends StatefulWidget {

  final SIPUAHelper _helper;
  CallHistoryPage(this._helper, {Key key}) : super(key: key);

  @override
  _CallHistoryPage createState() => _CallHistoryPage();

}
class _CallHistoryPage extends State<CallHistoryPage> {

  SIPUAHelper get helper => widget._helper;

  DatabaseHelper db = DatabaseHelper();
  List<CallsModel> callList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (callList == null) {
      callList = List<CallsModel>();
      updateCallList();
    }

    void navigateToDialPad() async {

      bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return DialPad(helper);
      }));
      if (result == true) {updateCallList();}
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.dialpad),
        backgroundColor: colorAccent,
        mini: false,
        onPressed: (){
          navigateToDialPad();
      },),
      body: Container(
        color: Colors.white,
        height: height,
        width: width,
        child: callList.isNotEmpty ? Column(children: <Widget>[
          Expanded(child: getCallList(),)
        ],) : FutureBuilder(
            future: Future.delayed(Duration(milliseconds: 500)),
            builder: (c, s) => s.connectionState == ConnectionState.done
                ? getEmptyListView()
                : Text('')
        )
      ),
    );
  }

  Widget getEmptyListView()  {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 5),
        child: Container(
          alignment: Alignment.center,
          height: height,
          width: width,
          child: Column(
            children: <Widget>[
              SizedBox(height: height/4,),
              Icon(Icons.access_time,size: 100,color: Colors.grey,),
              SizedBox(height: 4,),
              Text('your_call_history_is_empty'.tr(), style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: Colors.grey)),
              SizedBox(height: 4,),
              Text('no_call_history'.tr(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
        ));
  }

  ListView getCallList() {

    final width = MediaQuery.of(context).size.width;

    return ListView.builder(

      itemCount:  callList.length ,
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 100),
      itemBuilder: (BuildContext context, int position) {

        return Card(
          color: Colors.white,
          elevation: 0.5,
          child: Container(
            child: ExpansionTile(
              initiallyExpanded: false,
              key: PageStorageKey('myScrollable'),
              trailing: Icon(
                Icons.face,
                size: 0.0,
              ),
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 15.0, 15.0),
                    child: InkWell(
                      onTap: () {
                        var callInfo = callList[position];
                        var id = callInfo.id;
                        var contactInfo = ContactsModel('',id,callInfo.name, callInfo.number, callInfo.color, callInfo.name, 1, callInfo.profilePic);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactInfoPage(helper,contactInfo)));
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        colorAccent,
                        child: Text(
                            getFirstLetter(this.callList[position].name),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(this.callList[position].name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      SizedBox(height: 1),
                      Row(
                        children: <Widget>[
                         getIconOfCallType(callList[position],size: 15),
                         SizedBox(width: 5,),
                         getNameOfCallType(callList[position]),

                      ],),
                      SizedBox(height: 4,),
                      Text(getDayAndTime(this.callList[position].date), style: TextStyle(fontSize: 12, color: Colors.black54),),
                      SizedBox(height: 10,)

                    ],
                  )
                ],
              ),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 25,
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () {
                        CallManager().makeCall(helper, callList[position].id,isVideoCall: false);
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 23,
                      icon: Icon(Icons.message, color: Colors.cyan),
                      onPressed: () {  ChatManger().makeChat(context, helper, callList[position].id, callList[position].name, callList[position].email);},
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 28,
                      icon: Icon(Icons.videocam, color: Colors.green),
                      onPressed: () { CallManager().makeCall(helper,callList[position].id,isVideoCall: true);},
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      iconSize: 25,
                      icon: Icon(Icons.info, color: Colors.grey),
                      onPressed: () {
                        var callInfo = callList[position];
                        var id = callInfo.id;
                        var contactInfo = ContactsModel('',id,callInfo.name, callInfo.number, callInfo.color, callInfo.name, 0,callInfo.profilePic);
                        Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => ContactInfoPage(helper,contactInfo)));
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateCallList() async {
    var asteriskName = await Future.value(PreferencesManager().getName());
    print('AAAA'+asteriskName);
    final Future<Database> dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<CallsModel>> contactListFuture =
      db.getCallListAll(asteriskName);
      contactListFuture.then((list) {
        print(list.toString());
        setState(() {
          this.callList = list;
          this.count = list.length;
        });
      });
    });
  }


}
