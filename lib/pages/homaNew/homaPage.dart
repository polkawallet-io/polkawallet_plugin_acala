import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/pages/homa/homaHistoryPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/mintPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/redeemPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginIconButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:rive/rive.dart';

class HomaPage extends StatefulWidget {
  HomaPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/karura/homa';

  @override
  _HomaPageState createState() => _HomaPageState();
}

class _HomaPageState extends State<HomaPage> {
  Timer? _timer;
  String? _unlockingKsm;
  bool? _isHomaAlive = false;

  Future<void> _refreshRedeem() async {
    var data = await widget.plugin.api!.homa
        .redeemRequested(widget.keyring.current.address);
    if (!mounted) return;

    if (data != null && data.length > 0) {
      setState(() {
        _unlockingKsm = data;
      });
    } else if (_unlockingKsm != null) {
      setState(() {
        _unlockingKsm = null;
      });
    }
  }

  Future<void> _refreshData() async {
    widget.plugin.service!.assets.queryMarketPrices([relay_chain_token_symbol]);
    widget.plugin.service!.gov.updateBestNumber();

    if (_isHomaAlive!) {
      await widget.plugin.service!.homa.queryHomaEnv();
      widget.plugin.service!.homa.queryHomaPendingRedeem();
    } else {
      await widget.plugin.service!.homa.queryHomaLiteStakingPool();
      _refreshRedeem();
    }

    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 20), (timer) {
        _refreshData();
      });
    }
  }

  void _onCancelRedeem() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;
        return CupertinoAlertDialog(
          title: Text(dic['homa.confirm']!),
          content: Text(dic['homa.redeem.hint']!),
          actions: <Widget>[
            CupertinoButton(
              child: Text(
                dic['homa.redeem.cancel']!,
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(dic['homa.confirm']!),
              onPressed: () {
                Navigator.of(context).pop();
                _onSubmit();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSubmit() async {
    var params = [0, 0];
    var module = 'homaLite';
    var call = 'requestRedeem';
    var txDisplay = {};
    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: module,
          call: call,
          txTitle:
              "${I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!['homa.redeem.cancel']}${I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!['homa.redeem']}$relay_chain_token_symbol",
          txDisplay: txDisplay,
          params: params,
        ))) as Map?;

    if (res != null) {
      _refreshRedeem();
    }
  }

  Future<void> _claimRedeem(BuildContext context, num claimable) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;
    final res = await Navigator.of(context).pushNamed(
      TxConfirmPage.route,
      arguments: TxConfirmParams(
        module: 'homa',
        call: 'claimRedemption',
        txTitle: '${dic['homa.claim']} $relay_chain_token_symbol',
        txDisplay: {},
        txDisplayBold: {
          dic['loan.amount']!: Text(
            '${Fmt.priceFloor(claimable as double?, lengthMax: 4)} $relay_chain_token_symbol',
            style: Theme.of(context).textTheme.headline1,
          ),
        },
        params: [widget.keyring.current.address],
      ),
    );
    if (res != null) {
      _refreshData();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final isHomaAlive = await widget.plugin.api!.homa.isHomaAlive();
      setState(() {
        _isHomaAlive = isHomaAlive;
      });

      _refreshData();
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(builder: (BuildContext context) {
      final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;
      final stakeSymbol = relay_chain_token_symbol;

      final env = widget.plugin.store!.homa.env;
      final balances = AssetsUtils.getBalancePairFromTokenNameId(
          widget.plugin, [stakeSymbol, 'L$stakeSymbol']);
      final balanceStakeToken =
          Fmt.balanceDouble(balances[0]!.amount!, balances[0]!.decimals!);
      final balanceLiquidToken =
          Fmt.balanceDouble(balances[1]!.amount!, balances[1]!.decimals!);
      double unbonding = 0;
      (widget.plugin.store?.homa.userInfo?.unbondings ?? []).forEach((e) {
        unbonding += e['amount'];
      });
      final claimable =
          (widget.plugin.store?.homa.userInfo?.claimable ?? 0).toDouble();

      final paddingHorizontal = 16.0;
      final riveTop = 22.0;
      final riveWidget =
          MediaQuery.of(context).size.width - paddingHorizontal * 2;
      final riveHeight = riveWidget / 360 * 292;

      final aprValue =
          "${Fmt.priceFloor(env?.apy ?? 0 * 100, lengthFixed: 0)}%";
      final aprStyle = Theme.of(context).textTheme.headline4?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 0.9,
          color: Colors.white);

      return PluginScaffold(
        appBar: PluginAppBar(
          title: Text('${dic['homa.title']} $stakeSymbol'),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              child: PluginIconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(HomaHistoryPage.route),
                icon: Icon(
                  Icons.history,
                  size: 22,
                  color: Color(0xFF17161F),
                ),
              ),
            )
          ],
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: double.infinity,
                            height: riveHeight,
                            margin: EdgeInsets.only(top: riveTop),
                            child: RiveAnimation.asset(
                              'packages/polkawallet_plugin_karura/assets/images/new_file.riv',
                              animations: const [
                                'Animation 1',
                                'Animation 2',
                                'Animation 3',
                                'Animation 4'
                              ],
                            )),
                        Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage(
                                    'packages/polkawallet_plugin_karura/assets/images/homa_left_bg.png'),
                              )),
                              padding:
                                  EdgeInsets.only(left: 45, right: 15, top: 2),
                              child: Text(
                                  '1 L$stakeSymbol ≈ ${Fmt.priceFloor(env?.exchangeRate, lengthMax: 4)} $stakeSymbol',
                                  style: Theme.of(context)
                                      .appBarTheme
                                      .titleTextStyle
                                      ?.copyWith(
                                          fontSize: 14, color: Colors.white)),
                            ))
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 28,
                          alignment: Alignment.center,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "${dic['v3.total']!} L$stakeSymbol",
                            style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle
                                ?.copyWith(
                                    fontSize: 16, color: Color(0xFF292929)),
                          ),
                        ),
                        Container(
                          height: 28,
                          alignment: Alignment.center,
                          color: Color(0x33FFFFFF),
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            '${Fmt.priceFloor(env?.totalLiquidity, lengthMax: 4)}',
                            style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle
                                ?.copyWith(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        Container(
                          color: Color(0xFFFC8156),
                          height: 28,
                          width: 3,
                          margin: EdgeInsets.symmetric(horizontal: 3),
                        ),
                        Container(
                            color: Color(0x7fFC8156), height: 28, width: 3)
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          margin: EdgeInsets.only(
                              top: riveTop + riveHeight * 0.17,
                              right: paddingHorizontal +
                                  riveWidget * 0.195 -
                                  PluginFmt.boundingTextSize(
                                              aprValue, aprStyle!)
                                          .width /
                                      2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'APR',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    ?.copyWith(color: Colors.white),
                              ),
                              Text(
                                aprValue,
                                style: aprStyle,
                              )
                            ],
                          )),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin:
                            EdgeInsets.only(top: riveTop + riveHeight * 0.65),
                        width: riveWidget * 0.34,
                        height: riveWidget * 0.34 / 236 * 176,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                              'packages/polkawallet_plugin_karura/assets/images/homa_total_staked_bg.png'),
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              color: Color(0xFFFC8156),
                              child: Text(
                                dic['v3.totalStaked']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    ?.copyWith(
                                        color: Color(0xFF252629),
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.fromLTRB(5, 4, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${Fmt.priceFloor(env?.totalStaking, lengthMax: 4)} KSM',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          '≈ \$${Fmt.priceFloorFormatter((widget.plugin.store?.assets.marketPrices[stakeSymbol] ?? 0) * (env?.totalStaking ?? 0), lengthMax: 2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              ?.copyWith(color: Colors.white),
                                        ))
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(top: riveTop + riveHeight + 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 108,
                              height: 30,
                              padding: EdgeInsets.only(left: 5, top: 3),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage(
                                    'packages/polkawallet_plugin_karura/assets/images/homa_my_stats_bg.png'),
                              )),
                              child: Text(
                                dic['v3.myStats']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    ?.copyWith(
                                        color: Color(0xFF212123),
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  left: 11, top: 16, bottom: 20),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 127,
                                        height: 61,
                                        padding:
                                            EdgeInsets.only(left: 10, top: 6),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          image: AssetImage(
                                              'packages/polkawallet_plugin_karura/assets/images/homa_myStats_item_bg.png'),
                                        )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "L$stakeSymbol:",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            Text(
                                              Fmt.priceFloor(balanceLiquidToken,
                                                  lengthMax: 4),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 127,
                                        height: 61,
                                        padding:
                                            EdgeInsets.only(left: 10, top: 6),
                                        margin: EdgeInsets.only(top: 15),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          image: AssetImage(
                                              'packages/polkawallet_plugin_karura/assets/images/homa_myStats_item_bg.png'),
                                        )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dic['v3.unnonding']!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            Text(
                                              Fmt.priceFloor(unbonding,
                                                  lengthMax: 4),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 127,
                                        height: 61,
                                        padding:
                                            EdgeInsets.only(left: 10, top: 6),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          image: AssetImage(
                                              'packages/polkawallet_plugin_karura/assets/images/homa_myStats_item_bg.png'),
                                        )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$stakeSymbol:",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            Text(
                                              Fmt.priceFloor(balanceStakeToken,
                                                  lengthMax: 4),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            if (claimable > 0) {
                                              _claimRedeem(context, claimable);
                                            }
                                          },
                                          child: Container(
                                            width: 127,
                                            height: 61,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 6),
                                            margin: EdgeInsets.only(top: 15),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              image: AssetImage(
                                                  'packages/polkawallet_plugin_karura/assets/images/homa_myStats${claimable > 0 ? '_select' : ''}_item_bg.png'),
                                            )),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dic['v3.claim']!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4
                                                      ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                                Text(
                                                  Fmt.priceFloor(claimable,
                                                      lengthMax: 4),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4
                                                      ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                )
                                              ],
                                            ),
                                          ))
                                    ],
                                  ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ))),
                Container(
                    margin: EdgeInsets.only(bottom: 34),
                    child: Row(
                      children: [
                        Expanded(
                            child: PluginButton(
                          title: '${dic['homa.redeem']} $stakeSymbol',
                          onPressed: () => Navigator.of(context)
                              .pushNamed(RedeemPage.route, arguments: {
                            "isHomaAlive": _isHomaAlive
                          }).then((value) {
                            if (value != null) {
                              _refreshData();
                            }
                          }),
                        )),
                        Container(
                          width: 16,
                        ),
                        Expanded(
                            child: PluginButton(
                          title: '${dic['homa.mint']} L$stakeSymbol',
                          backgroundColor: (env?.totalStaking ?? 0) <
                                  (env?.stakingSoftCap ?? 1)
                              ? null
                              : Color(0x54FFFFFF),
                          onPressed: (env?.totalStaking ?? 0) <
                                  (env?.stakingSoftCap ?? 1)
                              ? () async {
                                  // if (!(await _confirmMint())) return;

                                  Navigator.of(context)
                                      .pushNamed(MintPage.route, arguments: {
                                    "isHomaAlive": _isHomaAlive
                                  }).then((value) {
                                    if (value != null) {
                                      _refreshData();
                                    }
                                  });
                                }
                              : null,
                        ))
                      ],
                    ))
              ],
            )),
      );
    });
  }
}