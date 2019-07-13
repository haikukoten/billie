import 'package:billie/models/MPesaMessage.dart';
import 'package:billie/widgets/custom_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchMessageTile extends StatelessWidget {
  final MPMessage message;

  SearchMessageTile(this.message);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      //onTap: (){},
      leading: IconButton(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        iconSize: 20.0,
        color: Colors.purpleAccent,
        icon: Icon(FontAwesomeIcons.envelopeOpenText),
        onPressed: () {},
      ),
      title: Text(
        message.bodyString,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        timeago.format(message.txDate),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
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
    //String num = value.toStringAsFixed(2);
    //var s =
    //   "${unicode_map[num.substring(num.length - 2, num.length - 1)]["sp"]}${unicode_map[num.substring(num.length - 1, num.length)]["sp"]}";
    return NumberFormat.compactCurrency(symbol: "\$").format(value);
  }

  @override
  Widget build(BuildContext context) {
    switch (message.mpMessageType) {
      case MPMessageType.MP_TYPE_RECEIVE:
        return ListTile(
          leading: IconButton(
              color: Colors.green,
              iconSize: 20.0,
              icon: Icon(FontAwesomeIcons.moneyCheckAlt),
              onPressed: () {}),
          title: Text(
              "${message.participant[0].toUpperCase()}${message.participant.substring(1)}"),
          dense: true,
          subtitle: Text(
            formatAsCurrency(message.txAmount),
          ),
        );
      case MPMessageType.MP_TYPE_UNKNOWN:
        return ListTile(
          dense: true,
          leading: IconButton(
              iconSize: 20.0,
              icon: Icon(FontAwesomeIcons.tools),
              onPressed: () {}),
          title: Text("Service Message!"),
        );
      case MPMessageType.MP_TYPE_AIRTIME:
        return ListTile(
          leading: IconButton(
              iconSize: 20.0,
              color: Colors.blue,
              icon: Icon(FontAwesomeIcons.mobile),
              onPressed: () {}),
          title: Text("Airtime purchase"),
          dense: true,
          subtitle: Text(
            formatAsCurrency(message.txAmount),
          ),
        );
      default:
        return ListTile(
          leading: IconButton(
              color: Colors.redAccent,
              iconSize: 20.0,
              icon: Icon(FontAwesomeIcons.creditCard),
              onPressed: () {}),
          dense: true,
          title: Text(
              "${message.participant[1].toUpperCase()}${message.participant.substring(2)}"),
          subtitle: Text(
            "${formatAsCurrency(message.txAmount)} | Fees: ${formatAsCurrency(message.txFees)}",
          ),
        );
    }
  }
}
