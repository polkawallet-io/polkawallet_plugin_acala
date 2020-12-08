import 'dart:async';
import 'dart:convert';

import 'package:polkawallet_plugin_acala/api/types/swapOutputData.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaServiceSwap {
  AcalaServiceSwap(this.plugin);

  final PluginAcala plugin;

  Future<Map> queryTokenSwapAmount(
    String supplyAmount,
    String targetAmount,
    List<String> swapPair,
    String slippage,
  ) async {
    final code =
        'acala.calcTokenSwapAmount(api, $supplyAmount, $targetAmount, ${jsonEncode(swapPair)}, $slippage)';
    final output = await plugin.sdk.webView.evalJavascript(code);
    return output;
  }

  Future<List> getDexPools() async {
    final List res =
        await plugin.sdk.webView.evalJavascript('acala.getTokenPairs(api)');
    return res;
  }

  Future<Map> queryDexLiquidityPoolRewards(
      List<List<AcalaTokenData>> dexPools) async {
    final pools = dexPools
        .map((pool) =>
            jsonEncode({'DEXShare': pool.map((e) => e.symbol).toList()}))
        .toList();
    final incentiveQuery = pools
        .map((i) => 'api.query.incentives.dEXIncentiveRewards($i)')
        .join(',');
    final savingRateQuery =
        pools.map((i) => 'api.query.incentives.dEXSavingRates($i)').join(',');
    final res = await Future.wait([
      plugin.sdk.webView.evalJavascript('Promise.all([$incentiveQuery])'),
      plugin.sdk.webView.evalJavascript('Promise.all([$savingRateQuery])')
    ]);
    final incentives = Map<String, dynamic>();
    final savingRates = Map<String, dynamic>();
    final tokenPairs =
        dexPools.map((e) => e.map((i) => i.symbol).join('-')).toList();
    tokenPairs.asMap().forEach((k, v) {
      incentives[v] = res[0][k];
      savingRates[v] = res[1][k];
    });
    return {
      'incentives': incentives,
      'savingRates': savingRates,
    };
  }

  Future<Map> queryDexPoolInfo(String pool, address) async {
    final Map info = await plugin.sdk.webView.evalJavascript(
        'acala.fetchDexPoolInfo(api, ${jsonEncode({
      'DEXShare': pool.split('-').map((e) => e.toUpperCase()).toList()
    })}, "$address")');
    return info;
  }
}
