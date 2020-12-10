import 'package:flutter/material.dart';

class ActionButtonCall extends StatefulWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final bool checked;
  final bool number;
  final Color fillColor;
  final Function() onPressed;
  final Function() onLongPress;

  const ActionButtonCall(
      {Key key,
      this.title,
      this.subTitle = '',
      this.icon,
      this.onPressed,
      this.onLongPress,
      this.checked = false,
      this.number = false,
      this.fillColor})
      : super(key: key);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButtonCall> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(

            onLongPress: widget.onLongPress,
            onTap: widget.onPressed,
            child: RawMaterialButton(
              padding:  EdgeInsets.all(0),
              constraints: BoxConstraints(),
              shape: CircleBorder(),
              onPressed: widget.onPressed,
              splashColor: widget.fillColor != null ? widget.fillColor : Colors.transparent ,
              fillColor: widget.fillColor != null ? widget.fillColor : Colors.transparent,

              elevation: widget.fillColor != null ? 18.0 : 4.0,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: widget.number
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text('${widget.title}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white
                                )),
                            Text('${widget.subTitle}'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white
                                ))
                          ])
                    : Icon(
                        widget.icon,
                        size: 25.0,
                        color: Colors.white,
                      ),
              ),
            )),
        widget.number
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0))
            : Container(
                margin: EdgeInsets.symmetric(vertical: 7.0, horizontal: 0.0),
                child: (widget.number || widget.title == null)
                    ? null
                    : Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14.0,
                          color:Colors.white,
                        ),
                      ),
              )
      ],
    );
  }
}
