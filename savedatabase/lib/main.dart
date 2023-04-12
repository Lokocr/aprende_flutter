import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:savedatabase/pages/dogs.dart';
import 'package:savedatabase/pages/home.dart';
import 'package:savedatabase/providers/dog_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => DogProvider()),
  ];

  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return new CupertinoApp(
      home: new MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    await Provider.of<DogProvider>(context, listen: false).initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: CupertinoColors.systemIndigo,
          inactiveColor: CupertinoColors.systemIndigo,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              activeIcon: Icon(
                CupertinoIcons.list_bullet_indent,
                color: CupertinoColors.systemIndigo,
              ),
              icon: Icon(
                CupertinoIcons.list_bullet,
                color: CupertinoColors.systemIndigo,
              ),
              label: 'Dogs',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                CupertinoIcons.doc_fill,
                color: CupertinoColors.systemIndigo,
              ),
              icon: Icon(
                CupertinoIcons.doc,
                color: CupertinoColors.systemIndigo,
              ),
              label: 'Home',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              return index == 0 ? const DogsPage() : const HomePage();
            },
          );
        },
      ),
    );
  }
}
