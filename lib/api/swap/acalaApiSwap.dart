import 'package:polkawallet_plugin_acala/api/swap/acalaServiceSwap.dart';
import 'package:polkawallet_plugin_acala/api/types/dexPoolInfoData.dart';
import 'package:polkawallet_plugin_acala/api/types/swapOutputData.dart';

class AcalaApiSwap {
  AcalaApiSwap(this.service);

  final AcalaServiceSwap service;

  Future<SwapOutputData> queryTokenSwapAmount(
    String supplyAmount,
    String targetAmount,
    List<String> swapPair,
    String slippage,
  ) async {
    final output = await service.queryTokenSwapAmount(
        supplyAmount, targetAmount, swapPair, slippage);
    return SwapOutputData.fromJson(output);
  }

  Future<List<List<AcalaTokenData>>> getDexPools() async {
    final pools = await service.getDexPools();
    return pools
        .map((pool) =>
            (pool as List).map((e) => AcalaTokenData.fromJson(e)).toList())
        .toList();
  }

  Future<Map> queryDexLiquidityPoolRewards(
      List<List<AcalaTokenData>> dexPools) async {
    final res = await service.queryDexLiquidityPoolRewards(dexPools);
    return res;
  }

  Future<Map<String, DexPoolInfoData>> queryDexPoolInfo(
      String pool, address) async {
    final Map info = await service.queryDexPoolInfo(pool, address);
    return {pool: DexPoolInfoData.fromJson(Map<String, dynamic>.of(info))};
  }
}
