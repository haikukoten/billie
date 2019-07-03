import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/providers/MPMessagesProvider.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:flutter/material.dart';
import 'package:billie/widgets/quick_stats.dart';

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
    print("DISPOSE");
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
    //slivers.add(SliverPersistentHeader(pinned: true, delegate: WalletStatistic()),);
    slivers.add(SliverToBoxAdapter(child: Container(height: 200, child: ChartWrapper()),),);
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
                  builder: (context, snapshot) {
                    return CustomScrollView(
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
                  ? Container(
                      color: Colors.white,
                      height: 182.0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      //alignment: Alignment.center,
                      child: WalletBalanceWidget(
                        snapshot.data,
                      ))
                  : Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text("Sanity -> No Data, Stats"));
              break;
            default:
              return Container(
                height: 182.0,
                child: Text("YIII"),
              );
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
  double get maxExtent => 128.0;

  @override
  // TODO: implement minExtent
  double get minExtent => 92.0;
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

  List<Widget> create(AsyncSnapshot  items){
    //var keys = items.keys.toList();
    //var values = items.values.toList();
    switch(items.connectionState){
      case ConnectionState.done:
      case ConnectionState.waiting:
      case ConnectionState.active:
        if (items.hasData) {
          print("SectionBuilder -> ${items.data.keys.length}");
          return  (items.data as Map).keys.map((e) =>
              SliverStickyHeaderBuilder(
                  builder: (context, state) => new Container(
                    height: 60.0,
                    color: (state.isPinned
                        ? Colors.pink
                        : Colors.lightBlue)
                        .withOpacity(1.0 - state.scrollPercentage),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: new Text(
                      '$e',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  sliver: new SliverList(
                    delegate: new SliverChildBuilderDelegate(
                          (context, i) => HistoryTile(),
                      childCount: 4,
                    ),
                  ))
          ).toList();
        } else {
          return [SliverToBoxAdapter(
            child: Text("No entries!"),
          )];
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
                      return BezierChart(
                        fromDate: (snapshot.data as List<DataPoint>).last.xAxis,
                        bezierChartScale: BezierChartScale.MONTHLY,
                        toDate: (snapshot.data as List<DataPoint>).first.xAxis,
                        selectedDate:
                            (snapshot.data as List<DataPoint>).first.xAxis,
                        //xAxisCustomValues: (snapshot.data as List<MPMessage>).map((m) => m.txDate).toList(),
                        series: [
                          BezierLine(
                            label: "Duty",
                            lineColor: Colors.purpleAccent,
                            onMissingValue: (dateTime) {
                              if (dateTime.day.isEven) {
                                return 20.0;
                              }
                              return 5.0;
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
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(icon: Icon(Icons.business_center), onPressed: null),
      title: Text("Business or Contact"),
      subtitle: Text("some mor information or something"),
    );
  }
}
