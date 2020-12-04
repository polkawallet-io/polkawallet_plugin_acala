import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/utils/format.dart';

class LoanInfoPanel extends StatelessWidget {
  LoanInfoPanel({
    this.price,
    this.liquidationRatio,
    this.requiredRatio,
    this.currentRatio,
    this.liquidationPrice,
    this.decimals,
  });
  final BigInt price;
  final BigInt liquidationRatio;
  final BigInt requiredRatio;
  final double currentRatio;
  final BigInt liquidationPrice;
  final int decimals;
  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
    final priceString = Fmt.token(price, decimals);
    final liquidationPriceString = Fmt.token(liquidationPrice, decimals);
    return Column(
      children: <Widget>[
        InfoItemRow(
          dic['collateral.price'],
          '\$$priceString',
        ),
//        LoanInfoItem(
//          dic['liquid.ratio'],
//          Fmt.ratio(
//            double.parse(
//              Fmt.token(liquidationRatio, decimals),
//            ),
//          ),
//        ),
        InfoItemRow(
          dic['liquid.ratio.require'],
          Fmt.ratio(
            double.parse(
              Fmt.token(requiredRatio, decimals),
            ),
          ),
        ),
        InfoItemRow(
          dic['liquid.ratio.current'],
          Fmt.ratio(currentRatio),
          colorPrimary: true,
        ),
        InfoItemRow(
          dic['liquid.price'],
          '\$$liquidationPriceString',
          colorPrimary: true,
        ),
      ],
    );
  }
}
