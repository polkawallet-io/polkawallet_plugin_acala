import 'package:polkawallet_plugin_acala/api/acalaService.dart';
import 'package:polkawallet_plugin_acala/api/assets/acalaApiAssets.dart';
import 'package:polkawallet_plugin_acala/api/earn/acalaApiEarn.dart';
import 'package:polkawallet_plugin_acala/api/homa/acalaApiHoma.dart';
import 'package:polkawallet_plugin_acala/api/loan/acalaApiLoan.dart';
import 'package:polkawallet_plugin_acala/api/swap/acalaApiSwap.dart';

class AcalaApi {
  AcalaApi(AcalaService service)
      : assets = AcalaApiAssets(service.assets),
        loan = AcalaApiLoan(service.loan),
        swap = AcalaApiSwap(service.swap),
        homa = AcalaApiHoma(service.homa),
        earn = AcalaApiEarn(service.earn);

  final AcalaApiAssets assets;
  final AcalaApiLoan loan;
  final AcalaApiSwap swap;
  final AcalaApiHoma homa;
  final AcalaApiEarn earn;
}
