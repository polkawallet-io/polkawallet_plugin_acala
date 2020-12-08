import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_ui/utils/format.dart';

class AcalaServiceAssets {
  AcalaServiceAssets(this.plugin);

  final PluginAcala plugin;

  Timer _tokenPricesSubscribeTimer;

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
          .unsubscribeMessage('$tokenBalanceChannel${LPToken.join('')}');
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
        (Map data) {
          callback({'symbol': e['Token'], 'balance': data});
        },
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
        (Map data) {
          if (BigInt.parse(data['free'].toString()) > BigInt.zero) {
            callback({'symbol': LPToken.join('-'), 'balance': data});
          }
        },
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

  Future<void> subscribeTokenPrices(
      Function(Map<String, BigInt>) callback) async {
    final List res = await plugin.sdk.webView
        .evalJavascript('api.rpc.oracle.getAllValues("Aggregated")');
    if (res != null) {
      final prices = Map<String, BigInt>();
      res.forEach((e) {
        prices[e[0]['Token']] = Fmt.balanceInt(e[1]['value'].toString());
      });
      callback(prices);
    }

    _tokenPricesSubscribeTimer =
        Timer(Duration(seconds: 10), () => subscribeTokenPrices(callback));
  }

  void unsubscribeTokenPrices() {
    if (_tokenPricesSubscribeTimer != null) {
      _tokenPricesSubscribeTimer.cancel();
      _tokenPricesSubscribeTimer = null;
    }
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
