import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';

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

class BillieWallet extends StatelessWidget {

  //Key drawerKey = Key("drawer");
  //TODO: Convert to stateful and use scaffoldstate for programmatic drawer opening

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
          child: NestedScrollView(
        headerSliverBuilder: (BuildContext c, _) => [
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
                  print("Stuff");
                }),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    print("Stuff");
                  }),
            ],
          ),
          SliverPersistentHeader(pinned: true, delegate: WalletStatHeader())
        ],
        body: Material(
          color: Colors.white,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                    height: 200,
                    child: ChartWrapper()),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 150,
                  padding: EdgeInsets.all(4.0),
                  child: RecentContactList()
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (_, index) =>
                          HistoryTile(),
                      childCount: 70))
            ],
          ),
        ),
      )
      ),
    );
  }
}

class WalletStatHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(
        color: Colors.purpleAccent,
        height: 182.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        alignment: Alignment.center,
        child: WalletBalanceWidget());
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 128.0;

  @override
  // TODO: implement minExtent
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return oldDelegate != this;
  }
}

class ChartWrapper extends StatelessWidget {

  final fromDate = DateTime(2019, 05, 22);
  final toDate = DateTime.now();

  final date1 = DateTime.now().subtract(Duration(days: 2));
  final date2 = DateTime.now().subtract(Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.red,
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: BezierChart(
          fromDate: fromDate,
          bezierChartScale: BezierChartScale.WEEKLY,
          toDate: toDate,
          selectedDate: toDate,
          series: [
            BezierLine(
              label: "Duty",
              onMissingValue: (dateTime) {
                if (dateTime.day.isEven) {
                  return 10.0;
                }
                return 5.0;
              },
              data: [
                DataPoint<DateTime>(value: 10, xAxis: date1),
                DataPoint<DateTime>(value: 50, xAxis: date2),
              ],
            ),
          ],
          config: BezierChartConfig(
            verticalIndicatorStrokeWidth: 3.0,
            verticalIndicatorColor: Colors.black26,
            showVerticalIndicator: true,
            verticalIndicatorFixedPosition: false,
            backgroundColor: Colors.deepPurpleAccent,
            footerHeight: 50.0,
          ),
        ),
      ),
    );
  }
}

class WalletBalanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      //direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "12,000 \u2070\u2070",
              style: TextStyle(fontSize: 52.0),
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
                  Text("EXPENSE", style: TextStyle(fontSize: 16.0)),
                  Text("6,500 \u2070\u2070", style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Text("INCOME", style: TextStyle(fontSize: 16.0)),
                  Text("6,500 \u2070\u2070", style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
          ],
        ),
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


