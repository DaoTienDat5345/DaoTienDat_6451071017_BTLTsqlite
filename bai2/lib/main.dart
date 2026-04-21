import 'package:flutter/material.dart';

import 'app/bai2_app.dart';
import 'utils/database_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDatabaseFactory();
  runApp(const Bai2App());
}
