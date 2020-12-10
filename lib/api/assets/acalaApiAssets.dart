import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:polkawallet_plugin_acala/api/assets/acalaServiceAssets.dart';
import 'package:polkawallet_plugin_acala/api/types/nftData.dart';
import 'package:polkawallet_plugin_acala/service/walletApi.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';

class AcalaApiAssets {
  AcalaApiAssets(this.service);

  final AcalaServiceAssets service;

  final Map _tokenBalances = {};

  Future<String> fetchFaucet(String address) async {
    String deviceId = address;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      deviceId = info.androidId;
    } else {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      deviceId = info.identifierForVendor;
    }
    String res = await WalletApi.fetchAcalaFaucet(address, deviceId);
    return res;
  }

  void unsubscribeTokenBalances(String address) {
    service.unsubscribeTokenBalances(address);
  }

  Future<void> subscribeTokenBalances(
      String address, Function(List<TokenBalanceData>) callback) async {
    final tokens = List.of(
        service.plugin.networkConst['accounts']['allNonNativeCurrencyIds']);
    _tokenBalances.clear();

    await service.subscribeTokenBalances(address, (Map data) {
      _tokenBalances[data['symbol']] = data;

      // do not callback if we did not receive enough data.
      if (_tokenBalances.keys.length < tokens.length) return;

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

  Future<List<NFTData>> queryNFTs(String address) async {
    final List res = await service.queryNFTs(address);
    return res
        .map((e) => NFTData.fromJson(Map<String, dynamic>.of(e)))
        .toList();
  }
}
