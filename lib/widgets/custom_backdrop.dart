import 'dart:ui';

import 'package:billie/blocs/sms_retriever_bloc.dart';
import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/providers/MPMessagesProvider.dart';
import 'package:billie/proxy/contact_service_proxy.dart';
import 'package:billie/widgets/history_tile.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:math' as math;

import 'package:transparent_image/transparent_image.dart';

enum FrontPanels { searchPanel, infoPanel }


class MessageViewModel extends Model{

  bool _useCondensedModel;

  MessageViewModel(this._useCondensedModel);

  bool get activeModelType => _useCondensedModel;


  void activate(bool model) {
    if(model != _useCondensedModel){
      _useCondensedModel = model;
      notifyListeners();
    }
  }

}

///Model to track which panel will be rendered onto the top of the stack
class PanelModel extends Model {
  ///
  FrontPanels _activePanel;

  PanelModel(this._activePanel);

  FrontPanels get activePanelType => _activePanel;

  //In case we need a draggable title!
  /*Widget panelTitle(BuildContext context) {
    return Container(
      child: Center(
        child: _activePanel == FrontPanels.panelOne
            ? Text('Panel ONE')
            : Text('Panel TWO'),
      ),
    );
  }*/

  Widget get activePanel => InkWell(
        //onTap: (){activate(FrontPanels.infoPanel);},
        child: _activePanel == FrontPanels.searchPanel
            ? SearchActivity()
            : InfoPanel(),
      );

  void activate(FrontPanels panel) {
    _activePanel = panel;
    notifyListeners();
  }
}

class SearchActivity extends StatefulWidget {
  @override
  _SearchActivityState createState() => _SearchActivityState();
}

class _SearchActivityState extends State<SearchActivity> {
  TextEditingController controller;
  FocusNode focusNode;
  SmsRetrieverBloc smsRetrieverBloc;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
  }

  void clearTextCallBack() {
    setState(() {
      controller.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    smsRetrieverBloc  = MPMessagesProvider.smsBlocOf(context);

    return Scrollbar(
      child: ScopedModel(
        model: MessageViewModel(true),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverPersistentHeader(
              floating: true,
                delegate: SearchActivityDelegate(
                    editingController: controller,
                    focusNode: focusNode,
                    smsRetrieverBloc: smsRetrieverBloc,
                    clearCallBack: this.clearTextCallBack)),
            SliverToBoxAdapter(
              child: Container(
                height: 24.0,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("CONTACT RESULTS", style: TextStyle(
                  fontSize: 10.0, color: Colors.blueGrey, fontWeight: FontWeight.bold
                ),),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 72.0,
                child: StreamBuilder<Iterable<Contact>>(
                  stream: smsRetrieverBloc.filterContacts,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState){
                      case ConnectionState.active:
                      case ConnectionState.done:

                      List<Contact> data =  snapshot.data.take(10).toList() ?? [];

                      return   data.length > 0 ?
                      ListView.builder(itemBuilder: (_,i){
                        return  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FutureBuilder<Iterable<Contact>>(
                                future: ContactServiceProxy.getInstance().searchContact(data[i].displayName),
                                builder: (context, snapshot) {
                                  switch(snapshot.connectionState){
                                    case ConnectionState.done:
                                    case ConnectionState.active:
                                      //print("${data[i].displayName}: ${snapshot.data.first.avatar.isEmpty}");
                                    return (snapshot.hasData && snapshot.data.length > 0) ? InkWell(
                                      child: CircleAvatar(
                                        radius: 24.0,
                                        child: ClipOval(
                                          child: snapshot.data.first.avatar.isEmpty
                                              ? Text(data[i].displayName.substring(0,1))
                                              : Image.memory(snapshot.data.first.avatar),
                                        ),
                                      ),
                                      onTap: (){
                                        String phoneNo = data[i].phones.first.value.replaceAll(" ", "").replaceAll("-", "").trim();
                                        smsRetrieverBloc.queryMessages.add(phoneNo);
                                        controller.text = phoneNo;
                                      },
                                    ): InkWell(
                                      child: CircleAvatar(
                                        radius: 24.0,
                                        child: ClipOval(
                                          child:Text(data[i].displayName.substring(0,1)),
                                        ),
                                      ),
                                      onTap: (){
                                        String phoneNo = data[i].phones.first.value.replaceAll(" ", "").replaceAll("-", "").trim();
                                        smsRetrieverBloc.queryMessages.add(phoneNo);
                                        controller.text = phoneNo;
                                      },
                                    );
                                    break;
                                    default:
                                      return InkWell(
                                        child: CircleAvatar(
                                          radius: 24.0,
                                          child: ClipOval(
                                            child:Text(data[i].displayName.substring(0,1)),
                                          ),
                                        ),
                                        onTap: (){
                                          String phoneNo = data[i].phones.first.value.replaceAll(" ", "").replaceAll("-", "").trim();
                                          smsRetrieverBloc.queryMessages.add(phoneNo);
                                          controller.text = phoneNo;
                                        },
                                      );
                                  }
                                }
                              ),
                              Text(data[i].displayName, style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold
                              ),)
                            ],
                          ),
                        );
                      },physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(
                          horizontal: 16.0
                        ), itemCount: data.length,) : Center(
                        child: Text("No Contact found!"),
                      );
                      break;
                      default:
                        return Center(
                          child: Text("Results not available"),
                        );
                        break;
                    }
                  }
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 24.0,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("MESSAGE RESULTS", style: TextStyle(
                    fontSize: 10.0, color: Colors.blueGrey, fontWeight: FontWeight.bold
                ),),
              ),
            ),
            StreamBuilder<List<MPMessage>>(
              stream: smsRetrieverBloc.queryResults,
              builder: (context, snapshot) {
                switch(snapshot.connectionState){
                  case ConnectionState.active:
                  case ConnectionState.done:
                    //TODO: Add Style of display switchers!
                  return snapshot.data?.length > 0 ?
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (c,i) =>
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ScopedModelDescendant<MessageViewModel>(
                                      builder: (_, __, model) =>
                                          AnimatedCrossFade(
                                              firstChild: SearchMessageTile(snapshot.data[i]),
                                              secondChild: HistoryTile(snapshot.data[i]),
                                              crossFadeState: model.activeModelType ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                              duration: Duration(milliseconds: 200))
                                  ),
                                  Divider()
                                ],
                              )

                          , childCount: snapshot.data.length,
                  )) : SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("No Results Found!!"),
                    ),
                  );
                  default:
                    return SliverToBoxAdapter(
                      child: Container(
                        height: 72.0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                }
              }
            )
          ],
        ),
      ),
    );
  }
}

enum Commands {
  toggleViewModel
}

class SearchActivityDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController editingController;
  final FocusNode focusNode;
  final Function clearCallBack;
  final SmsRetrieverBloc smsRetrieverBloc;

  SearchActivityDelegate({
    this.editingController,
    this.focusNode,
    this.clearCallBack,
    this.smsRetrieverBloc
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(
      color: Colors.white.withOpacity(0.7),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  //onTap: () {},
                  onChanged: smsRetrieverBloc.queryMessages.add,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    hintText: "Search Transactions",
                    prefixIcon: Icon(FontAwesomeIcons.searchDollar, size: 12.0,color: Colors.purpleAccent,),
                    suffix: IconButton(
                        iconSize: 12.0,
                        icon: Icon(FontAwesomeIcons.backspace),
                        onPressed: () {
                          focusNode.requestFocus();
                          Future.delayed(Duration(milliseconds: 50), () {
                            editingController.clear();
                            FocusScope.of(context).requestFocus(focusNode);
                          });
                        }),
                  ),
                  focusNode: focusNode,
                  controller: editingController,
                ),
              ),
              ScopedModelDescendant<MessageViewModel>(
                builder: (_, __, model) => PopupMenuButton<Commands>(
                  onSelected: (Commands result) {
                    switch (result) {
                      case Commands.toggleViewModel:
                        model.activate(!model.activeModelType);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<Commands>>[
                    CheckedPopupMenuItem<Commands>(
                      checked: model.activeModelType,
                      value: Commands.toggleViewModel,
                      child: const Text('Condensed', style: TextStyle(
                        fontSize: 14.0
                      ),),
                    ),
                    //const PopupMenuDivider(),
                    // ...other items listed here
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 52;

  @override
  // TODO: implement minExtent
  double get minExtent => 48;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return this != oldDelegate;
  }
}

/// Creation of front layers, both [SearchPanel] and [InfoPanel] as well as
/// back layer, [BackPanel]

class SearchPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PanelModel>(
      builder: (_context, _widget, model) => model.activePanel,
      /*child: Center(
        child: Text(
          'Panel ONE',
          style: TextStyle(fontSize: 42.0),
        ),
      ),*/
    );
  }
}

class InfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          'Panel TWO',
          style: TextStyle(fontSize: 42.0),
        ),
      ),
    );
  }
}

const _kFlingVelocity = 2.0;

///This is a BackdropPanel Adapter to hold the Front panel widget
class _BackdropPanel extends StatelessWidget {
  const _BackdropPanel({
    Key key,
    this.onTap,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.title,
    this.child,
    this.titleHeight,
    this.padding,
  }) : super(key: key);

  final VoidCallback onTap;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final Widget title;
  final Widget child;
  final double titleHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        elevation: 12.0,
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            /// Header goes here!
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: onVerticalDragUpdate,
              onVerticalDragEnd: onVerticalDragEnd,
              onTap: onTap,
              child: Container(height: titleHeight, child: title),
            ),

            ///Simple Divider
            /*Divider(
              height: 1.0,
            ),*/

            ///Child goes here!
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two panels, front and back. The front panel is shown
/// by default, and slides down to show the back panel, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back panel is showing.
class Backdrop extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontHeader;
  final double frontPanelOpenHeight;
  final double frontHeaderHeight;
  final bool frontHeaderVisibleClosed;
  final EdgeInsets frontPanelPadding;
  final ValueNotifier<bool> panelVisible;

  Backdrop(
      {@required this.frontLayer,
      @required this.backLayer,
      Key key,
      this.frontPanelOpenHeight = 0.0,
      this.frontHeaderHeight = 48.0,
      this.frontPanelPadding = const EdgeInsets.all(0.0),
      this.frontHeaderVisibleClosed = true,
      this.panelVisible,
      this.frontHeader})
      : assert(frontLayer != null),
        assert(backLayer != null),
        super(key: key);

  @override
  createState() => BackdropState();
}

class BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      // value of 0 hides the panel; value of 1 fully shows the panel
      value: (widget.panelVisible?.value ?? false) ? 1.0 : 0.0,
      vsync: this,
    );

    // Listen on the toggle value notifier if it's not null

    widget.panelVisible?.addListener(_subscribeToValueNotifier);

    // Ensure that the value notifier is updated when the panel is opened or closed
    if (widget.panelVisible != null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed)
          widget.panelVisible.value = true;
        else if (status == AnimationStatus.dismissed)
          widget.panelVisible.value = false;
      });
    }
  }

  void _subscribeToValueNotifier() {
    if (widget.panelVisible.value != _backdropPanelVisible)
      toggleBackdropPanelVisibility();
  }

  /// Required for resubscribing when hot reload occurs
  @override
  void didUpdateWidget(Backdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.panelVisible?.removeListener(_subscribeToValueNotifier);
    widget.panelVisible?.addListener(_subscribeToValueNotifier);
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.panelVisible?.dispose();
    super.dispose();
  }

  bool get _backdropPanelVisible =>
      _controller.status == AnimationStatus.completed ||
      _controller.status == AnimationStatus.forward;

  void toggleBackdropPanelVisibility() => _controller.fling(
      velocity: _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity);

  double get _backdropHeight {
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_controller.isAnimating)
      _controller.value -= details.primaryDelta / _backdropHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(_kFlingVelocity, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-_kFlingVelocity, -flingVelocity));
    else
      _controller.fling(
          velocity:
              _controller.value < 0.5 ? -_kFlingVelocity : _kFlingVelocity);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final panelSize = constraints.biggest;
      final closedPercentage = widget.frontHeaderVisibleClosed
          ? (panelSize.height - widget.frontHeaderHeight) / panelSize.height
          : 1.0;
      final openPercentage = widget.frontPanelOpenHeight / panelSize.height;

      final panelDetailsPosition = Tween<Offset>(
        begin: Offset(0.0, closedPercentage),
        end: Offset(0.0, openPercentage),
      ).animate(_controller.view);

      return Container(
        key: _backdropKey,
        child: Stack(
          children: <Widget>[
            widget.backLayer,
            SlideTransition(
              position: panelDetailsPosition,
              child: _BackdropPanel(
                onTap: toggleBackdropPanelVisibility,
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                title: widget.frontHeader,
                titleHeight: widget.frontHeaderHeight,

                ///Inject a padding to resolve some lost slice of the viewport when a custom height
                ///open Height is in use!!
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.frontPanelOpenHeight),
                  child: widget.frontLayer,
                ),
                padding: widget.frontPanelPadding,
              ),
            ),
          ],
        ),
      );
    });
  }
}
