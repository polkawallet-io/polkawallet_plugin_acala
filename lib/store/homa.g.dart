// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homa.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$HomaStore on _HomaStore, Store {
  final _$stakingPoolInfoAtom = Atom(name: '_HomaStore.stakingPoolInfo');

  @override
  StakingPoolInfoData get stakingPoolInfo {
    _$stakingPoolInfoAtom.reportRead();
    return super.stakingPoolInfo;
  }

  @override
  set stakingPoolInfo(StakingPoolInfoData value) {
    _$stakingPoolInfoAtom.reportWrite(value, super.stakingPoolInfo, () {
      super.stakingPoolInfo = value;
    });
  }

  final _$userInfoAtom = Atom(name: '_HomaStore.userInfo');

  @override
  HomaUserInfoData get userInfo {
    _$userInfoAtom.reportRead();
    return super.userInfo;
  }

  @override
  set userInfo(HomaUserInfoData value) {
    _$userInfoAtom.reportWrite(value, super.userInfo, () {
      super.userInfo = value;
    });
  }

  final _$txsAtom = Atom(name: '_HomaStore.txs');

  @override
  ObservableList<TxHomaData> get txs {
    _$txsAtom.reportRead();
    return super.txs;
  }

  @override
  set txs(ObservableList<TxHomaData> value) {
    _$txsAtom.reportWrite(value, super.txs, () {
      super.txs = value;
    });
  }

  final _$setHomaUserInfoAsyncAction =
      AsyncAction('_HomaStore.setHomaUserInfo');

  @override
  Future<void> setHomaUserInfo(HomaUserInfoData info) {
    return _$setHomaUserInfoAsyncAction.run(() => super.setHomaUserInfo(info));
  }

  final _$_HomaStoreActionController = ActionController(name: '_HomaStore');

  @override
  void setStakingPoolInfoData(StakingPoolInfoData data) {
    final _$actionInfo = _$_HomaStoreActionController.startAction(
        name: '_HomaStore.setStakingPoolInfoData');
    try {
      return super.setStakingPoolInfoData(data);
    } finally {
      _$_HomaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addHomaTx(Map<dynamic, dynamic> tx, String pubKey, int decimals) {
    final _$actionInfo =
        _$_HomaStoreActionController.startAction(name: '_HomaStore.addHomaTx');
    try {
      return super.addHomaTx(tx, pubKey, decimals);
    } finally {
      _$_HomaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void loadCache(String pubKey) {
    final _$actionInfo =
        _$_HomaStoreActionController.startAction(name: '_HomaStore.loadCache');
    try {
      return super.loadCache(pubKey);
    } finally {
      _$_HomaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
stakingPoolInfo: ${stakingPoolInfo},
userInfo: ${userInfo},
txs: ${txs}
    ''';
  }
}
