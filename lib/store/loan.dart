import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';

part 'loan.g.dart';

class LoanStore extends _LoanStore with _$LoanStore {
  LoanStore(StoreCache cache) : super(cache);
}

abstract class _LoanStore with Store {
  _LoanStore(this.cache);

  final StoreCache cache;

  // @observable
  // List<LoanType> loanTypes = List<LoanType>();
  //
  // @observable
  // Map<String, LoanData> loans = {};
  //
  // @observable
  // Map<String, BigInt> prices = {};
  //
  // @observable
  // List<LPTokenData> lpTokens = List<LPTokenData>();
  //
  // @observable
  // ObservableList<TxLoanData> txsLoan = ObservableList<TxLoanData>();
}
