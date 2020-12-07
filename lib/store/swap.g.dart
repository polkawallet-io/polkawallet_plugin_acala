// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SwapStore on _SwapStore, Store {
  final _$txsAtom = Atom(name: '_SwapStore.txs');

  @override
  ObservableList<TxSwapData> get txs {
    _$txsAtom.reportRead();
    return super.txs;
  }

  @override
  set txs(ObservableList<TxSwapData> value) {
    _$txsAtom.reportWrite(value, super.txs, () {
      super.txs = value;
    });
  }

  final _$addSwapTxAsyncAction = AsyncAction('_SwapStore.addSwapTx');

  @override
  Future<void> addSwapTx(
      Map<dynamic, dynamic> tx, String pubKey, int decimals) {
    return _$addSwapTxAsyncAction
        .run(() => super.addSwapTx(tx, pubKey, decimals));
  }

  final _$loadCacheAsyncAction = AsyncAction('_SwapStore.loadCache');

  @override
  Future<void> loadCache(String pubKey) {
    return _$loadCacheAsyncAction.run(() => super.loadCache(pubKey));
  }

  @override
  String toString() {
    return '''
txs: ${txs}
    ''';
  }
}
