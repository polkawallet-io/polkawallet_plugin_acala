import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_acala/store/loan.dart';

class PluginStore {
  PluginStore(StoreCache cache) : loan = LoanStore(cache);
  final LoanStore loan;
  // final GovernanceStore gov;
  // final AccountsStore accounts = AccountsStore();
}
