const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const node_list = [
  {
    'name': 'Acala Mandala (Hosted by Acala Network)',
    'ss58': 42,
    'endpoint': 'wss://acala-testnet-1.polkawallet.io:9904',
  },
  {
    'name': 'Mandala TC5 Node 1 (Hosted by OnFinality)',
    'ss58': 42,
    'endpoint': 'wss://node-6714447553777491968.jm.onfinality.io/ws',
  },
  {
    'name': 'Mandala TC5 Node 2 (Hosted by OnFinality)',
    'ss58': 42,
    'endpoint': 'wss://node-6714447553211260928.rz.onfinality.io/ws',
  },
];

const acala_token_decimals = 18;
const acala_stable_coin = 'AUSD';
