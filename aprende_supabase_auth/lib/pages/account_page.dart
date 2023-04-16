import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:palette_color/helpers/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;
  var _loading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single() as Map;
      _usernameController.text = (data['username'] ?? '') as String;
      _websiteController.text = (data['website'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected exception occurred');
    }

    setState(() {
      _loading = false;
    });
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text.trim();
    final website = _websiteController.text.trim();
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar(message: 'Successfully updated profile!');
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpeted error occurred');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      Fluttertoast.showToast(
          msg: "${error.message}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: CupertinoColors.systemIndigo,
          textColor: CupertinoColors.white,
          fontSize: 16.0);
    } catch (error) {
      Fluttertoast.showToast(
          msg: "${error.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: CupertinoColors.systemIndigo,
          textColor: CupertinoColors.white,
          fontSize: 16.0);
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        context.showSnackBar(message: 'Updated your profile image!');
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Account',
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            'Sign out',
          ),
          onPressed: _signOut,
        ),
        backgroundColor: CupertinoColors.white,
      ),
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : CupertinoListSection.insetGrouped(
              children: [
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    controller: _usernameController,
                    placeholder: 'Username',
                    prefix: const Icon(CupertinoIcons.person),
                  ),
                ),
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    controller: _websiteController,
                    placeholder: 'Website',
                    prefix: const Icon(CupertinoIcons.globe),
                  ),
                ),
                CupertinoButton(
                  child: Text(_loading ? 'Updating...' : 'Update'),
                  onPressed: _updateProfile,
                ),
              ],
            ),
    );
  }
}
