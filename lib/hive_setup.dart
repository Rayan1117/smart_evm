import 'package:hive_flutter/hive_flutter.dart';

class HiveSetup {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('curr-state');
  }
}
