import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/transferData.dart';
import 'package:polkawallet_plugin_acala/pages/assets/transferPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/pages/accountQrCodePage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class TokenDetailPage extends StatelessWidget {
  TokenDetailPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static final String route = '/assets/token/detail';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');

    final decimals = plugin.networkState.tokenDecimals;
    final TokenBalanceData token = ModalRoute.of(context).settings.arguments;

    final primaryColor = Theme.of(context).primaryColor;
    final titleColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(token.name),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final balance = Fmt.balanceInt(
                plugin.store.assets.tokenBalanceMap[token.symbol]?.amount ??
                    '0');

            final txs = plugin.store.assets.txs.reversed.toList();
            txs.retainWhere((i) => i.token.toUpperCase() == token.symbol);
            return Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  color: primaryColor,
                  padding: EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      Fmt.token(balance, decimals, length: 8),
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: titleColor,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      BorderedTitle(
                        title: dic['loan.txs'],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: txs.length + 1,
                      itemBuilder: (_, i) {
                        if (i == txs.length) {
                          return ListTail(
                              isEmpty: txs.length == 0, isLoading: false);
                        }
                        return TransferListItem(
                          data: txs[i],
                          token: token.symbol,
                          isOut: true,
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: Colors.lightBlue,
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Image.asset(
                                  'packages/polkawallet_plugin_acala/assets/images/assets_send.png',
                                  width: 24,
                                ),
                              ),
                              Text(
                                dic['transfer'],
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              TransferPage.route,
                              arguments: token.symbol,
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.lightGreen,
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.qr_code,
                                  color: titleColor,
                                  size: 24,
                                ),
                              ),
                              Text(
                                dic['receive'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AccountQrCodePage.route);
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class TransferListItem extends StatelessWidget {
  TransferListItem({
    this.data,
    this.token,
    this.isOut,
    this.crossChain,
  });

  final TransferData data;
  final String token;
  final String crossChain;
  final bool isOut;

  @override
  Widget build(BuildContext context) {
    String address = isOut ? data.to : data.from;
    String title =
        Fmt.address(address) ?? data.extrinsicIndex ?? Fmt.address(data.hash);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
      ),
      child: ListTile(
        title: Text('$title${crossChain != null ? ' ($crossChain)' : ''}'),
        subtitle: Text(Fmt.dateTime(
            DateTime.fromMillisecondsSinceEpoch(data.blockTimestamp * 1000))),
        trailing: Container(
          width: 110,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  '${data.amount} ${PluginFmt.tokenView(token)}',
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.right,
                ),
              )),
              isOut
                  ? Image.asset(
                      'packages/polkawallet_plugin_acala/assets/images/assets_up.png',
                      width: 16,
                    )
                  : Image.asset(
                      'packages/polkawallet_plugin_acala/assets/images/assets_down.png',
                      width: 16,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
