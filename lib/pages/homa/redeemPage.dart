import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/calcHomaRedeemAmount.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/pages/swap/bootstrapPage.dart';
import 'package:polkawallet_plugin_acala/pages/swap/swapTokenInput.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/textTag.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class RedeemPage extends StatefulWidget {
  RedeemPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/karura/homa/redeem';

  @override
  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  final TextEditingController _amountPayCtrl = new TextEditingController();

  bool _isFastRedeem = false;
  bool _canFastRedeem = false;

  String _error;
  BigInt _maxInput;

  CalcHomaRedeemAmount _data;
  num _receiveAmount = 0;
  num _fastFee = 0;

  List<String> symbols;
  final stakeToken = relay_chain_token_symbol;
  List<int> decimals;

  double karBalance;

  int stakeDecimal;

  double minRedeem;

  Timer _timer;

  @override
  void initState() {
    super.initState();

    symbols = widget.plugin.networkState.tokenSymbol;
    decimals = widget.plugin.networkState.tokenDecimals;

    karBalance = Fmt.balanceDouble(
        widget.plugin.balances.native.availableBalance.toString(),
        decimals[symbols.indexOf("L$stakeToken")]);

    stakeDecimal = decimals[symbols.indexOf("L$stakeToken")];

    minRedeem = widget.plugin.store.homa.env != null
        ? widget.plugin.store.homa.env.redeemThreshold
        : Fmt.balanceDouble(
            widget.plugin.networkConst['homaLite']['minimumRedeemThreshold']
                .toString(),
            stakeDecimal);
  }

  Future<void> _updateReceiveAmount(double input, BigInt max) async {
    if (mounted && input != null) {
      final data = await widget.plugin.api.homa
          .calcHomaNewRedeemAmount(input, _isFastRedeem);
      final canFast = data['canTryFastReddem'] ?? false;
      if (canFast) {
        setState(() {
          _receiveAmount = data['receive'];
          _fastFee = data['fee'] ?? 0;
          _canFastRedeem = true;
        });
      } else {
        if (_isFastRedeem) {
          // we can not do fast redeem, so we use swap here
          final lToken = AssetsUtils.getBalanceFromTokenNameId(
              widget.plugin, 'L$stakeToken');
          final token =
              AssetsUtils.getBalanceFromTokenNameId(widget.plugin, stakeToken);
          final swapRes = await widget.plugin.api.swap.queryTokenSwapAmount(
              input.toString(),
              null,
              [
                {...lToken.currencyId, 'decimals': lToken.decimals},
                {...token.currencyId, 'decimals': token.decimals},
              ],
              '0.1');
          setState(() {
            _canFastRedeem = false;
            _receiveAmount = swapRes.amount;
            _fastFee = swapRes.fee;
          });
        } else {
          // or we use normal redeem request
          setState(() {
            _canFastRedeem = false;
            _receiveAmount = data['receive'];
            _fastFee = 0;
          });
        }
      }
    }
  }

  void _onSupplyAmountChange(String v, BigInt max) {
    final supply = v.trim();
    setState(() {
      _maxInput = null;
    });

    final error = _validateInput(supply, max);
    setState(() {
      _error = error;
      if (error != null) {
        _data = null;
      }
    });

    if (error != null) {
      return;
    }
    _updateReceiveAmount(double.tryParse(supply), max);
  }

  String _validateInput(String supply, BigInt max) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');
    final error = Fmt.validatePrice(supply, context);
    if (error != null) {
      return error;
    }

    final pay = double.parse(supply);
    if (_maxInput == null &&
        Fmt.tokenInt(supply,
                decimals[symbols.indexOf('L$relay_chain_token_symbol')]) >
            max) {
      return dic['amount.low'];
    }

    if (pay <= minRedeem) {
      final minLabel = I18n.of(context)
          .getDic(i18n_full_dic_acala, 'acala')['homa.pool.redeem'];
      return '$minLabel > ${minRedeem.toStringAsFixed(4)}';
    }

    return error;
  }

  void _onSetMax(BigInt max) {
    final amount = Fmt.bigIntToDouble(max, stakeDecimal);
    setState(() {
      _amountPayCtrl.text = amount.toStringAsFixed(6);
      _maxInput = max;
      _error = _validateInput(amount.toString(), max);
    });

    _updateReceiveAmount(amount, max);
  }

  Future<void> _onSubmit() async {
    final pay = _amountPayCtrl.text.trim();

    if (_error != null || pay.isEmpty || (_data == null && _receiveAmount == 0))
      return;

    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');

    final txDisplay = {
      dic['dex.pay']: Text(
        '$pay L$stakeToken',
        style: Theme.of(context).textTheme.headline1,
      ),
      dic['dex.receive']: Text(
        '≈ ${Fmt.priceFloor(_receiveAmount)} $stakeToken',
        style: Theme.of(context).textTheme.headline1,
      ),
    };

    String module = 'homa';
    String call = 'requestRedeem';
    List params = [
      Fmt.tokenInt(pay, stakeDecimal).toString(),
      _isFastRedeem,
    ];
    String paramsRaw;
    if (_isFastRedeem && _canFastRedeem) {
      module = 'utility';
      call = 'batch';
      paramsRaw = '[['
          'api.tx.homa.requestRedeem(...${jsonEncode(params)}),'
          'api.tx.homa.fastMatchRedeems(["${widget.keyring.current.address}"])'
          ']]';
      params = [];
    }

    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: module,
          call: call,
          txTitle: dic['homa.redeem'],
          txDisplay: _isFastRedeem
              ? {
                  dic['homa.fast']: '',
                }
              : {},
          txDisplayBold: txDisplay,
          params: params,
          rawParams: paramsRaw,
        ))) as Map;

    if (res != null) {
      Navigator.of(context).pop('1');
    }
  }

  void _switchFast(bool value, BigInt max) {
    setState(() {
      _isFastRedeem = value;
    });
    if (_amountPayCtrl.text.trim().isEmpty) return;

    if (_maxInput != null) {
      _onSetMax(_maxInput);
    } else {
      _onSupplyAmountChange(_amountPayCtrl.text.trim(), max);
    }
  }

  @override
  void dispose() {
    _amountPayCtrl.dispose();
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(_) {
    final grey = Theme.of(context).unselectedWidgetColor;
    final labelStyle = TextStyle(color: grey, fontSize: 13);
    return Observer(
      builder: (BuildContext context) {
        final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');

        final pendingRedeemReq = Fmt.balanceInt(
            (widget.plugin.store.homa.userInfo?.redeemRequest ??
                    {})['amount'] ??
                '0');
        final pendingRedeemReqView = Fmt.priceFloorBigInt(pendingRedeemReq,
            decimals[symbols.indexOf('L$relay_chain_token_symbol')],
            lengthMax: 4);

        final lTokenBalance =
            widget.plugin.store.assets.tokenBalanceMap["L$stakeToken"];
        final max = Fmt.balanceInt(lTokenBalance.amount) + pendingRedeemReq;

        int unbondEras = 28;
        if (widget.plugin.networkConst['homa'] != null) {
          unbondEras =
              int.parse(widget.plugin.networkConst['homa']['bondingDuration']);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('${dic['homa.redeem']} $stakeToken'),
            centerTitle: true,
            leading: BackBtn(),
          ),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                          visible: pendingRedeemReq > BigInt.zero,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: TextTag(
                                  dic['homa.redeem.pending'] +
                                      ' $pendingRedeemReqView L$relay_chain_token_symbol' +
                                      '\n${dic['homa.redeem.replace']}',
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                ))
                              ],
                            ),
                          )),
                      SwapTokenInput(
                        title: dic['dex.pay'],
                        inputCtrl: _amountPayCtrl,
                        balance: TokenBalanceData(
                            symbol: lTokenBalance.symbol,
                            amount: max.toString(),
                            decimals: lTokenBalance.decimals),
                        tokenIconsMap: widget.plugin.tokenIcons,
                        onInputChange: (v) => _onSupplyAmountChange(v, max),
                        onSetMax: karBalance > 0.1 ? (v) => _onSetMax(v) : null,
                        onClear: () {
                          setState(() {
                            _amountPayCtrl.text = '';
                          });
                          _onSupplyAmountChange('', max);
                        },
                      ),
                      ErrorMessage(_error),
                      // Visibility(
                      //     visible: _amountReceive.isNotEmpty,
                      //     child: Container(
                      //       margin: EdgeInsets.only(top: 16),
                      //       child: InfoItemRow(dic['dex.receive'],
                      //           '$_amountReceive L$stakeToken'),
                      //     )),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(dic['homa.fast'],
                                style: TextStyle(fontSize: 13)),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: CupertinoSwitch(
                                value: _isFastRedeem,
                                onChanged: (res) => _switchFast(res, max),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          border: Border.all(
                              color: Theme.of(context).disabledColor,
                              width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Visibility(
                              visible: (!_isFastRedeem ||
                                  (_isFastRedeem && _canFastRedeem)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(dic['homa.redeem.unbonding'],
                                      style: labelStyle),
                                  Text("$unbondEras Kusama Eras")
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dic['homa.redeem.receive'],
                                    style: labelStyle),
                                Text(
                                    "${_data != null ? _data.expected : (_receiveAmount ?? 0)} $stakeToken")
                              ],
                            ),
                            Visibility(
                                visible: _isFastRedeem,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(dic['homa.redeem.fee'],
                                        style: labelStyle),
                                    Text(
                                        "${_data != null ? _data.fee : (_fastFee ?? 0)} L$stakeToken")
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: RoundedButton(
                    text: dic['homa.redeem'],
                    onPressed: _onSubmit,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
