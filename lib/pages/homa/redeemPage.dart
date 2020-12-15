import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/txHomaData.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/pages/homa/homaHistoryPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/currencyWithIcon.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class HomaRedeemPage extends StatefulWidget {
  HomaRedeemPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/homa/redeem';

  @override
  _HomaRedeemPageState createState() => _HomaRedeemPageState();
}

class _HomaRedeemPageState extends State<HomaRedeemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();

  int _radioSelect = 0;
  int _eraSelected = 0;
  double _fee = 0;

  Timer _timer;

  Future<void> _updateReceiveAmount(double input) async {
    if (input == null || input == 0) return;

    final era =
        widget.plugin.store.homa.stakingPoolInfo.freeList[_eraSelected].era;
    final res = await widget.plugin.api.homa
        .queryHomaRedeemAmount(input, _radioSelect, era);
    double fee = 0;
    double amount = 0;
    if (res.fee != null) {
      fee = res.fee;
      amount = res.received;
    } else {
      amount = res.amount;
    }

    if (mounted) {
      setState(() {
        _amountReceiveCtrl.text = amount.toStringAsFixed(6);
        _fee = fee;
      });
      _formKey.currentState.validate();
    }
  }

  void _onSupplyAmountChange(String v) {
    String supply = v.trim();
    if (supply.isEmpty) {
      return;
    }

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(seconds: 1), () {
      _updateReceiveAmount(double.parse(supply));
    });
  }

  Future<void> _onRadioChange(int value) async {
    if (value == 1) {
      final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
      final pool = widget.plugin.store.homa.stakingPoolInfo;
      if (pool.freeList.length == 0) return;

      if (pool.freeList.length > 1) {
        await showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 58,
              scrollController: FixedExtentScrollController(
                initialItem: _eraSelected,
              ),
              children: pool.freeList.map((i) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Era ${i.era}, ${dic['homa.redeem.free']} ${Fmt.priceFloor(i.free)}',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onSelectedItemChanged: (v) {
                setState(() {
                  _eraSelected = v;
                });
              },
            ),
          ),
        );
      }
    }
    setState(() {
      _radioSelect = value;
    });
    if (_amountPayCtrl.text.isNotEmpty) {
      _updateReceiveAmount(double.parse(_amountPayCtrl.text.trim()));
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      final decimals = widget.plugin.networkState.tokenDecimals;
      final pay = _amountPayCtrl.text.trim();
      final receive = Fmt.priceFloor(
        double.parse(_amountReceiveCtrl.text),
        lengthMax: 4,
      );
      var strategy = TxHomaData.redeemTypeNow;
      if (_radioSelect == 2) {
        strategy = TxHomaData.redeemTypeWait;
      }
      int era = 0;
      final pool = widget.plugin.store.homa.stakingPoolInfo;
      if (pool.freeList.length > 0) {
        era = pool.freeList[_eraSelected].era;
      }
      final params = [
        Fmt.tokenInt(pay, decimals).toString(),
        _radioSelect == 1 ? {"Target": era} : strategy
      ];
      final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
          arguments: TxConfirmParams(
            module: 'homa',
            call: 'redeem',
            txTitle: I18n.of(context)
                .getDic(i18n_full_dic_acala, 'acala')['homa.redeem'],
            txDisplay: {
              "amountPay": pay,
              "amountReceive": receive,
              "strategy": _radioSelect == 1 ? 'Era $era' : strategy,
            },
            params: params,
          ))) as Map;
      if (res != null) {
        res['time'] = DateTime.now().millisecondsSinceEpoch;
        res['action'] = TxHomaData.actionRedeem;
        res['amountReceive'] = receive;
        res['params'] = params;
        widget.plugin.store.homa
            .addHomaTx(res, widget.keyring.current.pubKey, decimals);
        Navigator.of(context).pushNamed(HomaHistoryPage.route);
      }
    }
  }

  @override
  void dispose() {
    _amountPayCtrl.dispose();
    _amountReceiveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
        final dicAssets =
            I18n.of(context).getDic(i18n_full_dic_acala, 'common');
        final decimals = widget.plugin.networkState.tokenDecimals;

        final balance = Fmt.balanceInt(
            widget.plugin.store.assets.tokenBalanceMap['LDOT'].amount);

        final pool = widget.plugin.store.homa.stakingPoolInfo;

        final availableNow = pool.communalTotal *
            pool.communalFreeRatio *
            pool.liquidExchangeRate;
        double available = 0;
        String eraSelectText = dic['homa.era'];
        String eraSelectTextTail = '';
        if (pool.freeList.length > 0) {
          final item = pool.freeList[_eraSelected];
          available = item.free * pool.liquidExchangeRate;
          eraSelectText += ': ${item.era}';
          eraSelectTextTail =
              '(≈ ${(item.era - pool.currentEra).toInt()}${dic['homa.redeem.day']}, ${dicAssets['amount.available']}: ${Fmt.priceFloor(pool.freeList[_eraSelected].free, lengthMax: 3)} DOT)';
        }

        final primary = Theme.of(context).primaryColor;
        final grey = Theme.of(context).unselectedWidgetColor;

        return Scaffold(
          appBar: AppBar(title: Text(dic['homa.redeem']), centerTitle: true),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CurrencyWithIcon(
                                    'LDOT',
                                    TokenIcon('LDOT', widget.plugin.tokenIcons),
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: dic['dex.pay'],
                                      labelText: dic['dex.pay'],
                                      suffix: GestureDetector(
                                        child: Icon(
                                          CupertinoIcons.clear_thick_circled,
                                          color:
                                              Theme.of(context).disabledColor,
                                          size: 18,
                                        ),
                                        onTap: () {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) =>
                                                  _amountPayCtrl.clear());
                                        },
                                      ),
                                    ),
                                    inputFormatters: [
                                      UI.decimalInputFormatter(decimals)
                                    ],
                                    controller: _amountPayCtrl,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (v) {
                                      double amt;
                                      try {
                                        amt = double.parse(v.trim());
                                        if (v.trim().isEmpty || amt == 0) {
                                          return dicAssets['amount.error'];
                                        }
                                      } catch (err) {
                                        return dicAssets['amount.error'];
                                      }
                                      if (amt >=
                                          Fmt.bigIntToDouble(
                                              balance, decimals)) {
                                        return dicAssets['amount.low'];
                                      }
                                      final input = double.parse(v.trim()) *
                                          pool.liquidExchangeRate;
                                      if (_radioSelect == 0 &&
                                          input > availableNow) {
                                        return dic['homa.pool.low'];
                                      }
                                      if (_radioSelect == 1 &&
                                          input > available) {
                                        return dic['homa.pool.low'];
                                      }
                                      return null;
                                    },
                                    onChanged: _onSupplyAmountChange,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${dicAssets['balance']}: ${Fmt.token(balance, decimals)} LDOT',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .unselectedWidgetColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 2, 8, 0),
                              child: Icon(
                                Icons.repeat,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CurrencyWithIcon(
                                    'DOT',
                                    TokenIcon('DOT', widget.plugin.tokenIcons),
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: dic['dex.receive'],
                                      suffix: Container(
                                        height: 16,
                                        width: 8,
                                      ),
                                    ),
                                    controller: _amountReceiveCtrl,
                                    readOnly: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  dic['dex.rate'],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .unselectedWidgetColor),
                                ),
                                Text(
                                    '1 LDOT = ${Fmt.priceFloor(pool.liquidExchangeRate, lengthMax: 3)} DOT'),
                              ],
                            ),
                            GestureDetector(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.history, color: primary),
                                    Text(
                                      dic['loan.txs'],
                                      style: TextStyle(
                                          color: primary, fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () => Navigator.of(context)
                                  .pushNamed(HomaHistoryPage.route),
                            ),
                          ])
                    ],
                  ),
                ),
                RoundedCard(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.fromLTRB(0, 8, 16, 8),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${dic['homa.redeem.fee']}:'),
                            Text('(≈ ${Fmt.doubleFormat(_fee)} DOT)'),
                          ],
                        ),
                      ),
                      Divider(height: 4),
                      GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: 0,
                              groupValue: _radioSelect,
                              onChanged: (v) => _onRadioChange(v),
                            ),
                            Expanded(
                              child: Text(dic['homa.now']),
                            ),
                            Text(
                              '(${dic['homa.redeem.free']}: ${Fmt.priceFloor(availableNow)} DOT)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        onTap: () => _onRadioChange(0),
                      ),
                      GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: 1,
                              groupValue: _radioSelect,
                              onChanged: (v) => _onRadioChange(v),
                            ),
                            Expanded(
                              child: Text(
                                eraSelectText,
                                style: pool.freeList.length == 0
                                    ? TextStyle(color: grey)
                                    : null,
                              ),
                            ),
                            Text(
                              eraSelectTextTail,
                              style: pool.freeList.length == 0
                                  ? TextStyle(color: grey)
                                  : null,
                            ),
                          ],
                        ),
                        onTap: () => _onRadioChange(1),
                      ),
                      GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: 2,
                              groupValue: _radioSelect,
                              onChanged: (v) => _onRadioChange(v),
                            ),
                            Expanded(
                              child: Text(dic['homa.unbond']),
                            ),
                            Text(
                              '(${pool.bondingDuration.toInt() + 1} Era ≈ ${(pool.unbondingDuration / 1000 ~/ SECONDS_OF_DAY) + 1} ${dic['homa.redeem.day']})',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        onTap: () => _onRadioChange(2),
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
