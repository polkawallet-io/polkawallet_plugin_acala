import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/txSwapData.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';

part 'swap.g.dart';

class SwapStore extends _SwapStore with _$SwapStore {
  SwapStore(StoreCache cache) : super(cache);
}

abstract class _SwapStore with Store {
  _SwapStore(this.cache);

  final StoreCache cache;

  @observable
  ObservableList<TxSwapData> txs = ObservableList<TxSwapData>();

  @action
  Future<void> addSwapTx(Map tx, String pubKey, int decimals) async {
    txs.add(TxSwapData.fromJson(Map<String, dynamic>.from(tx), decimals));

    final cached = cache.swapTxs.val;
    List list = cached[pubKey];
    if (list != null) {
      list.add(tx);
    } else {
      list = [tx];
    }
    cached[pubKey] = list;
    cache.swapTxs.val = cached;
  }

  @action
  Future<void> loadCache(String pubKey) async {
    if (pubKey == null || pubKey.isEmpty) return;

    final cached = cache.swapTxs.val;
    final list = cached[pubKey] as List;
    if (list != null) {
      txs = ObservableList<TxSwapData>.of(list.map((e) => TxSwapData.fromJson(
          Map<String, dynamic>.from(e), acala_token_decimals)));
    }
  }
}
