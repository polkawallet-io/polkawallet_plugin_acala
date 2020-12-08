import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/dexPoolInfoData.dart';
import 'package:polkawallet_plugin_acala/api/types/swapOutputData.dart';
import 'package:polkawallet_plugin_acala/api/types/txLiquidityData.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';

part 'earn.g.dart';

class EarnStore extends _EarnStore with _$EarnStore {
  EarnStore(StoreCache cache) : super(cache);
}

abstract class _EarnStore with Store {
  _EarnStore(this.cache);

  final StoreCache cache;

  @observable
  Map<String, double> swapPoolRewards = Map<String, double>();

  @observable
  Map<String, double> swapPoolSavingRewards = Map<String, double>();

  @observable
  List<List<AcalaTokenData>> dexPools = List<List<AcalaTokenData>>();

  @observable
  ObservableMap<String, DexPoolInfoData> dexPoolInfoMap =
      ObservableMap<String, DexPoolInfoData>();

  @observable
  ObservableList<TxDexLiquidityData> txs = ObservableList<TxDexLiquidityData>();

  @action
  void setDexPools(List<List<AcalaTokenData>> list) {
    dexPools = list;
  }

  @action
  void setDexPoolInfo(Map<String, DexPoolInfoData> data) {
    dexPoolInfoMap.addAll(data);
  }

  @action
  void setDexPoolRewards(Map<String, Map<String, double>> data) {
    swapPoolRewards = data['incentives'];
    swapPoolSavingRewards = data['savingRates'];
  }

  @action
  void addDexLiquidityTx(Map tx, String pubKey, int decimals) {
    txs.add(
        TxDexLiquidityData.fromJson(Map<String, dynamic>.from(tx), decimals));

    final cached = cache.dexLiquidityTxs.val;
    List list = cached[pubKey];
    if (list != null) {
      list.add(tx);
    } else {
      list = [tx];
    }
    cached[pubKey] = list;
    cache.dexLiquidityTxs.val = cached;
  }

  @action
  void loadCache(String pubKey) {
    if (pubKey == null || pubKey.isEmpty) return;

    final cached = cache.dexLiquidityTxs.val;
    final list = cached[pubKey] as List;
    if (list != null) {
      txs = ObservableList<TxDexLiquidityData>.of(list.map((e) =>
          TxDexLiquidityData.fromJson(
              Map<String, dynamic>.from(e), acala_token_decimals)));
    }
  }
}
