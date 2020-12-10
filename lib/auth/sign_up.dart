import 'dart:convert';

import 'package:custom_switch_button/custom_switch_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:huna/auth/login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:huna/constant.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/utils/show.dart';
import 'package:http/http.dart' as http;
import 'package:huna/utils/utils.dart';
import "package:huna/utils/string_extension.dart";
import 'package:sizer/sizer.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  final SIPUAHelper _helper;

  SignUpPage(this._helper, {Key key}) : super(key: key);

  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  SIPUAHelper get helper => widget._helper;

  String _picked = "Individual";

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _organisationName = TextEditingController();
  final _domainName = TextEditingController();

  bool isLoading = false;
  bool emailValid = false;

  bool isChecked = false;


  @override
  void initState() {
    super.initState();
    
    _email.addListener(() {

      emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_email.text);
      try {
        _domainName.text = _email.text.split('@')[1].capitalize();
      } catch (e) {print(e);
      _domainName.text = "";
      }

    });


  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        //Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
            ),
            Text('',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, controller, {bool readOnly = false, bool typeNumber = false, bool isPassword = false}) {
    return Visibility(
      child: Container(
        margin: EdgeInsets.only(right: 0,left: 0,top: 5,bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: TextStyle(color: blackLight, fontWeight: FontWeight.bold, fontSize: 13.5.sp),),
            SizedBox(height: 13,),
            TextField(
                style: TextStyle(color: Color(0xff60608f), fontSize: 13.0.sp),
                cursorColor: Color(0xff60608f),
                readOnly: readOnly,
                keyboardType: typeNumber ? TextInputType.number : TextInputType.text,
                inputFormatters: typeNumber ? [new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,|\\-]')),] : [new BlacklistingTextInputFormatter(new RegExp('')),],
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Color(0xfff2f6f9),
                    filled: true))
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: (){

        if(_picked == 'Organisation'){

          if(_organisationName.text.isEmpty){
            Show.showToast ('please_enter_organisation'.tr(),false);
            return;
          }

          /*if(_domainName.text.isEmpty){
            Show.showToast('domain_not_valid'.tr(),false);
            return;
          }*/

        }

        if(_name.text.isEmpty){
          Show.showToast ('please_enter_fullName'.tr(),false);
          return;
        }

        if(_phone.text.isEmpty){
          Show.showToast('please_enter_phone'.tr(),false);
          return;
        }


        if(_email.text.isEmpty){
          Show.showToast ('please_enter_email'.tr(),false);
          return;
        }

        if(!emailValid){
          Show.showToast ('please_enter_valid_email'.tr(),false);
          return;
        }

        if(_password.text.isEmpty){
          Show.showToast('please_enter_password'.tr(),false);
          return;
        }

        doSignUp();


      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 1.0.h, 12, 20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    colorOrangeLight,
                    colorOrangeLight,
                  ])),
          child: Text(
            'CREATE',
            style: TextStyle(
                fontSize: 15.0.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }



  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField('fullName'.tr(), _name),
        _entryField('phone'.tr(), _phone , typeNumber: true),
        _entryField('email'.tr(), _email),
        _entryField('password'.tr(), _password, isPassword: true),
      ],
    );
  }

  Widget _emailPasswordWidgetWithOrganization() {
    return Column(
      children: <Widget>[
        _entryField('organizationName'.tr(), _organisationName),
        _entryField('domainName'.tr(), _domainName, readOnly: true),
        _entryField('fullName'.tr(), _name),
        _entryField('phone'.tr(), _phone, typeNumber: true),
        _entryField('email'.tr(), _email),
        _entryField('password'.tr(), _password, isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: height,
        child: Stack(fit: StackFit.expand, children: [
          Image(
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            image: AssetImage('assets/images/bg.jpg'),
          ),
          Container(
            height: height,
            width: double.infinity,
            child: signUpUi(height)
          ),
        ]
        ),
      ),
    );
  }



  Widget loading(){
    return  SpinKitFadingCube(
      color: colorOrange,
      size: 30.0,
    );
  }

  signAs() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[

            new Text('INDV', style: new TextStyle(color: colorAccent, fontWeight: FontWeight.bold, fontSize: 12.0.sp,),),
            SizedBox(width: 7,),
            GestureDetector(
              onTap: (){
                setState(() {
                  if(_picked == "Individual"){
                    _picked = "Organisation";
                    isChecked = true;
                  }else{
                    _picked = "Individual";
                    isChecked = false;
                  }
                });
              },
              child: Center(
                child: CustomSwitchButton(
                  buttonHeight: 23,
                  indicatorWidth: 16,
                  backgroundColor: colorAccent,
                  unCheckedColor: Colors.yellow[600],
                  animationDuration: Duration(milliseconds: 400),
                  checkedColor: Colors.yellow[600],
                  checked: isChecked,
                ),
              ),
            ),
            SizedBox(width: 7,),
            new Text('ORG', style: new TextStyle(color: colorAccent, fontWeight: FontWeight.bold, fontSize: 12.0.sp,),),

          ]),
    );
  }

  signUpUi(double height){

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            color: whiteTrans,
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            children: [
              _top(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(right: 22,left: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        signAs(),
                        _signInToAccess(),
                        SizedBox(height: 10),
                        _picked == 'Individual'
                            ? _emailPasswordWidget()
                            : _emailPasswordWidgetWithOrganization(),
                        SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Visibility(
                                maintainAnimation: true,
                                maintainState: true,
                                maintainSize: true,
                                visible: !isLoading,
                                child: _submitButton()
                            ),
                            Visibility(
                              maintainAnimation: true,
                              maintainState: true,
                              maintainSize: true,
                              visible: isLoading,
                              child: loading(),
                            )
                          ],),
                        _bottomLabel(),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );



  }

  _signInToAccess() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(
                  color: colorOrangeLight,
                  fontSize: 28.0.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'to create your account.',
              style: TextStyle(
                  color: colorAccent,
                  fontSize: 15.0.sp,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }



  Future<void> doSignUp() async {

    setState(() {isLoading = true;});

    var body = jsonEncode({

      "data": {

        "name":  _name.text,
        "phone": int.parse(_phone.text),
        "email":  _email.text,
        "password": _password.text,
        "domain":  _domainName.text,
        "status": "InActive",
        "role": _picked == "Individual" ? "individual" : "admin",
        "authenticationLevel": "database",
        "loginCounter": 0
      }

    });

    print("BODY");
    print(body);

    final response = await http.post(SIGN_UP_API,
        body: body ,headers: {"Content-Type": "application/json"} ).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          failedSignUp();
          return null;
        });

    if (response.statusCode == 200) {

      setState(() {isLoading = false;});

      print(response.body);

      Map<String, dynamic> map = jsonDecode(response.body);
      if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); setState(() {isLoading = false;});}

      else{

        if(map['response'] == "SUCCESS"){

          print('Sign up success');
          isLoading = false;
          Show.showToast("Signed up successfully", false);
          Phoenix.rebirth(context);

        }
      }

      } else {
      setState(() {isLoading = false;});
      failedSignUp();
      throw Exception('Failed to sign up');
    }
  }

  void failedSignUp(){
    setState(() {isLoading = false;});
    Show.showToast('something_went_wrong'.tr(), true);
  }

  Widget _top() {
    return Container(
        height: 27.0.h,
        width: double.infinity,
        color: colorOrangeLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 3.0.h,
            ),
            Image(
              height: 15.0.h,
              fit: BoxFit.contain,
              image: AssetImage('assets/images/logo_style_2.png'),
            ),
          ],
        ));
  }

  Widget _bottomLabel() {

    return Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'already_have_an_account'.tr(),
            style: TextStyle(
                color: blackLight,
                fontSize: 13.0.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
              onTap: () {
                if (!isLoading) {
                  // Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(helper)));
                }
              },
              child: Text(
                'Sign in',
                style: TextStyle(
                    color: colorAccent,
                    fontSize: 13.0.sp,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }


}
