import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/viewmodels/admin_data_viewmodel.dart';
import 'features/auth/admin_auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDataViewModel()),
      ],
      child: const AdminApp(),
    ),
  );
}
