import 'dart:async';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  //final _suggestions = generateWordPairs().take(100).toList();
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions() {
    /*
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, i) {
        return _buildRow(_suggestions[i]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
    */

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }

        final index = i ~/ 2;

        if (index >= _suggestions.length) {
          // if list goes brrrr
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  void _pushSaved() {
    Future<bool?> getFutureDeletion(context) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deletion is not implemented yet'),
      ));
      return Future<bool?>.value(false);
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) {
        final tiles = _saved.map(
          (pair) {
            return Dismissible(
              key: UniqueKey(),
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
                return await getFutureDeletion(context);
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

  void _pushLogin() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Login'),
            ),
            body: LoginForm());
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
          IconButton(
            onPressed: _pushLogin,
            icon: const Icon(Icons.login),
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(30),
          child:
              Text('Welcome to Startup Names Generator, please login in below'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 00, 30, 30),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 00, 30, 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.deepPurple,
              minimumSize: const Size.fromHeight(40),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Login is not implemented yet'),
              ));
            },
            child: const Text('Log in'),
          ),
        ),
      ],
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
      home: RandomWords(),
    );
  }
}
