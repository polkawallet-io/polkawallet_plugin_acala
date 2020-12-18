# polkawallet_plugin_acala

Acala network plugin for polkawallet.

## Usage

To install the package:
```yaml
  polkawallet_plugin_acala:
    git:
      url: https://github.com/polkawallet-io/polkawallet_plugin_acala.git
      ref: master
```

To start the plugin:
```dart
class _MyAppState extends State<MyApp> {

  /// The Keyring instance manages the local keyPairs
  /// with dart package `get_storage`
  final _keyring = Keyring();

  /// The PluginAcala instance connects remote node
  /// and provides APIs from acala.js
  PolkawalletPlugin _network = PluginAcala();

  Future<void> _startPlugin() async {
    /// Waiting for Keyring local storage initiate.
    await _keyring.init();

    /// Waiting for PluginAcala load js code
    /// and start a hidden webView to run `acala.js`.
    await _network.beforeStart(_keyring);

    /// Calling `PluginAcala(Keyring)` to
    /// connect to remote acala node.
    final connected = await _network.start(_keyring);

    _setConnectedNode(connected);
  }

  //...
}
```

The `PluginAcala` will query token balances of accounts of `Keyring`
 while plugin started.

To query other data from network, call: [_network.api](https://github.com/polkawallet-io/polkawallet_plugin_acala/blob/master/lib/api/acalaApi.dart)
