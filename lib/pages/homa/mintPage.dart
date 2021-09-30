import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_karura/common/constants/index.dart';
import 'package:polkawallet_plugin_karura/pages/homa/homaHistoryPage.dart';
import 'package:polkawallet_plugin_karura/pages/swap/bootstrapPage.dart';
import 'package:polkawallet_plugin_karura/pages/swap/swapTokenInput.dart';
import 'package:polkawallet_plugin_karura/polkawallet_plugin_karura.dart';
import 'package:polkawallet_plugin_karura/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class MintPage extends StatefulWidget {
  MintPage(this.plugin, this.keyring);
  final PluginKarura plugin;
  final Keyring keyring;

  static const String route = '/karura/homa/mint';

  @override
  _MintPageState createState() => _MintPageState();
}

class _MintPageState extends State<MintPage> {
  final TextEditingController _amountPayCtrl = new TextEditingController();

  final _payFocusNode = FocusNode();

  String _error;
  String _amountReceive = '';
  BigInt _maxInput;

  Future<void> _updateReceiveAmount(double input) async {
    if (mounted) {
      final symbols = widget.plugin.networkState.tokenSymbol;
      final decimals = widget.plugin.networkState.tokenDecimals;

      final stakeToken = relay_chain_token_symbol;
      final stakeDecimal = decimals[symbols.indexOf(stakeToken)];
      final poolInfo = widget.plugin.store.homa.poolInfo;
      final mintFee = Fmt.balanceDouble(
          widget.plugin.networkConst['homaLite']['mintFee'].toString(),
          stakeDecimal);
      final maxRewardPerEra = int.parse(widget
              .plugin.networkConst['homaLite']['maxRewardPerEra']
              .toString()) /
          1000000; // type of maxRewardPerEra is PerMill
      final exchangeRate = poolInfo.staked > BigInt.zero
          ? (poolInfo.liquidTokenIssuance / poolInfo.staked)
          : Fmt.balanceDouble(
              widget.plugin.networkConst['homaLite']['defaultExchangeRate'],
              acala_price_decimals);
      final receive = (input - mintFee) * exchangeRate * (1 - maxRewardPerEra);

      setState(() {
        _amountReceive =
            Fmt.priceFloor(receive > 0 ? receive : 0, lengthFixed: 3);
      });
    }
  }

  void _onSupplyAmountChange(String v, double balance, double minStake) {
    final supply = v.trim();
    setState(() {
      _maxInput = null;
    });

    final error = _validateInput(supply, balance, minStake);
    setState(() {
      _error = error;
      if (error != null) {
        _amountReceive = '';
      }
    });
    if (error != null) {
      return;
    }
    _updateReceiveAmount(double.parse(supply));
  }

  String _validateInput(String supply, double balance, double minStake) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'common');
    String error;
    if (supply.isEmpty) {
      return dic['amount.error'];
    }
    try {
      final pay = double.parse(supply);
      if (_maxInput == null && pay > balance) {
        return dic['amount.low'];
      }

      if (pay <= minStake) {
        final minLabel = I18n.of(context)
            .getDic(i18n_full_dic_karura, 'acala')['homa.pool.min'];
        return '$minLabel > ${minStake.toStringAsFixed(4)}';
      }

      final symbols = widget.plugin.networkState.tokenSymbol;
      final decimals = widget.plugin.networkState.tokenDecimals;
      final stakeDecimal = decimals[symbols.indexOf(relay_chain_token_symbol)];
      final poolInfo = widget.plugin.store.homa.poolInfo;
      if (Fmt.tokenInt(supply, stakeDecimal) + poolInfo.staked > poolInfo.cap) {
        return I18n.of(context)
            .getDic(i18n_full_dic_karura, 'acala')['homa.pool.cap.error'];
      }
    } catch (err) {
      error = dic['amount.error'];
    }
    return error;
  }

  void _onSetMax(BigInt max, int decimals, double balance, double minStake) {
    final poolInfo = widget.plugin.store.homa.poolInfo;
    if (poolInfo.staked + max > poolInfo.cap) {
      max = poolInfo.cap - poolInfo.staked;
    }

    final amount = Fmt.bigIntToDouble(max, decimals);
    setState(() {
      _amountPayCtrl.text = amount.toStringAsFixed(6);
      _maxInput = max;
      _error = _validateInput(amount.toString(), balance, minStake);
    });

    _updateReceiveAmount(amount);
  }

  Future<void> _onSubmit(int stakeDecimal) async {
    final pay = _amountPayCtrl.text.trim();

    if (_error != null || pay.isEmpty) return;

    final params = [
      _maxInput != null
          ? _maxInput.toString()
          : Fmt.tokenInt(pay, stakeDecimal).toString()
    ];
    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'homaLite',
          call: 'mint',
          txTitle: I18n.of(context)
              .getDic(i18n_full_dic_karura, 'acala')['homa.mint'],
          txDisplay: {
            "amountPay": pay,
            "amountReceive": _amountReceive,
          },
          params: params,
        ))) as Map;

    if (res != null) {
      // res['time'] = DateTime.now().millisecondsSinceEpoch;
      // res['action'] = TxHomaData.actionMint;
      // res['amountPay'] = pay;
      // res['amountReceive'] = receive;
      // res['params'] = params;
      // widget.plugin.store.homa.addHomaTx(res, widget.keyring.current.pubKey);
      // Navigator.of(context).pushNamed(HomaHistoryPage.route);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _amountPayCtrl.dispose();
    _payFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'acala');

        final symbols = widget.plugin.networkState.tokenSymbol;
        final stakeToken = relay_chain_token_symbol;
        final decimals = widget.plugin.networkState.tokenDecimals;

        final karBalance = Fmt.balanceDouble(
            widget.plugin.balances.native.availableBalance.toString(),
            decimals[0]);
        final balanceData =
            widget.plugin.store.assets.tokenBalanceMap[stakeToken];

        final stakeDecimal = decimals[symbols.indexOf(stakeToken)];
        final balanceDouble =
            Fmt.balanceDouble(balanceData.amount, stakeDecimal);

        final minStake = Fmt.balanceDouble(
                widget.plugin.networkConst['homaLite']['minimumMintThreshold']
                    .toString(),
                stakeDecimal) +
            Fmt.balanceDouble(
                widget.plugin.networkConst['homaLite']['mintFee'].toString(),
                stakeDecimal);

        return Scaffold(
          appBar: AppBar(
            title: Text('${dic['homa.mint']} L$stakeToken'),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(HomaHistoryPage.route),
                  icon: Icon(Icons.history))
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SwapTokenInput(
                        title: dic['dex.pay'],
                        inputCtrl: _amountPayCtrl,
                        focusNode: _payFocusNode,
                        balance: widget
                            .plugin.store.assets.tokenBalanceMap[stakeToken],
                        tokenIconsMap: widget.plugin.tokenIcons,
                        onInputChange: (v) =>
                            _onSupplyAmountChange(v, balanceDouble, minStake),
                        onSetMax: karBalance > 0.1
                            ? (v) => _onSetMax(
                                v, stakeDecimal, balanceDouble, minStake)
                            : null,
                        onClear: () {
                          setState(() {
                            _amountPayCtrl.text = '';
                          });
                          _onSupplyAmountChange('', balanceDouble, minStake);
                        },
                      ),
                      ErrorMessage(_error),
                      _amountReceive.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.only(top: 16),
                              child: InfoItemRow(dic['dex.receive'],
                                  '$_amountReceive L$stakeToken'),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: RoundedButton(
                    text: dic['homa.mint'],
                    onPressed: () => _onSubmit(stakeDecimal),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
