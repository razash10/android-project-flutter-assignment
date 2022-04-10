import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/snapping_sheets.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'auth.dart';
import 'main.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildRow(WordPair pair) {
    return Consumer<SavesModel>(
        builder: (context, saves, child) => ListTile(
              title: Text(
                pair.asPascalCase,
                style: _biggerFont,
              ),
              trailing: Icon(
                saves.contains(pair) ? Icons.star : Icons.star_border,
                color: saves.contains(pair) ? Colors.deepPurple : null,
                semanticLabel:
                    saves.contains(pair) ? 'Remove from saved' : 'Save',
              ),
              onTap: () {
                setState(() {
                  if (saves.contains(pair)) {
                    saves.remove(pair);
                  } else {
                    saves.add(pair);
                  }
                });
              },
            ));
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }

        final index = i ~/ 2;

        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  void _pushSaved() {
    String? newPair;

    Widget yesButton = Consumer<SavesModel>(
        builder: (context, savesModel, child) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text("Yes"),
              onPressed: () {
                WordPair? elementToRemove;
                savesModel.saves.forEach((element) {
                  if (element.asPascalCase == newPair) {
                    elementToRemove = element;
                  }
                });
                savesModel.remove(elementToRemove!);
                Navigator.of(context).pop();
              },
            ));

    Widget noButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.deepPurple,
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Future<bool?> getFutureDeletion(context, pair) async {
      newPair = pair.asPascalCase;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Delete Suggestion"),
              content: Text("Are you sure you want to delete "
                  "$newPair from your saved suggestions?"),
              actions: [
                yesButton,
                noButton,
              ],
            );
          });
      return Future<bool?>.value(false);
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) {
        final tiles = Provider.of<SavesModel>(context).saves.map(
          (pair) {
            Key _key = UniqueKey();
            return Dismissible(
              key: _key,
              background: Container(
                color: Colors.deepPurple,
                child: Row(children: const <Widget>[
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  Text(
                    'Delete Suggestion',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
              child: ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              ),
              confirmDismiss: (DismissDirection direction) async {
                return await getFutureDeletion(context, pair);
              },
            );
          },
        );
        final divided = tiles.isNotEmpty
            ? ListTile.divideTiles(
                context: context,
                tiles: tiles,
              ).toList()
            : <Widget>[];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Suggestions'),
          ),
          body: ListView(children: divided),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          Consumer<LoginModel>(
              builder: (context, loginModel, child) => IconButton(
                    onPressed: () {
                      if (loginModel.isLoggedIn) {
                        Provider.of<SavesModel>(context, listen: false)
                            .profileSheetController
                            .snapToPosition(SnappingPosition.factor(
                              positionFactor: 0.0,
                              grabbingContentOffset: GrabbingContentOffset.top,
                            ));
                        AuthModel.instance().signOut();
                        loginModel.logOut();
                        loginModel.toggleLogging();
                        Provider.of<SavesModel>(context, listen: false)
                            .removeAll();
                        loginModel.setUserImageUrl('');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Successfully logged out'),
                        ));
                      } else {
                        Navigator.of(context)
                            .push(MaterialPageRoute<void>(builder: (context) {
                          return Scaffold(
                              appBar: AppBar(
                                title: const Text('Login'),
                              ),
                              body: RegisterSnappingSheet());
                        }));
                      }
                    },
                    icon: loginModel.isLoggedIn
                        ? Icon(Icons.exit_to_app)
                        : Icon(Icons.login),
                  )),
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}
