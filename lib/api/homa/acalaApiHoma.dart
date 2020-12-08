import 'package:polkawallet_plugin_acala/api/homa/acalaServiceHoma.dart';
import 'package:polkawallet_plugin_acala/api/types/homaRedeemAmountData.dart';
import 'package:polkawallet_plugin_acala/api/types/stakingPoolInfoData.dart';

class AcalaApiHoma {
  AcalaApiHoma(this.service);

  final AcalaServiceHoma service;

  Future<StakingPoolInfoData> queryHomaStakingPool() async {
    final Map res = await service.queryHomaStakingPool();
    return StakingPoolInfoData.fromJson(Map<String, dynamic>.of(res));
  }

  Future<HomaUserInfoData> queryHomaUserInfo(String address) async {
    final Map res = await service.queryHomaUserInfo(address);
    return HomaUserInfoData.fromJson(Map<String, dynamic>.of(res));
  }

  Future<HomaRedeemAmountData> queryHomaRedeemAmount(
      double input, int redeemType, era) async {
    final Map res = await service.queryHomaRedeemAmount(input, redeemType, era);
    return HomaRedeemAmountData.fromJson(res);
  }
}
