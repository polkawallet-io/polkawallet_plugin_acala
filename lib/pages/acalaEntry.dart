import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/pages/earn/earnPage.dart';
import 'package:polkawallet_plugin_acala/pages/gov/democracyPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/homaPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/pages/nft/nftPage.dart';
import 'package:polkawallet_plugin_acala/pages/swap/swapPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/SkaletonList.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginItemCard.dart';

class AcalaEntry extends StatefulWidget {
  AcalaEntry(this.plugin, this.keyring);

  final PluginAcala plugin;
  final Keyring keyring;

  @override
  _AcalaEntryState createState() => _AcalaEntryState();
}

class _AcalaEntryState extends State<AcalaEntry> {
  final _liveModuleRoutes = {
    'loan': LoanPage.route,
    'swap': SwapPage.route,
    'earn': EarnPage.route,
    'homa': HomaPage.route,
    'nft': NFTPage.route,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            "packages/polkawallet_plugin_acala/assets/images/acala_entry_bg.png",
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Image.asset(
              "packages/polkawallet_plugin_acala/assets/images/acala_entry_3.png"),
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.4),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: ClipRect(
                      child: Align(
                          widthFactor: 0.8,
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                              "packages/polkawallet_plugin_acala/assets/images/acala_entry_1.png"))))),
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.25),
              child: ClipRect(
                  child: Align(
                      widthFactor: 0.85,
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                          "packages/polkawallet_plugin_acala/assets/images/acala_entry_2.png")))),
          Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.12),
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Under Construction",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 36, color: Colors.white),
                  ),
                  Text(
                    "The acala DeFi hub will be\nlaunched in Q1 2022",
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(fontSize: 23, color: Colors.white),
                  )
                ],
              ))
        ],
      ),
    );
    // final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');
    // final dicGov = I18n.of(context).getDic(i18n_full_dic_acala, 'gov');

    // return Scaffold(
    //   backgroundColor: Colors.transparent,
    //   body: SafeArea(
    //     child: Column(
    //       children: <Widget>[
    //         Padding(
    //           padding: EdgeInsets.all(16),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               Text(
    //                 dic['acala'],
    //                 style: TextStyle(
    //                   fontSize: 20,
    //                   color: Theme.of(context).cardColor,
    //                   fontWeight: FontWeight.w500,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Expanded(
    //           child: Observer(
    //             builder: (_) {
    //               if (widget.plugin.sdk.api?.connectedNode == null) {
    //                 return Column(children: [
    //                   Container(
    //                     height: 68,
    //                     margin: EdgeInsets.only(bottom: 16),
    //                     child: SvgPicture.asset(
    //                         'packages/polkawallet_plugin_acala/assets/images/logo_kar_empty.svg',
    //                         color: Colors.white70),
    //                   ),
    //                   Expanded(
    //                       child: SkaletonList(
    //                     items: _liveModuleRoutes.length,
    //                   ))
    //                 ]);
    //                 // return Container(
    //                 //   padding: EdgeInsets.only(
    //                 //       top: MediaQuery.of(context).size.width / 2),
    //                 //   child: Column(
    //                 //     children: [
    //                 //       CupertinoActivityIndicator(),
    //                 //       Text(dic['node.connecting']),
    //                 //     ],
    //                 //   ),
    //                 // );
    //               }
    //               final modulesConfig = widget.plugin.store.setting.liveModules;
    //               final List liveModules =
    //                   modulesConfig.keys.toList().sublist(1);

    //               liveModules?.retainWhere((e) => modulesConfig[e]['visible']);

    //               return ListView(
    //                 padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
    //                 children: <Widget>[
    //                   Container(
    //                     height: 68,
    //                     margin: EdgeInsets.only(bottom: 16),
    //                     child: SvgPicture.asset(
    //                         'packages/polkawallet_plugin_acala/assets/images/logo_kar_empty.svg',
    //                         color: Colors.white70),
    //                   ),
    //                   ...liveModules.map((e) {
    //                     final enabled = modulesConfig[e]['enabled'];
    //                     return Padding(
    //                       padding: EdgeInsets.only(bottom: 16),
    //                       child: GestureDetector(
    //                         child: EntryPageCard(
    //                           dic['$e.title'],
    //                           dic['$e.brief'],
    //                           SvgPicture.asset(
    //                             module_icons_uri[e],
    //                             height: 88,
    //                           ),
    //                           color: Colors.transparent,
    //                         ),
    //                         onTap: () {
    //                           if (enabled) {
    //                             Navigator.of(context).pushNamed(
    //                                 _liveModuleRoutes[e],
    //                                 arguments: enabled);
    //                           } else {
    //                             showCupertinoDialog(
    //                               context: context,
    //                               builder: (context) {
    //                                 return CupertinoAlertDialog(
    //                                   title: Text(dic['upgrading']),
    //                                   content: Text(dic['upgrading.context']),
    //                                   actions: <Widget>[
    //                                     CupertinoDialogAction(
    //                                       child: Text(dic['upgrading.btn']),
    //                                       onPressed: () {
    //                                         Navigator.of(context).pop();
    //                                       },
    //                                     ),
    //                                   ],
    //                                 );
    //                               },
    //                             );
    //                           }
    //                         },
    //                       ),
    //                     );
    //                   }).toList(),
    //                   Padding(
    //                     padding: EdgeInsets.only(bottom: 16),
    //                     child: GestureDetector(
    //                       child: EntryPageCard(
    //                         dicGov['democracy'],
    //                         dicGov['democracy.brief'],
    //                         SvgPicture.asset(
    //                           'packages/polkawallet_plugin_acala/assets/images/democracy.svg',
    //                           height: 88,
    //                           color: Theme.of(context).primaryColor,
    //                         ),
    //                         color: Colors.transparent,
    //                       ),
    //                       onTap: () => Navigator.of(context)
    //                           .pushNamed(DemocracyPage.route),
    //                     ),
    //                   ),
    //                 ],
    //               );
    //             },
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}

class DefiWidget extends StatefulWidget {
  DefiWidget(this.plugin);

  final PluginAcala plugin;

  @override
  _DefiWidgetState createState() => _DefiWidgetState();
}

class _DefiWidgetState extends State<DefiWidget> {
  final _liveModuleRoutes = {
    'loan': LoanPage.route,
    'swap': SwapPage.route,
    'earn': EarnPage.route,
    'homa': HomaPage.route,
  };

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');
    final modulesConfig = widget.plugin.store!.setting.liveModules;
    final List liveModules = modulesConfig.keys.toList().sublist(1);

    liveModules.retainWhere((e) => modulesConfig[e]['visible'] && e != 'nft');
    return Observer(builder: (_) {
      // if (widget.plugin.sdk.api.connectedNode == null) {
      //   return SkaletonList(
      //     padding: EdgeInsets.zero,
      //     shrinkWrap: true,
      //     physics: NeverScrollableScrollPhysics(),
      //     items: _liveModuleRoutes.length,
      //     itemMargin: EdgeInsets.only(bottom: 16),
      //     child: Container(
      //       padding: EdgeInsets.fromLTRB(9, 6, 6, 11),
      //       child: Column(
      //         children: <Widget>[
      //           Row(
      //             children: [
      //               Container(
      //                 width: 50,
      //                 height: 18,
      //                 color: Colors.white,
      //               ),
      //               SizedBox(width: 6),
      //               Container(
      //                   width: 18,
      //                   height: 18,
      //                   padding: EdgeInsets.all(2),
      //                   decoration: BoxDecoration(
      //                     borderRadius:
      //                         const BorderRadius.all(const Radius.circular(5)),
      //                     color: Colors.white,
      //                   ))
      //             ],
      //           ),
      //           SizedBox(height: 7),
      //           Container(
      //             width: double.infinity,
      //             height: 11,
      //             color: Colors.white,
      //           ),
      //           SizedBox(height: 3),
      //           Container(
      //             width: double.infinity,
      //             height: 11,
      //             color: Colors.white,
      //           ),
      //         ],
      //       ),
      //     ),
      //   );
      // }
      return Container(
        child: Column(
          children: liveModules.map((e) {
            final enabled = modulesConfig[e]['enabled'];
            return GestureDetector(
              child: PluginItemCard(
                margin: EdgeInsets.only(bottom: 16),
                title: dic!['$e.title']!,
                describe: dic['$e.brief'],
                icon: Image.asset(
                    "packages/polkawallet_plugin_karura/assets/images/icon_$e.png",
                    width: 18),
              ),
              onTap: () {
                if (enabled) {
                  Navigator.of(context)
                      .pushNamed(_liveModuleRoutes[e]!, arguments: enabled);
                } else {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text(dic['upgrading']!),
                        content: Text(dic['upgrading.context']!),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text(dic['upgrading.btn']!),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          }).toList(),
        ),
      );
    });
  }
}

class NFTWidget extends StatefulWidget {
  NFTWidget(this.plugin);

  final PluginAcala plugin;

  @override
  _NFTWidgetState createState() => _NFTWidgetState();
}

class _NFTWidgetState extends State<NFTWidget> {
  final _liveModuleRoutes = {
    'nft': NFTPage.route,
  };

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');
    final modulesConfig = widget.plugin.store!.setting.liveModules;
    final List liveModules = modulesConfig.keys.toList().sublist(1);

    liveModules.retainWhere((e) => modulesConfig[e]['visible'] && e == 'nft');
    return Observer(builder: (_) {
      if (widget.plugin.sdk.api.connectedNode == null) {
        return SkaletonList(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          items: _liveModuleRoutes.length,
          itemMargin: EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(9, 6, 6, 11),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Container(
                        width: 18,
                        height: 18,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(const Radius.circular(5)),
                          color: Colors.white,
                        ))
                  ],
                ),
                SizedBox(height: 7),
                Container(
                  width: double.infinity,
                  height: 11,
                  color: Colors.white,
                ),
                SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  height: 11,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      }
      return Container(
        child: Column(
          children: liveModules.map((e) {
            final enabled = modulesConfig[e]['enabled'];
            return GestureDetector(
              child: PluginItemCard(
                margin: EdgeInsets.only(bottom: 16),
                title: dic!['$e.title']!,
                describe: dic['$e.brief'],
              ),
              onTap: () {
                if (enabled) {
                  Navigator.of(context)
                      .pushNamed(_liveModuleRoutes[e]!, arguments: enabled);
                } else {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text(dic['upgrading']!),
                        content: Text(dic['upgrading.context']!),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text(dic['upgrading.btn']!),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          }).toList(),
        ),
      );
    });
  }
}

class GovernanceWidget extends StatefulWidget {
  GovernanceWidget(this.plugin);
  final PluginAcala plugin;

  @override
  _GovernanceWidgetState createState() => _GovernanceWidgetState();
}

class _GovernanceWidgetState extends State<GovernanceWidget> {
  @override
  Widget build(BuildContext context) {
    final dicGov = I18n.of(context)!.getDic(i18n_full_dic_acala, 'gov');

    return Observer(builder: (_) {
      if (widget.plugin.sdk.api.connectedNode == null) {
        return SkaletonList(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          items: 1,
          itemMargin: EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(9, 6, 6, 11),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Container(
                        width: 18,
                        height: 18,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(const Radius.circular(5)),
                          color: Colors.white,
                        ))
                  ],
                ),
                SizedBox(height: 7),
                Container(
                  width: double.infinity,
                  height: 11,
                  color: Colors.white,
                ),
                SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  height: 11,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      }
      return Container(
        child: Column(
          children: [
            GestureDetector(
              child: PluginItemCard(
                margin: EdgeInsets.only(bottom: 16),
                title: dicGov!['democracy']!,
                describe: dicGov['democracy.brief'],
                icon: Image.asset(
                    "packages/polkawallet_plugin_karura/assets/images/icon_democracy.png",
                    width: 18),
              ),
              onTap: () => Navigator.of(context).pushNamed(DemocracyPage.route),
            ),
          ],
        ),
      );
    });
  }
}
