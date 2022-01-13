import 'package:flutter/cupertino.dart';
import 'package:polkawallet_plugin_acala/common/constants/base.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/service/serviceAssets.dart';
import 'package:polkawallet_plugin_acala/service/serviceEarn.dart';
import 'package:polkawallet_plugin_acala/service/serviceGov.dart';
import 'package:polkawallet_plugin_acala/service/serviceHoma.dart';
import 'package:polkawallet_plugin_acala/service/serviceLoan.dart';
import 'package:polkawallet_plugin_acala/service/walletApi.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class PluginService {
  PluginService(PluginAcala plugin, Keyring keyring)
      : assets = ServiceAssets(plugin, keyring),
        loan = ServiceLoan(plugin, keyring),
        earn = ServiceEarn(plugin, keyring),
        homa = ServiceHoma(plugin, keyring),
        gov = ServiceGov(plugin, keyring),
        plugin = plugin;
  final ServiceAssets assets;
  final ServiceLoan loan;
  final ServiceEarn earn;
  final ServiceHoma homa;
  final ServiceGov gov;

  final PluginAcala plugin;

  bool connected = false;

  Future<String?> getPassword(BuildContext context, KeyPairData acc) async {
    final password = await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          plugin.sdk.api,
          title: Text(
              I18n.of(context)!.getDic(i18n_full_dic_ui, 'common')!['unlock']!),
          account: acc,
        );
      },
    );
    return password;
  }

  Future<void> fetchLiveModules() async {
    final res = await WalletApi.getLiveModules();
    if (res != null) {
      plugin.store!.setting.setLiveModules(res);
    } else {
      plugin.store!.setting.setLiveModules(config_modules);
    }
  }

  Future<void> fetchTokensConfig() async {
    final res = await WalletApi.getTokensConfig();
    if (res != null) {
      plugin.store!.setting.setTokensConfig(res);
    }
  }
}
