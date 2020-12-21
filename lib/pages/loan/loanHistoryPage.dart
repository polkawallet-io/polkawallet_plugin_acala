import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';
import 'package:polkawallet_plugin_acala/api/types/txLoanData.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/utils/format.dart';

class LoanHistoryPage extends StatelessWidget {
  LoanHistoryPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/loan/txs';

  @override
  Widget build(BuildContext context) {
    final int decimals = plugin.networkState.tokenDecimals;
    final list = plugin.store.loan.txs.reversed.toList();

    final LoanType loanType = ModalRoute.of(context).settings.arguments;
    list.retainWhere((i) => i.currencyId == loanType.token);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            I18n.of(context).getDic(i18n_full_dic_acala, 'acala')['loan.txs']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: list.length + 1,
          itemBuilder: (BuildContext context, int i) {
            if (i == list.length) {
              return ListTail(isEmpty: list.length == 0, isLoading: false);
            }

            TxLoanData detail = list[i];
            LoanType loanType = plugin.store.loan.loanTypes
                .firstWhere((i) => i.token == detail.currencyId);
            BigInt amountView = detail.amountCollateral;
            if (detail.currencyIdView.toUpperCase() == acala_stable_coin) {
              amountView =
                  loanType.debitShareToDebit(detail.amountDebitShare, decimals);
            } else {
              amountView = BigInt.zero - amountView;
            }
            String icon = 'assets_down.png';
            if (detail.actionType == TxLoanData.actionTypePayback ||
                detail.actionType == TxLoanData.actionTypeDeposit) {
              icon = 'assets_up.png';
            }
            return Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 0.5, color: Colors.black12)),
              ),
              child: ListTile(
                title: Text(list[i].actionType),
                subtitle: Text(Fmt.dateTime(list[i].time)),
                trailing: Container(
                  width: 140,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            '${Fmt.priceFloorBigInt(amountView, decimals)} ${detail.currencyIdView}',
                            style: Theme.of(context).textTheme.headline4,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      Image.asset(
                          'packages/polkawallet_plugin_acala/assets/images/$icon',
                          width: 16)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
