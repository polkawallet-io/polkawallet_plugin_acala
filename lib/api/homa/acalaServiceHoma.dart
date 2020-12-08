import 'dart:async';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaServiceHoma {
  AcalaServiceHoma(this.plugin);

  final PluginAcala plugin;

  Future<Map> queryHomaStakingPool() async {
    final Map res = await plugin.sdk.webView
        .evalJavascript('acala.fetchHomaStakingPool(api)');
    return res;
  }

  Future<Map> queryHomaUserInfo(String address) async {
    final Map res = await plugin.sdk.webView
        .evalJavascript('acala.fetchHomaUserInfo(api, "$address")');
    return res;
  }

  Future<Map> queryHomaRedeemAmount(double input, int redeemType, era) async {
    final Map res = await plugin.sdk.webView.evalJavascript(
        'acala.queryHomaRedeemAmount(api, $input, $redeemType, $era)');
    return res;
  }
}
