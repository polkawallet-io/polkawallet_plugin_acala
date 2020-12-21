import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/api/types/txHomaData.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/utils/format.dart';

class HomaHistoryPage extends StatelessWidget {
  HomaHistoryPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/homa/txs';

  @override
  Widget build(BuildContext context) {
    final list = plugin.store.homa.txs.reversed.toList();
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

            final detail = list[i];

            String amountPay = detail.amountPay ?? '0';
            String amountReceive = detail.amountReceive ?? '0';
            if (detail.action == TxHomaData.actionRedeem) {
              amountPay += ' LDOT';
              amountReceive += ' DOT';
            } else {
              amountPay += ' DOT';
              amountReceive += ' LDOT';
            }
            return Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 0.5, color: Colors.black12)),
              ),
              child: ListTile(
                title: Text('${list[i].action} $amountReceive'),
                subtitle: Text(Fmt.dateTime(list[i].time)),
                trailing: Container(
                  width: 140,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            amountPay,
                            style: Theme.of(context).textTheme.headline4,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      Image.asset(
                        'packages/polkawallet_plugin_acala/assets/images/assets_up.png',
                        width: 16,
                      )
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
