import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/api/types/transferData.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/txDetail.dart';
import 'package:polkawallet_ui/utils/format.dart';

class TransferDetailPage extends StatelessWidget {
  TransferDetailPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static final String route = '/assets/token/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_acala, 'common');

    final TransferData tx = ModalRoute.of(context).settings.arguments;

    final String txType =
        tx.from == keyring.current.address ? dic['transfer'] : dic['receive'];

    String networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName.split('-')[0]}-testnet';
    }
    return TxDetail(
      current: keyring.current,
      success: tx.isSuccess,
      action: txType,
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime: Fmt.dateTime(DateTime.parse(tx.timestamp)),
      networkName: networkName,
      infoItems: <TxDetailInfoItem>[
        TxDetailInfoItem(
          label: dic['amount'],
          content: Text(
            '${tx.from == keyring.current.address ? '-' : '+'}${tx.amount} ${PluginFmt.tokenView(tx.token)}',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        TxDetailInfoItem(
          label: 'From',
          content: Text(Fmt.address(tx.from)),
          copyText: tx.from,
        ),
        TxDetailInfoItem(
          label: 'To',
          content: Text(Fmt.address(tx.to)),
          copyText: tx.to,
        )
      ],
    );
  }
}
