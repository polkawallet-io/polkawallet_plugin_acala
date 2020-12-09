import 'package:polkawallet_plugin_acala/api/assets/acalaServiceAssets.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';

class AcalaApiAssets {
  AcalaApiAssets(this.service);

  final AcalaServiceAssets service;

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
                name: PluginFmt.tokenView(e['symbol']),
                symbol: e['symbol'],
                amount: e['balance']['free'].toString(),
                detailPageRoute: '/assets/token/detail',
              ))
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
