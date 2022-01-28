import 'dart:convert';

import 'package:polkawallet_plugin_acala/api/acalaApi.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/service/walletApi.dart';
import 'package:polkawallet_plugin_acala/store/index.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ServiceAssets {
  ServiceAssets(this.plugin, this.keyring)
      : api = plugin.api,
        store = plugin.store;

  final PluginAcala plugin;
  final Keyring keyring;
  final AcalaApi? api;
  final PluginStore? store;

  Future<void> queryMarketPrices(List<String?> tokens) async {
    final all = tokens.toList();
    all.removeWhere((e) =>
        e == acala_stable_coin ||
        e == 'L$relay_chain_token_symbol' ||
        e == 'USDT');
    if (all.length == 0) return;

    final Map? res = await WalletApi.getTokenPrice();
    final Map<String, double> prices = {
      acala_stable_coin: 1.0,
      'USDT': 1.0,
      ...((res?['prices'] as Map?) ?? {})
    };

    try {
      if (prices[relay_chain_token_symbol] != null &&
          await (api!.homa.isHomaAlive() as Future<bool>)) {
        final homaEnv = await plugin.service!.homa.queryHomaEnv();
        prices['L$relay_chain_token_symbol'] =
            prices[relay_chain_token_symbol]! * homaEnv.exchangeRate;
      }
    } catch (err) {
      print(err);
      // ignore
    }

    store!.assets.setMarketPrices(prices);
  }

  Future<void> updateTokenBalances(TokenBalanceData token) async {
    final res = await plugin.sdk.webView!.evalJavascript(
        'api.query.tokens.accounts("${keyring.current.address}", ${jsonEncode(token.currencyId)})');

    final balances =
        Map<String?, TokenBalanceData>.from(store!.assets.tokenBalanceMap);
    final data = TokenBalanceData(
        id: token.id,
        name: token.name,
        fullName: token.fullName,
        symbol: token.symbol,
        tokenNameId: token.tokenNameId,
        currencyId: token.currencyId,
        type: token.type,
        decimals: token.decimals,
        minBalance: token.minBalance,
        amount: res['free'].toString(),
        locked: res['frozen'].toString(),
        reserved: res['reserved'].toString(),
        detailPageRoute: token.detailPageRoute,
        price: store!.assets.marketPrices[token.symbol]);
    balances[token.tokenNameId] = data;

    store!.assets
        .setTokenBalanceMap(balances.values.toList(), keyring.current.pubKey);
    plugin.balances.setTokens([data]);
  }

  Future<void> queryAggregatedAssets() async {
    queryMarketPrices([plugin.networkState.tokenSymbol![0]]);
    final data =
        await plugin.api!.assets.queryAggregatedAssets(keyring.current.address);
    plugin.store!.assets.setAggregatedAssets(data, keyring.current.pubKey);
  }

  void calcLPTokenPrices() {
    final Map<String, double> prices = {};
    plugin.store!.earn.dexPoolInfoMap.values.forEach((e) {
      final pool = plugin.store!.earn.dexPools
          .firstWhere((i) => i.tokenNameId == e.tokenNameId);
      final tokenPair = pool.tokens!
          .map((id) => AssetsUtils.tokenDataFromCurrencyId(plugin, id))
          .toList();

      prices[tokenPair.map((e) => e!.symbol).join('-')] = (Fmt.bigIntToDouble(
                      e.amountLeft, tokenPair[0]!.decimals!) *
                  (plugin.store!.assets.marketPrices[tokenPair[0]!.symbol] ??
                      0) +
              Fmt.bigIntToDouble(e.amountRight, tokenPair[1]!.decimals!) *
                  (plugin.store!.assets.marketPrices[tokenPair[1]!.symbol] ??
                      0)) /
          Fmt.bigIntToDouble(e.issuance, tokenPair[0]!.decimals!);
    });
    plugin.store!.assets.setMarketPrices(prices);
  }
}
