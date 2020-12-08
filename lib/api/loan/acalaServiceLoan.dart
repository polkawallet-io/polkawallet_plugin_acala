import 'dart:async';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaServiceLoan {
  AcalaServiceLoan(this.plugin);

  final PluginAcala plugin;

  Future<List> queryAccountLoans(String address) async {
    final List res = await plugin.sdk.webView
        .evalJavascript('api.derive.loan.allLoans("$address")');
    return res;
  }

  Future<List> queryLoanTypes() async {
    final List res = await plugin.sdk.webView
        .evalJavascript('api.derive.loan.allLoanTypes()');
    return res;
  }
}
