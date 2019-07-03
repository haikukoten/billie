import 'package:flutter/material.dart';

class QuickStats extends StatelessWidget {
  final double balance;
  final double expense;
  final double income;

  QuickStats(
      {@required this.balance, @required this.expense, @required this.income});

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
    return Column(
      //mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
          "CURRENT BALANCE",
          style: TextStyle(
              color: Colors.grey,
              //wordSpacing: 4.0,
              //letterSpacing: 4.0,
              fontSize: 12.0,
              fontWeight: FontWeight.bold),
        ),
        Text(
          "${formatAsCurrency(this.balance)}",
          style: TextStyle(
            fontSize: 32.0,
          ),
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
                      color: Colors.grey,
                      //wordSpacing: 4.0,
                      //letterSpacing: 4.0,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatAsCurrency(this.income)}",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
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
                      color: Colors.grey,
                      //wordSpacing: 4.0,
                      //letterSpacing: 4.0,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatAsCurrency(this.expense)}",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
