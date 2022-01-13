import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/pages/homaNew/homaPage.dart';
import 'package:polkawallet_plugin_acala/pages/loanNew/loanPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

Map<String, WidgetBuilder> getNewUiRoutes(PluginAcala plugin, Keyring keyring) {
  return {
    HomaPage.route: (_) => HomaPage(plugin, keyring),
    LoanPage.route: (_) => LoanPage(plugin, keyring),
  };
}
