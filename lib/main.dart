import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/providers/MPMessagesProvider.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
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
        child: /*NestedScrollView(
          headerSliverBuilder: (innercontext, __) {
            return [
            SliverOverlapAbsorber(
                // This widget takes the overlapping behavior of the SliverAppBar,
                // and redirects it to the SliverOverlapInjector below. If it is
                // missing, then it is possible for the nested "inner" scroll view
                // below to end up under the SliverAppBar even when the inner
                // scroll view thinks it has not been scrolled.
                // This is not necessary if the "headerSliverBuilder" only builds
                // widgets that do not overlap the next sliver.
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(innercontext),
              child: SliverAppBar(
                pinned: true,
                backgroundColor: Colors.purpleAccent,
                title: Text("Billie Wallet"),
                centerTitle: true,
                elevation: 0.0,
                leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      print("$_batteryLevel");
                    }),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.account_circle), onPressed: () {}),
                ],
              ),),
              /*SliverOverlapAbsorber(
                  // This widget takes the overlapping behavior of the SliverAppBar,
                  // and redirects it to the SliverOverlapInjector below. If it is
                  // missing, then it is possible for the nested "inner" scroll view
                  // below to end up under the SliverAppBar even when the inner
                  // scroll view thinks it has not been scrolled.
                  // This is not necessary if the "headerSliverBuilder" only builds
                  // widgets that do not overlap the next sliver.
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(innercontext),
                  child: */
              Builder(builder: (c) {
                    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(c);
                    return SliverPersistentHeader(
                              //pinned: true,
                                delegate: WalletStatistic());
                  })//)
            ];
          },
          body: */
        Builder(
            builder: (innerContext) => Material(
              color: Colors.white,
              child: CustomScrollView(
                key: PageStorageKey<String>("csrv"),
                slivers: <Widget>[
                 SliverAppBar(
                      pinned: false,
                      backgroundColor: Colors.purpleAccent,
                      title: Text("Billie Wallet"),
                      centerTitle: true,
                      elevation: 0.0,
                      leading: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            print("$_batteryLevel");
                          }),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.account_circle), onPressed: () {}),
                      ],
                    ),
                SliverPersistentHeader(
                  pinned: true,
                    delegate: WalletStatistic()),
                  /*SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(innerContext)),*/
                  SliverToBoxAdapter(
                    child: Container(height: 200, child: ChartWrapper()),
                  ),
                  HistoryBox(),
                  /*SliverObstructionInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(innerContext),
                    //child: Container(height: 200, child: ChartWrapper()),
                  ),*/
                  //SliverOverlapInjector(handle: null)
                ],
              ),
            ),
          ),
        ),
      ));
    //);
  }
}

class WalletStatistic extends SliverPersistentHeaderDelegate{

  SmsRetrieverBloc smsRetrieverBloc;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return
      StreamBuilder(
          stream: smsRetrieverBloc.statsStream,
          builder: (c,snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:
                return snapshot.hasData ? Container(
                    color: Colors.purpleAccent,
                    height: 182.0,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    alignment: Alignment.center,
                    child:
                    WalletBalanceWidget(
                      snapshot.data,
                    )) : Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
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
  double get minExtent => 80.0;

}

class WalletBalanceWidget extends StatelessWidget {

  Map<String, double> stats;

  WalletBalanceWidget(this.stats);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("${stats[SmsServiceProxy.MAX]}");
  }
}

class HistoryBox extends StatelessWidget {
  SmsRetrieverBloc smsRetrieverBloc;

  @override
  Widget build(BuildContext context) {
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return StreamBuilder(
        stream: smsRetrieverBloc.historyChunks,
        builder: (context, snapshot) {
          //print("Data: ${snapshot.data}");
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return new SliverStickyHeaderBuilder(
                builder: (context, state) => new Container(
                  height: 60.0,
                  color: (state.isPinned ? Colors.pink : Colors.lightBlue)
                      .withOpacity(1.0 - state.scrollPercentage),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: new Text(
                    'Header #1',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                sliver: new SliverList(
                  delegate: new SliverChildBuilderDelegate(
                    (context, i) => HistoryTile(),
                    childCount: 14,
                  ),
                ),
              );
            default:
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
          }
        });
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
            //padding: const EdgeInsets.all(8.0),
            stream: smsRetrieverBloc.mpesaSmsStream,
            builder: (_, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return snapshot.hasData
                      ? StreamBuilder(
                          stream: smsRetrieverBloc.datapointsStream,
                          builder: (_, snapshotInner) {
                            switch (snapshotInner.connectionState) {
                              case ConnectionState.done:
                                return BezierChart(
                                  fromDate: (snapshot.data as List<MPMessage>)
                                      .last
                                      .txDate,
                                  bezierChartScale: BezierChartScale.MONTHLY,
                                  toDate: (snapshot.data as List<MPMessage>)
                                      .first
                                      .txDate,
                                  selectedDate:
                                      (snapshot.data as List<MPMessage>)
                                          .first
                                          .txDate,
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
                                      data: snapshotInner.data,
                                    )
                                  ],
                                  config: BezierChartConfig(
                                    verticalIndicatorStrokeWidth: 3.0,
                                    verticalIndicatorColor: Colors.black26,
                                    pinchZoom: true,
                                    //showVerticalIndicator: true,
                                    //xLinesColor: Colors.black45,
                                    xAxisTextStyle:
                                        TextStyle(color: Colors.black45),
                                    //displayYAxis: true,
                                    startYAxisFromNonZeroValue: false,
                                    yAxisTextStyle:
                                        TextStyle(color: Colors.black54),
                                    verticalIndicatorFixedPosition: false,
                                    //backgroundColor: Colors.deepPurpleAccent,
                                    footerHeight: 50.0,
                                  ),
                                );
                              default:
                                return Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                            }
                          })
                      : Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        );
                default:
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
              }
            }),
      ),
    );
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