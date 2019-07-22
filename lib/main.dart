import 'dart:collection';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:billie/widgets/history_tile.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:billie/providers/MPMessagesProvider.dart';
import 'package:billie/proxy/sms_service_proxy.dart';
import 'package:flutter/material.dart';
import 'package:billie/widgets/quick_stats.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:billie/widgets/custom_backdrop.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billie',
      debugShowCheckedModeBanner: false,
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
          fontFamily: "GoogleSans"),
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

enum HandleDrawer {
  HANDLE_ACCOUNT_SETTINGS,
  HANDLE_BACKUP_ACTION,
  HANDLE_RESTORE_ACTION,
  HANDLE_SETTINGS_ACTION,
  HANDLE_FEEDBACK
}

class _BillieWalletState extends State<BillieWallet>
    with TickerProviderStateMixin {
  SmsRetrieverBloc smsRetrieverBloc;
  ScrollController _scrollController;
  Function listener;
  PanelModel panelModel;

  List<Widget> slivers;
  GlobalKey<BackdropState> _globalBackdropKey =
      GlobalKey(debugLabel: "BackDropState");
  ValueNotifier<bool> panelVisible = ValueNotifier(false);

  final List<Map<String, dynamic>> _drawerItems = [
    {
      "name": "Account",
      "subtitle": "Manage your account",
      "action": HandleDrawer.HANDLE_ACCOUNT_SETTINGS,
      "icon": FontAwesomeIcons.userCircle
    },
    {
      "name": "Backup",
      "subtitle": "Create and Manage backups",
      "action": HandleDrawer.HANDLE_ACCOUNT_SETTINGS,
      "icon": FontAwesomeIcons.cloudUploadAlt
    },
    {
      "name": "Settings",
      "subtitle": "Configure the application",
      "action": HandleDrawer.HANDLE_ACCOUNT_SETTINGS,
      "icon": FontAwesomeIcons.toolbox
    },
    {
      "name": "Feedback",
      "subtitle": "Give us your opinion ;)",
      "action": HandleDrawer.HANDLE_ACCOUNT_SETTINGS,
      "icon": FontAwesomeIcons.connectdevelop
    },
  ];

  @override
  void initState() {
    super.initState();
    slivers = List<Widget>();
    _scrollController = ScrollController();
    panelModel = PanelModel(FrontPanels.searchPanel);
    slivers.addAll([
      SliverAppBar(
        pinned: false,
        floating: true,
        expandedHeight: 64.0,
        backgroundColor: Colors.white,
        title: Text(
          "Billie",
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              //letterSpacing: 1.0,
              fontFamily: "Raleway"),
        ),
        centerTitle: true,
        elevation: 0.0,
        leading: Builder(
            //stream: null,
            builder: (innerContext) {
          return IconButton(
              iconSize: 16.0,
              icon: Icon(
                FontAwesomeIcons.bars,
                color: Colors.black,
              ),
              onPressed: () {
                ScaffoldState _scaffoldState = Scaffold.of(innerContext);
                !_scaffoldState.isDrawerOpen
                    ? _scaffoldState.openDrawer()
                    : _scaffoldState.isDrawerOpen;
              });
        }),
        actions: <Widget>[
          IconButton(
              iconSize: 16.0,
              icon: Icon(
                FontAwesomeIcons.wallet,
                color: Colors.black,
              ),
              onPressed: () {
                //TODO: Use stack with some sort of handler for wallet functions
                _globalBackdropKey.currentState.toggleBackdropPanelVisibility();
              }),
        ],
      ),
      SliverPersistentHeader(
          pinned: true, floating: false, delegate: WalletStatistic()),
      SliverToBoxAdapter(
        child: Container(height: 200, child: ChartWrapper()),
      ),
      SliverToBoxAdapter(
        child: Divider(),
      ),
      SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          trailing: Icon(
            FontAwesomeIcons.history, size: 14.0,
            color: Colors.blueGrey.withOpacity(0.5), //: Colors.purple.
          ),
          title: const Text(
            "TRANSACTION HISTORY",
            style: const TextStyle(
                color: Colors.blueGrey,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
                fontSize: 10.0),
          ),
        ),
      )
    ]);
  }

  @override
  void dispose() {
    //_scrollController.removeListener(listener);
    smsRetrieverBloc.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void switchScene(FrontPanels panelType) {
    if (panelModel.activePanelType == panelType) {
      _globalBackdropKey.currentState.toggleBackdropPanelVisibility();
    } else
      panelModel.activate(panelType);
    _globalBackdropKey.currentState.toggleBackdropPanelVisibility();
  }

  Widget _createScrollViewArea() {
    return Builder(
      builder: (innerContext) {
        smsRetrieverBloc = MPMessagesProvider.smsBlocOf(innerContext);
        return Material(
          color: Colors.white,
          child: StreamBuilder<Map<DateTime,List<dynamic>>>(
              initialData: {},
              stream: smsRetrieverBloc.historyChunks,
              builder: (context, AsyncSnapshot<Map<DateTime,List<dynamic>>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      return CustomScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        key: PageStorageKey<String>("csrv"),
                        slivers: slivers
                          ..addAll(SliverSectionBuilder().create(snapshot)),
                      );
                    } else
                      return Container();
                    break;
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              }),
        );
      },
    );
  }

  void handleDrawerAction(HandleDrawer handle) {
    print("Handling ${handle.toString()}");
  }

  Widget _fromDrawerMap(Map<String, dynamic> _drawer) {
    return ListTile(
      dense: true,
      leading: IconButton(
        icon: Icon(_drawer['icon']),
        iconSize: 16.0,
        color: Colors.purpleAccent,
        onPressed: () {},
      ),
      //trailing: Icon(FontAwesomeIcons.googleDrive, size: 16.0,),
      title: Text(
        _drawer['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_drawer['subtitle']),
      onTap: () {
        handleDrawerAction(_drawer['action']);
      },
    );
  }

  Widget renderDrawerListItems() {
    return ListView(
        physics: BouncingScrollPhysics(),
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "https://source.unsplash.com/640x480/?money+currency",
                    )),
              ),
              child: Stack(children: [
                Positioned(
                    //left: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 32.0,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                          child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image:
                                  "https://randomuser.me/api/portraits/women/7.jpg")),
                    )),
              ])),
        ]..addAll(List.generate(_drawerItems.length,
            (index) => _fromDrawerMap(_drawerItems[index]))));
  }

  Future<bool> _asyncBackPressHandler() async {
    if (panelVisible.value) {
      _globalBackdropKey.currentState.toggleBackdropPanelVisibility();
      return false;
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _asyncBackPressHandler,
      child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButton: FloatingActionButton(
              child: Icon(
                FontAwesomeIcons.handHoldingUsd,
                size: 16.0,
              ),
              backgroundColor: Colors.purpleAccent,
              onPressed: () {
                //_scrollController.animateTo(0.0, duration: Duration(seconds: 1), curve: Curves.easeOut);
              }),
          drawer: Drawer(child: renderDrawerListItems()),
          //color: Colors.purpleAccent,
          body: SafeArea(
              child: MPMessagesProvider(
            child: Backdrop(
                key: _globalBackdropKey,
                frontLayer: ScopedModel<PanelModel>(
                  model: panelModel,
                  child: SearchPanel(),
                ),
                frontHeaderVisibleClosed: false,
                frontHeaderHeight: 35.0,
                frontHeader: const Center(
                  child: Icon(FontAwesomeIcons.gripHorizontal),
                ),
                frontPanelOpenHeight: 72.0,
                panelVisible: panelVisible,
                backLayer: Scrollbar(child: _createScrollViewArea())),
          ))),
    );
    //);
  }
}

class WalletStatistic extends SliverPersistentHeaderDelegate {
  SmsRetrieverBloc smsRetrieverBloc;

  static const double _kElevationOnMinShrinkOffset = 0.0;
  static const double _kElevationOnOtherShrinkOffset = 2.0;
  static const double _kMaxExtent = 136.0;
  static const double _kMinExtent = 109.0;
  static const double _kHorizontalCardPadding = 16.0;
  static const double _kVerticalCardPadding = 8.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return StreamBuilder(
        initialData: null,
        stream: smsRetrieverBloc.statsStream,
        builder: (c, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.active:
              return snapshot.hasData
                  ? Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(0.0),
                      elevation: shrinkOffset == 0
                          ? _kElevationOnMinShrinkOffset
                          : _kElevationOnOtherShrinkOffset,
                      //elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      //height: 182.0,
                      //padding:EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      //alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: _kHorizontalCardPadding,
                            vertical: _kVerticalCardPadding),
                        child: WalletBalanceWidget(snapshot.data),
                      ))
                  : Container(
                      height: _kMinExtent,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator());
              break;
            default:
              return Container(
                  height: _kMinExtent,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
          }
        });
  }

  @override
  bool shouldRebuild(WalletStatistic oldDelegate) {
    return oldDelegate != this;
  }

  @override
  double get maxExtent => _kMaxExtent;

  @override
  double get minExtent => _kMinExtent;
}

class WalletBalanceWidget extends StatelessWidget {
  final Map<String, double> stats;

  WalletBalanceWidget(this.stats);

  @override
  Widget build(BuildContext context) {
    return QuickStats(
        balance: stats[SmsServiceProxy.BALANCE],
        expense: stats[SmsServiceProxy.EXPENSE],
        income: stats[SmsServiceProxy.INCOME]);
  }
}

class SliverSectionBuilder {

  static const double _kTitleTextSize = 12.0;
  static const double _kPinnedElevation = 2.0;
  static const double _kUnpinnedElevation = 2.0;
  static const double _kTitleHorizontalPadding = 16.0;
  static const double _kTitleVerticalPadding = 8.0;
  static const double _kTitleHeight = 30.0;

  static const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  String capitalize(String f) {
    return "${f[0].toUpperCase()}${f.substring(1)}";
  }

  Widget _createTitle(SliverStickyHeaderState state, DateTime _dateKey){
    return Row(
      children: <Widget>[
        Expanded(
          child: new Text(
            DateTime.now().difference(_dateKey) < Duration(days: 30)
                ? '${timeago.format(_dateKey).toUpperCase()}'
                : '${timeago.format(_dateKey).toUpperCase()} on ${months[(_dateKey.month - 1)]} ${_dateKey.day ?? "Unknown"}',
            style: TextStyle(
                fontSize: _kTitleTextSize,
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold,
                color:
                state.isPinned ? Colors.purple : Colors.purple.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }

  Widget _createCardSection(AsyncSnapshot _items, DateTime _dateKey) {
    return SliverStickyHeaderBuilder(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: state.isPinned ? (_kPinnedElevation) : _kUnpinnedElevation,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            //padding: const EdgeInsets.all(8.0),
            child: new Container(
              height: _kTitleHeight,
              color: Colors.white.withOpacity(0.7),
              margin:const EdgeInsets.symmetric(
                  horizontal: _kTitleHorizontalPadding,
                  vertical: _kTitleVerticalPadding),
              alignment: Alignment.centerLeft,
              child: _createTitle(state, _dateKey)
            ),
          );
        },
        sliver: new SliverList(
          delegate: new SliverChildBuilderDelegate(
            (context, index) => HistoryTile(_items.data[_dateKey][index]),
            childCount: _items.data[_dateKey].length,
          ),
        ));
  }

  List<Widget> create(AsyncSnapshot<Map<DateTime, List>> items) {
    switch (items.connectionState) {
      case ConnectionState.done:
      case ConnectionState.waiting:
      case ConnectionState.active:
        if (items.hasData) {
          return (items.data)
              .keys
              .map((DateTime dateKey) => _createCardSection(items, dateKey))
              .toList();
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
  final HashMap<DateTime, DataPoint<DateTime>> preComputeCache = new HashMap();
  //final QuiverCache.MapCache<DateTime, DataPoint<DateTime>> preComputeCache = QuiverCache.MapCache();

  @override
  Widget build(BuildContext context) {
    SmsRetrieverBloc smsRetrieverBloc = MPMessagesProvider.smsBlocOf(context);
    return Center(
        child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder(
                initialData: [],
                stream: smsRetrieverBloc.dataPointStream,
                builder: (_, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                    case ConnectionState.active:
                      var data = snapshot.data as List<DataPoint<DateTime>>;
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: BezierChart(
                          fromDate: data.last.xAxis,
                          bezierChartScale: BezierChartScale.WEEKLY,
                          toDate: data.first.xAxis,
                          selectedDate: data.first.xAxis,
                          //xAxisCustomValues: (snapshot.data as List<MPMessage>).map((m) => m.txDate).toList(),
                          series: [
                            BezierLine(
                              label: "Balance",
                              lineColor: Colors.purpleAccent,
                              onMissingValue: (dateTime) {
                                if (preComputeCache[dateTime] != null) {
                                  return preComputeCache[dateTime].value;
                                } else {
                                  DataPoint prev = data.lastWhere(
                                      (e) => dateTime.isBefore(e.xAxis),
                                      orElse: () => data.last);
                                  preComputeCache[dateTime] = prev;
                                  return prev.value;
                                }
                              },
                              data: snapshot.data,
                            ),
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
