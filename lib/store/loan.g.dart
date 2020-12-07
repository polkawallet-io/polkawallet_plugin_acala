// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LoanStore on _LoanStore, Store {
  final _$tokenBalanceMapAtom = Atom(name: '_LoanStore.tokenBalanceMap');

  @override
  Map<String, TokenBalanceData> get tokenBalanceMap {
    _$tokenBalanceMapAtom.reportRead();
    return super.tokenBalanceMap;
  }

  @override
  set tokenBalanceMap(Map<String, TokenBalanceData> value) {
    _$tokenBalanceMapAtom.reportWrite(value, super.tokenBalanceMap, () {
      super.tokenBalanceMap = value;
    });
  }

  final _$loanTypesAtom = Atom(name: '_LoanStore.loanTypes');

  @override
  List<LoanType> get loanTypes {
    _$loanTypesAtom.reportRead();
    return super.loanTypes;
  }

  @override
  set loanTypes(List<LoanType> value) {
    _$loanTypesAtom.reportWrite(value, super.loanTypes, () {
      super.loanTypes = value;
    });
  }

  final _$loansAtom = Atom(name: '_LoanStore.loans');

  @override
  Map<String, LoanData> get loans {
    _$loansAtom.reportRead();
    return super.loans;
  }

  @override
  set loans(Map<String, LoanData> value) {
    _$loansAtom.reportWrite(value, super.loans, () {
      super.loans = value;
    });
  }

  final _$pricesAtom = Atom(name: '_LoanStore.prices');

  @override
  Map<String, BigInt> get prices {
    _$pricesAtom.reportRead();
    return super.prices;
  }

  @override
  set prices(Map<String, BigInt> value) {
    _$pricesAtom.reportWrite(value, super.prices, () {
      super.prices = value;
    });
  }

  final _$txsAtom = Atom(name: '_LoanStore.txs');

  @override
  ObservableList<TxLoanData> get txs {
    _$txsAtom.reportRead();
    return super.txs;
  }

  @override
  set txs(ObservableList<TxLoanData> value) {
    _$txsAtom.reportWrite(value, super.txs, () {
      super.txs = value;
    });
  }

  final _$addLoanTxAsyncAction = AsyncAction('_LoanStore.addLoanTx');

  @override
  Future<void> addLoanTx(Map<dynamic, dynamic> tx, String pubKey) {
    return _$addLoanTxAsyncAction.run(() => super.addLoanTx(tx, pubKey));
  }

  final _$loadCacheAsyncAction = AsyncAction('_LoanStore.loadCache');

  @override
  Future<void> loadCache(String pubKey) {
    return _$loadCacheAsyncAction.run(() => super.loadCache(pubKey));
  }

  final _$_LoanStoreActionController = ActionController(name: '_LoanStore');

  @override
  void setTokenBalanceMap(List<TokenBalanceData> list) {
    final _$actionInfo = _$_LoanStoreActionController.startAction(
        name: '_LoanStore.setTokenBalanceMap');
    try {
      return super.setTokenBalanceMap(list);
    } finally {
      _$_LoanStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoanTypes(List<LoanType> list) {
    final _$actionInfo = _$_LoanStoreActionController.startAction(
        name: '_LoanStore.setLoanTypes');
    try {
      return super.setLoanTypes(list);
    } finally {
      _$_LoanStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountLoans(Map<String, LoanData> data) {
    final _$actionInfo = _$_LoanStoreActionController.startAction(
        name: '_LoanStore.setAccountLoans');
    try {
      return super.setAccountLoans(data);
    } finally {
      _$_LoanStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrices(Map<String, BigInt> data) {
    final _$actionInfo =
        _$_LoanStoreActionController.startAction(name: '_LoanStore.setPrices');
    try {
      return super.setPrices(data);
    } finally {
      _$_LoanStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
tokenBalanceMap: ${tokenBalanceMap},
loanTypes: ${loanTypes},
loans: ${loans},
prices: ${prices},
txs: ${txs}
    ''';
  }
}
