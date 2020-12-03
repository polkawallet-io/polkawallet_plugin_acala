import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';

part 'setting.g.dart';

class SettingStore extends _SettingStore with _$SettingStore {
  SettingStore(StoreCache cache) : super(cache);
}

abstract class _SettingStore with Store {
  _SettingStore(this.cache);

  final StoreCache cache;

  @observable
  Map liveModules = Map();

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

  @action
  void setLiveModules(Map value) {
    liveModules = value;
  }
}
