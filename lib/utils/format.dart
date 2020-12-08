import 'package:polkawallet_plugin_acala/common/constants.dart';

class PluginFmt {
  static String tokenView(String token) {
    String tokenView = token ?? '';
    if (token == acala_stable_coin) {
      tokenView = acala_stable_coin_view;
    }
    if (token == acala_token_ren_btc) {
      tokenView = acala_token_ren_btc_view;
    }
    if (token.contains('-')) {
      tokenView =
          '${token.split('-').map((e) => PluginFmt.tokenView(e)).join('-')} LP';
    }
    return tokenView;
  }
}
