/*
 * Enumarated types of transactions!
 */
enum MPMessageType {
  MP_TYPE_RECEIVE,
  MP_TYPE_SENT,
  MP_TYPE_WITHDRAW,
  MP_TYPE_PAYBILL,
  MP_TYPE_AIRTIME,
  MP_TYPE_TXBAL,
  MP_TYPE_UNKNOWN,
}

/*
  * MPMessage: Class that returns objects based on parsed M-Pesa messages
  */
class MPMessage {
  final String participant;
  final String txCode;
  final MPMessageType mpMessageType;
  final double txFees;
  final double txAmount;
  final double txBal;
  final DateTime txDate;

  MPMessage(this.participant, this.txCode, this.mpMessageType, this.txFees,
      this.txAmount, this.txBal, this.txDate);

  static MPMessage fromBody(
      SillyMPMessageParser parser, String body, DateTime timeStamp) {
    return parser.parseBody(body, timeStamp);
  }
}

class SillyMPMessageParser {
  SillyMPMessageParser();

  MPMessage parseBody(String bodyString, DateTime date) {
    final String lowcBodyString = bodyString.toLowerCase();
    List<String> exploded = lowcBodyString.split(" ");
    String txCode = exploded[0];
    MPMessageType txType = getTransactionType(lowcBodyString);
    String participant = getParticipant(txType, lowcBodyString);

    String amount = "";
    String balance = "";
    String transactionCost = "";

    int moneyCount = 0;
    for (String str in exploded) {
      if (str.startsWith("ksh")) {
        String money = str.replaceAll("ksh", "");
        if (moneyCount == 0) {
          amount = money;
        } else if (moneyCount == 1) {
          balance = money.substring(0, money.length - 1);
        } else if (moneyCount == 2) {
          transactionCost = money.substring(0, money.length - 1);
        }
        moneyCount++;
      }
    }

    return MPMessage(participant, txCode, txType, double.parse(transactionCost),
        double.parse(amount), double.parse(balance), date);
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
        return matcher.firstMatch(body).group(1);
      } else {
        return "";
      }
    } else if (txType == MPMessageType.MP_TYPE_WITHDRAW) {
      RegExp matcher =
          RegExp("from(.*)new m-pesa", caseSensitive: false, multiLine: false);
      if (matcher.hasMatch(body)) {
        return matcher.firstMatch(body).group(1);
      } else {
        return "";
      }
    } else if (txType == MPMessageType.MP_TYPE_SENT ||
        txType == MPMessageType.MP_TYPE_PAYBILL) {
      RegExp matcher =
          RegExp("to(.*)on [1-9]", caseSensitive: false, multiLine: false);
      if (matcher.hasMatch(body)) {
        return matcher.firstMatch(body).group(1);
      } else {
        return "";
      }
    }
    return "";
  }
}
