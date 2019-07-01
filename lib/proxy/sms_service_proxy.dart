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
    //Always initialize
    List<MPMessage> mpesaMessages = [];
    SillyMPMessageParser parser = SillyMPMessageParser();

    try {
      /*
      Remember Internal values cannot inferred thus a call like:
      final List<dynamic> strings = await platform.invokeMethod('getSmsMessages');
      print(strings);

      will pass but changing to List<Map<T,T>> will fail
      */
      await platform.invokeListMethod('getSmsMessages').then(
          (platformMessages){
            print("pl: ${platformMessages.length}");
            platformMessages.forEach((messageBody){
              //Casting also fails you!! So this will fail and halt execution from
              // the other thread!!??
              // Map messageMap = messageBody as Map<String,String>;
               print("m: ${messageBody.values.first} \n");

              MPMessage m = MPMessage.fromBody(
                  parser,
                  messageBody.values.first,
                  messageBody.keys.first);
                  mpesaMessages.add(m);
            });
          }
      );
    } on PlatformException catch (e) {
      print(e.message);
    }
    //print(mpesaMessages);
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
