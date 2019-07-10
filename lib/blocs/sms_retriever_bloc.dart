import 'dart:async';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart' as Collections;
///PROTIP:
/// Use  [StreamController] if you need access to a [Sink], can be refactored later
/// within Service proxy to Marshall [MPMessage]s on the fly and push them to the
/// stream directly for better response, chack for Data though!!

class SmsRetrieverBloc {
  final SmsServiceProxy smsServiceProxy;

  StreamController<List<MPMessage>> _mpesaSmsController = StreamController
      .broadcast(
      onListen: (){print("MPMessage Listener");},
      onCancel: (){print("MPMessage listener Cancelled");},
  );

  StreamController<List<DataPoint<DateTime>>> _datapointController = StreamController
      (
    onListen: (){print("Datapoints Listener");},
    onCancel: (){print("Datapoints listener Cancelled");
    },
  );

  StreamController<Map<String,double>> _statsController = StreamController
    .broadcast(
      onListen: (){print("Stats Listener");},
      onCancel: (){print("Stats listener Cancelled");},
  );

  StreamController<Map<DateTime,List<MPMessage>>> _historyChunkController = StreamController
    (
    onListen: (){print("History Listener");},
    onCancel: (){print("History listener Cancelled");
    },
  );

  ReplaySubject<String>   _queryMessages =  ReplaySubject<String>(maxSize: 5);
  //Stream<List<MPMessage>> _queryResults  =  Stream.empty(); //Track query results
  //Stream<String>          _queryLog      =  Stream.empty(); //Track latest query

  Stream<List<MPMessage>> get mpesaSmsStream => _mpesaSmsController.stream;
  Stream<List<DataPoint<DateTime>>> get datapointsStream => _datapointController.stream;
  Stream<Map<String,double>> get statsStream => _statsController.stream;
  Stream<Map<DateTime,List<MPMessage>>> get historyChunks => _historyChunkController.stream;


  Sink<String> get queryMessages => _queryMessages;
  //Stream<String> get queryLog => _queryLog;
  Stream<List<MPMessage>> get queryResults  =>

      Observable.combineLatest2(_queryMessages.debounceTime(Duration(milliseconds: 500)), mpesaSmsStream,
          (String eventString, List messages){
    return messages.where((message){
      return message.participant.contains(eventString.toLowerCase());
    }).take(10).toList();
  });

  StreamSubscription mpesaStreamSub;


  SmsRetrieverBloc(this.smsServiceProxy){
    smsServiceProxy.getSmsMessages().then((List data){
      _mpesaSmsController.sink.add(data);
    });

    queryResults.listen((results){
      print("LenRes: ${results.length}");
    });

    mpesaStreamSub = mpesaSmsStream.listen((e){
      _datapointController.addStream(smsServiceProxy.getDataPoints(e).asStream());
      _statsController.addStream(smsServiceProxy.getReducedSums(e).asStream());
      _historyChunkController.addStream(smsServiceProxy.chunkByDate(e).asStream());
    });

  }

  void dispose(){
    mpesaStreamSub.cancel();
    _mpesaSmsController.close();
    _datapointController.close();
    _statsController.close();
    _historyChunkController.close();
    _queryMessages.close();
  }
}
