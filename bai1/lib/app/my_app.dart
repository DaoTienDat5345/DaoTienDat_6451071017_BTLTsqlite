import 'package:flutter/material.dart';

import '../screens/noteDetail/note_list_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter SQLite CRUD',
      debugShowCheckedModeBanner: false,
      home: NoteListScreen(),
    );
  }
}
