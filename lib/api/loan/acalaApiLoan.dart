import 'package:polkawallet_plugin_acala/api/loan/acalaServiceLoan.dart';
import 'package:polkawallet_plugin_acala/api/types/loanType.dart';

class AcalaApiLoan {
  AcalaApiLoan(this.service);

  final AcalaServiceLoan service;

  Future<List> queryAccountLoans(String address) async {
    final List res = await service.queryAccountLoans(address);
    return res;
  }

  Future<List<LoanType>> queryLoanTypes() async {
    final List res = await service.queryLoanTypes();
    return res
        .map((e) => LoanType.fromJson(Map<String, dynamic>.of(e)))
        .toList();
  }
}
