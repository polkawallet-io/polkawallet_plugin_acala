import 'dart:async';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaServiceEarn {
  AcalaServiceEarn(this.plugin);

  final PluginAcala plugin;

  Future<Map> queryIncentives() async {
    final Map res =
        await plugin.sdk.webView.evalJavascript('acala.queryIncentives(api)');
    return res;
  }

  Future<List> queryDexIncentiveLoyaltyEndBlock() async {
    final List<dynamic> res = await plugin.sdk.webView
        .evalJavascript('acala.queryDexIncentiveLoyaltyEndBlock(api)');
    return res;
  }
}
