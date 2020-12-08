import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/txLiquidityData.dart';
import 'package:polkawallet_plugin_acala/common/constants.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/utils/format.dart';

class EarnHistoryPage extends StatelessWidget {
  EarnHistoryPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/earn/txs';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['loan.txs']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final decimals = plugin.networkState.tokenDecimals;
            final symbol = plugin.networkState.tokenSymbol;
            final String poolId = ModalRoute.of(context).settings.arguments;
            final pair = poolId.split('-');
            final list = plugin.store.earn.txs.reversed.toList();
            list.retainWhere((i) => i.currencyId == poolId);

            return ListView.builder(
              itemCount: list.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == list.length) {
                  return ListTail(isEmpty: list.length == 0, isLoading: false);
                }

                TxDexLiquidityData detail = list[i];
                String amount = '';
                String image = 'assets/images/assets_down.png';
                switch (detail.action) {
                  case TxDexLiquidityData.actionDeposit:
                    amount =
                        '${Fmt.priceCeilBigInt(detail.amountToken, decimals)} ${pair[0]}\n+ ${Fmt.priceCeilBigInt(detail.amountStableCoin, decimals)} ${pair[1]}';
                    image = 'assets/images/assets_up.png';
                    break;
                  case TxDexLiquidityData.actionWithdraw:
                    amount =
                        '${Fmt.priceFloorBigInt(detail.amountShare, decimals, lengthFixed: 0)} ${PluginFmt.tokenView(poolId)}';
                    break;
                  case TxDexLiquidityData.actionRewardIncentive:
                    amount =
                        '${Fmt.priceCeilBigInt(detail.amountToken, decimals)} $symbol';
                    break;
                  case TxDexLiquidityData.actionRewardSaving:
                    amount =
                        '${Fmt.priceCeilBigInt(detail.amountStableCoin, decimals)} $acala_stable_coin_view';
                    break;
                  case TxDexLiquidityData.actionStake:
                    amount =
                        '${Fmt.priceCeilBigInt(detail.amountShare, decimals)} ${PluginFmt.tokenView(poolId)}';
                    image = 'assets/images/assets_up.png';
                    break;
                  case TxDexLiquidityData.actionUnStake:
                    amount =
                        '${Fmt.priceCeilBigInt(detail.amountShare, decimals)} ${PluginFmt.tokenView(poolId)}';
                    break;
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12)),
                  ),
                  child: ListTile(
                    title: Text(detail.action),
                    subtitle: Text(list[i].time.toString().split('.')[0]),
                    trailing: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text(
                                amount,
                                style: Theme.of(context).textTheme.headline4,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          Image.asset(
                            'packages/polkawallet_plugin_acala/$image',
                            width: 16,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
