import 'dart:async';
import 'dart:convert';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_ui/utils/format.dart';

class AcalaServiceAssets {
  AcalaServiceAssets(this.plugin);

  final PluginAcala plugin;

  Timer? _tokenPricesSubscribeTimer;

  final tokenBalanceChannel = 'tokenBalance';

  Future<List?> getAllTokenSymbols() async {
    final List? res =
        await plugin.sdk.webView!.evalJavascript('acala.getAllTokens(api)');
    return res;
  }

  void unsubscribeTokenBalances(String? address) async {
    final tokens = await plugin.api!.assets.getAllTokenSymbols(withCache: true);
    tokens.forEach((e) {
      plugin.sdk.api.unsubscribeMessage('$tokenBalanceChannel${e.symbol}');
    });

    final dexPairs = await plugin.api!.swap.getTokenPairs();
    dexPairs.forEach((e) {
      final lpToken =
          AssetsUtils.getBalanceFromTokenNameId(plugin, e.tokenNameId)!
              .symbol!
              .split('-');
      plugin.sdk.api
          .unsubscribeMessage('$tokenBalanceChannel${lpToken.join('')}');
    });
  }

  Future<void> subscribeTokenBalances(String? address,
      List<TokenBalanceData> tokens, Function(Map) callback) async {
    tokens.forEach((e) {
      final channel = '$tokenBalanceChannel${e.symbol}';
      plugin.sdk.api.subscribeMessage(
        'api.query.tokens.accounts',
        [
          address,
          e.currencyId ?? {'Token': e.symbol}
        ],
        channel,
        (Map data) {
          callback({
            'id': e.id,
            'symbol': e.symbol,
            'tokenNameId': e.tokenNameId,
            'currencyId': e.currencyId,
            'type': e.type,
            'minBalance': e.minBalance,
            'decimals': e.decimals,
            'balance': data
          });
        },
      );
    });
    final dexPairs = await plugin.api!.swap.getTokenPairs();
    dexPairs.forEach((e) {
      final currencyId = {'DEXShare': e.tokens};
      final lpToken = e.tokens!
          .map((e) => AssetsUtils.tokenDataFromCurrencyId(plugin, e))
          .toList();
      final tokenId = lpToken.map((e) => e!.symbol).join('-');
      final channel =
          '$tokenBalanceChannel${lpToken.map((e) => e!.symbol).join('')}';
      plugin.sdk.api.subscribeMessage(
        'api.query.tokens.accounts',
        [address, currencyId],
        channel,
        (Map data) {
          callback({
            'symbol': tokenId,
            'type': 'DexShare',
            'tokenNameId': e.tokenNameId,
            'currencyId': currencyId,
            'decimals': lpToken[0]!.decimals,
            'balance': data
          });
        },
      );
    });
  }

  Future<Map> queryAirdropTokens(String address) async {
    final res = await plugin.sdk.webView!.evalJavascript(
        'JSON.stringify(api.registry.createType("AirDropCurrencyId").defKeys)',
        wrapPromise: false);
    if (res != null) {
      final List tokens = jsonDecode(res);
      final queries = tokens
          .map((i) => 'api.query.airDrop.airDrops("$address", "$i")')
          .join(",");
      final List? amount =
          await plugin.sdk.webView!.evalJavascript('Promise.all([$queries])');
      return {
        'tokens': tokens,
        'amount': amount,
      };
    }
    return {};
  }

  Future<void> subscribeTokenPrices(
      Function(Map<String, BigInt>) callback) async {
    final loanTypes = plugin.store?.loan.loanTypes
        .map((e) => e.token?.tokenNameId ?? '')
        .toList();
    loanTypes?.removeWhere((e) => e == 'LDOT');

    final List? res = await plugin.sdk.webView!.evalJavascript(
        'acala.queryTokenPriceFromOracle(api, ${jsonEncode(loanTypes)})');
    if (res != null) {
      final prices = Map<String, BigInt>();
      loanTypes?.asMap().forEach((i, e) {
        prices[e] = Fmt.balanceInt(res[i]);
      });
      callback(prices);
    }

    _tokenPricesSubscribeTimer =
        Timer(Duration(seconds: 30), () => subscribeTokenPrices(callback));
  }

  void unsubscribeTokenPrices() {
    if (_tokenPricesSubscribeTimer != null) {
      _tokenPricesSubscribeTimer!.cancel();
      _tokenPricesSubscribeTimer = null;
    }
  }

  Future<List?> queryNFTs(String? address) async {
    final List? res = await plugin.sdk.webView!
        .evalJavascript('acala.queryNFTs(api, "$address")');
    return res;
  }

  Future<Map?> queryAggregatedAssets(String? address) async {
    final Map? res = await plugin.sdk.webView!
        .evalJavascript('acala.queryAggregatedAssets(api, "$address")');
    return res;
  }

  Future<bool?> checkExistentialDepositForTransfer(
    String address,
    Map currencyId,
    int decimal,
    String amount, {
    String direction = 'to',
  }) async {
    final res = await plugin.sdk.webView!.evalJavascript(
        'acala.checkExistentialDepositForTransfer(api, "$address", ${jsonEncode(currencyId)}, $decimal, $amount, "$direction")');
    return res['result'] as bool?;
  }
}
