import 'package:polkawallet_plugin_karura/polkawallet_plugin_karura.dart';
import 'package:polkawallet_plugin_karura/utils/types/aggregatedAssetsData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';

class AssetsUtils {
  static const categoryTokens = 'Tokens';
  static const categoryVaults = 'Vaults';
  static const categoryLP = 'LP Staking';
  static const categoryLPFree = 'LP Free';
  static const categoryRewards = 'Rewards';

  static List<AggregatedAssetsData> aggregatedAssetsDataFromJson(
      Map assetsMap, BalancesStore balances, Map<String, double> marketPrices) {
    final lpFreeMapInt = {};
    balances.tokens?.forEach((e) {
      if (e.id.contains('-')) {
        final amount = BigInt.tryParse(e.amount) ?? BigInt.zero;
        if (amount > BigInt.zero) {
          lpFreeMapInt[e.id] = amount;
        }
      }
    });

    final List<AggregatedAssetsData> list = assetsMap.keys.map((k) {
      final data = AggregatedAssetsData();
      data.category = k;
      data.assets =
          List<AggregatedAssetsItemData>.from(assetsMap[k].keys.map((key) {
        final item = AggregatedAssetsItemData();
        item.token = key;
        item.amount = double.parse(assetsMap[k][key].toString());
        item.value = (marketPrices[key] ?? 0) * item.amount;
        return item;
      }).toList());
      data.value = data.assets.length > 0
          ? data.assets.map((e) => e.value).reduce((v, e) => v + e)
          : 0;
      return data;
    }).toList();

    if (assetsMap[categoryLPFree].keys.length > 0) {
      final lpFreeValueItem = AggregatedAssetsItemData();
      lpFreeValueItem.token = 'FreeLP';
      lpFreeValueItem.amount = 0;
      lpFreeValueItem.value = list
          .firstWhere((e) => e.category == categoryLPFree)
          .assets
          .map((e) => e.value)
          .reduce((a, b) => a + b);
      final tokensData = list.firstWhere((e) => e.category == categoryTokens);
      tokensData.assets.add(lpFreeValueItem);
      tokensData.value += lpFreeValueItem.value;
    }

    list.removeWhere((i) => i.category == categoryLPFree);

    return list;
  }

  static TokenBalanceData tokenDataFromCurrencyId(
      PluginKarura plugin, Map currencyId) {
    if (currencyId['token'] != null || currencyId['Token'] != null) {
      return getBalanceFromTokenNameId(
          plugin, currencyId['token'] ?? currencyId['Token']);
    }
    if (currencyId['foreignAsset'] != null ||
        currencyId['ForeignAsset'] != null) {
      return plugin.store.assets.tokenBalanceMap.values.firstWhere((e) =>
          e.type == 'ForeignAsset' &&
          e.id ==
              (currencyId['foreignAsset'] ?? currencyId['ForeignAsset'])
                  .toString());
    }
    if (currencyId['liquidCroadloan'] != null ||
        currencyId['LiquidCroadloan'] != null) {
      return plugin.store.assets.tokenBalanceMap.values.firstWhere((e) =>
          e.type == 'LiquidCroadloan' &&
          e.id ==
              (currencyId['liquidCroadloan'] ?? currencyId['LiquidCroadloan'])
                  .toString());
    }
    return TokenBalanceData();
  }

  static TokenBalanceData getBalanceFromTokenNameId(
      PluginKarura plugin, String tokenNameId) {
    if (tokenNameId == plugin.networkState.tokenSymbol[0]) {
      return TokenBalanceData(
          id: tokenNameId,
          symbol: tokenNameId,
          tokenNameId: tokenNameId,
          currencyId: {'Token': tokenNameId},
          type: 'Token',
          minBalance: plugin.networkConst['balances']['existentialDeposit'],
          decimals: plugin.networkState.tokenDecimals[0],
          amount: (plugin.balances.native?.availableBalance ?? 0).toString());
    }
    if (plugin.store.assets.tokenBalanceMap[tokenNameId] != null) {
      return plugin.store.assets.tokenBalanceMap[tokenNameId];
    }
    final tokenDataIndex = plugin.store.assets.allTokens
        .indexWhere((e) => e.tokenNameId == tokenNameId);
    return tokenDataIndex < 0
        ? TokenBalanceData()
        : plugin.store.assets.allTokens[tokenDataIndex];
  }

  static List<TokenBalanceData> getBalancePairFromTokenNameId(
      PluginKarura plugin, List<String> tokenNameIdPair) {
    return tokenNameIdPair
        .map((e) => getBalanceFromTokenNameId(plugin, e))
        .toList();
  }
}
