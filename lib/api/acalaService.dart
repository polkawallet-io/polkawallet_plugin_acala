import 'dart:convert';
import 'dart:io';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaService {
  AcalaService(this.plugin);

  final PluginAcala plugin;

  final String tokenPricesSubscribeChannel = 'TokenPrices';

  final tokenBalanceChannel = 'tokenBalance';

  // Future<String> fetchFaucet() async {
  //   String address = store.account.currentAddress;
  //   String deviceId = address;
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo info = await deviceInfo.androidInfo;
  //     deviceId = info.androidId;
  //   } else {
  //     IosDeviceInfo info = await deviceInfo.iosInfo;
  //     deviceId = info.identifierForVendor;
  //   }
  //   String res = await FaucetApi.getAcalaTokensV2(address, deviceId);
  //   return res;
  // }
  void unsubscribeTokenBalances(String address) async {
    final tokens =
        List.of(plugin.networkConst['accounts']['allNonNativeCurrencyIds']);
    tokens.forEach((e) {
      plugin.sdk.api.unsubscribeMessage('$tokenBalanceChannel${e['Token']}');
    });

    final dexPairs = List.of(plugin.networkConst['dex']['enabledTradingPairs']);
    dexPairs.forEach((e) {
      final LPToken = List.of(e).map((i) => i['Token']).toList();
      plugin.sdk.api
          .unsubscribeMessage('$tokenBalanceChannel${LPToken.join('-')}');
    });
  }

  Future<void> subscribeTokenBalances(
      String address, Function(Map) callback) async {
    final tokens =
        List.of(plugin.networkConst['accounts']['allNonNativeCurrencyIds']);
    tokens.forEach((e) {
      final channel = '$tokenBalanceChannel${e['Token']}';
      plugin.sdk.api.subscribeMessage(
        'api.query.tokens.accounts',
        [address, e],
        channel,
        (Map data) => callback({'symbol': e['Token'], 'balance': data}),
      );
    });
    final dexPairs = List.of(plugin.networkConst['dex']['enabledTradingPairs']);
    dexPairs.forEach((e) {
      final LPToken = List.of(e).map((i) => i['Token']).toList();
      final channel = '$tokenBalanceChannel${LPToken.join('')}';
      plugin.sdk.api.subscribeMessage(
        'api.query.tokens.accounts',
        [
          address,
          {'DEXShare': LPToken}
        ],
        channel,
        (Map data) => callback({'symbol': LPToken.join('-'), 'balance': data}),
      );
    });
  }

  Future<Map> queryAirdropTokens(String address) async {
    final getCurrencyIds = Platform.isIOS
        ? 'JSON.stringify(api.registry.createType("AirDropCurrencyId").defKeys)'
        : 'api.createType("AirDropCurrencyId").defKeys';

    final res = await plugin.sdk.webView
        .evalJavascript(getCurrencyIds, wrapPromise: false);
    if (res != null) {
      final List tokens = jsonDecode(res);
      final queries = tokens
          .map((i) => 'api.query.airDrop.airDrops("$address", "$i")')
          .join(",");
      final List amount =
          await plugin.sdk.webView.evalJavascript('Promise.all([$queries])');
      return {
        'tokens': tokens,
        'amount': amount,
      };
    }
    return {};
  }

  // Future<void> fetchAccountLoans() async {
  //   String address = store.account.currentAddress;
  //   List res =
  //       await apiRoot.evalJavascript('api.derive.loan.allLoans("$address")');
  //   store.acala.setAccountLoans(res);
  // }
  //
  // Future<void> fetchLoanTypes() async {
  //   List res = await apiRoot.evalJavascript('api.derive.loan.allLoanTypes()');
  //   store.acala.setLoanTypes(res);
  // }
  //
  // Future<SwapOutputData> fetchTokenSwapAmount(
  //   String supplyAmount,
  //   String targetAmount,
  //   List<String> swapPair,
  //   String slippage,
  // ) async {
  //   final code =
  //       'acala.calcTokenSwapAmount(api, $supplyAmount, $targetAmount, ${jsonEncode(swapPair)}, $slippage)';
  //   final output = await apiRoot.evalJavascript(code, allowRepeat: true);
  //   return SwapOutputData.fromJson(output);
  // }
  //
  // Future<void> fetchDexPools() async {
  //   final res = await apiRoot.evalJavascript('acala.getTokenPairs()');
  //   store.acala.setDexPools(res);
  // }
  //
  // Future<void> fetchDexLiquidityPoolRewards() async {
  //   await webApi.acala.fetchDexPools();
  //   final pools = store.acala.dexPools
  //       .map((pool) =>
  //           jsonEncode({'DEXShare': pool.map((e) => e.name).toList()}))
  //       .toList();
  //   final incentiveQuery = pools
  //       .map((i) => 'api.query.incentives.dEXIncentiveRewards($i)')
  //       .join(',');
  //   final savingRateQuery =
  //       pools.map((i) => 'api.query.incentives.dEXSavingRates($i)').join(',');
  //   final res = await Future.wait([
  //     apiRoot.evalJavascript('Promise.all([$incentiveQuery])',
  //         allowRepeat: true),
  //     apiRoot.evalJavascript('Promise.all([$savingRateQuery])',
  //         allowRepeat: true)
  //   ]);
  //   final incentives = Map<String, dynamic>();
  //   final savingRates = Map<String, dynamic>();
  //   final tokenPairs = store.acala.dexPools
  //       .map((e) => e.map((i) => i.symbol).join('-'))
  //       .toList();
  //   tokenPairs.asMap().forEach((k, v) {
  //     incentives[v] = res[0][k];
  //     savingRates[v] = res[1][k];
  //   });
  //   store.acala.setSwapPoolRewards(incentives);
  //   store.acala.setSwapSavingRates(savingRates);
  // }
  //
  // Future<void> fetchDexPoolInfo(String pool) async {
  //   Map info = await apiRoot.evalJavascript(
  //     'acala.fetchDexPoolInfo(${jsonEncode({
  //       'DEXShare': pool.split('-').map((e) => e.toUpperCase()).toList()
  //     })}, "${store.account.currentAddress}")',
  //     allowRepeat: true,
  //   );
  //   store.acala.setDexPoolInfo(pool, info);
  // }
  //
  // Future<void> fetchHomaStakingPool() async {
  //   Map res = await apiRoot.evalJavascript('acala.fetchHomaStakingPool(api)');
  //   store.acala.setHomaStakingPool(res);
  // }
  //
  // Future<void> fetchHomaUserInfo() async {
  //   String address = store.account.currentAddress;
  //   Map res = await apiRoot
  //       .evalJavascript('acala.fetchHomaUserInfo(api, "$address")');
  //   store.acala.setHomaUserInfo(res);
  // }
  //
  // Future<void> fetchUserNFTs() async {
  //   final address = store.account.currentAddress;
  //   final time = DateTime.now();
  //   final enable = time.millisecondsSinceEpoch > 1604099149427;
  //   final code =
  //       'api.derive.nft.queryTokensByAccount("$address", ${enable ? 1 : 0}).then(res => res.map(e => ({...e.data.value, metadata: e.data.value.metadata.toUtf8()})))';
  //   final List res = await apiRoot.evalJavascript(code, allowRepeat: true);
  //   store.acala.setUserNFTs(res);
  // }
}
