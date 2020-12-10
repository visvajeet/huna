import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:huna/call/calls_model.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/chat_manager.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/home.dart';
import 'package:huna/auth/login.dart';
import 'package:huna/auth/sign_up.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/utils/show.dart';
import 'package:random_color/random_color.dart';
import 'package:sqflite/sqflite.dart';
import 'package:huna/utils/utils.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import '../constant.dart';

class ContactInfoPage extends StatefulWidget {
  final ContactsModel contact;

  final SIPUAHelper _helper;
  ContactInfoPage(this._helper, this.contact, {Key key}) : super(key: key);

  @override
  _ContactInfoPage createState() => _ContactInfoPage();
}

class _ContactInfoPage extends State<ContactInfoPage> {

  SIPUAHelper get helper => widget._helper;

  bool isUpdateContact = false;

  DatabaseHelper db = DatabaseHelper();
  List<CallsModel> callList;
  int count = 0;

  final _name = TextEditingController();
  final _id = TextEditingController();
  final _number = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (callList == null) {
      callList = List<CallsModel>();
      updateCallList();

      _name.text = widget.contact.name;
      _id.text = widget.contact.id;
      _number.text = widget.contact.number;
      _email.text = widget.contact.email;
    }

    _header() {
      String name;
      IconData icon;

      name = "edit".tr();
      icon = Icons.edit;

    /*  if (widget.contact.saved == 1) {
        name = "edit".tr();
        icon = Icons.edit;
      } else{
        name = "add".tr();
        icon = Icons.add;
      }*/

      return IntrinsicHeight(
          child: new Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Flexible(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () => {
                        if (widget.contact.saved == 1)
                          {saveContact(true)}
                        else
                          {saveContact(false)}
                      },
                      padding: EdgeInsets.all(7.0),
                      child: Column(
                        // Replace with a Row for horizontal icon + text
                        children: <Widget>[
                          Icon(
                            icon,
                            size: 23,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            name,
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                  height: 60,
                  color: Colors.white,
                )),
            Flexible(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox.expand(
                    child: Visibility(
                      child: FlatButton(
                        onPressed: () => {onDelete()},
                        padding: EdgeInsets.all(7.0),
                        child: Column(
                          // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Icon(
                              Icons.delete,
                              size: 23,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  height: 60,
                  color: Colors.white,
                )),
            Flexible(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () => {
                      WcFlutterShare.share(
                      sharePopupTitle: 'Share',
                      subject: 'Contact',
                      text: '${widget.contact.name}\n${widget.contact.number}',
                      mimeType: 'text/plain')
                      },
                      padding: EdgeInsets.all(7.0),
                      child: Column(
                        // Replace with a Row for horizontal icon + text
                        children: <Widget>[
                          Icon(
                            Icons.share,
                            size: 23,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            "Share",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                  height: 60,
                  color: Colors.white,
                ))
          ]));
    }

    return WillPopScope(
      onWillPop: () {
        print('Back button pressed');
        Navigator.pop(context, isUpdateContact);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(),
          body: Container(
            color: Colors.white,
            height: height,
            width: width,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: getCallList(),
                ),
                _header(),
                SizedBox(
                  height: 0,
                )
              ],
            ),
          )),
    );
  }

  ListView getCallList() {
    final double circleRadius = 100.0;
    final double circleBorderWidth = 0;

    return ListView.builder(
      itemCount: callList == null ? 1 : callList.length + 1,
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 100),
      itemBuilder: (BuildContext context, int position) {
        if (position == 0) {
          // return the header
          return Padding(
              padding: EdgeInsets.only(top: 10, bottom: 5),
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: circleRadius / 2.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      shadowColor: Colors.grey,
                      elevation: 2,
                      child: Container(
                        color: Color(0xFFFAFAFA),
                        height: 200.0,
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                        padding: EdgeInsets.all(circleBorderWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Color(int.parse(widget.contact.color)),
                              child: Text(getFirstLetter(widget.contact.name),
                                  style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(widget.contact.name,
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87)),
                            SizedBox(
                              height: 5,
                            ),
                            Visibility(

                              child: Text(widget.contact.number,
                                  style: TextStyle(
                                      letterSpacing: 0.3,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black54)),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  iconSize: 28,
                                  icon: Icon(Icons.call, color: Colors.green),
                                  onPressed: () { CallManager().makeCall(helper,widget.contact.id,isVideoCall: false);},
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                IconButton(
                                  iconSize: 25,
                                  icon: Icon(Icons.message, color: Colors.cyan),
                                  onPressed: () {  ChatManger().makeChat(context, helper, widget.contact.id, widget.contact.name,widget.contact.email);},
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                IconButton(
                                  iconSize: 32,
                                  icon:
                                      Icon(Icons.videocam, color: Colors.green),
                                  onPressed: () { CallManager().makeCall(helper,widget.contact.id,isVideoCall: true);},
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ],
              ));
        }
        position -= 1;
        return Card(
          color: Colors.white,
          elevation: 1.0,
          child: Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 30.0),
                  child: InkWell(
                    child: getIconOfCallType(callList[position]),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(getDayAndTime(this.callList[position].date),
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            color: Colors.black87)),
                    SizedBox(height: 1),
                    getNameOfCallType(callList[position]),
                    SizedBox(
                      height: 5,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void updateCallList() {
    final Future<Database> dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<CallsModel>> contactListFuture =
          db.getCallListOfNumber(widget.contact.number);
      contactListFuture.then((list) {
        print(list.toString());
        setState(() {
          this.callList = list;
          this.count = list.length;
        });
      });
    });
  }

  //Edit contact

  saveContact(bool isEdit) {
    String title;
   /*
    if (widget.contact.saved == 0) {
      title = 'edit_contact'.tr();
    } else {
      title = 'save_contact'.tr();
    }*/

    title = 'edit_contact'.tr();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  _addTextFiled('name'.tr(), Icons.person, _name, 20),
                  SizedBox(
                    height: 10,
                  ),
                  _addTextFiled('number'.tr(), Icons.call, _number, 15,typeNumber : true),
                  SizedBox(
                    height: 10,
                  ),
                  _addTextFiled('email'.tr(), Icons.email, _email, 60),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('cancel_cap'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('ok'.tr()),
                onPressed: () {
                  _addContactToDatabase(isEdit,Navigator.of(context));
                },
              )
            ],
          );
        });
  }

  //Add or Edit contact
  _addContactToDatabase(bool isEdit, NavigatorState of) async {
    var _randomColor = RandomColor();
    var _color = _randomColor
        .randomColor(colorSaturation: ColorSaturation.lowSaturation)
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("Color", "");
    print(_color);

    if (_name.text.isEmpty) {
      Show.showToast('please_enter_name'.tr(), false);
      return;
    }

    if (_number.text.isEmpty) {
      Show.showToast('please_enter_number'.tr(), false);
      return;
    }

    if (_email.text.isEmpty) {
      Show.showToast('please_enter_email'.tr(), false);
      return;
    }

    ContactsModel contact;

    if (isEdit) {
      var asteriskName = await Future.value(PreferencesManager().getName());
      contact = ContactsModel(asteriskName, widget.contact.id,_name.text.trim(),
          _number.text.trim(), widget.contact.color, _email.text.trim(), 1, "");
      db.updateContact(contact);
      print(contact.number);
      Show.showToast('contact_updated'.tr(), false);


    } else {
      var asteriskName = await Future.value(PreferencesManager().getName());
      contact = ContactsModel(asteriskName,widget.contact.id,_name.text.trim(),
          _number.text.trim(), _color, _email.text.trim(), 1, "");
      db.insertContact(contact);
      Show.showToast('contact_saved'.tr(), false);
    }

    widget.contact.name = contact.name;
    widget.contact.email = contact.email;
    widget.contact.number = contact.number;
    widget.contact.color = contact.color;

    updateCallList();
    isUpdateContact = true;
    of.pop();

  }

  //Delete contact
  onDelete() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('are_you_sure_delete_contact'.tr()),
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
                  _deleteContact();
                },
              )
            ],
          );
        });
  }

  _deleteContact(){
    Show.showToast('contact_deleted'.tr(), false);
    db.deleteContact(widget.contact.id);
    Navigator.pop(context,true);
  }
  _addTextFiled(
      String title, IconData icon, TextEditingController tec, int maxLength,{bool typeNumber = false}) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: colorAccent,
      ),
      child: TextFormField(
        keyboardType: typeNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: typeNumber ? [new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,|\\-]')),] : [new BlacklistingTextInputFormatter(new RegExp('')),],
        controller: tec,
        cursorColor: Theme.of(context).cursorColor,
        maxLength: maxLength,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          border: OutlineInputBorder(),
          labelText: title,
          labelStyle: TextStyle(),
        ),
      ),
    );
  }
}
