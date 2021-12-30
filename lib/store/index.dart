import 'package:polkawallet_plugin_acala/store/accounts.dart';
import 'package:polkawallet_plugin_acala/store/assets.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_acala/store/earn.dart';
import 'package:polkawallet_plugin_acala/store/gov/governance.dart';
import 'package:polkawallet_plugin_acala/store/homa.dart';
import 'package:polkawallet_plugin_acala/store/loan.dart';
import 'package:polkawallet_plugin_acala/store/setting.dart';
import 'package:polkawallet_plugin_acala/store/swap.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : setting = SettingStore(cache),
        gov = GovernanceStore(cache),
        assets = AssetsStore(cache),
        loan = LoanStore(cache),
        earn = EarnStore(cache),
        swap = SwapStore(cache),
        homa = HomaStore(cache);

  final accounts = AccountsStore();

  final SettingStore setting;
  final AssetsStore assets;
  final LoanStore loan;
  final EarnStore earn;
  final HomaStore homa;
  final GovernanceStore gov;
  final SwapStore swap;
}
