import 'package:polkawallet_plugin_acala/api/acalaApi.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/store/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ServiceEarn {
  ServiceEarn(this.plugin, this.keyring)
      : api = plugin.api,
        store = plugin.store;

  final PluginAcala plugin;
  final Keyring keyring;
  final AcalaApi api;
  final PluginStore store;

  Map<String, double> _calcIncentives(Map rewards) {
    final int blockTime = plugin.networkConst['babe']['expectedBlockTime'];
    final int epoch = plugin.networkConst['incentives']['accumulatePeriod'];
    final epochOfDay = SECONDS_OF_DAY * 1000 / blockTime / epoch;
    final res = Map<String, double>();
    rewards.forEach((k, v) {
      res[k] =
          Fmt.balanceDouble(v.toString(), plugin.networkState.tokenDecimals) *
              epochOfDay;
    });
    return res;
  }

  Map<String, double> _calcSavingRates(Map savingRates) {
    final int blockTime = plugin.networkConst['babe']['expectedBlockTime'];
    final int epoch = plugin.networkConst['incentives']['accumulatePeriod'];
    final epochOfYear = SECONDS_OF_YEAR * 1000 / blockTime / epoch;
    final res = Map<String, double>();
    savingRates.forEach((k, v) {
      res[k] =
          Fmt.balanceDouble(v.toString(), plugin.networkState.tokenDecimals) *
              epochOfYear;
    });
    return res;
  }

  Future<void> queryDexPoolRewards() async {
    final pools = await api.getDexPools();
    store.earn.setDexPools(pools);

    final rewards = await api.queryDexLiquidityPoolRewards(pools);
    final res = Map<String, Map<String, double>>();
    res['incentives'] = _calcIncentives(rewards['incentives']);
    res['savingRates'] = _calcSavingRates(rewards['savingRates']);
    store.earn.setDexPoolRewards(res);
  }

  Future<void> queryDexPoolInfo(String poolId) async {
    final info = await api.queryDexPoolInfo(poolId, keyring.current.address);
    store.earn.setDexPoolInfo(info);
  }

  double getSwapFee() {
    return plugin.networkConst['dex']['getExchangeFee'][0] /
        plugin.networkConst['dex']['getExchangeFee'][1];
  }
}
