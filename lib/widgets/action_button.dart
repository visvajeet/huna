import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final bool checked;
  final bool number;
  final Color fillColor;
  final Function() onPressed;
  final Function() onLongPress;

  const ActionButton(
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

class _ActionButtonState extends State<ActionButton> {
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
              onPressed: widget.onPressed,
              splashColor: widget.fillColor != null
                  ? widget.fillColor
                  : (widget.checked ? Colors.transparent : Colors.purple[900]),
              fillColor: widget.fillColor != null
                  ? widget.fillColor
                  : (widget.checked ? Colors.purple[900] : Colors.transparent),
              shape: CircleBorder(side: BorderSide(width: 1.2, color: Colors.purple[900])),
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: widget.number
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text('${widget.title}',
                                style: TextStyle(
                                  fontSize: 21,
                                  color: widget.fillColor != null
                                      ? widget.fillColor
                                      : Colors.black,
                                )),
                            Text('${widget.subTitle}'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.fillColor != null
                                      ? widget.fillColor
                                      : Colors.black,
                                ))
                          ])
                    : Icon(
                        widget.icon,
                        size: 25.0,
                        color: widget.fillColor != null
                            ? Colors.white
                            : (widget.checked ? Colors.white : Colors.purple[800]),
                      ),
              ),
            )),
        widget.number
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0))
            : Container(
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: (widget.number || widget.title == null)
                    ? null
                    : Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: widget.fillColor != null
                              ? widget.fillColor
                              : Colors.grey[500],
                        ),
                      ),
              )
      ],
    );
  }
}
