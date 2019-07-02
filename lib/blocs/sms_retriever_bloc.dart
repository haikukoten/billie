import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/proxy/sms_service_proxy.dart';

///PROTIP:
/// Use  [StreamController] if you need access to a [Sink], can be refactored later
/// within Service proxy to Marshall [MPMessage]s on the fly and push them to the
/// stream directly for better response, chack for Data though!!

class SmsRetrieverBloc {
  final SmsServiceProxy smsServiceProxy;
  Stream<List<MPMessage>> mpesaSmsStream = Stream.empty();
  Stream<List<DataPoint<DateTime>>> datapointsStream = Stream.empty();
  Stream<Map<String,double>> statsStream = Stream.empty();
  Stream<Map<DateTime,List<MPMessage>>> historyChunks = Stream.empty();

  //TODO: Switch to StreamController based
  SmsRetrieverBloc(this.smsServiceProxy){
    mpesaSmsStream = smsServiceProxy.getSmsMessages().asStream().asBroadcastStream();
    /*final subscription =
    * Can be cancelled and resumed, paused
    * */
    mpesaSmsStream.listen((smsData){
      this.statsStream = smsServiceProxy.getReducedSums(smsData).asStream();
      this.historyChunks = smsServiceProxy.chunkByDate(smsData).asStream();
      this.datapointsStream = smsServiceProxy.getDataPoints(smsData).asStream();
    }, onError: (r) => print("Error in Bloc: $r"));
  }
}
