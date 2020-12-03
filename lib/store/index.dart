import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_acala/store/homa.dart';
import 'package:polkawallet_plugin_acala/store/loan.dart';
import 'package:polkawallet_plugin_acala/store/setting.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : setting = SettingStore(cache),
        loan = LoanStore(cache),
        homa = HomaStore(cache);
  final SettingStore setting;
  final LoanStore loan;
  final HomaStore homa;
  // final GovernanceStore gov;
  // final AccountsStore accounts = AccountsStore();
}
