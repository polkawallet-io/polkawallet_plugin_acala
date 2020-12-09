import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanInfoPanel.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class LoanAdjustPage extends StatefulWidget {
  LoanAdjustPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/loan/adjust';
  static const String actionTypeBorrow = 'borrow';
  static const String actionTypePayback = 'payback';
  static const String actionTypeDeposit = 'deposit';
  static const String actionTypeWithdraw = 'withdraw';

  @override
  _LoanAdjustPageState createState() => _LoanAdjustPageState();
}

class LoanAdjustPageParams {
  LoanAdjustPageParams(this.actionType, this.token);
  final String actionType;
  final String token;
}

class _LoanAdjustPageState extends State<LoanAdjustPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _amountCtrl2 = new TextEditingController();

  BigInt _amountCollateral = BigInt.zero;
  BigInt _amountDebit = BigInt.zero;

  double _currentRatio = 0;
  BigInt _liquidationPrice = BigInt.zero;

  bool _autoValidate = false;
  bool _paybackAndCloseChecked = false;

  void _updateState(LoanType loanType, BigInt collateral, BigInt debit) {
    final decimals = widget.plugin.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    final tokenPrice = widget.plugin.store.assets.prices[params.token];
    final stableCoinPrice = Fmt.tokenInt('1', decimals);
    final collateralInUSD =
        loanType.tokenToUSD(collateral, tokenPrice, decimals);
    final debitInUSD = loanType.tokenToUSD(debit, stableCoinPrice, decimals);
    setState(() {
      _liquidationPrice = loanType.calcLiquidationPrice(
        debitInUSD,
        collateral,
      );
      _currentRatio = loanType.calcCollateralRatio(debitInUSD, collateralInUSD);
    });
  }

  Map _calcTotalAmount(BigInt collateral, BigInt debit) {
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    var collateralTotal = collateral;
    var debitTotal = debit;
    final loan = widget.plugin.store.loan.loans[params.token];
    switch (params.actionType) {
      case LoanAdjustPage.actionTypeDeposit:
        collateralTotal = loan.collaterals + collateral;
        break;
      case LoanAdjustPage.actionTypeWithdraw:
        collateralTotal = loan.collaterals - collateral;
        break;
      case LoanAdjustPage.actionTypeBorrow:
        debitTotal = loan.debits + debit;
        break;
      case LoanAdjustPage.actionTypePayback:
        debitTotal = loan.debits - debit;
        break;
      default:
      // do nothing
    }

    return {
      'collateral': collateralTotal,
      'debit': debitTotal,
    };
  }

  void _onAmount1Change(
    String value,
    LoanType loanType,
    BigInt price,
    BigInt stableCoinPrice,
    int decimals, {
    BigInt max,
  }) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt collateral = max != null ? max : Fmt.tokenInt(v, decimals);
    setState(() {
      _amountCollateral = collateral;
    });

    Map amountTotal = _calcTotalAmount(collateral, _amountDebit);
    _updateState(loanType, amountTotal['collateral'], amountTotal['debit']);

    _checkAutoValidate();
  }

  void _onAmount2Change(
    String value,
    LoanType loanType,
    BigInt stableCoinPrice,
    int decimals,
    bool showCheckbox, {
    BigInt debits,
  }) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt debitsNew = debits ?? Fmt.tokenInt(v, decimals);

    setState(() {
      _amountDebit = debitsNew;
    });
    if (!showCheckbox && _paybackAndCloseChecked) {
      setState(() {
        _paybackAndCloseChecked = false;
      });
    }

    Map amountTotal = _calcTotalAmount(_amountCollateral, debitsNew);
    _updateState(loanType, amountTotal['collateral'], amountTotal['debit']);

    _checkAutoValidate();
  }

  void _checkAutoValidate({String value1, String value2}) {
    if (_autoValidate) return;
    if (value1 == null) {
      value1 = _amountCtrl.text.trim();
    }
    if (value2 == null) {
      value2 = _amountCtrl2.text.trim();
    }
    if (value1.isNotEmpty || value2.isNotEmpty) {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String _validateAmount1(String value, BigInt available) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) == 0) {
        return dic['amount.error'];
      }
    } catch (err) {
      return dic['amount.error'];
    }
    if (_amountCollateral > available) {
      return dic['amount.low'];
    }
    return null;
  }

  String _validateAmount2(String value, BigInt max, String maxToBorrowView,
      BigInt balanceAUSD, LoanData loan, int decimals) {
    final assetDic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) == 0) {
        return assetDic['amount.error'];
      }
    } catch (err) {
      return assetDic['amount.error'];
    }
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    if (params.actionType == LoanAdjustPage.actionTypeBorrow &&
        _amountDebit > max) {
      return '${dic['loan.max']} $maxToBorrowView';
    }
    if (params.actionType == LoanAdjustPage.actionTypePayback) {
      if (_amountDebit > balanceAUSD) {
        String balance = Fmt.token(balanceAUSD, decimals);
        return '${assetDic['amount.low']}(${assetDic['balance']}: $balance)';
      }
      BigInt debitLeft = loan.debits - _amountDebit;
      if (debitLeft > BigInt.zero &&
          loan.type.debitToDebitShare(debitLeft, decimals) <
              loan.type.minimumDebitValue) {
        return dic['payback.small'];
      }
    }
    return null;
  }

  Future<bool> _confirmPaybackParams() async {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
    final bool res = await showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            content: Text(dic['loan.warn']),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(dic['loan.warn.back']),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: Text(I18n.of(context)
                    .getDic(i18n_full_dic_acala, 'common')['ok']),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          );
        });
    return res;
  }

  Future<Map> _getTxParams(LoanData loan) async {
    final decimals = widget.plugin.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    switch (params.actionType) {
      case LoanAdjustPage.actionTypeBorrow:
        BigInt debitAdd = loan.type.debitToDebitShare(_amountDebit, decimals);
        return {
          'detail': {
            "amount": _amountCtrl2.text.trim(),
          },
          'params': [
            {'Token': params.token},
            0,
            debitAdd.toString(),
          ]
        };
      case LoanAdjustPage.actionTypePayback:

        /// payback all debts if user input more than debts
        BigInt debitSubtract = _amountDebit >= loan.debits
            ? loan.debitShares
            : loan.type.debitToDebitShare(_amountDebit, decimals);

        /// pay less if less than 1 debit(aUSD) will be left,
        /// make sure tx success by leaving more than 1 debit(aUSD).
        final debitValueOne = Fmt.tokenInt('1', decimals);
        if (loan.debits - _amountDebit > BigInt.zero &&
            loan.debits - _amountDebit < debitValueOne) {
          final bool canContinue = await _confirmPaybackParams();
          if (!canContinue) return null;
          debitSubtract = loan.debitShares -
              loan.type.debitToDebitShare(debitValueOne, decimals);
        }
        return {
          'detail': {
            "amount": _amountCtrl2.text.trim(),
          },
          'params': [
            {'Token': params.token},
            _paybackAndCloseChecked
                ? (BigInt.zero - loan.collaterals).toString()
                : 0,
            (BigInt.zero - debitSubtract).toString(),
          ]
        };
      case LoanAdjustPage.actionTypeDeposit:
        return {
          'detail': {
            "amount": _amountCtrl.text.trim(),
          },
          'params': [
            {'Token': params.token},
            _amountCollateral.toString(),
            0,
          ]
        };
      case LoanAdjustPage.actionTypeWithdraw:

        /// withdraw all if user input near max
        BigInt amt =
            loan.collaterals - _amountCollateral > BigInt.parse('1000000000000')
                ? _amountCollateral
                : loan.collaterals;
        return {
          'detail': {
            "amount": _amountCtrl.text.trim(),
          },
          'params': [
            {'Token': params.token},
            (BigInt.zero - amt).toString(),
            0,
          ]
        };
      default:
        return {};
    }
  }

  Future<TxConfirmParams> _onSubmit(String title, LoanData loan) async {
    final params = await _getTxParams(loan);
    if (params == null) return null;

    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'honzon',
          call: 'adjustLoan',
          txTitle: title,
          txDisplay: params['detail'],
          params: params['params'],
        ))) as Map;
    if (res != null) {
      res['params'] = params['params'];
      res['time'] = DateTime.now().millisecondsSinceEpoch;

      widget.plugin.store.loan.addLoanTx(res, widget.keyring.current.pubKey);
      Navigator.of(context).pop(res);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LoanAdjustPageParams params =
          ModalRoute.of(context).settings.arguments;
      final loan = widget.plugin.store.loan.loans[params.token];
      setState(() {
        _amountCollateral = loan.collaterals;
        _amountDebit = loan.debits;
      });
      _updateState(loan.type, loan.collaterals, loan.debits);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
    var assetDic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');

    final decimals = widget.plugin.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    final symbol = params.token;
    final loan = widget.plugin.store.loan.loans[symbol];

    final price = widget.plugin.store.assets.prices[symbol];
    final stableCoinPrice = Fmt.tokenInt('1', decimals);

    String titleSuffix = ' $symbol';
    bool showCollateral = true;
    bool showDebit = true;

    BigInt balanceAUSD = Fmt.balanceInt(
        widget.plugin.store.assets.tokenBalanceMap[acala_stable_coin].amount);
    BigInt balance = Fmt.balanceInt(
        widget.plugin.store.assets.tokenBalanceMap[params.token].amount);
    BigInt available = balance;
    BigInt maxToBorrow = loan.maxToBorrow - loan.debits;
    String maxToBorrowView = Fmt.priceFloorBigInt(maxToBorrow, decimals);

    switch (params.actionType) {
      case LoanAdjustPage.actionTypeBorrow:
        maxToBorrow = Fmt.tokenInt(maxToBorrowView, decimals);
        showCollateral = false;
        titleSuffix = ' aUSD';
        break;
      case LoanAdjustPage.actionTypePayback:
        // max to payback
        maxToBorrow = loan.debits;
        maxToBorrowView = Fmt.priceCeilBigInt(maxToBorrow, decimals);
        showCollateral = false;
        titleSuffix = ' aUSD';
        break;
      case LoanAdjustPage.actionTypeDeposit:
        showDebit = false;
        break;
      case LoanAdjustPage.actionTypeWithdraw:
        available = loan.collaterals - loan.requiredCollateral;
        showDebit = false;
        break;
      default:
    }

    int maxCollateralDecimal =
        loan.debits > BigInt.zero ? 6 : acala_token_decimals;
    String availableView = Fmt.priceFloorBigInt(available, decimals,
        lengthMax: maxCollateralDecimal);

    String pageTitle = '${dic['loan.${params.actionType}']}$titleSuffix';

    bool showCheckbox = params.actionType == LoanAdjustPage.actionTypePayback &&
        _amountCtrl2.text.trim().isNotEmpty &&
        _amountDebit == loan.debits;

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: LoanInfoPanel(
                          price: price,
                          liquidationRatio: loan.type.liquidationRatio,
                          requiredRatio: loan.type.requiredCollateralRatio,
                          currentRatio: _currentRatio,
                          liquidationPrice: _liquidationPrice,
                          decimals: decimals,
                        ),
                      ),
                      showCollateral
                          ? Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: assetDic['amount'],
                                  labelText:
                                      '${assetDic['amount']} (${assetDic['amount.available']}: $availableView $symbol)',
                                  suffix: GestureDetector(
                                    child: Text(
                                      dic['loan.max'],
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        _amountCollateral = available;
                                        _amountCtrl.text = availableView;
                                      });
                                      _onAmount1Change(
                                        availableView,
                                        loan.type,
                                        price,
                                        stableCoinPrice,
                                        decimals,
                                        max: available,
                                      );
                                    },
                                  ),
                                ),
                                inputFormatters: [
                                  UI.decimalInputFormatter(decimals)
                                ],
                                controller: _amountCtrl,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) =>
                                    _validateAmount1(v, available),
                                onChanged: (v) => _onAmount1Change(
                                  v,
                                  loan.type,
                                  price,
                                  stableCoinPrice,
                                  decimals,
                                ),
                              ),
                            )
                          : Container(),
                      showDebit
                          ? Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: assetDic['amount'],
                                  labelText:
                                      '${assetDic['amount']}(${dic['loan.max']}: $maxToBorrowView)',
                                  suffix: GestureDetector(
                                    child: Text(
                                      dic['loan.max'],
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onTap: () async {
                                      double max = NumberFormat(",##0.00")
                                          .parse(maxToBorrowView);
                                      setState(() {
                                        _amountDebit = maxToBorrow;
                                        _amountCtrl2.text = max.toString();
                                      });
                                      _onAmount2Change(
                                        maxToBorrowView,
                                        loan.type,
                                        stableCoinPrice,
                                        decimals,
                                        showCheckbox,
                                        debits: maxToBorrow,
                                      );
                                    },
                                  ),
                                ),
                                inputFormatters: [
                                  UI.decimalInputFormatter(decimals)
                                ],
                                controller: _amountCtrl2,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) => _validateAmount2(
                                    v,
                                    maxToBorrow,
                                    maxToBorrowView,
                                    balanceAUSD,
                                    loan,
                                    decimals),
                                onChanged: (v) => _onAmount2Change(v, loan.type,
                                    stableCoinPrice, decimals, showCheckbox),
                              ),
                            )
                          : Container(),
                      showCheckbox
                          ? Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _paybackAndCloseChecked,
                                  onChanged: (v) {
                                    setState(() {
                                      _paybackAndCloseChecked = v;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Text(dic['loan.withdraw.all']),
                                  onTap: () {
                                    setState(() {
                                      _paybackAndCloseChecked =
                                          !_paybackAndCloseChecked;
                                    });
                                  },
                                )
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context)
                      .getDic(i18n_full_dic_ui, 'common')['tx.submit'],
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _onSubmit(pageTitle, loan);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
