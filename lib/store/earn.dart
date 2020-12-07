import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/dexPoolInfoData.dart';
import 'package:polkawallet_plugin_acala/api/types/swapOutputData.dart';
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
}
