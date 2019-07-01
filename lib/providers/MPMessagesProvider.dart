import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:flutter/material.dart';

// Allows Blocs to be accessed via the Context that sort of trickles down the tree
// But whatever

class MPMessagesProvider extends InheritedWidget {
  final SmsRetrieverBloc smsRetrieverBloc;

  MPMessagesProvider({Key key, Widget child, SmsRetrieverBloc sBloc})
      : this.smsRetrieverBloc =
            sBloc ?? SmsRetrieverBloc(SmsServiceProxy.getInstance()),
        super(key: key, child: child);

  static SmsRetrieverBloc listsBlocOf(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(MPMessagesProvider)
            as MPMessagesProvider)
        .smsRetrieverBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}
