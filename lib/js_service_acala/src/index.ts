import "@babel/polyfill";
import { WsProvider, ApiPromise } from "@polkadot/api";
import { subscribeMessage, getNetworkConst, getNetworkProperties } from "./service/setting";
import keyring from "./service/keyring";
import { options } from "@acala-network/api";
import account from "./service/account";
import gov from "./service/gov";
import acala from "./service/acala";
import { genLinks } from "./utils/config/config";

// send message to JSChannel: PolkaWallet
function send(path: string, data: any) {
  if (window.location.href === "about:blank") {
    PolkaWallet.postMessage(JSON.stringify({ path, data }));
  } else {
    console.log(path, data);
  }
}
send("log", "main js loaded");
(<any>window).send = send;

async function connect(nodes: string[]) {
  return new Promise(async (resolve, reject) => {
    const wsProvider = new WsProvider(nodes);
    try {
      const res = new ApiPromise(
        options({
          provider: wsProvider,
        })
      );
      await res.isReady;
      (<any>window).api = res;
      const url = nodes[(<any>res)._options.provider.__private_18_endpointIndex];
      send("log", `${url} wss connected success`);
      resolve(url);
    } catch (err) {
      send("log", `connect failed`);
      wsProvider.disconnect();
      resolve(null);
    }
  });
}

(<any>window).settings = {
  connect,
  getNetworkConst,
  getNetworkProperties,
  subscribeMessage,
  genLinks,
};
(<any>window).keyring = keyring;
(<any>window).account = account;
(<any>window).gov = gov;
(<any>window).acala = acala;
