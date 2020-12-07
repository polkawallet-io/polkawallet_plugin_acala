import 'package:flutter/cupertino.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/service/serviceEarn.dart';
import 'package:polkawallet_plugin_acala/service/serviceLoan.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class PluginService {
  PluginService(PluginAcala plugin, Keyring keyring)
      : loan = ServiceLoan(plugin, keyring),
        earn = ServiceEarn(plugin, keyring),
        plugin = plugin;
  final ServiceLoan loan;
  final ServiceEarn earn;

  final PluginAcala plugin;

  Future<String> getPassword(BuildContext context, KeyPairData acc) async {
    final password = await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          plugin.sdk.api,
          title: Text(
              I18n.of(context).getDic(i18n_full_dic_ui, 'common')['unlock']),
          account: acc,
        );
      },
    );
    return password;
  }
}
