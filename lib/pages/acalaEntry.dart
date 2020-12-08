import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_plugin_acala/pages/earn/earnPage.dart';
import 'package:polkawallet_plugin_acala/pages/homa/homaPage.dart';
import 'package:polkawallet_plugin_acala/pages/loan/loanPage.dart';
import 'package:polkawallet_plugin_acala/pages/swap/swapPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/service/walletApi.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/entryPageCard.dart';

class AcalaEntry extends StatelessWidget {
  AcalaEntry(this.plugin, this.keyring);

  final PluginAcala plugin;
  final Keyring keyring;

  Future<void> _fetchLiveModules() async {
    final res = await WalletApi.getLiveModules();
    if (res != null) {
      print(res);
      plugin.store.setting.setLiveModules(res);
    }
  }

  final _liveModuleRoutes = {
    // 'nft': NFTPage.route,
  };

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_acala, 'common');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    dic['acala'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (plugin.sdk.api.connectedNode == null) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 2),
                      child: Column(
                        children: [
                          CupertinoActivityIndicator(),
                          Text(dic['node.connecting']),
                        ],
                      ),
                    );
                  }
                  final List liveModules =
                      plugin.store.setting.liveModules['acala'];
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['loan.title'],
                            dic['loan.brief'],
                            SvgPicture.asset(
                              'packages/polkawallet_plugin_acala/assets/images/loan.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(LoanPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['dex.title'],
                            dic['dex.brief'],
                            SvgPicture.asset(
                              'packages/polkawallet_plugin_acala/assets/images/exchange.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(SwapPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['earn.title'],
                            dic['earn.brief'],
                            SvgPicture.asset(
                              'packages/polkawallet_plugin_acala/assets/images/deposit.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(EarnPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['homa.title'],
                            dic['homa.brief'],
                            SvgPicture.asset(
                              'packages/polkawallet_plugin_acala/assets/images/swap.svg',
                              height: 56,
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(HomaPage.route),
                        ),
                      ),
                      liveModules != null
                          ? Column(
                              children: liveModules.map((e) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    child: EntryPageCard(
                                      dic['$e.title'],
                                      dic['$e.brief'],
                                      SvgPicture.asset(
                                        'packages/polkawallet_plugin_acala/assets/images/$e.svg',
                                        color: Colors.white,
                                        height: 56,
                                      ),
                                    ),
                                    // onTap: () => Navigator.of(context)
                                    //     .pushNamed(_liveModuleRoutes[e]),
                                  ),
                                );
                              }).toList(),
                            )
                          : Container()
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
