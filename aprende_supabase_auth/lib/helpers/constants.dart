import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = CupertinoColors.white,
  }) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: CupertinoColors.systemIndigo,
        textColor: CupertinoColors.white,
        fontSize: 16.0);
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: CupertinoColors.systemRed);
  }
}
