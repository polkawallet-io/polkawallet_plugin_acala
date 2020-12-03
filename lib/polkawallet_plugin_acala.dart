library polkawallet_plugin_acala;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/api/acalaApi.dart';
import 'package:polkawallet_plugin_acala/api/acalaService.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/pages/acalaEntry.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/service/index.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_acala/store/index.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';

class PluginAcala extends PolkawalletPlugin {
  @override
  final basic = PluginBasicData(
    name: 'acala',
    ss58: 42,
    primaryColor: Colors.indigo,
    icon: Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/acala.png'),
    iconDisabled: Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/acala_gray.png'),
  );

  @override
  List<NetworkParams> get nodeList {
    return node_list.map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  Map<String, Widget> tokenIcons = {
    'ACA': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/ACA.png'),
    'AUSD': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/AUSD.png'),
    'DOT': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/DOT.png'),
    'LDOT': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/LDOT.png'),
    'RENBTC': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/RENBTC.png'),
    'XBTC': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/XBTC.png'),
  };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    return [
      HomeNavItem(
        text: 'Acala',
        icon: Image(
            image: AssetImage('assets/images/Acala_dark.png',
                package: 'polkawallet_plugin_acala')),
        iconActive: Image(
            image: AssetImage('assets/images/Acala_indigo.png',
                package: 'polkawallet_plugin_acala')),
        content: AcalaEntry(this, keyring),
      )
    ];
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      // TxConfirmPage.route: (_) =>
      //     TxConfirmPage(this, keyring, _service.getPassword),

      // staking pages
      LoanPage.route: (_) => LoanPage(this, keyring),
    };
  }

  final balances = BalancesStore();

  AcalaApi _api;
  AcalaApi get api => _api;

  final StoreCache _cache = StoreCache();
  PluginStore _store;
  PluginService _service;
  PluginStore get store => _store;
  PluginService get service => _service;

  @override
  Future<void> beforeStart(Keyring keyring) async {
    _api = AcalaApi(AcalaService(this));

    _store = PluginStore(_cache);
    _service = PluginService(this, keyring);
  }

  @override
  Future<void> onStarted(Keyring keyring) async {
    if (keyring.current.address != null) {
      _api.subscribeTokenBalances(keyring.current.address, (data) {
        balances.setTokens(data);
      });

      final airdrops = await _api.queryAirdropTokens(keyring.current.address);
      balances
          .setExtraTokens([ExtraTokenData(title: 'Airdrop', tokens: airdrops)]);
    }
  }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _api.unsubscribeTokenBalances(acc.address);
    balances.setTokens([]);
    _api.subscribeTokenBalances(acc.address, (data) {
      balances.setTokens(data);
    });
  }
}
