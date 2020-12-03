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
  String toString() {
    return '''
stakingPoolInfo: ${stakingPoolInfo}
    ''';
  }
}
