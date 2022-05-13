import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'server/server_provider.dart';
import 'services/notification_service.dart';

late Box userDataBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.initialize();
  await Hive.initFlutter();
  userDataBox = await Hive.openBox('userDataBox');
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: (context) => ServerProvider(), child: App()));
}
