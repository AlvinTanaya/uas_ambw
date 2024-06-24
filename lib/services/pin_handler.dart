import 'package:hive/hive.dart';

class PinHandler {
  static const String pinBoxName = 'pinBox';
  static const String pinKey = 'pin';

  static Future<void> setPin(String pin) async {
    var box = await Hive.openBox(pinBoxName);
    await box.put(pinKey, pin);
  }

  static Future<String?> getPin() async {
    var box = await Hive.openBox(pinBoxName);
    return box.get(pinKey);
  }

  static Future<bool> verifyPin(String pin) async {
    var storedPin = await getPin();
    return storedPin == pin;
  }

  static Future<void> deletePin() async {
    var box = await Hive.openBox(pinBoxName);
    await box.delete(pinKey);
  }
}
