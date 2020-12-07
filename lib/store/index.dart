import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_acala/store/homa.dart';
import 'package:polkawallet_plugin_acala/store/loan.dart';
import 'package:polkawallet_plugin_acala/store/setting.dart';
import 'package:polkawallet_plugin_acala/store/swap.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : setting = SettingStore(cache),
        loan = LoanStore(cache),
        swap = SwapStore(cache),
        homa = HomaStore(cache);
  final SettingStore setting;
  final LoanStore loan;
  final SwapStore swap;
  final HomaStore homa;
  // final GovernanceStore gov;
  // final AccountsStore accounts = AccountsStore();
}
