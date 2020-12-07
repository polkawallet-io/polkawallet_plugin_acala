import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/pages/currencySelectPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanAdjustPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanCard.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanChart.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanCreatePage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanHistoryPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/utils/format.dart';

class LoanPage extends StatefulWidget {
  LoanPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/loan';

  @override
  _LoanPageState createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  String _tab = 'DOT';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.plugin.service.loan
          .subscribeAccountLoans(widget.keyring.current.address);
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.plugin.service.loan.unsubscribeAccountLoans();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
    return Observer(
      builder: (_) {
        final loan = widget.plugin.store.loan.loans[_tab];

        final decimals = widget.plugin.networkState.tokenDecimals;
        var aUSDBalance = BigInt.zero;
        final aUSDBalanceIndex = widget.plugin.balances.tokens
            .indexWhere((e) => e.symbol == acala_stable_coin);
        if (aUSDBalanceIndex >= 0) {
          aUSDBalance = Fmt.balanceInt(
              widget.plugin.balances.tokens[aUSDBalanceIndex].amount);
        }

        // final aUSDBalance = Fmt.priceFloorBigInt(
        //   Fmt.balanceInt(
        //       widget.plugin.balances.tokens..tokenBalances[acala_stable_coin]),
        //   decimals,
        // );

        final Color cardColor = Theme.of(context).cardColor;
        final Color primaryColor = Theme.of(context).primaryColor;
        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: AppBar(
            title: Text(dic['loan.title']),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.history, color: cardColor),
                onPressed: () => Navigator.of(context)
                    .pushNamed(LoanHistoryPage.route, arguments: loan.type),
              )
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                CurrencySelector(
                  tokenOptions: widget.plugin.store.loan.loanTypes
                      .map((e) => e.token)
                      .toList(),
                  tokenIcons: widget.plugin.tokenIcons,
                  token: _tab,
                  decimals: decimals,
                  price: widget.plugin.store.loan.prices[_tab],
                  onSelect: (res) {
                    if (res != null) {
                      setState(() {
                        _tab = res;
                      });
                    }
                  },
                ),
                Expanded(
                  child: loan != null
                      ? ListView(
                          children: <Widget>[
                            loan.collaterals > BigInt.zero
                                ? LoanCard(
                                    loan,
                                    Fmt.priceFloorBigInt(aUSDBalance, decimals),
                                    decimals)
                                : RoundedCard(
                                    margin: EdgeInsets.all(16),
                                    padding:
                                        EdgeInsets.fromLTRB(48, 24, 48, 24),
                                    child: SvgPicture.asset(
                                        'packages/polkawallet_plugin_acala/assets/images/loan-start.svg'),
                                  ),
                            loan.debitInUSD > BigInt.zero
                                ? LoanChart(loan, decimals)
//                                    ? LoanDonutChart(loan)
                                : Container()
                          ],
                        )
                      : Container(),
                ),
                widget.plugin.store.loan.loanTypes.length > 0
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: Colors.blue,
                              child: FlatButton(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Text(
                                    dic['loan.borrow'],
                                    style: TextStyle(color: cardColor),
                                  ),
                                  onPressed: () {
                                    if (loan != null &&
                                        loan.collaterals > BigInt.zero) {
                                      Navigator.of(context).pushNamed(
                                        LoanAdjustPage.route,
                                        arguments: LoanAdjustPageParams(
                                            LoanAdjustPage.actionTypeBorrow,
                                            _tab),
                                      );
                                    } else {
                                      Navigator.of(context).pushNamed(
                                        LoanCreatePage.route,
                                        arguments:
                                            LoanAdjustPageParams('', _tab),
                                      );
                                    }
                                  }),
                            ),
                          ),
                          loan != null && loan.debitInUSD > BigInt.zero
                              ? Expanded(
                                  child: Container(
                                    color: primaryColor,
                                    child: FlatButton(
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 16),
                                      child: Text(
                                        dic['loan.payback'],
                                        style: TextStyle(color: cardColor),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pushNamed(
                                        LoanAdjustPage.route,
                                        arguments: LoanAdjustPageParams(
                                            LoanAdjustPage.actionTypePayback,
                                            _tab),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrencySelector extends StatelessWidget {
  CurrencySelector({
    this.tokenOptions,
    this.tokenIcons,
    this.token,
    this.decimals,
    this.price,
    this.onSelect,
  });
  final List<String> tokenOptions;
  final Map<String, Widget> tokenIcons;
  final String token;
  final int decimals;
  final BigInt price;
  final Function(String) onSelect;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16.0, // has the effect of softening the shadow
            spreadRadius: 4.0, // has the effect of extending the shadow
            offset: Offset(
              2.0, // horizontal, move right 10
              2.0, // vertical, move down 10
            ),
          )
        ],
      ),
      child: ListTile(
        leading: SizedBox(child: tokenIcons[token], width: 32),
        title: Text(
          token,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        subtitle: price != null
            ? Text(
                '\$${Fmt.token(price, decimals)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              )
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () async {
          final res = await Navigator.of(context).pushNamed(
            CurrencySelectPage.route,
            arguments: tokenOptions,
          );
          if (res != null) {
            onSelect(res);
          }
        },
      ),
    );
  }
}
