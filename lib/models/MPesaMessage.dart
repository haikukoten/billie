
import 'package:quiver/core.dart';

enum MPMessageType {
  MP_TYPE_RECEIVE,
  MP_TYPE_SENT,
  MP_TYPE_WITHDRAW,
  MP_TYPE_PAYBILL,
  MP_TYPE_AIRTIME,
  MP_TYPE_TXBAL,
  MP_TYPE_UNKNOWN,
  MP_TYPE_MSHWARI //Implement handling sooner or later
}

/*
  * MPMessage: Class that returns objects based on parsed M-Pesa messages
  */
class MPMessage  {
  final String participant;
  final String txCode;
  final MPMessageType mpMessageType;
  final double txFees;
  final double txAmount;
  final double txBal;
  final DateTime txDate;
  final String bodyString;

  MPMessage(this.participant, this.txCode, this.mpMessageType, this.txFees,
      this.txAmount, this.txBal, this.txDate, this.bodyString);

  static MPMessage fromBody(SillyMPMessageParser parser, String body, String timeStamp) {
    DateTime t =  DateTime.fromMillisecondsSinceEpoch(
        int.parse(timeStamp)
    );
    return parser.parseBody(body, t);
  }

  @override
  String toString() {
    return "Transaction: { $txCode, $txAmount, $txBal, $txFees, $mpMessageType, $txDate } \n";
  }

  bool operator == (other) => other is MPMessage && other.txCode == txCode;

  int get hashCode => hash2(txCode, bodyString);

}

class SillyMPMessageParser {
  SillyMPMessageParser();

  MPMessage parseBody(String bodyString, DateTime date) {
    final String lowcBodyString = bodyString.toLowerCase();
    final List<String> exploded = lowcBodyString.split(" ");
    final String txCode = exploded[0];
    final MPMessageType txType = getTransactionType(lowcBodyString);
    final String participant = getParticipant(txType, lowcBodyString);

    double amount = 0;
    double balance = 0;
    double transactionCost = 0;

    int moneyCount = 0;
    if (txType == MPMessageType.MP_TYPE_UNKNOWN){
      //skip as is un-needed
    } else {
      for (String str in exploded) {
        //Remember to trim newlines and commas!!
        if (str.startsWith("ksh")) {
          //print("Str: $str, rep: $moneyCount");
          String money = str.replaceAll("ksh", "");
          if (moneyCount == 0) {
            amount = double.tryParse(money.trim().replaceAll(",", ""))?? 0;
          } else if (moneyCount == 1) {
            balance = double.tryParse(money.substring(0, money.length - 1).trim().replaceAll(",", ""))?? 0;
          } else if (moneyCount == 2) {
            transactionCost = double.tryParse(money.substring(0, money.length - 1).trim().replaceAll(",", ""))?? 0;
          }
          moneyCount++;
        }
      }
    }
    return MPMessage(participant, txCode, txType, transactionCost, amount, balance, date, bodyString);
  }

  MPMessageType getTransactionType(String message) {
    MPMessageType transactionType = MPMessageType.MP_TYPE_UNKNOWN;
    if (message.contains("you have received")) {
      transactionType = MPMessageType.MP_TYPE_RECEIVE;
    } else if (message.toLowerCase().contains("sent to")) {
      transactionType = MPMessageType.MP_TYPE_SENT;
    } else if (message.toLowerCase().contains("withdraw")) {
      transactionType = MPMessageType.MP_TYPE_WITHDRAW;
    } else if (message.toLowerCase().contains("paid to")) {
      transactionType = MPMessageType.MP_TYPE_PAYBILL;
    } else if (message.toLowerCase().contains("you bought")) {
      transactionType = MPMessageType.MP_TYPE_AIRTIME;
    }
    return transactionType;
  }

  String getParticipant(MPMessageType txType, String body) {
    if (txType == MPMessageType.MP_TYPE_RECEIVE) {
      RegExp matcher =
          RegExp("from(.*)on [1-9]", caseSensitive: false, multiLine: false);
      if (matcher.hasMatch(body)) {
        return matcher.firstMatch(body).group(1).trim();
      } else {
        return "EMPTY";
      }
    } else if (txType == MPMessageType.MP_TYPE_WITHDRAW) {
      RegExp matcher =
          RegExp("from(.*)new m-pesa", caseSensitive: false, multiLine: false);
      if (matcher.hasMatch(body)) {
        return matcher.firstMatch(body).group(1).trim();
      } else {
        return "EMPTY";
      }
    } else if (txType == MPMessageType.MP_TYPE_SENT ||
        txType == MPMessageType.MP_TYPE_PAYBILL) {
      RegExp matcher =
          RegExp("to(.*)on [1-9]", caseSensitive: false, multiLine: false);
      if (matcher.hasMatch(body)) {
        return matcher.firstMatch(body).group(1).trim();
      } else {
        return "EMPTY";
      }
    }
    return "EMPTY";
  }
}
