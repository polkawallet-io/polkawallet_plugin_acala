import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/stakingPoolInfoData.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';

part 'homa.g.dart';

class HomaStore extends _HomaStore with _$HomaStore {
  HomaStore(StoreCache cache) : super(cache);
}

abstract class _HomaStore with Store {
  _HomaStore(this.cache);

  final StoreCache cache;

  @observable
  StakingPoolInfoData stakingPoolInfo = StakingPoolInfoData();

  @action
  void setStakingPoolInfoData(StakingPoolInfoData data) {
    stakingPoolInfo = data;
  }
}
