import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/nftData.dart';
import 'package:polkawallet_plugin_acala/api/types/transferData.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/utils/format.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(StoreCache cache) : super(cache);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.cache);

  final StoreCache cache;
  final String cacheTxsTransferKey = 'transfer_txs';

  @observable
  Map<String, TokenBalanceData> tokenBalanceMap =
      Map<String, TokenBalanceData>();

  @observable
  Map<String, BigInt> prices = {};

  @observable
  ObservableList<TransferData> txs = ObservableList<TransferData>();

  @observable
  List<NFTData> nft = [];

  @action
  void setTokenBalanceMap(List<TokenBalanceData> list) {
    final data = Map<String, TokenBalanceData>();
    list.forEach((e) {
      data[e.symbol] = e;
    });
    tokenBalanceMap = data;
  }

  @action
  void setPrices(Map<String, BigInt> data) {
    prices = data;
  }

  @action
  void setNFTs(List<NFTData> list) {
    nft = list;
  }

  @action
  void addTx(Map tx, KeyPairData acc) {
    final txData = Map<String, dynamic>.of({
      "block_timestamp": int.parse(tx['time'].toString().substring(0, 10)),
      "hash": tx['hash'],
      "success": true,
      "from": acc.address,
      "to": tx['params'][0],
      "token": tx['params'][1]['Token'] ??
          List.of(tx['params'][1]['DEXShare']).join('-').toUpperCase(),
      "amount": Fmt.balance(
        tx['params'][2],
        acala_token_decimals,
      ),
    });
    txs.add(TransferData.fromJson(txData));

    final cached = cache.transferTxs.val;
    List list = cached[acc.pubKey];
    if (list != null) {
      list.add(txData);
    } else {
      list = [txData];
    }
    cached[acc.pubKey] = list;
    cache.transferTxs.val = cached;
  }

  @action
  void loadCache(String pubKey) {
    if (pubKey == null || pubKey.isEmpty) return;

    final cached = cache.transferTxs.val;
    final list = cached[pubKey] as List;
    if (list != null) {
      txs = ObservableList<TransferData>.of(
          list.map((e) => TransferData.fromJson(Map<String, dynamic>.from(e))));
    } else {
      txs = ObservableList<TransferData>();
    }
  }
}
