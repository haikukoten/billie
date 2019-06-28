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

class BillieWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.purpleAccent,
      child: SafeArea(child: NestedScrollView(
          headerSliverBuilder: (BuildContext c, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: Colors.purpleAccent,
              title: Text("Billie Wallet"),
              centerTitle: true,
              elevation: 0.0,
              leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
                print("Stuff");
              }),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.account_circle), onPressed: (){
                  print("Stuff");
                }),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
                delegate: WalletStatHeader())
          ],
          body:

         Material(
           color: Colors.white,
           child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      child: Center(
                        child: Text("Chart",textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      child: Center(
                        child: Text("Row of Contacts"),
                      ),
                    ),
                  ),
                  SliverList(delegate: SliverChildBuilderDelegate((_,index) =>
                      Container(
                        child: Text("Unique Company! $index",textAlign: TextAlign.center,),
                      ), childCount: 30)
                  )
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return ClipRect(
      child: Container(
        color: Colors.purpleAccent,
        height: 182.0,
        alignment: Alignment.center,
        child: Text("Header", textAlign: TextAlign.center,),
      ),
    );
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
    return oldDelegate!= this;
  }
}

class ChartWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


