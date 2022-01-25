import 'package:polkawallet_plugin_acala/api/acalaApi.dart';
import 'package:polkawallet_plugin_acala/api/types/homaNewEnvData.dart';
import 'package:polkawallet_plugin_acala/api/types/homaPendingRedeemData.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/store/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ServiceHoma {
  ServiceHoma(this.plugin, this.keyring)
      : api = plugin.api,
        store = plugin.store;

  final PluginAcala plugin;
  final Keyring keyring;
  final AcalaApi? api;
  final PluginStore? store;

  Future<HomaNewEnvData> queryHomaEnv() async {
    final res = await api!.homa.queryHomaNewEnv();
    store!.homa.setHomaEnv(res);
    return res;
  }

  Future<HomaPendingRedeemData> queryHomaPendingRedeem() async {
    final res = await api!.homa.queryHomaPendingRedeem(keyring.current.address);
    store!.homa.setUserInfo(res);
    return res;
  }
}
