import 'package:polkawallet_plugin_acala/api/assets/acalaServiceAssets.dart';
import 'package:polkawallet_plugin_acala/api/homa/acalaServiceHoma.dart';
import 'package:polkawallet_plugin_acala/api/loan/acalaServiceLoan.dart';
import 'package:polkawallet_plugin_acala/api/swap/acalaServiceSwap.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaService {
  AcalaService(PluginAcala plugin)
      : assets = AcalaServiceAssets(plugin),
        loan = AcalaServiceLoan(plugin),
        swap = AcalaServiceSwap(plugin),
        homa = AcalaServiceHoma(plugin);

  final AcalaServiceAssets assets;
  final AcalaServiceLoan loan;
  final AcalaServiceSwap swap;
  final AcalaServiceHoma homa;
}
