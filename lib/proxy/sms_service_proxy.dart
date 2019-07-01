import 'package:billie/models/MPesaMessage.dart';
import 'package:flutter/services.dart';

class SmsServiceProxy {
  static const platform = const MethodChannel('dev.billie.billie/sms');
  static SmsServiceProxy sSmsServiceProxyInstance;

  static SmsServiceProxy getInstance() {
    return sSmsServiceProxyInstance == null
        ? SmsServiceProxy()
        : sSmsServiceProxyInstance;
  }

  Future<List<MPMessage>> getSmsMessages() async {
    List<MPMessage> mpesaMessages;
    SillyMPMessageParser parser = SillyMPMessageParser();

    try {
      await platform.invokeMethod('getSmsMessages').then(
            (platformMessages) => platformMessages.forEach((Map messageInfo) =>
                mpesaMessages.add(MPMessage.fromBody(
                    parser,
                    messageInfo.values.toList()[1],
                    messageInfo.values.toList()[0]))),
          );
    } on PlatformException catch (e) {
      print(e.message);
    }

    return mpesaMessages;
  }

  Future<String> getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    return batteryLevel;
  }
}
