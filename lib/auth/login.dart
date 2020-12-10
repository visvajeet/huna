import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:huna/auth/user_model.dart';
import 'package:huna/constant.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/home.dart';
import 'package:huna/auth/sign_up.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/utils/show.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  final SIPUAHelper _helper;

  LoginPage(this._helper, {Key key}) : super(key: key);

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> implements SipUaHelperListener {
  SIPUAHelper get helper => widget._helper;

  final _email = TextEditingController();
  final _forgotEmail = TextEditingController();
  final _password = TextEditingController();

  bool isLoading = false;

  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    helper.addSipUaHelperListener(this);
  }

  @override
  deactivate() {
    super.deactivate();
    helper.removeSipUaHelperListener(this);
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

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.only(right: 0,left: 0,top: 5,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: blackLight, fontWeight: FontWeight.bold, fontSize: 13.5.sp),),
          SizedBox(height: 10,),
          TextField(
              style: TextStyle(color: Color(0xff60608f), fontSize: 13.0.sp),
              cursorColor: Color(0xff60608f),
              enabled: !isLoading,
              controller: isPassword ? _password : _email,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff2f6f9),
                  filled: true))
        ],
      ),
    );
  }

  loginHome() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: colorOrangeTrans,
            height: double.infinity,
            width: double.infinity,
          ),
          Visibility(
            visible: false,
            child: Image(
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              image: AssetImage('assets/images/layer_2.jpg'),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 18.0.h),
              child: Image(
                fit: BoxFit.cover,
                height: 150,
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
          ),
          Container(
              alignment: Alignment.bottomCenter, child: signInSignUpButtons())
        ],
      ),
    );
  }

  loginUi() {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 2.0.h,
                      ),
                      _signInToAccess(),
                      _emailPasswordWidget(),
                      _loginAccountLabel(),
                      SizedBox(height: 20,),
                      socialButtons(),
                      SizedBox(height: 10,),

                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget signInSignUpButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage(helper)));
              },
              child: Text('SIGN UP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0.sp,
                      fontWeight: FontWeight.w600)),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50)),
            ),
          ),
        ),
        SizedBox(
          height: 18,
        ),
        Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: RaisedButton(
              disabledColor: Colors.white,
              onPressed: () {
                setState(() {
                  isFirst = false;
                });
              },
              child: Text('SIGN IN',
                  style: TextStyle(
                    color: colorOrange,
                    fontSize: 15.0.sp,
                    fontWeight: FontWeight.w600,
                  )),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
          ),
        ),
        SizedBox(
          height: 13.0.h,
        )
      ],
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if (_email.text.isEmpty) {
          Show.showToast('please_enter_email'.tr(), false);
          return;
        }

        if (_password.text.isEmpty) {
          Show.showToast('please_enter_password'.tr(), false);
          return;
        }

        getSipDetailsFromApi();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 3.0.h, 12, 20),
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
            'SIGN IN',
            style: TextStyle(
                fontSize: 15.0.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'do_not_have_an_account'.tr(),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage(helper)));
                }
              },
              child: Text(
                'sign_up'.tr(),
                style: TextStyle(
                    color: colorAccent,
                    fontSize: 13.0.sp,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Column(
        children: <Widget>[
          _entryField('Email:'),
          _entryField('Password:', isPassword: true),
          _forgotPassword(),
          _submitButton()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      Image(
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        image: AssetImage('assets/images/bg.jpg'),
      ),
      Container(
        height: height,
        width: double.infinity,
        child: !isFirst ? loginUi() : loginHome(),
      ),
    ]));
  }

  void failedLogin() {
    setState(() {
      isLoading = false;
    });
    Show.showToast('something_went_wrong'.tr(), true);
  }

  Future callForgotPasswordApi(email, BuildContext contextDialog) async {
    if (email.isEmpty) {
      Show.showToast('please_enter_email'.tr(), false);
      return;
    }

    Show.showLoading(context);

    var body = {'email': email};

    final response = await http
        .post(FORGOT_PASSWORD_API, body: body)
        .timeout(Duration(seconds: 60), onTimeout: () {
      failedLogin();
      return null;
    });

    if (response.statusCode == 200) {
      print(response.body);
      Show.hideLoading();

      Map<String, dynamic> map = jsonDecode(response.body);

      if (map['response'] == "ERROR") {
        Show.showToast('${map['message']}', false);
        setState(() {
          isLoading = false;
        });
      } else {
        var message = map['message'] as String;

        Navigator.of(contextDialog).pop();

        showSimpleNotification(Text(message),
            background: Colors.cyan,
            autoDismiss: false,
            slideDismiss: true,
            key: Key('PASSWORD_UI'));
      }
    } else {
      Show.hideLoading();
      Show.showToast('something_went_wrong'.tr(), true);
      throw Exception('Failed to get user from login api');
    }
  }

  showForgotPasswordDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Forgot Password"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _addTextFiled('email'.tr(), Icons.email, _forgotEmail, 60),
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
                  callForgotPasswordApi(_forgotEmail.text, context);
                },
              )
            ],
          );
        });
  }

  _addTextFiled(
      String title, IconData icon, TextEditingController tec, int maxLength,
      {bool typeNumber = false}) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: colorAccent,
      ),
      child: TextFormField(
        keyboardType: typeNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: typeNumber
            ? [
                new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,|\\-]')),
              ]
            : [
                new BlacklistingTextInputFormatter(new RegExp('')),
              ],
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

  Future getSipDetailsFromApi() async {
    var db = DatabaseHelper();
    var pref = PreferencesManager();
    setState(() {
      isLoading = true;
    });

    var body = {'email': '${_email.text}', 'password': '${_password.text}'};

    final response = await http
        .post(LOGIN_API, body: body)
        .timeout(Duration(seconds: 60), onTimeout: () {
      failedLogin();
      return null;
    });

    if (response.statusCode == 200) {
      print(response.body);

      Map<String, dynamic> map = jsonDecode(response.body);

      if (map['response'] == "ERROR") {
        Show.showToast('${map['message']}', false);
        setState(() {
          isLoading = false;
        });
      } else {
        var token = map['token'] as String;
        var payload = Jwt.parseJwt(token);

        await PreferencesManager().saveToken(token);
        db.addUser(payload).then((d) {
          registerSip(
              payload['asteriskUsername'],
              payload['asteriskUsername'] + DOMAIN_,
              payload['asteriskPassword'],
              payload['FullName'],
              WSS);
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      failedLogin();
      throw Exception('Failed to get user from login api');
    }
  }

  void registerSip(String userName, domain, password, displayName, wss) {
    UaSettings settings = UaSettings();
    settings.webSocketUrl = wss;
    settings.uri = domain;
    settings.authorizationUser = userName;
    settings.password = password;
    settings.displayName = displayName;
    settings.userAgent = 'Dart SIP Client v1.0.0';
    helper.start(settings);
  }

  @override
  void callStateChanged(Call call, CallState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {
    this.setState(() {
      if (state.state == RegistrationStateEnum.REGISTERED) {
        setState(() {
          isLoading = false;
        });
        DatabaseHelper().getUserList().then((value) => {
              PreferencesManager().saveLogin(
                  value[0].fullName,
                  value[0].asteriskUsername,
                  value[0].asteriskPassword,
                  value[0].userEmail,
                  value[0].domain,
                  value[0].role,
                  WSS),
              Navigator.pop(context),
              Phoenix.rebirth(context)
            });
      } else if ((state.state == RegistrationStateEnum.UNREGISTERED)) {
        setState(() {
          isLoading = false;
          Show.showToast('Sip Registration failed', true);
        });
      }
      ;
    });
  }

  @override
  void transportStateChanged(TransportState state) {}

  socialButtons() {
    return Container(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              height: 40,
              fit: BoxFit.contain,
              image: AssetImage('assets/images/fb.png'),
            ),
            SizedBox(
              width: 12,
            ),
            Image(
              height: 40,
              fit: BoxFit.contain,
              image: AssetImage('assets/images/yt.png'),
            ),
            SizedBox(
              width: 12,
            ),
            Image(
              height: 40,
              fit: BoxFit.contain,
              image: AssetImage('assets/images/linked_in.png'),
            )
          ],
        ));
  }

  _forgotPassword() {
    return Container(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: InkWell(
            onTap: () {
              showForgotPasswordDialog();
            },
            child: Text(
              'Forgot password?',
              style: TextStyle(
                  color: blackLight,
                  fontSize: 11.0.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}

_signInToAccess() {
  return Container(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.fromLTRB(22, 20, 22, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Sign In',
            style: TextStyle(
                color: colorOrangeLight,
                fontSize: 28.0.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'to access your account.',
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

Widget loading() {
  return SpinKitFadingCube(
    color: colorOrange,
    size: 30.0,
  );
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
