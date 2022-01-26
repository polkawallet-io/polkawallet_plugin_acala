import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/pages/earn/earnPage.dart';
import 'package:polkawallet_plugin_acala/pages/gov/democracyPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/homaPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/pages/swap/swapPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginItemCard.dart';

class AcalaEntry extends StatelessWidget {
  AcalaEntry(this.plugin, this.keyring);

  final PluginAcala plugin;
  final Keyring keyring;

  static final route = '/acala/entry/temp';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acala'),
        centerTitle: true,
        leading: BackBtn(),
      ),
      body: Container(
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
              alignment: Alignment.topCenter,
              child: Text(
                "Under Construction",
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 36, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
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
    return Observer(builder: (_) {
      final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');
      final modulesConfig = widget.plugin.store!.setting.liveModules;
      List liveModules = [];
      if (modulesConfig.keys.length > 0) {
        liveModules = modulesConfig.keys.toList().sublist(1);
      }

      liveModules.retainWhere((e) => modulesConfig[e]['visible'] && e != 'nft');

      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
                  Navigator.of(context).pushNamed(_liveModuleRoutes[e]!);
                } else {
                  Navigator.of(context).pushNamed(AcalaEntry.route);
                  // showCupertinoDialog(
                  //   context: context,
                  //   builder: (context) {
                  //     return CupertinoAlertDialog(
                  //       title: Text(dic['upgrading']!),
                  //       content: Text(dic['upgrading.context']!),
                  //       actions: <Widget>[
                  //         CupertinoDialogAction(
                  //           child: Text(dic['upgrading.btn']!),
                  //           onPressed: () {
                  //             Navigator.of(context).pop();
                  //           },
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // );
                }
              },
            );
          }).toList(),
        ),
      );
    });
  }
}

class NFTWidget extends StatelessWidget {
  NFTWidget(this.plugin);

  final PluginAcala plugin;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');

    return Container(
      child: Column(
        children: [
          GestureDetector(
            child: PluginItemCard(
              margin: EdgeInsets.only(bottom: 16),
              title: dic!['nft.title']!,
              describe: dic['nft.brief'],
              icon: Image.asset(
                  "packages/polkawallet_plugin_karura/assets/images/icon_nft.png",
                  width: 18),
            ),
            onTap: () => Navigator.of(context).pushNamed(DemocracyPage.route),
          ),
        ],
      ),
    );
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
  }
}
