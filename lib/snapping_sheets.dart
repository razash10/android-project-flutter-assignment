import 'package:flutter/material.dart';
import 'package:hello_me/random_words.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'auth.dart';
import 'login_form.dart';
import 'main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class RegisterSnappingSheet extends StatelessWidget {
  final _confirmPasswordKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
        body: SnappingSheet(
          controller: loginModel.registerSheetController,
          lockOverflowDrag: true,
          sheetBelow: SnappingSheetContent(
              draggable: false,
              child: Container(
                  color: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Expanded(
                            child: Text('Please confirm your password below:'),
                          ),
                          Expanded(
                              flex: 3,
                              child: Form(
                                key: _confirmPasswordKey,
                                child: TextFormField(
                                  controller:
                                      loginModel.confirmPasswordController,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  validator: (currPassword) {
                                    return (loginModel
                                                .passwordController.text !=
                                            currPassword)
                                        ? 'Passwords must match'
                                        : null;
                                  },
                                  decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Password'),
                                ),
                              )),
                          Expanded(
                            child: Divider(color: Colors.white),
                          ),
                          Consumer<LoginModel>(
                              builder: (context, loginModel, child) {
                            return Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_confirmPasswordKey.currentState!
                                      .validate()) {
                                    loginModel.toggleLogging();
                                    final email =
                                        loginModel.emailController.text;
                                    final password =
                                        loginModel.passwordController.text;
                                    await AuthModel.instance()
                                        .signUp(email, password);
                                    await AuthModel.instance()
                                        .signIn(email, password)
                                        .then((result) {
                                      if (result == true) {
                                        loginModel.logIn();
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'There was an error logging into the app'),
                                            ))
                                            .closed
                                            .then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .clearSnackBars());
                                        loginModel.toggleLogging();
                                      }
                                    });
                                  }
                                },
                                child: const Text('Confirm'),
                              ),
                            );
                          })
                        ],
                      )))),
          child: LoginForm(),
        ),
      );
    });
  }
}

class GrabbingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SavesModel>(builder: (context, savesModel, child) {
      LoginModel loginModel = Provider.of<LoginModel>(context, listen: true);
      return loginModel.isLoggedIn
          ? Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
              ),
              child: ListTile(
                title: Text(
                  "Welcome back, " + loginModel.emailController.text,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: GestureDetector(
                    onTap: () {
                      if (savesModel.profileSheetController.currentPosition >
                          25) {
                        savesModel.profileSheetController
                            .snapToPosition(SnappingPosition.factor(
                          positionFactor: 0.0,
                          grabbingContentOffset: GrabbingContentOffset.top,
                        ));
                      } else {
                        savesModel.profileSheetController
                            .snapToPosition(SnappingPosition.pixels(
                          positionPixels: 140.0,
                        ));
                      }
                    },
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.black)),
              ),
            )
          : Container();
    });
  }
}

class UserProfileSnappingSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LoginModel loginModel = Provider.of<LoginModel>(context, listen: true);
    //var _profileImage = loginModel.getUserImage();
    //loginModel.addListener(() {
    //_profileImage = loginModel.getUserImage();
    //});
    return Consumer<SavesModel>(builder: (context, savesModel, child) {
      return Scaffold(
        body: SnappingSheet(
          controller: savesModel.profileSheetController,
          lockOverflowDrag: true,
          snappingPositions: [
            SnappingPosition.factor(
              positionFactor: 0,
              grabbingContentOffset: GrabbingContentOffset.top,
            ),
            SnappingPosition.pixels(
              positionPixels: 140,
            ),
            SnappingPosition.factor(
              positionFactor: 100,
              grabbingContentOffset: GrabbingContentOffset.bottom,
            ),
          ],
          grabbingHeight: 50,
          grabbing: GrabbingWidget(),
          sheetBelow: SnappingSheetContent(
              draggable: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: CircleAvatar(
                              backgroundImage: loginModel.getUserImage(),
                              backgroundColor: Colors.transparent,
                              radius: 40)),
                      Flexible(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 10, 5),
                                  child: Text(
                                    loginModel.emailController.text,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 22,
                                    ),
                                  ))),
                          Flexible(
                              child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 15),
                            child: ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker
                                      .platform
                                      .pickFiles(withData: true);

                                  if (result != null) {
                                    PlatformFile file = result.files.first;
                                    final uid = AuthModel.instance().user?.uid;
                                    final ref = FirebaseStorage.instance
                                        .ref('profile_pics/$uid');
                                    await ref.putData(file.bytes!);
                                    final url = await ref.getDownloadURL();
                                    loginModel.setUserImageUrl(url);
                                    //_profileImage = NetworkImage(url);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                          content: Text('No image selected'),
                                        ))
                                        .closed
                                        .then((value) =>
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars());
                                  }
                                },
                                child: Text('Change avatar'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  textStyle: const TextStyle(fontSize: 16),
                                )),
                          ))
                        ],
                      ))
                    ]),
              )),
          child: RandomWords(),
        ),
      );
    });
  }
}
