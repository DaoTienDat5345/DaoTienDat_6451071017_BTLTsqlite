import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> configurePlatformDatabaseFactory() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

