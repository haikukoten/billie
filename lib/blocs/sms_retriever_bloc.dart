import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/proxy/sms_service_proxy.dart';

class SmsRetrieverBloc {
  final SmsServiceProxy smsServiceProxy;
  Stream<List<MPMessage>> mpesaSmsStream = Stream.empty();

  SmsRetrieverBloc(this.smsServiceProxy)
      : mpesaSmsStream = smsServiceProxy.getSmsMessages().asStream().asBroadcastStream();
}
