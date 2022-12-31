import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _username;

  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _username = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Shared Preferences"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(helperText: "Username"),
                controller: myController,
              ),
            ),
            FutureBuilder<String>(
                future: _username,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return snapshot.data == ''
                            ? const Text(
                                'No user saved yet.',
                                style: TextStyle(color: Colors.blueGrey),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text("Saved user : "),
                                  Text(snapshot.data!),
                                  IconButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.remove('username');

                                        setState(() {
                                          _username = _prefs
                                              .then((SharedPreferences prefs) {
                                            return prefs
                                                    .getString('username') ??
                                                '';
                                          });
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ))
                                ],
                              );
                      }
                  }
                }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('username', myController.text);

              setState(() {
                _username = _prefs.then((SharedPreferences prefs) {
                  return prefs.getString('username') ?? '';
                });
              });

              myController.text = "";
            },
            child: const Icon(Icons.save)),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
  }
}
