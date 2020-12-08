import 'package:polkawallet_plugin_acala/api/acalaApi.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/store/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ServiceLoan {
  ServiceLoan(this.plugin, this.keyring)
      : api = plugin.api,
        store = plugin.store;

  final PluginAcala plugin;
  final Keyring keyring;
  final AcalaApi api;
  final PluginStore store;

  void _calcLDOTPrice(Map<String, BigInt> prices, double liquidExchangeRate) {
    // LDOT price may lost precision here
    prices['LDOT'] = Fmt.tokenInt(
        (Fmt.bigIntToDouble(prices['DOT'], plugin.networkState.tokenDecimals) *
                liquidExchangeRate)
            .toString(),
        plugin.networkState.tokenDecimals);
  }

  Map<String, LoanData> _calcLoanData(
    List loans,
    List<LoanType> loanTypes,
    Map<String, BigInt> prices,
  ) {
    final data = Map<String, LoanData>();
    loans.forEach((i) {
      String token = i['currency']['Token'];
      data[token] = LoanData.fromJson(
        Map<String, dynamic>.from(i),
        loanTypes.firstWhere((t) => t.token == token),
        prices[token] ?? BigInt.zero,
        plugin.networkState.tokenDecimals,
      );
    });
    return data;
  }

  Future<void> subscribeAccountLoans(String address) async {
    if (address == null) return;

    // 1. we need to get all LoanTypes
    final loanTypes = await api.loan.queryLoanTypes();
    store.loan.setLoanTypes(loanTypes);

    // 2. subscribe all token prices, callback triggers per 5s.
    api.assets.subscribeTokenPrices((Map<String, BigInt> prices) async {
      // 3. we need homa staking pool info to calculate price of LDOT
      final stakingPoolInfo = await api.homa.queryHomaStakingPool();
      store.homa.setStakingPoolInfoData(stakingPoolInfo);

      // 4. set prices
      _calcLDOTPrice(prices, stakingPoolInfo.liquidExchangeRate);
      store.loan.setPrices(prices);

      // 5. we need loanTypes & prices to get account loans
      final loans = await api.loan.queryAccountLoans(address);
      if (loans != null && loans.length > 0) {
        store.loan.setAccountLoans(_calcLoanData(loans, loanTypes, prices));
      }
    });
  }

  void unsubscribeAccountLoans() {
    api.assets.unsubscribeTokenPrices();
  }
}
