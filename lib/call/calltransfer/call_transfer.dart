import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:huna/call/callscreen_ravi.dart';
import 'package:huna/contacts/contacts_model.dart';
import 'package:huna/database/database_helper.dart';
import 'package:huna/libraries/sip_ua/event_manager/refer_events.dart';
import 'package:huna/libraries/sip_ua/sip_ua_helper.dart';
import 'package:huna/manager/call_manager.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:responsive_widgets/responsive_widgets.dart';
import 'package:sqflite/sqflite.dart';

import '../../constant.dart';

class CallTransfer extends StatefulWidget {
  final SIPUAHelper _helper;

  CallTransfer(this._helper, {Key key}) : super(key: key);

  @override
  _CallTransfer createState() => _CallTransfer();
}

class _CallTransfer extends State<CallTransfer> implements SipUaHelperListener {
  DatabaseHelper db = DatabaseHelper();
  List<ContactsModel> contactsList;
  int count = 0;
  var isContactsVisible = false;

  @override
  void initState() {
    super.initState();
    helper.addSipUaHelperListener(this);

    WidgetsBinding.instance.addPostFrameCallback((_) =>
    {
      if (contactsList == null) {
        contactsList = List<ContactsModel>(),
        updateContacts()
      }
    });
  }

  void updateContacts() {
    final Future<Database> dbFuture = db.initializeDatabase();
    var asteriskName = PreferencesManager().getName().toString();
    dbFuture.then((database) {
      Future<List<ContactsModel>> contactListFuture = db.getContactList(
          asteriskName);
      contactListFuture.then((list) {
        print(list.toString());
        setState(() {
          this.contactsList = list;
          this.count = list.length;
        });
      });
    });
  }

  @override
  deactivate() {
    super.deactivate();
    helper.removeSipUaHelperListener(this);
  }

  SIPUAHelper get helper => widget._helper;

  String typedNumber = "";
  String callTransferText = "Blind Transfer";

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
    ResponsiveWidgets.init(
      context,
      height: 1920, // Optional
      width: 1080, // Optional
      allowFontScaling: true, // Optional
    );

    return ResponsiveWidgets.builder(
        height: 1920, // Optional
        width: 1080, // Optional
        allowFontScaling: true, // Optional
        child: WillPopScope(
            onWillPop: () {
              print('Back button pressed');
              Navigator.pop(context, true);
              return Future.value(false);
            },
            child: Scaffold(
              body: SafeArea(
                child: isContactsVisible ? _contacts() : _dialPad(),
              ),
            )));
  }

  _contacts() {
    final height = MediaQuery
        .of(context)
        .size
        .height;
    final width = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      color: Colors.white,
      height: height,
      width: width,
      child: Column(
        children: <Widget>[
          Container(
            width: width,
            height: 50,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: new BoxDecoration(
              //you can get rid of below line also
              //below line is for rectangular shape
              shape: BoxShape.rectangle,
              //you can change opacity with color here(I used black) for rect
              color: Colors.blueGrey,
              //I added some shadow, but you can remove boxShadow also.
            ),
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isContactsVisible = false;
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Icon(Icons.arrow_back,
                                size: 22.0, color: Colors.white)),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 12, left: 20),
                        child: Text('DialPad', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: getContactList(),
          )
        ],
      ),
    );
  }

  ListView getContactList() {
    return ListView.builder(
      itemCount: contactsList == null ? 1 : contactsList.length + 1,
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 100),
      itemBuilder: (BuildContext context, int position) {
        if (position == 0) {
          // return the header
          var countStr =
          count > 0 ? 'all_contacts'.tr() + " (${count.toString()})" : "";
          return Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
              child: new Text(
                countStr,
                textAlign: TextAlign.end,
                style: TextStyle(
                    letterSpacing: 0.5,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ));
        }
        position -= 1;
        return Card(
          color: Colors.white,
          elevation: 0.5,
          child: Container(
            key: PageStorageKey('myScrollable'),
            child: ExpansionTile(
              initiallyExpanded: false,
              trailing: Icon(
                Icons.face,
                size: 0.0,
              ),
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 15.0, 15.0),
                    child: InkWell(
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor:
                        Color(int.parse(this.contactsList[position].color)),
                        child: Text(
                            getFirstLetter(this.contactsList[position].name),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(this.contactsList[position].name,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      SizedBox(height: 1),
                      Text(this.contactsList[position].number,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54)),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  )
                ],
              ),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      elevation: 1,
                      color: Colors.green[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      child: Text(
                        callTransferText,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                          blindTransfer(contactsList[position].id);
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

  _dialPad() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 20,),

            Text('Call Transfer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            Expanded(child: Container(),),
            RawMaterialButton(
              child: Icon(
                Icons.contacts,
                size: 25,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  isContactsVisible = true;
                });
              },
              elevation: 0.0,
              constraints: BoxConstraints.tightFor(
                width: 76.0,
                height: 76.0,
              ),
              shape: CircleBorder(),
              fillColor: null,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 0, right: 0, top: 0),
          child: SizedBoxResponsive(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 80,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: TextResponsive(

                      /// If number gets really long, we truncate it to show only the
                      /// last 15 symbols, and everything else gets replaced by ...
                      "${typedNumber.length > 15
                          ? '...' + typedNumber.substring(
                          typedNumber.length - 15, typedNumber.length)
                          : typedNumber}",
                      style: rebuildTextStyle(),
                    ),
                  ),
                ),
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
              ],
            ),
          ),
        ),
        SizedBoxResponsive(
          height: 30,
        ),
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
            SizedBoxResponsive(
              width: 80,
            ),
            NumberedRoundButton(
                num: "2",
                onPressed: () {
                  SoundPlayer.playDTMFSound("2");
                  setState(() {
                    typedNumber += "2";
                  });
                }),
            SizedBoxResponsive(
              width: 80,
            ),
            NumberedRoundButton(
                num: "3",
                onPressed: () {
                  SoundPlayer.playDTMFSound("3");
                  setState(() {
                    typedNumber += "3";
                  });
                }),
            SizedBoxResponsive(
              width: 0,
            )
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
          height: 80,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: typedNumber.length > 0,
              child: RaisedButton(
                elevation: 1,
                color: Colors.green[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                child: Text(
                  callTransferText,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                   blindTransfer(typedNumber);
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void callStateChanged(Call call, CallState callState) {
    if (callState.state == CallStateEnum.REFER) {
      // Show.showToast("Transferring...", false);
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}

  void blindTransfer(String target) {

    var session = helper.findCall(CURRENT_CALL_ID).session;

    assert(session != null, 'ERROR(refer): rtc session is invalid!');
    var refer = session.refer(target);

    refer.on(EventReferTrying(), (EventReferTrying data) {
      Show.showToast("Transferring...", false);
      setState(() {
        callTransferText = "Transferring";
      });
    });
    refer.on(EventReferProgress(), (EventReferProgress data) {
      Show.showToast("In Progress...", false);

      setState(() {
        callTransferText = "In Progress...";
      });
    });
    refer.on(EventReferAccepted(), (EventReferAccepted data) {
      Show.showToast("Confirmed...", false);
      session.terminate();
    });

    refer.on(EventReferFailed(), (EventReferFailed data) {
      Show.showToast("Failed...", false);

      setState(() {
        callTransferText = "Blind Transfer";
      });
    });
  }
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
        constraints: BoxConstraints.tightFor(),
        padding: EdgeInsets.all(5),
        shape: CircleBorder(
          side: BorderSide(width: 1.5, color: colorAccent),
        ),
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
        size: 25,
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
