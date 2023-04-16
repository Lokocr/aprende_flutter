import 'package:flutter/cupertino.dart';
import 'package:palette_color/helpers/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _redirectCalled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 4));
    if (_redirectCalled || !mounted) {
      return;
    }
    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/account');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // add flutter logo from internet
              Image.network(
                'https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png',
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 32),
              Image.network(
                'https://supabase.com/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fsupabase-logo-wordmark--dark.9d28c69f.png&w=384&q=75',
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 32),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 16),
              const CupertinoActivityIndicator(
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
