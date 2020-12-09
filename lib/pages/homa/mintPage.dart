import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/txHomaData.dart';
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

class MintPage extends StatefulWidget {
  MintPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/homa/mint';

  @override
  _MintPageState createState() => _MintPageState();
}

class _MintPageState extends State<MintPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();

  Future<void> _updateReceiveAmount(double input) async {
    if (mounted) {
      double exchangeRate =
          1 / widget.plugin.store.homa.stakingPoolInfo.liquidExchangeRate;
      setState(() {
        _amountReceiveCtrl.text =
            Fmt.priceFloor(input * exchangeRate, lengthFixed: 3);
      });
    }
  }

  void _onSupplyAmountChange(String v) {
    String supply = v.trim();
    if (supply.isEmpty) {
      return;
    }
    _updateReceiveAmount(double.parse(supply));
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      final decimals = widget.plugin.networkState.tokenDecimals;
      final pay = _amountPayCtrl.text.trim();
      final receive = _amountReceiveCtrl.text.trim();

      final params = [
        Fmt.tokenInt(pay, decimals).toString(),
      ];
      final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
          arguments: TxConfirmParams(
            module: 'homa',
            call: 'mint',
            txTitle: I18n.of(context)
                .getDic(i18n_full_dic_acala, 'acala')['homa.mint'],
            txDisplay: {
              "amountPay": pay,
              "amountReceive": receive,
            },
            params: params,
          ))) as Map;
      if (res != null) {
        res['time'] = DateTime.now().millisecondsSinceEpoch;
        res['action'] = TxHomaData.actionMint;
        res['amountReceive'] = receive;
        res['params'] = params;
        widget.plugin.store.homa
            .addHomaTx(res, widget.keyring.current.pubKey, decimals);
        Navigator.of(context).pushNamed(HomaHistoryPage.route);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateReceiveAmount(0);
    });
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
            widget.plugin.store.assets.tokenBalanceMap['DOT'].amount);

        final pool = widget.plugin.store.homa.stakingPoolInfo;

        Color primary = Theme.of(context).primaryColor;

        return Scaffold(
          appBar: AppBar(title: Text(dic['homa.mint']), centerTitle: true),
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
                                    'DOT',
                                    TokenIcon('DOT', widget.plugin.tokenIcons),
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
                                      try {
                                        if (v.isEmpty || double.parse(v) == 0) {
                                          return dicAssets['amount.error'];
                                        }
                                      } catch (err) {
                                        return dicAssets['amount.error'];
                                      }
                                      if (double.parse(v.trim()) >=
                                          Fmt.bigIntToDouble(
                                              balance, decimals)) {
                                        return dicAssets['amount.low'];
                                      }
                                      return null;
                                    },
                                    onChanged: _onSupplyAmountChange,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${dicAssets['balance']}: ${Fmt.token(balance, decimals)} DOT',
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
                                children: <Widget>[
                                  CurrencyWithIcon(
                                    'LDOT',
                                    TokenIcon('LDOT', widget.plugin.tokenIcons),
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
                                    '1 DOT = ${Fmt.priceFloor(1 / pool.liquidExchangeRate, lengthMax: 3)} L-DOT'),
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
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: RoundedButton(
                    text: dic['homa.mint'],
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
