import 'dart:async';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:billie/proxy/contact_service_proxy.dart';

///PROTIP:
/// Use  [StreamController] if you need access to a [Sink], can be refactored later
/// within Service proxy to Marshall [MPMessage]s on the fly and push them to the
/// stream directly for better response, chack for Data though!!

class SmsRetrieverBloc {
  final SmsServiceProxy smsServiceProxy;
  final ContactServiceProxy contactServiceProxy;

  BehaviorSubject<List<MPMessage>> _mpesaSmsController = BehaviorSubject<List<MPMessage>>();
  StreamController<List<DataPoint<DateTime>>> _datapointController = StreamController();
  StreamController<Map<String,double>> _statsController = StreamController();
  StreamController<Map<DateTime,List<MPMessage>>> _historyChunkController = StreamController();

  ReplaySubject<String>   _queryMessages =  ReplaySubject<String>(maxSize: 1);

  Stream<List<MPMessage>> get mpesaSmsStream => _mpesaSmsController.stream;
  Stream<List<DataPoint<DateTime>>> get datapointsStream => _datapointController.stream;
  Stream<Map<String,double>> get statsStream => _statsController.stream;
  Stream<Map<DateTime,List<MPMessage>>> get historyChunks => _historyChunkController.stream;


  Sink<String> get queryMessages => _queryMessages;

  BehaviorSubject<Iterable<Contact>> _myContactsController = BehaviorSubject<Iterable<Contact>>();

  Stream<Iterable<Contact>> get allContacts => _myContactsController.stream;


  Stream<Iterable<Contact>> get filterContacts => Observable.combineLatest2(
      _queryMessages.debounceTime(Duration(milliseconds: 600)).distinct(), allContacts,
          (String filter, Iterable<Contact> contacts) {
        return contacts.where((contact) =>
        contact.phones.any((phone) => phone.value.contains(filter)) ||
            contact.displayName.toLowerCase().contains(filter.toLowerCase())
        );
      });

  ///TODO: Switch to iterator model to handle larger workloads better
  Stream<List<MPMessage>> get queryResults  => Observable.combineLatest2(
      _queryMessages.debounceTime(Duration(milliseconds: 600)).distinct(),  mpesaSmsStream,
          (String eventString, List messages){
        return messages.where((message){
      return message.bodyString.toLowerCase().contains(eventString.toLowerCase(),);
    }).take(10).toList();
  });


  SmsRetrieverBloc(this.smsServiceProxy, this.contactServiceProxy){
    smsServiceProxy.getSmsMessages().then((List data){
      _mpesaSmsController.sink.add(data);
    });

    contactServiceProxy.getContacts().then((data){
      _myContactsController.sink.add(data);
    });

    mpesaSmsStream.listen((e){
      _datapointController.addStream(smsServiceProxy.getDataPoints(e).asStream());
      _statsController.addStream(smsServiceProxy.getReducedSums(e).asStream());
      _historyChunkController.addStream(smsServiceProxy.chunkByDate(e).asStream());
    });

  }

  void dispose(){
    _myContactsController.close();
    _mpesaSmsController.close();
    _datapointController.close();
    _statsController.close();
    _historyChunkController.close();
    _queryMessages.close();
  }
}
