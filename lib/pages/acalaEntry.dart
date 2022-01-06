import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:polkawallet_plugin_acala/pages/earn/earnPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/homaPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/pages/nft/nftPage.dart';
import 'package:polkawallet_plugin_acala/pages/swap/swapPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

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
                        .headline1
                        .copyWith(fontSize: 36, color: Colors.white),
                  ),
                  Text(
                    "The acala DeFi hub will be\nlaunched in Q1 2022",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
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
