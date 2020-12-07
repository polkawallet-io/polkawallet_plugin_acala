import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanAdjustPage.dart';
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

class LoanCreatePage extends StatefulWidget {
  LoanCreatePage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/loan/create';

  @override
  _LoanCreatePageState createState() => _LoanCreatePageState();
}

class _LoanCreatePageState extends State<LoanCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _amountCtrl2 = new TextEditingController();

  BigInt _amountCollateral = BigInt.zero;
  BigInt _amountDebit = BigInt.zero;

  BigInt _maxToBorrow = BigInt.zero;
  double _currentRatio = 0;
  BigInt _liquidationPrice = BigInt.zero;

  bool _autoValidate = false;

  void _updateState(LoanType loanType, BigInt collateral, BigInt debit) {
    final decimals = widget.plugin.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    final tokenPrice = widget.plugin.store.loan.prices[params.token];
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

  void _onAmount1Change(
    String value,
    LoanType loanType,
    BigInt price,
    stableCoinPrice,
    int decimals,
  ) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt collateral = Fmt.tokenInt(v, decimals);
    setState(() {
      _amountCollateral = collateral;
      _maxToBorrow = loanType.calcMaxToBorrow(
          collateral, price, stableCoinPrice, decimals);
    });
    print(_maxToBorrow.toString());

    if (_amountDebit > BigInt.zero) {
      _updateState(loanType, collateral, _amountDebit);
    }

    _checkAutoValidate();
  }

  void _onAmount2Change(String value, LoanType loanType, int decimals) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt debits = Fmt.tokenInt(v, decimals);

    setState(() {
      _amountDebit = debits;
    });

    if (_amountCollateral > BigInt.zero) {
      _updateState(loanType, _amountCollateral, debits);
    }

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
    if (value1.isNotEmpty && value2.isNotEmpty) {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String _validateAmount1(String value, BigInt available, int decimals) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) == 0) {
        return dic['amount.error'];
      }
    } catch (err) {
      return dic['amount.error'];
    }
    BigInt collateral = Fmt.tokenInt(v, decimals);
    if (collateral > available) {
      return dic['amount.low'];
    }
    return null;
  }

  String _validateAmount2(String value, max, int decimals) {
    final assetDic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) < 1) {
        return assetDic['amount.error'];
      }
    } catch (err) {
      return assetDic['amount.error'];
    }
    BigInt debits = Fmt.tokenInt(v, decimals);
    if (debits >= _maxToBorrow) {
      return '${dic['loan.max']} $max';
    }
    return null;
  }

  Map _getTxParams(LoanType loanType, int decimals) {
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    BigInt debitShare = loanType.debitToDebitShare(_amountDebit, decimals);
    return {
      'detail': {
        "colleterals": Fmt.token(_amountCollateral, decimals),
        "debits": Fmt.token(_amountDebit, decimals),
      },
      'params': [
        {'Token': params.token},
        _amountCollateral.toString(),
        debitShare.toString(),
      ]
    };
  }

  Future<void> _onSubmit(
      String pageTitle, LoanType loanType, int decimals) async {
    final params = _getTxParams(loanType, decimals);
    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'honzon',
          call: 'adjustLoan',
          txTitle: pageTitle,
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
  void dispose() {
    _amountCtrl.dispose();
    _amountCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
    final assetDic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');
    final decimals = widget.plugin.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    String symbol = params.token;

    String pageTitle = '${dic['loan.create']} $symbol';

    final price = widget.plugin.store.loan.prices[symbol];
    final stableCoinPrice = Fmt.tokenInt('1', decimals);

    final loanType =
        widget.plugin.store.loan.loanTypes.firstWhere((i) => i.token == symbol);
    final balance = Fmt.balanceInt(
        widget.plugin.store.loan.tokenBalanceMap[symbol]?.amount);
    final available = balance;

    final balanceView = Fmt.token(available, decimals);
    final maxToBorrow = Fmt.token(_maxToBorrow, decimals);

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
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      LoanInfoPanel(
                        price: price,
                        liquidationRatio: loanType.liquidationRatio,
                        requiredRatio: loanType.requiredCollateralRatio,
                        currentRatio: _currentRatio,
                        liquidationPrice: _liquidationPrice,
                        decimals: decimals,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(dic['loan.amount.collateral']),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: assetDic['amount'],
                          labelText:
                              '${assetDic['amount']} (${assetDic['amount.available']}: $balanceView $symbol)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                            _validateAmount1(v, available, decimals),
                        onChanged: (v) => _onAmount1Change(
                            v, loanType, price, stableCoinPrice, decimals),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(dic['loan.amount.debit']),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: assetDic['amount'],
                          labelText:
                              '${assetDic['amount']}(${dic['loan.max']}: $maxToBorrow)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)],
                        controller: _amountCtrl2,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                            _validateAmount2(v, maxToBorrow, decimals),
                        onChanged: (v) =>
                            _onAmount2Change(v, loanType, decimals),
                      ),
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
                      _onSubmit(pageTitle, loanType, decimals);
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
