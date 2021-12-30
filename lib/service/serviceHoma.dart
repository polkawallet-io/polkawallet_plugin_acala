import 'package:polkawallet_plugin_acala/api/acalaApi.dart';
import 'package:polkawallet_plugin_acala/api/types/stakingPoolInfoData.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/store/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ServiceHoma {
  ServiceHoma(this.plugin, this.keyring)
      : api = plugin.api,
        store = plugin.store;

  final PluginAcala plugin;
  final Keyring keyring;
  final AcalaApi api;
  final PluginStore store;

  Future<HomaLitePoolInfoData> queryHomaLiteStakingPool() async {
    final res = await api.homa.queryHomaLiteStakingPool();
    store.homa.setHomaLitePoolInfoData(res);
    return res;
  }
}
