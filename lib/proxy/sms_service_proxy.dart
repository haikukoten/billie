import 'package:collection/collection.dart' as Collections;
import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:flutter/services.dart';

class SmsServiceProxy {
  static const platform = const MethodChannel('dev.billie.billie/sms');
  static SmsServiceProxy sSmsServiceProxyInstance;

  static const INCOME = "incomeSum";
  static const EXPENSE = "expenseSum";
  static const FEES = "fees";
  static const MAX = "max";

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

  Future<List<DataPoint<DateTime>>> getDataPoints(List<MPMessage> messages) async {
    return messages.map((e) =>
        DataPoint<DateTime>(value: e.txBal, xAxis: e.txDate)).toList();
  }

  Future<Map<String,double>> getReducedSums(List<MPMessage> messages) async {
    double expenseSum = 0;
    double incomeSum = 0;
    double txFees = 0;
    double max = messages.first.txBal;
    messages.forEach((MPMessage m){
      switch(m.mpMessageType){
        case MPMessageType.MP_TYPE_PAYBILL:
        case MPMessageType.MP_TYPE_SENT:
        case MPMessageType.MP_TYPE_WITHDRAW:
        case MPMessageType.MP_TYPE_AIRTIME:
          expenseSum += m.txAmount;
          txFees += m.txFees;
          break;
        case MPMessageType.MP_TYPE_RECEIVE:
          incomeSum += m.txAmount;
          txFees += m.txFees;
          break;
        default:
          break;
      }
    });
    return {INCOME: incomeSum, EXPENSE: expenseSum, FEES: txFees, MAX: max};
  }

  Future<Map<DateTime,List<MPMessage>>> chunkByDate(List<MPMessage> flatMessages) async{
    return Collections.groupBy(flatMessages, (MPMessage el) {
      return DateTime(el.txDate.year,el.txDate.month, el.txDate.day);
    });
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
