import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_plugin_acala/pages/currencySelectPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/components/addressInputField.dart';
import 'package:polkawallet_ui/components/currencyWithIcon.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/scanPage.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class TransferPage extends StatefulWidget {
  TransferPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static final String route = '/assets/token/transfer';

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  KeyPairData _accountTo;
  String _token = 'AUSD';

  Future<void> _onScan() async {
    final to = await Navigator.of(context).pushNamed(ScanPage.route);
    if (to == null) return;
    final acc = KeyPairData();
    acc.address = (to as QRCodeResult).address.address;
    acc.name = (to as QRCodeResult).address.name;
    final icon =
        await widget.plugin.sdk.api.account.getAddressIcons([acc.address]);
    if (icon != null && icon[0] != null) {
      acc.icon = icon[0][1];
    }
    setState(() {
      _accountTo = acc;
    });
    print(_accountTo.address);
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      final decimals = widget.plugin.networkState.tokenDecimals;
      final params = [
        // params.to
        _accountTo.address,
        // params.currencyId
        _token.contains('-')
            ? {'DEXShare': _token.toUpperCase().split('-')}
            : {'Token': _token.toUpperCase()},
        // params.amount
        Fmt.tokenInt(_amountCtrl.text.trim(), decimals).toString(),
      ];
      final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
          arguments: TxConfirmParams(
            module: 'currencies',
            call: 'transfer',
            txTitle:
                '${I18n.of(context).getDic(i18n_full_dic_acala, 'acala')['transfer']} $_token',
            txDisplay: {
              "destination": _accountTo.address,
              "currency": _token,
              "amount": _amountCtrl.text.trim(),
            },
            params: params,
          ))) as Map;
      if (res != null) {
        res['params'] = params;
        res['time'] = DateTime.now().millisecondsSinceEpoch;

        widget.plugin.store.assets.addTx(res, widget.keyring.current);
        Navigator.of(context).pop(res);
      }
    }
  }

  Future<void> _initAccountTo(String address) async {
    final acc = KeyPairData();
    acc.address = address;
    setState(() {
      _accountTo = acc;
    });
    final icon = await widget.plugin.sdk.api.account.getAddressIcons([address]);
    if (icon != null) {
      final accWithIcon = KeyPairData();
      accWithIcon.address = address;
      accWithIcon.icon = icon[0][1];
      setState(() {
        _accountTo = accWithIcon;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String token = ModalRoute.of(context).settings.arguments;
      setState(() {
        _token = token;
      });

      if (widget.keyring.allWithContacts.length > 0) {
        _initAccountTo(widget.keyring.allWithContacts[0].address);
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');
        final decimals = widget.plugin.networkState.tokenDecimals;

        final available = Fmt.balanceInt(widget
            .plugin.store.assets.tokenBalanceMap[_token.toUpperCase()].amount);

        return Scaffold(
          appBar: AppBar(
            title: Text(dic['transfer']),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  'packages/polkawallet_plugin_acala/assets/images/scan.svg',
                  color: Theme.of(context).cardColor,
                  width: 20,
                ),
                onPressed: _onScan,
              )
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: <Widget>[
                        AddressInputField(
                          widget.plugin.sdk.api,
                          widget.keyring.allAccounts,
                          label: dic['address'],
                          initialValue: _accountTo,
                          onChanged: (KeyPairData acc) {
                            setState(() {
                              _accountTo = acc;
                            });
                          },
                          key: ValueKey<KeyPairData>(_accountTo),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: dic['amount'],
                            labelText:
                                '${dic['amount']} (${dic['balance']}: ${Fmt.priceFloorBigInt(
                              available,
                              decimals,
                              lengthMax: 6,
                            )})',
                          ),
                          inputFormatters: [UI.decimalInputFormatter(decimals)],
                          controller: _amountCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v.isEmpty) {
                              return dic['amount.error'];
                            }
                            if (double.parse(v.trim()) >=
                                available / BigInt.from(pow(10, decimals)) -
                                    0.001) {
                              return dic['amount.low'];
                            }
                            return null;
                          },
                        ),
                        Container(
                          color: Theme.of(context).canvasColor,
                          margin: EdgeInsets.only(top: 16, bottom: 16),
                          child: GestureDetector(
                            child: Container(
                              color: Theme.of(context).canvasColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        dic['currency'],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .unselectedWidgetColor),
                                      ),
                                      CurrencyWithIcon(
                                        _token,
                                        TokenIcon(
                                            _token, widget.plugin.tokenIcons),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                  )
                                ],
                              ),
                            ),
                            onTap: () async {
                              final tokens = widget
                                  .plugin.store.assets.tokenBalanceMap.keys
                                  .toList();
                              final token = await Navigator.of(context)
                                  .pushNamed(CurrencySelectPage.route,
                                      arguments: tokens);
                              if (token != null) {
                                setState(() {
                                  _token = token;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: RoundedButton(
                    text: dic['make'],
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
