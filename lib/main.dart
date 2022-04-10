import 'package:hello_me/snapping_sheets.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'firebase_options.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoginModel()),
      ChangeNotifierProvider(create: (context) => SavesModel()),
    ],
    child: App(),
  ));
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      color: Colors.deepPurple,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: UserProfileSnappingSheet(),
    );
  }
}

class LoginModel extends ChangeNotifier {
  LoginModel();

  bool _isLoggedIn = false;
  bool _isLoggingIn = false;
  String _userImageUrl = '';
  final _registerSheetController = SnappingSheetController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get isLoggingIn => _isLoggingIn;
  bool get isLoggedIn => _isLoggedIn;
  SnappingSheetController get registerSheetController =>
      _registerSheetController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  void logIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logOut() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // for disabling login button
  void toggleLogging() {
    _isLoggingIn = !_isLoggingIn;
    notifyListeners();
  }

  bool arePasswordsEqual() {
    notifyListeners();
    return _passwordController.text == _confirmPasswordController.text;
  }

  void setUserImageUrl(String url) {
    _userImageUrl = url;
    notifyListeners();
  }

  NetworkImage? getUserImage() {
    if (_userImageUrl == '') {
      return null;
    } else {
      return NetworkImage(_userImageUrl);
    }
  }
}

class SavesModel extends ChangeNotifier {
  final _pascalWordsRE = RegExp(r"(?<=[a-z])(?=[A-Z])");
  var _saves = <WordPair>{};
  final _profileSheetController = SnappingSheetController();

  Set<WordPair> get saves => _saves;
  SnappingSheetController get profileSheetController => _profileSheetController;

  void updateSavesOnFirestore() {
    AuthModel auth = AuthModel.instance();
    if (auth.isAuthenticated) {
      final currUser = AuthModel.instance().user?.email;
      FirebaseFirestore fireStore = FirebaseFirestore.instance;
      fireStore.collection('users').doc(currUser).get().then((value) {
        final map = Map<String, List<String>>();
        map.addAll({"saves": strSaved});
        fireStore.collection('users').doc(currUser).set(map);
      });
    }
  }

  List<String> get strSaved {
    List<String> saved = <String>[];
    _saves.forEach((element) {
      saved.add(element.asPascalCase);
    });
    return saved;
  }

  void add(WordPair item) {
    _saves.add(item);
    updateSavesOnFirestore();
  }

  void remove(WordPair item) {
    _saves.remove(item);
    updateSavesOnFirestore();
    notifyListeners();
  }

  void removeAll() {
    _saves = <WordPair>{};
    notifyListeners();
  }

  void set(List<String> list) {
    _saves = <WordPair>{};
    list.forEach((pair) {
      List<String> list = pair.split(_pascalWordsRE);
      _saves.add(WordPair(list[0].toLowerCase(), list[1].toLowerCase()));
    });
    notifyListeners();
  }

  bool contains(WordPair item) {
    return _saves.contains(item);
  }
}
