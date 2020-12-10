import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/tapTooltip.dart';

class NFTPage extends StatelessWidget {
  NFTPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/nft';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFTs'), centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final list = plugin.store.assets.nft;
            return ListView.builder(
              itemCount: list.length + 1,
              padding: EdgeInsets.all(16),
              itemBuilder: (_, i) {
                if (i == list.length) {
                  return ListTail(isLoading: false, isEmpty: list.length == 0);
                }
                return RoundedCard(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Column(
                      children: [
                        Image.network(list[i].externalUrl),
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Text(
                                  list[i].name,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ),
                              TapTooltip(
                                message: '\n${list[i].description}\n',
                                child: Icon(
                                  Icons.info,
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
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
