import 'dart:async';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:billie/proxy/contact_service_proxy.dart';
import 'package:collection/collection.dart' as Collections;


class SmsRetrieverBloc {
  final SmsServiceProxy smsServiceProxy;
  final ContactServiceProxy contactServiceProxy;

  ///Controllers for various events
  BehaviorSubject<List<MPMessage>> _mpesaSmsController =
      BehaviorSubject<List<MPMessage>>();
  ReplaySubject<String> _queryMessages = ReplaySubject<String>(maxSize: 2);
  Stream<List<MPMessage>> get mpesaSmsStream => _mpesaSmsController.stream;
  Sink<String> get queryMessages => _queryMessages;
  BehaviorSubject<Iterable<Contact>> _myContactsController =
      BehaviorSubject<Iterable<Contact>>();

  /// Streams , Please see Note below for more info in case of undefined behaviour
  Stream<Iterable<Contact>> get allContacts => _myContactsController.stream;
  Stream<Iterable<Contact>> get filterContacts => Observable.combineLatest2(
          _queryMessages.debounceTime(Duration(milliseconds: 600)).distinct(),
          allContacts, (String filter, Iterable<Contact> contacts) {
        return contacts.where((contact) =>
            contact.phones.any((phone) => phone.value.contains(filter)) ||
            contact.displayName.toLowerCase().contains(filter.toLowerCase()));
      });

  ///NOTE: Transformed Streams are only declared here but fully inititalized in the Constructor!!
  ///This is to prevent an infinite loop! Refer to link below:
  ///      [https://stackoverflow.com/questions/56075306/flutter-infinite-loop-when-streambuilder-inside-layoutbuilder]
  Stream<Map<String, double>> statsStream;
  Stream<Map<DateTime, List<MPMessage>>> historyChunks;
  Stream<List<DataPoint<DateTime>>> dataPointStream;

  ///TODO: Switch to iterator model to handle larger workloads better
  Stream<List<MPMessage>> get queryResults => Observable.combineLatest2(
          _queryMessages.debounceTime(Duration(milliseconds: 600)).distinct(),
          mpesaSmsStream, (String eventString, List messages) {
        return messages
            .where((message) {
              return message.bodyString.toLowerCase().contains(
                    eventString.toLowerCase(),
                  );
            })
            .take(10)
            .toList();
      });

  SmsRetrieverBloc(this.smsServiceProxy, this.contactServiceProxy) {
    dataPointStream = _mpesaSmsController
        .distinct(Collections.ListEquality<MPMessage>().equals)
        .transform(DataPointTransformer());

    historyChunks = _mpesaSmsController
        .distinct(Collections.ListEquality<MPMessage>().equals)
        .transform(ChunkTransformer());

    statsStream = _mpesaSmsController
        .distinct(Collections.ListEquality<MPMessage>().equals)
        .transform(StatsTransformer());


    smsServiceProxy.getSmsMessages().then((List data) {
      _mpesaSmsController.sink.add(data);
    });

    Future.delayed(Duration(seconds: 10), (){
      smsServiceProxy.getSmsMessages().then((List data) {
        _mpesaSmsController.sink.add(data);
      });
    });

    contactServiceProxy.getContacts().then((data) {
      _myContactsController.sink.add(data);
    });
  }

  void dispose() {
    _myContactsController.close();
    _mpesaSmsController.close();
    _queryMessages.close();
  }
}

/// Used together with a [StatsTransformer()] to Map Message events to Statistics Map
class StatisticsSink extends EventSink<List<MPMessage>> {

  final EventSink<Map<String, double>> _eventSink;

  StatisticsSink(this._eventSink);

  Map<String, double> transformEvent(List<MPMessage> messages) {
    double expenseSum = 0;
    double incomeSum = 0;
    double txFees = 0;
    double balance = messages.first.txBal;
    messages.forEach((MPMessage m) {
      switch (m.mpMessageType) {
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
    return {
      SmsServiceProxy.INCOME: incomeSum,
      SmsServiceProxy.EXPENSE: expenseSum,
      SmsServiceProxy.FEES: txFees,
      SmsServiceProxy.BALANCE: balance
    };
  }

  @override
  void add(List<MPMessage> event) {
    _eventSink.add(transformEvent(event));
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _eventSink.addError(error);
  }

  @override
  void close() {
    _eventSink.close();
  }
}

class StatsTransformer extends StreamTransformerBase<List<MPMessage>, Map<String, double>> {

  @override
  Stream<Map<String, double>> bind(Stream<List<MPMessage>> stream) {
    return new
    Stream<Map<String, double>>.eventTransformed(stream,
            (EventSink<Map<String, double>> eventSink) =>
                StatisticsSink(eventSink));
  }
  
}

class ChunkSink extends EventSink<List<MPMessage>> {

  final EventSink<Map<DateTime, List<MPMessage>>> _eventSink;

  ChunkSink(this._eventSink);

  @override
  void add(List<MPMessage> event) {
    _eventSink.add(Collections.groupBy(event, (MPMessage el) {
      return DateTime(el.txDate.year, el.txDate.month, el.txDate.day);
    }));
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _eventSink.addError(error);
  }

  @override
  void close() {
    _eventSink.close();
  }

}

class ChunkTransformer extends StreamTransformerBase<List<MPMessage>,Map<DateTime, List<MPMessage>>> {
  @override
  Stream<Map<DateTime, List<MPMessage>>> bind(Stream<List<MPMessage>> stream) {
    // TODO: implement bind
    return new Stream<Map<DateTime, List<MPMessage>>>.eventTransformed(
        stream,
            (EventSink<Map<DateTime,List<MPMessage>>> eventSink) =>
                ChunkSink(eventSink));
  }
  
}

class DataPointTransformer extends StreamTransformerBase<List<MPMessage>,List<DataPoint<DateTime>>> {

  @override
  Stream<List<DataPoint<DateTime>>> bind(Stream<List<MPMessage>> stream) {
    // TODO: implement bind
    return new Stream<List<DataPoint<DateTime>>>.eventTransformed(
        stream,
            (EventSink _eventSink) => DataPointSink(_eventSink));
  }

}

class DataPointSink extends EventSink<List<MPMessage>> {
  final EventSink<List<DataPoint<DateTime>>> _eventSink;
  DataPointSink(this._eventSink);

  @override
  void add(List<MPMessage> event) {
    _eventSink.add(event.map((msg) {
      return DataPoint<DateTime>(value: msg.txBal, xAxis: msg.txDate);
    }).toList());
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _eventSink.addError(error);
  }

  @override
  void close() {
    _eventSink.close();
  }
}
