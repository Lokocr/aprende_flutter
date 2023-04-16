import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:palette_color/helpers/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _isRedirecting = false;
  late final TextEditingController _emailController;
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _singIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithOtp(
        email: _emailController.text,
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        Fluttertoast.showToast(
            msg: "Check your email for the code.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: CupertinoColors.systemIndigo,
            textColor: CupertinoColors.white,
            fontSize: 16.0);
        _emailController.clear();
      }
    } on AuthException catch (e) {
      Fluttertoast.showToast(
          msg: "Error signing in: ${e.message}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: CupertinoColors.systemIndigo,
          textColor: CupertinoColors.white,
          fontSize: 16.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error signing in: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: CupertinoColors.systemIndigo,
          textColor: CupertinoColors.white,
          fontSize: 16.0);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((event) {
      if (_isRedirecting) {
        return;
      }
      final session = event.session;
      if (session != null) {
        _isRedirecting = true;
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Login Page',
        ),
      ),
      child: SafeArea(
        child: Form(
          child: CupertinoListSection.insetGrouped(
            children: [
              CupertinoFormRow(
                child: CupertinoTextFormFieldRow(
                  controller: _emailController,
                  placeholder: 'Email',
                  prefix: const Icon(
                    CupertinoIcons.mail,
                    color: CupertinoColors.systemGrey,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSaved: (_) => _singIn(),
                ),
              ),
              CupertinoFormRow(
                child: CupertinoButton(
                  child: Text(_isLoading ? 'Loading...' : 'Login'),
                  onPressed: _isLoading ? null : _singIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
