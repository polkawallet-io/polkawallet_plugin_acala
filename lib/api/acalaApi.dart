import 'package:polkawallet_plugin_acala/api/acalaService.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';
import 'package:polkawallet_plugin_acala/api/types/stakingPoolInfoData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';

class AcalaApi {
  AcalaApi(this.service);

  final AcalaService service;

  final Map _tokenBalances = {};

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

  void unsubscribeTokenBalances(String address) {
    service.unsubscribeTokenBalances(address);
  }

  Future<void> subscribeTokenBalances(
      String address, Function(List<TokenBalanceData>) callback) async {
    await service.subscribeTokenBalances(address, (Map data) {
      _tokenBalances[data['symbol']] = data;
      callback(_tokenBalances.values
          .map((e) => TokenBalanceData(
              name: e['symbol'],
              symbol: e['symbol'],
              amount: e['balance']['free'].toString()))
          .toList());
    });
  }

  Future<List<TokenBalanceData>> queryAirdropTokens(String address) async {
    final res = List<TokenBalanceData>();
    final ls = await service.queryAirdropTokens(address);
    if (ls['tokens'] != null) {
      List.of(ls['tokens']).asMap().forEach((i, v) {
        res.add(TokenBalanceData(
            name: v, symbol: v, amount: ls['amount'][i].toString()));
      });
    }
    return res;
  }

  Future<void> subscribeTokenPrices(
      Function(Map<String, BigInt>) callback) async {
    service.subscribeTokenPrices(callback);
  }

  void unsubscribeTokenPrices() {
    service.unsubscribeTokenPrices();
  }

  Future<List> queryAccountLoans(String address) async {
    final List res = await service.queryAccountLoans(address);
    return res;
  }

  Future<List<LoanType>> queryLoanTypes() async {
    final List res = await service.queryLoanTypes();
    return res
        .map((e) => LoanType.fromJson(Map<String, dynamic>.of(e)))
        .toList();
  }

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

  Future<StakingPoolInfoData> queryHomaStakingPool() async {
    final Map res = await service.queryHomaStakingPool();
    return StakingPoolInfoData.fromJson(Map<String, dynamic>.of(res));
  }

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
