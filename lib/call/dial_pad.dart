import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:huna/call/callscreen_ravi.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:responsive_widgets/responsive_widgets.dart';

import '../constant.dart';


class DialPad extends StatefulWidget {

  final SIPUAHelper _helper;
  DialPad(this._helper, {Key key}) : super(key: key);

  @override
  _DialPad createState() => _DialPad();

}

class _DialPad extends State<DialPad> implements SipUaHelperListener {


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

  SIPUAHelper get helper => widget._helper;

  String typedNumber = "";

  TextStyle rebuildTextStyle() {
    /// Return different text styles depending on the number of symbols in it
    if (typedNumber.length <= 10) {
      return TextStyle(
        fontSize: 70,
        fontWeight: FontWeight.w400,
      );
    } else if (typedNumber.length < 13) {
      return TextStyle(
        fontSize: 55,
        fontWeight: FontWeight.w400,
      );
    } else {
      return TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    ResponsiveWidgets.init(context,
      height: 1920, // Optional
      width: 1080, // Optional
      allowFontScaling: true, // Optional
    );

    return  ResponsiveWidgets.builder(
      height: 1920, // Optional
      width: 1080, // Optional
      allowFontScaling: true, // Optional
      child:  WillPopScope(
          onWillPop: () {
            print('Back button pressed');
            Navigator.pop(context, true);
            return Future.value(false);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: Text('make_a_call'.tr(),),),
            body: SafeArea(

               child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(bottom: 10, left: 0, right: 0, top: 50),
                      child: SizedBoxResponsive(
                        height: 100,
                        child: TextResponsive(
                          /// If number gets really long, we truncate it to show only the
                          /// last 15 symbols, and everything else gets replaced by ...
                          "${typedNumber.length > 15 ? '...' + typedNumber.substring(typedNumber.length - 15, typedNumber.length) : typedNumber}",
                          style: rebuildTextStyle(),
                        ),
                      ),
                    ),
                    SizedBoxResponsive(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        NumberedRoundButton(
                            num: "1",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("1");
                              setState(() {
                                typedNumber += "1";
                              });
                            }),
                        SizedBoxResponsive(width: 80,),
                        NumberedRoundButton(
                            num: "2",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("2");
                              setState(() {
                                typedNumber += "2";
                              });
                            }),
                        SizedBoxResponsive(width: 80,),
                        NumberedRoundButton(
                            num: "3",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("3");
                              setState(() {
                                typedNumber += "3";
                              });
                            }),
                        SizedBoxResponsive(width: 0,)
                      ],
                    ),
                    SizedBoxResponsive(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        NumberedRoundButton(
                            num: "4",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("4");
                              setState(() {
                                typedNumber += "4";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 80,
                        ),
                        NumberedRoundButton(
                            num: "5",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("5");
                              setState(() {
                                typedNumber += "5";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 80,
                        ),
                        NumberedRoundButton(
                            num: "6",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("6");
                              setState(() {
                                typedNumber += "6";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 0,
                        )
                      ],
                    ),
                    SizedBoxResponsive(
                      height: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        NumberedRoundButton(
                            num: "7",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("7");
                              setState(() {
                                typedNumber += "7";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 80,
                        ),
                        NumberedRoundButton(
                            num: "8",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("8");
                              setState(() {
                                typedNumber += "8";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 80,
                        ),
                        NumberedRoundButton(
                            num: "9",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("9");
                              setState(() {
                                typedNumber += "9";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 0,
                        )
                      ],
                    ),
                    SizedBoxResponsive(
                      height: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        NumberedRoundButton(
                            num: '*',
                            onPressed: () {
                              SoundPlayer.playDTMFSound("star");
                              setState(() {
                                typedNumber += "*";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 80,
                        ),
                        GestureDetector(
                          /// When doing a long tap on 0 button, we enter +
                          onLongPress: () {
                            setState(() {
                              typedNumber += '+';
                            });
                          },
                          child: NumberedRoundButton(
                              num: "0",
                              onPressed: () {
                                SoundPlayer.playDTMFSound("0");
                                setState(() {
                                  typedNumber += "0";
                                });
                              }),
                        ),
                        SizedBoxResponsive(
                          width: 80,
                        ),
                        NumberedRoundButton(
                            num: "#",
                            onPressed: () {
                              SoundPlayer.playDTMFSound("hash");
                              setState(() {
                                typedNumber += "#";
                              });
                            }),
                        SizedBoxResponsive(
                          width: 0,
                        ),
                      ],
                    ),
                    SizedBoxResponsive(
                      height: 120,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Visibility(
                          /// If there is any numbers seen, then we should be able to delete it
                          visible: typedNumber.length > 0,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: VideoCallButton(
                            onPressed: () {
                              if(typedNumber.length > 0) {
                                CallManager().makeCall(helper,typedNumber,isVideoCall: true);
                              }
                            },
                          ),
                        ),
                        SizedBoxResponsive(width: 25,),
                        RoundIconButton(  icon: Icons.call, onPressed: () {
                          if(typedNumber.length > 0) {
                            CallManager().makeCall(helper,typedNumber,isVideoCall: false);
                          }

                        }),
                        SizedBoxResponsive(width: 25,),
                        Visibility(
                          /// If there is any numbers seen, then we should be able to delete it
                          visible: typedNumber.length > 0,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: DeleteButton(
                            onPressed: () {
                              setState(() {
                                typedNumber =
                                    typedNumber.substring(0, typedNumber.length - 1);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 0,
                        ),
                      ],
                    )
                  ],
                ),

            ),
          ))
    );
  }

  @override
  void callStateChanged(Call call, CallState callState) {

    /*if (callState.state == CallStateEnum.CALL_INITIATION) {
      Navigator.push(baseContext, MaterialPageRoute(builder: (context) => CallScreenPage(this.helper,call)));
    }
*/
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {

  }

  @override
  void registrationStateChanged(RegistrationState state) {

  }

  @override
  void transportStateChanged(TransportState state) {}


}

class NumberedRoundButton extends StatelessWidget {
  NumberedRoundButton({this.num, this.onPressed});

  final String num;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      onPressed: this.onPressed,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextResponsive("$num", style: kKeyPadNumberTextStyle),
            TextResponsive(
              "${numToTextMapping[num]}",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
              ),
            ),
          ]),
    );
  }
}

class RoundButton extends StatelessWidget {
  RoundButton({@required this.child, @required this.onPressed});

  final Widget child;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ContainerResponsive(
      width: 180.0,
      height: 180.0,
      child: RawMaterialButton(
        child: child,
        onPressed: onPressed,
        elevation: 1.0,
        constraints: BoxConstraints.tightFor(

        ),
        padding: EdgeInsets.all(5),
        shape: CircleBorder(side: BorderSide(width: 1.5, color: colorAccent),),
        fillColor: Colors.white,
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  RoundIconButton({@required this.icon, @required this.onPressed});

  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(
        icon,
        size: 35,
        color: Colors.white,
      ),
      onPressed: onPressed,
      elevation: 0.0,
      constraints: BoxConstraints.tightFor(
        width: 68.0,
        height: 68.0,
      ),
      shape: CircleBorder(),

      fillColor: Colors.lightGreenAccent.shade700,
    );
  }
}

class DeleteButton extends StatelessWidget {
  DeleteButton({this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(
        Icons.backspace,
        size: 32,
        color: Colors.black54,
      ),
      onPressed: onPressed,
      elevation: 0.0,
      constraints: BoxConstraints.tightFor(
        width: 76.0,
        height: 76.0,
      ),
      shape: CircleBorder(),
      fillColor: null,
    );
  }

}

class VideoCallButton extends StatelessWidget {
  VideoCallButton({this.onPressed});
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(
        Icons.videocam,
        size: 40,
        color: Colors.green,
      ),
      onPressed: onPressed,
      elevation: 0.0,
      constraints: BoxConstraints.tightFor(
        width: 76.0,
        height: 76.0,
      ),
      shape: CircleBorder(),
      fillColor: null,
    );
  }



}