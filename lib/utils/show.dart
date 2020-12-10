import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Show {

  static ProgressDialog progressDialog = ProgressDialog(type: ProgressDialogType.Normal, isDismissible: true);


  static void showToast(String msg, bool isError) {
    Fluttertoast.showToast(
        msg: msg,

        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.redAccent : Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static void showLoading(BuildContext context,{String message = "Please Wait .."} )  {
    progressDialog.style(message: message,backgroundColor: Colors.white);
    progressDialog.show(context);
  }

  static void hideLoading()  {
    progressDialog.hide();

  }



}