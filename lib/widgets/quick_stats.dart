import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'custom_backdrop.dart';

class QuickStats extends StatefulWidget {
  final double balance;
  final double expense;
  final double income;

  QuickStats(
      {@required this.balance, @required this.expense, @required this.income,});

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

  @override
  _QuickStatsState createState() => _QuickStatsState();
}

class _QuickStatsState extends State<QuickStats> {
  bool searchStatCrossfade = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String formatAsCurrency(double value) {
    return "${NumberFormat.compactCurrency(symbol: "").format(value)}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
          "BALANCE",
          style: TextStyle(
              color: Colors.blueGrey,
              //wordSpacing: 4.0,
              letterSpacing: 1.0,
              fontSize: 10.0,
              fontWeight: FontWeight.bold),
        ),
        Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "\$",
                  style: TextStyle(
                      color: Colors.grey,
                      //fontFamily: "DMSerifDisplay",
                      fontSize: 10.0),
                ),
              ],
            ),
            Text(
              "${formatAsCurrency(this.widget.balance)}",
              style: TextStyle(
                //fontFamily: "DMSerifDisplay",
                fontSize: 28.0,
              ),
            ),
          ],
        ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "INCOME",
                      style: TextStyle(
                          color: Colors.green,
                          //wordSpacing: 4.0,
                          letterSpacing: 1.0,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "\$",
                              style: TextStyle(
                                  //fontFamily: "DMSerifDisplay",
                                  color: Colors.grey,
                                  fontSize: 10.0),
                            ),
                          ],
                        ),
                        Text(
                          "${formatAsCurrency(this.widget.income)}",
                          style: TextStyle(
                            //fontFamily: "DMSerifDisplay",
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "EXPENSE",
                      style: TextStyle(
                          color: Colors.redAccent,
                          //wordSpacing: 4.0,
                          letterSpacing: 1.0,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "\$",
                              style: TextStyle(
                                  color: Colors.grey,
                                  // fontFamily: "DMSerifDisplay",
                                  fontSize: 10.0),
                            ),
                          ],
                        ),
                        Text(
                          "${formatAsCurrency(this.widget.expense)}",
                          style: TextStyle(
                            //fontFamily: "DMSerifDisplay",
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
      ],
    );
  }

  @override
  void dispose() {
    if(_focusNode.hasFocus){
      _focusNode.unfocus();
    }
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }


}
