library polkawallet_plugin_acala;

import 'package:flutter/cupertino.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';

class PluginAcala extends PolkawalletPlugin {
  @override
  final basic = PluginBasicData();

  @override
  List<NetworkParams> get nodeList {
    return node_list.map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  Map<String, Widget> tokenIcons = {
    'ACA': Image.asset(
        'packages/polkawallet_plugin_acala/assets/images/tokens/KSM.png'),
    'KAR': Image.asset(
        'packages/polkawallet_plugin_kusama/assets/images/tokens/DOT.png'),
  };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    return [
      HomeNavItem(
        text: 'Acala',
        icon: Image(
            image: AssetImage('assets/images/public/Acala_dark.png',
                package: 'polkawallet_plugin_kusama')),
        iconActive: Image(
            image: AssetImage('assets/images/public/Acala_indigo.png',
                package: 'polkawallet_plugin_kusama')),
        content: Container(),
      )
    ];
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      // TxConfirmPage.route: (_) =>
      //     TxConfirmPage(this, keyring, _service.getPassword),

      // staking pages
    };
  }

  // PluginStore _store;
  // PluginApi _service;
  // PluginStore get store => _store;
  // PluginApi get service => _service;
  //
  // final StoreCache _cache;
  //
  // @override
  // Future<void> beforeStart(Keyring keyring) async {
  //   _store = PluginStore(_cache);
  //   _service = PluginApi(this, keyring);
  // }
  //
  // @override
  // Future<void> onStarted(Keyring keyring) async {
  //   _service.staking.fetchStakingOverview();
  // }
}
