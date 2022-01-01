import 'package:polkawallet_plugin_acala/common/constants/base.dart';

const plugin_cache_key = 'plugin_acala';

const plugin_genesis_hash =
    '0x5fad1818cb637f0737771f27db0c28e7f669305ea71d84299291370d6723809c';
const acala_price_decimals = 18;
const acala_stable_coin = 'AUSD';
const acala_stable_coin_view = 'aUSD';
const acala_token_ren_btc = 'RENBTC';
const acala_token_ren_btc_view = 'renBTC';
const acala_token_polka_btc = 'POLKABTC';
const acala_token_polka_btc_view = 'polkaBTC';

const relay_chain_name = 'polkadot';
const para_chain_name_bifrost = 'bifrost';
const para_chain_name_khala = 'khala';
const para_chain_ids = {
  para_chain_name_bifrost: 2001,
  para_chain_name_khala: 2004,
};

const network_ss58_format = {
  plugin_name_acala: 42,
  relay_chain_name: 2,
  para_chain_name_bifrost: 6,
  para_chain_name_khala: 30,
};
const relay_chain_token_symbol = 'DOT';
const para_chain_token_symbol_bifrost = 'BNC';
const para_chain_token_symbol_khala = 'PHA';
const cross_chain_xcm_fees = {
  relay_chain_name: {
    relay_chain_token_symbol: {
      'fee': '79999999',
      'existentialDeposit': '33333333',
    },
  },
  para_chain_name_bifrost: {
    relay_chain_token_symbol: {
      'fee': '64000000',
      'existentialDeposit': '100000000',
    },
    para_chain_token_symbol_bifrost: {
      'fee': '5120000000',
      'existentialDeposit': '10000000000',
    },
    'VSKSM': {
      'fee': '64000000',
      'existentialDeposit': '100000000',
    }
  },
  para_chain_name_khala: {
    para_chain_token_symbol_khala: {
      'fee': '800000000',
      'existentialDeposit': '10000000000',
    }
  }
};
const xcm_dest_weight_kusama = '3000000000';
const xcm_dest_weight_karura = '600000000';
const xcm_dest_weight_v2 = '5000000000';

const acala_token_ids = [
  'ACA',
  'AUSD',
  'DOT',
  'LDOT',
  'LCDOT',
  'RENBTC',
  'XBTC',
  'POLKABTC',
  'PLM',
  'PHA'
];

const module_name_assets = 'assets';
const module_name_loan = 'loan';
const module_name_swap = 'swap';
const module_name_earn = 'earn';
const module_name_homa = 'homa';
const module_name_nft = 'nft';
const config_modules = {
  module_name_assets: {
    'visible': true,
    'enabled': false,
  },
  module_name_loan: {
    'visible': true,
    'enabled': false,
  },
  module_name_swap: {
    'visible': true,
    'enabled': false,
  },
  module_name_earn: {
    'visible': true,
    'enabled': false,
  },
  module_name_homa: {
    'visible': true,
    'enabled': false,
  },
  module_name_nft: {
    'visible': true,
    'enabled': true,
  },
};

const image_assets_uri = 'packages/polkawallet_plugin_acala/assets/images';
const module_icons_uri = {
  module_name_loan: '$image_assets_uri/loan.svg',
  module_name_swap: '$image_assets_uri/swap.svg',
  module_name_earn: '$image_assets_uri/earn.svg',
  module_name_homa: '$image_assets_uri/homa.svg',
  module_name_nft: '$image_assets_uri/nft.svg',
};

const cross_chain_icons = {
  plugin_name_acala: '$image_assets_uri/tokens/DOT.png',
  relay_chain_name: '$image_assets_uri/tokens/KSM.png',
  para_chain_name_bifrost: '$image_assets_uri/tokens/BNC.png',
  para_chain_name_khala: '$image_assets_uri/tokens/PHA.png',
};
