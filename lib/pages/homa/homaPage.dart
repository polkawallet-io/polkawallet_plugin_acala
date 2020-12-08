import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/api/types/txHomaData.dart';
import 'package:polkawallet_plugin_acala/pages/homa/mintPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/redeemPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItem.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class HomaPage extends StatefulWidget {
  HomaPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/homa';

  @override
  _HomaPageState createState() => _HomaPageState();
}

class _HomaPageState extends State<HomaPage> {
  Timer _timer;

  Future<void> _refreshData() async {
    await Future.wait([
      widget.plugin.service.homa.queryHomaStakingPool(),
      widget.plugin.service.homa
          .queryHomaUserInfo(widget.keyring.current.address),
    ]);

    _timer = Timer(Duration(seconds: 10), () {
      _refreshData();
    });
  }

  Future<void> _onSubmitWithdraw() async {
    final decimals = widget.plugin.networkState.tokenDecimals;
    final userInfo = widget.plugin.store.homa.userInfo;
    final String receive =
        Fmt.priceFloorBigInt(userInfo.unbonded, decimals, lengthMax: 3);

    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'homa',
          call: 'withdrawRedemption',
          txTitle: I18n.of(context)
              .getDic(i18n_full_dic_acala, 'acala')['homa.redeem'],
          txDisplay: {
            "amountReceive": receive,
          },
          params: [],
        ))) as Map;
    if (res != null) {
      res['time'] = DateTime.now().millisecondsSinceEpoch;
      res['action'] = TxHomaData.actionWithdrawRedemption;
      res['amountReceive'] = receive;
      widget.plugin.store.homa
          .addHomaTx(res, widget.keyring.current.pubKey, decimals);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'acala');
        final decimals = widget.plugin.networkState.tokenDecimals;

        final pool = widget.plugin.store.homa.stakingPoolInfo;
        final userInfo = widget.plugin.store.homa.userInfo;
        bool hasUserInfo = false;
        if (userInfo != null &&
            userInfo.unbonded != null &&
            (userInfo.unbonded > BigInt.zero || userInfo.claims.length > 0)) {
          hasUserInfo = true;
        }

        final primary = Theme.of(context).primaryColor;
        final white = Theme.of(context).cardColor;

        return Scaffold(
          appBar: AppBar(
            title: Text(dic['homa.title']),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [primary, white],
                              stops: [0.4, 0.9],
                            )),
                          ),
                          RoundedCard(
                            margin: EdgeInsets.all(16),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: <Widget>[
                                Text('DOT ${dic['homa.pool']}'),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    dic['homa.pool.total'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    Fmt.doubleFormat(pool.communalTotal ?? 0),
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    InfoItem(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      title: dic['homa.pool.bonded'],
                                      content: Fmt.doubleFormat(
                                        pool.communalBonded ?? 0,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24),
                                Row(
                                  children: <Widget>[
                                    InfoItem(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      title: dic['homa.pool.free'],
                                      content: Fmt.doubleFormat(
                                        (pool.communalTotal ?? 0) *
                                            (pool.communalFreeRatio ?? 0),
                                      ),
                                    ),
                                    InfoItem(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      title: dic['homa.pool.unbonding'],
                                      content: Fmt.doubleFormat(
                                        (pool.communalTotal ?? 0) *
                                            (pool.unbondingToFreeRatio ?? 0),
                                      ),
                                    ),
                                    InfoItem(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      title: dic['homa.pool.ratio'],
                                      content: Fmt.ratio(
                                        pool.communalBondedRatio ?? 0,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      hasUserInfo
                          ? RoundedCard(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Text(dic['homa.user']),
                                  ),
                                  userInfo.claims.length > 0
                                      ? Column(
                                          children: userInfo.claims.map((i) {
                                            String unlockTime =
                                                (i.era - (pool.currentEra ?? 0))
                                                    .toInt()
                                                    .toString();
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: <Widget>[
                                                  InfoItem(
                                                    title: I18n.of(context)
                                                        .getDic(
                                                            i18n_full_dic_acala,
                                                            'common')['amount'],
                                                    content:
                                                        Fmt.priceFloorBigInt(
                                                            i.claimed,
                                                            decimals),
                                                  ),
                                                  InfoItem(
                                                    title:
                                                        dic['homa.user.time'],
                                                    content:
                                                        '$unlockTime Era ≈ $unlockTime ${dic['homa.redeem.day']}',
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : Container(),
                                  userInfo.unbonded > BigInt.zero
                                      ? Divider(height: 24)
                                      : Container(),
                                  userInfo.unbonded > BigInt.zero
                                      ? Row(
                                          children: <Widget>[
                                            InfoItem(
                                              title:
                                                  dic['homa.user.redeemable'],
                                              content: Fmt.priceFloorBigInt(
                                                  userInfo.unbonded, decimals),
                                            ),
                                            OutlinedButtonSmall(
                                              margin: EdgeInsets.all(0),
                                              active: true,
                                              content: dic['homa.now'],
                                              onPressed: _onSubmitWithdraw,
                                            ),
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                pool.communalTotal != null
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: Colors.blue,
                              child: FlatButton(
                                padding: EdgeInsets.only(top: 16, bottom: 16),
                                child: Text(
                                  dic['homa.mint'],
                                  style: TextStyle(color: white),
                                ),
                                onPressed: pool.communalTotal != null
                                    ? () => Navigator.of(context)
                                        .pushNamed(MintPage.route)
                                    : null,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: primary,
                              child: FlatButton(
                                padding: EdgeInsets.only(top: 16, bottom: 16),
                                child: Text(
                                  dic['homa.redeem'],
                                  style: TextStyle(color: white),
                                ),
                                onPressed: pool.communalTotal != null
                                    ? () => Navigator.of(context)
                                        .pushNamed(HomaRedeemPage.route)
                                    : null,
                              ),
                            ),
                          ),
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
