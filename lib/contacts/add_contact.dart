import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/home.dart';
import 'package:huna/auth/login.dart';
import 'package:huna/auth/sign_up.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:huna/utils/show.dart';
import 'package:random_color/random_color.dart';
import 'package:http/http.dart' as http;
import 'package:sdp_transform/sdp_transform.dart';

import '../constant.dart';
class AddContactPage extends StatefulWidget {
  AddContactPage({Key key}) : super(key: key);

  @override
  _AddContactPage createState() => _AddContactPage();

}
class _AddContactPage extends State<AddContactPage> {

  DatabaseHelper db = DatabaseHelper();
  
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('add_contact'.tr())),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: height,
          width: width,
          child: _contactsFields(),
        ),
      ),
    );
  }

  _contactsFields() {

    return Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 15),
      child: Column(
          children: <Widget>[
            _addTextFiled('name'.tr(), Icons.person, _name,20),
            SizedBox(height: 10,),
            _addTextFiled('number'.tr(), Icons.call, _number,15, typeNumber: true),
            SizedBox(height: 10,),
            _addTextFiled('email'.tr(), Icons.email, _email,60),
            SizedBox(height: 50,),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: RaisedButton(
                color: colorAccent,
                child: Text('save'.tr(), style: TextStyle(fontSize: 20, color: Colors.white)),
                onPressed: (){
                  _addContactToDatabase();
                },
              ),
            )
          ]));
  }

  _addTextFiled(String title, IconData icon, TextEditingController tec, int maxLength,{bool typeNumber = false}){

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
          prefixIcon: Icon(icon, color: Colors.grey,),
          border: OutlineInputBorder(),
          labelText: title,
          labelStyle: TextStyle(),
        ),
      ),
    );
  }
  
  _addContactToDatabase() async {

    RandomColor _randomColor = RandomColor();
    var _color = _randomColor.randomColor(colorSaturation: ColorSaturation.lowSaturation).toString().replaceAll("(", "").replaceAll(")", "").replaceAll("Color", "");
    print(_color);


    if(_name.text.isEmpty){
      Show.showToast ('please_enter_name'.tr(),false);
      return;
    }

    if(_number.text.isEmpty){
      Show.showToast('please_enter_number'.tr(),false);
      return;
    }

    if(_email.text.isEmpty){
      Show.showToast('please_enter_email'.tr(),false);
      return;
    }

    var id =  _number.text.trim();
    var asteriskName = await Future.value(PreferencesManager().getName());
    var contact = ContactsModel(asteriskName,id,_name.text.trim(), _number.text.trim(), _color, _email.text.trim(),1, "");

    var userMail = await   PreferencesManager().getEmail();
    var loginUserCallerId = await PreferencesManager().getName();


    var body = {
      "user" : userMail,
      'emailId': _email.text.trim().toString(),
      "loginUserCallerId" : loginUserCallerId

    };

    /*var body = jsonEncode({
      "user" : userMail.toString(),
      'emailId': _email.text.trim().toString(),
      //"loginUserCallerId" : int.parse(loginUserCallerId)
    });*/

    Show.showLoading(context);

    final apiAddContact = await http.post(ADD_CONTACT, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

    if (apiAddContact.statusCode == 200) {

      Map<String, dynamic> map = jsonDecode(apiAddContact.body);

      if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); Show.hideLoading(); return;}

      if(map['response'] == "SUCCESS") {

        Show.hideLoading();
        Show.showToast('contact_saved'.tr(),false);

      }

      }else{
      Show.hideLoading();
      Show.showToast('Something went wrong, Please try again later', false);
    }


    
  }

/* var bodyEditContact = {
          "user" : userMail,
          'emailId': _email.text.trim(),
          "userPhone" : _number.text.trim(),
          "fullName" : _name.text.trim()
        };*/

// final apiEditContact = await http.post(EDIT_CONTACT, body: bodyEditContact).timeout(Duration(seconds: 60), onTimeout: () {return null;});

/*if (apiEditContact.statusCode == 200) {

          Map<String, dynamic> map = jsonDecode(apiEditContact.body);

          if(map['response'] == "ERROR"){Show.showToast('EDIT _CONTACT${map['message']}', false); Show.hideLoading(); return;}

          if(map['response'] == "SUCCESS") {
            db.insertContact(contact);
            Show.showToast('contact_saved'.tr(),false);
            Navigator.pop(context,true);
          }

          }else{
          Show.hideLoading();
          Show.showToast('Something went wrong, Please try again later', false);
        }*/

 

}
