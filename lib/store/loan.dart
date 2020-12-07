import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';
import 'package:polkawallet_plugin_acala/api/types/txLoanData.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';

part 'loan.g.dart';

class LoanStore extends _LoanStore with _$LoanStore {
  LoanStore(StoreCache cache) : super(cache);
}

abstract class _LoanStore with Store {
  _LoanStore(this.cache);

  final StoreCache cache;
  final String cacheTxsLoanKey = 'loan_txs';

  @observable
  Map<String, TokenBalanceData> tokenBalanceMap =
      Map<String, TokenBalanceData>();

  @observable
  List<LoanType> loanTypes = List<LoanType>();

  @observable
  Map<String, LoanData> loans = {};

  @observable
  Map<String, BigInt> prices = {};

  @observable
  ObservableList<TxLoanData> txs = ObservableList<TxLoanData>();

  @action
  void setTokenBalanceMap(List<TokenBalanceData> list) {
    final data = Map<String, TokenBalanceData>();
    list.forEach((e) {
      data[e.symbol] = e;
    });
    tokenBalanceMap = data;
  }

  @action
  void setLoanTypes(List<LoanType> list) {
    loanTypes = list;
  }

  @action
  void setAccountLoans(Map<String, LoanData> data) {
    loans = data;
  }

  @action
  void setPrices(Map<String, BigInt> data) {
    prices = data;
  }

  @action
  Future<void> addLoanTx(Map tx, String pubKey) async {
    txs.add(TxLoanData.fromJson(Map<String, dynamic>.from(tx)));

    final cached = cache.loanTxs.val;
    List list = cached[pubKey];
    if (list != null) {
      list.add(tx);
    } else {
      list = [tx];
    }
    cached[pubKey] = list;
    cache.loanTxs.val = cached;
    print('save cache loan');
    print(cached);
  }

  @action
  Future<void> loadCache(String pubKey) async {
    if (pubKey == null || pubKey.isEmpty) return;

    final cached = cache.loanTxs.val;
    final list = cached[pubKey] as List;
    print(cached);
    print('loadCache loan');
    if (list != null) {
      print(list);
      txs = ObservableList<TxLoanData>.of(
          list.map((e) => TxLoanData.fromJson(Map<String, dynamic>.from(e))));
    }
    print(txs);
  }
}
