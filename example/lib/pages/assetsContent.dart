import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class AssetsContent extends StatefulWidget {
  AssetsContent(
    this.network,
    this.keyring,
  );
  final PolkawalletPlugin network;
  final Keyring keyring;
  @override
  _AssetsContentState createState() => _AssetsContentState();
}

class _AssetsContentState extends State<AssetsContent> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final symbol = widget.network.networkState.tokenSymbol ?? '';
        final decimals = widget.network.networkState.tokenDecimals ?? 12;

        final balancesInfo = widget.network.balances.native;
        final tokens = widget.network.balances.tokens;
        // final extraTokens = widget.service.plugin.balances.extraTokens;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    RoundedCard(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('address'),
                          Text(widget.keyring.current.address)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: BorderedTitle(
                        title: 'Assets',
                      ),
                    ),
                    RoundedCard(
                      margin: EdgeInsets.only(top: 16),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          child: CircleAvatar(
                            child: Text(symbol),
                          ),
                        ),
                        title: Text(symbol),
                        trailing: Text(
                          Fmt.priceFloorBigInt(
                              balancesInfo != null
                                  ? Fmt.balanceTotal(balancesInfo)
                                  : BigInt.zero,
                              decimals,
                              lengthFixed: 3),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        // onTap: () {
                        //   Navigator.pushNamed(context, AssetPage.route);
                        // },
                      ),
                    ),
                    Column(
                      children: tokens == null || tokens.length == 0
                          ? [Container()]
                          : tokens.map((i) {
                              return RoundedCard(
                                margin: EdgeInsets.only(top: 16),
                                child: ListTile(
                                  leading: Container(
                                    width: 36,
                                    child: CircleAvatar(
                                      child: Text(i.symbol.substring(0, 2)),
                                    ),
                                  ),
                                  title: Text(i.symbol),
                                  trailing: Text(
                                    Fmt.priceFloorBigInt(
                                        Fmt.balanceInt(i.amount), decimals,
                                        lengthFixed: 3),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black54),
                                  ),
                                  onTap: () {
                                    // Navigator.pushNamed(
                                    //     context, AssetPage.route,
                                    //     arguments: TokenData(
                                    //         tokenType: TokenType.Token,
                                    //         id: token));
                                  },
                                ),
                              );
                            }).toList(),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 32),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Observer(
  //     builder: (_) {
  //       return ListView(
  //         padding: EdgeInsets.all(16),
  //         children: [
  //           Text('assets content',
  //               style: Theme.of(context).textTheme.headline4),
  //           Divider(),
  //           RoundedCard(
  //             padding: EdgeInsets.only(top: 40, bottom: 40),
  //             child: Column(
  //               children: [
  //                 Text(
  //                     'decimals: ${widget.network.networkState.tokenDecimals}'),
  //                 Text('symbol: ${widget.network.networkState.tokenSymbol}'),
  //                 Text(
  //                     'free balance: ${widget.network.balances.native?.freeBalance}'),
  //                 Text(
  //                     'available balance: ${widget.network.balances.native?.availableBalance}')
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
