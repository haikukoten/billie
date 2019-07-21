import 'dart:async';
import 'package:billie/models/MPesaMessage.dart';
import 'package:flutter/services.dart';

class SmsServiceProxy {
  static const platform = const MethodChannel('dev.billie.billie/sms');
  static final SmsServiceProxy _sSmsServiceProxyInstance = new SmsServiceProxy._internal();

  static const INCOME = "incomeSum";
  static const EXPENSE = "expenseSum";
  static const FEES = "fees";
  static const BALANCE = "max";

  ///Singleton object constructor,
  ///Same reference is returned even if it is accessed with new operator anywhere!
  factory SmsServiceProxy() {
    return _sSmsServiceProxyInstance;
  }

  SmsServiceProxy._internal();

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
            //print("pl: ${platformMessages.length}");
            platformMessages.forEach((messageBody){
              ///Casting also fails you!! So this will fail and halt execution from
              ///the other thread!!??
              /// Map messageMap = messageBody as Map<String,String>;
              ///print("m: ${messageBody.values.first} \n");
              MPMessage m = MPMessage.fromBody(
                  parser,
                  messageBody.values.first,
                  messageBody.keys.first);
                  if(m.mpMessageType != MPMessageType.MP_TYPE_UNKNOWN){
                    //myController.sink.add(m);
                    mpesaMessages.add(m);
                  }
            });
          }
      );
    } on PlatformException catch (e) {
      print(e.message);
    }
    return mpesaMessages;
  }

}
