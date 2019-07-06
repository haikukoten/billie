import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:billie/providers/MPMessagesProvider.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:flutter/material.dart';
import 'package:billie/widgets/quick_stats.dart';
import 'dart:math' as math;

import 'models/MPesaMessage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billie',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: BillieWallet(),
    );
  }
}

class BillieWallet extends StatefulWidget {
  //Key drawerKey = Key("drawer");
  //TODO: Convert to stateful and use [ScaffoldState] for programmatic drawer opening

  @override
  _BillieWalletState createState() => _BillieWalletState();
}

class _BillieWalletState extends State<BillieWallet> {
  String _batteryLevel = "Unknown";
  SmsRetrieverBloc smsRetrieverBloc;

  List<Widget> slivers = new List<Widget>();


  @override
  void dispose() {
    smsRetrieverBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    slivers.add(SliverAppBar(
      pinned: false,
      //expandedHeight: 120.0,
      backgroundColor: Colors.white,
      title: Text(
        "Billie Wallet",
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
      elevation: 0.0,
      leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            print("$_batteryLevel");
          }),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.black,
            ),
            onPressed: () {}),
      ],
    ),);

    slivers.add( SliverPersistentHeader(pinned: true, delegate: WalletStatistic()),);
    slivers.add(SliverToBoxAdapter(child: Container(height: 200, child: ChartWrapper()),),);
    slivers.add(SliverToBoxAdapter(child: ListTile(
      dense: true,
      title: Text("TRANSACTION HISTORY", style: TextStyle(
        color: Colors.grey,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
        fontSize: 10.0
      ),),
    ),));
    //slivers.add(HistoryBox());

    return Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          //key: drawerKey,
          child: Container(
            color: Colors.white,
            height: 500,
          ),
        ),
        //color: Colors.purpleAccent,
        body: SafeArea(
          child: MPMessagesProvider(
            child: Builder(
              builder: (innerContext){
                smsRetrieverBloc = MPMessagesProvider.smsBlocOf(innerContext);
                return Material(
                color: Colors.white,
                child:
                StreamBuilder<Object>(
                  stream: smsRetrieverBloc.historyChunks,
                  builder: (context, AsyncSnapshot<Object> snapshot) {
                    return CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      key: PageStorageKey<String>("csrv"),
                      slivers: slivers..addAll(SliverSectionBuilder().create(snapshot)),
                    );
                  }
                ),
              );},
            ),
          ),
        ));
    //);
  }
}

class WalletStatistic extends SliverPersistentHeaderDelegate {
  SmsRetrieverBloc smsRetrieverBloc;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return StreamBuilder(
        stream: smsRetrieverBloc.statsStream,
        builder: (c, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.active:
              return snapshot.hasData
                  ? Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(0.0),
                      elevation: 2.0,
                      shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      //height: 182.0,
                      //padding:EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      //alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: WalletBalanceWidget(
                          snapshot.data,
                        ),
                      ))
                  : Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text("Sanity -> No Data, Stats"));
              break;
            default:
              return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text("Sanity -> No Data, Stats"));
          }
        });
  }

  @override
  bool shouldRebuild(WalletStatistic oldDelegate) {
    // TODO: implement shouldRebuild
    return oldDelegate != this;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 132.0;

  @override
  // TODO: implement minExtent
  double get minExtent => 102.0;
}

class WalletBalanceWidget extends StatelessWidget {
  final Map<String, double> stats;

  WalletBalanceWidget(this.stats);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return QuickStats(
        balance: stats[SmsServiceProxy.BALANCE],
        expense: stats[SmsServiceProxy.EXPENSE],
        income: stats[SmsServiceProxy.INCOME]);
  }
}

class SliverSectionBuilder {

  static const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  String capitalize(String f){
    return "${f[0].toUpperCase()}${f.substring(1)}";
  }

  List<Widget> create(AsyncSnapshot items){
    //var keys = items.keys.toList();
    //var values = items.values.toList();
    switch(items.connectionState){
      case ConnectionState.done:
      case ConnectionState.waiting:
      case ConnectionState.active:
        if (items.hasData) {
          return  (items.data as Map<DateTime,List>).keys.map((DateTime e) =>
              SliverStickyHeaderBuilder(
                  builder: (context, state) {
                     return Card(
                       margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    elevation: state.isPinned ? (4.0) : 1.0 - (state.scrollPercentage),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)
                    ),
                    //padding: const EdgeInsets.all(8.0),
                    child: new Container(
                      height: 30.0,
                      color: (state.isPinned
                          ? Colors.white
                          : Colors.white).withOpacity(1.0 - state.scrollPercentage),
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        DateTime.now().difference(e) < Duration(days: 30)
                            ? '${timeago.format(e).toUpperCase()}'
                            : '${timeago.format(e).toUpperCase()} on ${ months[e.month]} ${e.day}',
                        style: TextStyle(
                          fontSize: 12.0,
                          //fontWeight: FontWeight.bold,
                          //color: state.isPinned ? Colors.white : Colors.black87
                        ),
                      ),
                    ),
                  );},
                  sliver: new SliverList(
                    delegate: new SliverChildBuilderDelegate(
                          (context, i) => HistoryTile(items.data[e][i]),
                      childCount: items.data[e].length,
                    ),
                  ))
          ).toList();
        } else {
          return [];
        }
        break;
      default:
        return [];
    }
  }
}

class ChartWrapper extends StatelessWidget {
  SmsRetrieverBloc smsRetrieverBloc;

  @override
  Widget build(BuildContext context) {
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return Center(
        child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder(
                stream: smsRetrieverBloc.datapointsStream,
                builder: (_, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                    case ConnectionState.active:
                      var data = snapshot.data as List<DataPoint>;
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: BezierChart(
                          fromDate: data.last.xAxis,
                          //TODO: Use a custom scale to better handle missing values
                          bezierChartScale: BezierChartScale.WEEKLY,
                          toDate: data.first.xAxis,
                          selectedDate:
                              data.first.xAxis,
                          //xAxisCustomValues: (snapshot.data as List<MPMessage>).map((m) => m.txDate).toList(),
                          series: [
                            BezierLine(
                              label: "Duty",
                              lineColor: Colors.purpleAccent,
                              onMissingValue: (dateTime) {
                                return math.Random().nextDouble() * 5000;
                              },
                              data: snapshot.data,
                            )
                          ],
                          config: BezierChartConfig(
                            verticalIndicatorStrokeWidth: 3.0,
                            verticalIndicatorColor: Colors.black26,
                            pinchZoom: true,
                            //showVerticalIndicator: true,
                            //xLinesColor: Colors.black45,
                            xAxisTextStyle: TextStyle(color: Colors.black45),
                            //displayYAxis: true,
                            startYAxisFromNonZeroValue: false,
                            yAxisTextStyle: TextStyle(color: Colors.black54),
                            verticalIndicatorFixedPosition: false,
                            //backgroundColor: Colors.deepPurpleAccent,
                            footerHeight: 50.0,
                          ),
                        ),
                      );
                      break;
                    default:
                      return Container(
                        alignment: Alignment.center,
                        child: Text("Sanity -> Default, Stats"),
                      );
                  }
                })));
  }
}

class HistoryTile extends StatelessWidget {

  final MPMessage message;

  HistoryTile(this.message);

  static const unicode_map = {
    // #           superscript     subscript
    '0': {"sp": '\u2070', "sb": '\u2080'},
    '1': {"sp": '\u00B9', "sb": '\u2081'},
    '2': {"sp": '\u00B2', "sb": '\u2082'},
    '3': {"sp": '\u00B3', "sb": '\u2083'},
    '4': {"sp": '\u2074', "sb": '\u2084'},
    '5': {"sp": '\u2075', "sb": '\u2085'},
    '6': {"sp": '\u2076', "sb": '\u2086'},
    '7': {"sp": '\u2077', "sb": '\u2087'},
    '8': {"sp": '\u2078', "sb": '\u2088'},
    '9': {"sp": '\u2079', "sb": '\u2089'},
  };

  //Creates a string with the decimal points as superscripts
  String formatAsCurrency(double value) {
    String num = value.toStringAsFixed(2);
    var s =
        "${unicode_map[num.substring(num.length - 2, num.length - 1)]["sp"]}${unicode_map[num.substring(num.length - 1, num.length)]["sp"]}";
    return "\$${value.toStringAsFixed(0)}.$s";
  }


  @override
  Widget build(BuildContext context) {
    switch(message.mpMessageType){
      case MPMessageType.MP_TYPE_RECEIVE:
        return ListTile(
          leading: IconButton(
            color: Colors.green,
              iconSize: 20.0,
              icon: Icon(Icons.monetization_on),
              onPressed: (){}),
          title: Text("${message.participant[1].toUpperCase()}${message.participant.substring(2)}"),
          dense: true,
          subtitle: Text(formatAsCurrency(message.txAmount)),
        );
      case MPMessageType.MP_TYPE_UNKNOWN:
        return ListTile(
          dense: true,
          leading: IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.room_service), onPressed: (){}),
          title: Text("Service Message!"),
        );
      case MPMessageType.MP_TYPE_AIRTIME:
        return ListTile(
          leading: IconButton(
              iconSize: 20.0,
              color: Colors.blue,
              icon: Icon(Icons.perm_data_setting), onPressed: (){}),
          title: Text("Airtime purchase"),
          dense: true,
          subtitle: Text(formatAsCurrency(message.txAmount)),
        );
      default:
        return ListTile(
          leading: IconButton(
              color: Colors.redAccent,
              iconSize: 20.0,
              icon: Icon(Icons.payment), onPressed: (){}),
          dense: true,
          title: Text("${message.participant[1].toUpperCase()}${message.participant.substring(2)}"),
          subtitle: Text("${formatAsCurrency(message.txAmount)}  |  Fees: ${formatAsCurrency(message.txFees)}"),
        );
    }
  }
}
