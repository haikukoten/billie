import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/providers/MPMessagesProvider.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: false,
              floating: true,
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
                IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
              ],
            ),
            SliverPersistentHeader(pinned: true, delegate: WalletStatHeader())
          ],
          body: Material(
            color: Colors.white,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(height: 200, child: ChartWrapper()),
                ),
                SliverToBoxAdapter(
                  child: Container(
                      height: 150,
                      padding: EdgeInsets.all(4.0),
                      child: RecentContactList()),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (_, index) => HistoryTile(),
                        childCount: 70))
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class WalletStatHeader extends SliverPersistentHeaderDelegate {
  SmsRetrieverBloc smsRetrieverBloc;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return StreamBuilder(
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            //print(snapshot.data);
            return snapshot.hasData ? Container(
                color: Colors.purpleAccent,
                height: 182.0,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                alignment: Alignment.center,
                child: WalletBalanceWidget(
                  mpmessages: snapshot.data as List<MPMessage>,
                )) : Container(
              height: 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          default:
            return Container(
              child: CircularProgressIndicator(),
              height: 200,
              alignment: Alignment.center,
            );
        }
      }
      /*snapshot.hasData
          ? Container(
              color: Colors.purpleAccent,
              height: 182.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              alignment: Alignment.center,
              child: WalletBalanceWidget())
          : Container(
              child: CircularProgressIndicator(),
              height: 200,
              alignment: Alignment.center,
            ),*/
      ,
      stream: smsRetrieverBloc.mpesaSmsStream,
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 128.0;

  @override
  // TODO: implement minExtent
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return oldDelegate != this;
  }
}

class ChartWrapper extends StatelessWidget {
  SmsRetrieverBloc smsRetrieverBloc;

  final toDate = DateTime.now();

  final date0 = DateTime.now().subtract(Duration(days: 1));
  final date1 = DateTime.now().subtract(Duration(days: 2));
  final date2 = DateTime.now().subtract(Duration(days: 3));
  final date3 = DateTime.now().subtract(Duration(days: 5));
  final date4 = DateTime.now().subtract(Duration(days: 9));

  @override
  Widget build(BuildContext context) {
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);

    final fromDate = DateTime(2017, 05, 22);

    return Center(
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
            //padding: const EdgeInsets.all(8.0),
          stream: smsRetrieverBloc.mpesaSmsStream,
            builder: (_, snapshot) {
              switch(snapshot.connectionState){
                case ConnectionState.done:
                   return snapshot.hasData ? BezierChart(
                    fromDate: (snapshot.data as List<MPMessage>).last.txDate,
                    bezierChartScale: BezierChartScale.MONTHLY,
                    toDate: (snapshot.data as List<MPMessage>).first.txDate,
                    selectedDate: (snapshot.data as List<MPMessage>).first.txDate,
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
                        data:
                        (snapshot.data as List<MPMessage>).map((e) =>
                            DataPoint<DateTime>(value: e.txBal, xAxis: e.txDate)).toList()
                        /*[
                          DataPoint<DateTime>(value: 60, xAxis: date0),
                          DataPoint<DateTime>(value: 10, xAxis: date1),
                          DataPoint<DateTime>(value: 20, xAxis: date1),
                          DataPoint<DateTime>(value: 50, xAxis: date3),
                          DataPoint<DateTime>(value: 80, xAxis: date4),
                        ]*/,
                      ),
                    ],
                    config: BezierChartConfig(
                      verticalIndicatorStrokeWidth: 3.0,
                      verticalIndicatorColor: Colors.black26,
                      showVerticalIndicator: true,
                      //xLinesColor: Colors.black45,
                      xAxisTextStyle: TextStyle(color: Colors.black45),
                      displayYAxis: true,
                      verticalIndicatorFixedPosition: false,
                      //backgroundColor: Colors.deepPurpleAccent,
                      footerHeight: 50.0,
                    ),
                  ) : Container(
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

class WalletBalanceWidget extends StatelessWidget {
  final List<MPMessage> mpmessages;
  WalletBalanceWidget({this.mpmessages});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      //direction: Axis.vertical,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "CURRENT BALANCE",
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        Expanded(
          //flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "\$${mpmessages.first.txBal.toStringAsFixed(0)}\u2070\u2070",
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        Row(
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Column(
                children: <Widget>[
                  Text("EXPENSE", style: TextStyle(fontSize: 14.0)),
                  Text("\$6,500 \u2070\u2070",
                      style: TextStyle(fontSize: 14.0)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Text("INCOME", style: TextStyle(fontSize: 14.0)),
                  Text("\u00246,500 \u2070\u2070",
                      style: TextStyle(fontSize: 14.0)),
                ],
              ),
            ),
          ],
        ),
        //ClipRect(
        //child: Padding(
        //padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        //child:
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("~Past 30 days", style: TextStyle(fontSize: 12.0))),
        // ),
        //)
      ],
    );
  }
}

class RecentContactList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        Container(
          width: 160.0,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.red,
          ),
        ),
        Container(
          width: 160.0,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.blue,
          ),
        ),
        Container(
          width: 160.0,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.green,
          ),
        ),
        Container(
          width: 160.0,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.yellow,
          ),
        ),
        Container(
          width: 160.0,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.orange,
          ),
        ),
      ],
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
