import 'dart:convert';

import 'package:http/http.dart';

class WalletApi {
  static const String _endpoint = 'https://api.polkawallet.io';

  static Future<Map> getLiveModules() async {
    try {
      Response res = await get('$_endpoint/liveModules.json');
      if (res == null) {
        return null;
      } else {
        return jsonDecode(res.body) as Map;
      }
    } catch (err) {
      print(err);
      return null;
    }
  }

  static Future<String> fetchAcalaFaucet(
      String address, String deviceId) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    String body = jsonEncode({
      "address": address,
      "account": deviceId,
    });
    try {
      Response res = await post('$_endpoint/v2/faucet/faucet',
          headers: headers, body: body);
      if (res.statusCode == 200) {
        try {
          final body = jsonDecode(res.body);
          if (body['code'] == 200) {
            return 'success';
          }
          return body['message'];
        } catch (_) {
          return null;
        }
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }
}
