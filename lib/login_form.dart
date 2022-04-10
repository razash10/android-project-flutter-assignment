import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'auth.dart';
import 'main.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isSnappingSheetEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<SavesModel>(
            builder: (context, savesModel, child) => StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final localSaves = savesModel.strSaved;
                      FirebaseFirestore fireStore = FirebaseFirestore.instance;
                      String? currUser = snapshot.data?.email;
                      fireStore
                          .collection('users')
                          .doc(currUser)
                          .get()
                          .then((snapshot) {
                        snapshot.data()?.forEach((key, value) {
                          // key == "saves"
                          for (int i = 0; i < value.length; i++) {
                            if (!localSaves.contains(value[i])) {
                              localSaves.add(value[i]);
                            }
                          }
                        });
                      }).then((value) {
                        savesModel.set(localSaves);
                        final map = Map<String, List<String>>();
                        map.addAll({"saves": localSaves});
                        fireStore.collection('users').doc(currUser).set(map);
                      });
                    }

                    final loginModel =
                        Provider.of<LoginModel>(context, listen: false);
                    void loginNow() {
                      loginModel.toggleLogging();
                      AuthModel.instance()
                          .signIn(loginModel.emailController.text,
                              loginModel.passwordController.text)
                          .then((result) async {
                        if (result == true) {
                          loginModel.logIn();
                          final uid = AuthModel.instance().user?.uid;
                          String? url;
                          final ref =
                              FirebaseStorage.instance.ref('profile_pics/$uid');
                          try {
                            url = await ref.getDownloadURL();
                          } catch (error) {
                            url = '';
                          }
                          loginModel.setUserImageUrl(url);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                content: Text(
                                    'There was an error logging into the app'),
                              ))
                              .closed
                              .then((value) => ScaffoldMessenger.of(context)
                                  .clearSnackBars());
                          loginModel.toggleLogging();
                        }
                      });
                    }

                    return Consumer<LoginModel>(
                        builder: (context, loginModel, child) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 30, 30, 10),
                              child: Text(
                                  'Welcome to Startup Names Generator, please login in below'),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                              child: TextFormField(
                                controller: loginModel.emailController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Email',
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 00, 30, 30),
                              child: TextFormField(
                                controller: loginModel.passwordController,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Password',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.deepPurple,
                                  minimumSize: const Size.fromHeight(40),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed:
                                    loginModel.isLoggingIn ? null : loginNow,
                                child: const Text('Log in'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                    textStyle: const TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: () {
                                    double targetPositionPixels = 200;
                                    if (_isSnappingSheetEnabled) {
                                      targetPositionPixels = -10;
                                    }
                                    loginModel.registerSheetController
                                        .snapToPosition(SnappingPosition.pixels(
                                            positionPixels:
                                                targetPositionPixels));
                                    _isSnappingSheetEnabled =
                                        !_isSnappingSheetEnabled;
                                  },
                                  child:
                                      const Text('New user? Click to sign up')),
                            )
                          ]);
                    });
                  },
                )));
  }
}
