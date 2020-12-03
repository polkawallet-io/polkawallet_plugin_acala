import { StakingPool } from "@acala-network/sdk-homa";
import { FixedPointNumber, getPresetToken, PresetToken } from "@acala-network/sdk-core";
import { SwapTrade } from "@acala-network/sdk-swap";
import { ApiPromise } from "@polkadot/api";

/**
 * calc token swap amount
 * @param {ApiPromise} api
 * @param {Number} input
 * @param {Number} output
 * @param {List<String>} swapPair
 * @param {Number} slippage
 */
async function calcTokenSwapAmount(api: ApiPromise, input: number, output: number, swapPair: PresetToken[], slippage: number) {
  const i = getPresetToken(swapPair[0]).clone({
    amount: new FixedPointNumber(input || 0),
  });
  const o = getPresetToken(swapPair[1]).clone({
    amount: new FixedPointNumber(output || 0),
  });
  const mode = output === null ? "EXACT_INPUT" : "EXACT_OUTPUT";
  const availableTokenPairs = SwapTrade.getAvailableTokenPairs(api);
  const maxTradePathLength = new FixedPointNumber(api.consts.dex.tradingPathLimit.toString()).toNumber();
  const fee = {
    numerator: new FixedPointNumber(api.consts.dex.getExchangeFee[0].toString()),
    denominator: new FixedPointNumber(api.consts.dex.getExchangeFee[1].toString()),
  };
  const swapTrader = new SwapTrade({
    input: i,
    output: o,
    mode,
    availableTokenPairs,
    maxTradePathLength,
    fee,
    acceptSlippage: new FixedPointNumber(slippage),
  });

  const paths = swapTrader.getTradeTokenPairsByPaths();
  const res = await api.queryMulti(paths.map((e) => [api.query.dex.liquidityPool, e.toChainData()]));
  const pools = SwapTrade.convertLiquidityPoolsToTokenPairs(paths, res as any);
  const data = swapTrader.getTradeParameters(pools);
  const params = data.toChainData(mode);
  return {
    amount: output === null ? data.output.amount.toNumber(6) : data.input.amount.toNumber(6),
    path: params[0],
    input: params[1],
    output: params[2],
  };
}

async function queryLPTokens(api: ApiPromise, address: string) {
  const allTokens = (api.consts.dex.enabledTradingPairs as any).map((item: any) =>
    api.createType("CurrencyId" as any, {
      DEXShare: [item[0].asToken.toString(), item[1].asToken.toString()],
    })
  );

  const res = await api.queryMulti(allTokens.map((e) => [api.query.tokens.accounts, [address, e]]));
  return (res as any)
    .map((e: any, i: number) => ({ free: e.free.toString(), currencyId: allTokens[i].asDexShare }))
    .filter((e: any) => e.free > 0);
}

/**
 * getTokenPairs
 * @param {String} currencyId
 * @param {String} address
 */
async function getTokenPairs(api: ApiPromise) {
  return SwapTrade.getAvailableTokenPairs(api).map((e: any) => e.origin);
}

/**
 * fetchDexPoolInfo
 * @param {String} poolId
 * @param {String} address
 */
async function fetchDexPoolInfo(api: ApiPromise, pool: any, address: string) {
  const res = (await Promise.all([
    api.query.dex.liquidityPool(pool.DEXShare.map((e: any) => ({ Token: e }))),
    api.query.rewards.pools({ DexIncentive: pool }),
    api.query.rewards.pools({ DexSaving: pool }),
    api.query.rewards.shareAndWithdrawnReward({ DexIncentive: pool }, address),
    api.query.rewards.shareAndWithdrawnReward({ DexSaving: pool }, address),
    api.query.tokens.totalIssuance(pool),
  ])) as any;
  let proportion = 0;
  if (res[2]) {
    proportion = FixedPointNumber.fromInner(res[3][0].toString())
      .div(FixedPointNumber.fromInner(res[1].totalShares.toString()))
      .toNumber();
  }
  return {
    token: pool.DEXShare.join("-"),
    pool: res[0],
    sharesTotal: res[1].totalShares,
    shares: res[3][0],
    proportion: proportion || 0,
    reward: {
      incentive: new FixedPointNumber(res[1].totalRewards * proportion - res[3][1] || 0).toString(),
      saving: new FixedPointNumber(res[2].totalRewards * proportion - res[4][1] || 0).toString(),
    },
    issuance: res[5],
  };
}

async function _calacFreeList(api: ApiPromise, start: number, duration: number) {
  const list = [];
  for (let i = start; i < start + duration; i++) {
    const result = await api.query.stakingPool.unbonding(i);
    const free = FixedPointNumber.fromInner(result[0]).minus(FixedPointNumber.fromInner(result[1]));
    list.push({
      era: i,
      free: free.toNumber(),
    });
  }
  return list.filter((item) => item.free);
}

let homaStakingPool;

async function fetchHomaStakingPool(api: ApiPromise) {
  const [stakingPool, { mockRewardRate }] = (await Promise.all([
    (api.derive as any).homa.stakingPool(),
    api.query.polkadotBridge.subAccounts(0),
  ])) as any;

  const poolInfo = new StakingPool({
    stakingPoolParams: {
      targetMaxFreeUnbondedRatio: FixedPointNumber.fromInner(stakingPool.stakingPoolParams.targetMaxFreeUnbondedRatio.toString()),
      targetMinFreeUnbondedRatio: FixedPointNumber.fromInner(stakingPool.stakingPoolParams.targetMinFreeUnbondedRatio.toString()),
      targetUnbondingToFreeRatio: FixedPointNumber.fromInner(stakingPool.stakingPoolParams.targetUnbondingToFreeRatio.toString()),
      baseFeeRate: FixedPointNumber.fromInner(stakingPool.stakingPoolParams.baseFeeRate.toString()),
    },
    defaultExchangeRate: FixedPointNumber.fromInner(stakingPool.defaultExchangeRate.toString()),
    liquidTotalIssuance: FixedPointNumber.fromInner(stakingPool.liquidTokenIssuance.toString()),
    unbondNextEra: FixedPointNumber.fromInner(stakingPool.nextEraUnbond[0].toString()),
    currentEra: stakingPool.currentEra.toNumber(),
    bondingDuration: stakingPool.bondingDuration.toNumber(),
    totalBonded: FixedPointNumber.fromInner(stakingPool.totalBonded.toString()),
    unbondingToFree: FixedPointNumber.fromInner(stakingPool.unbondingToFree.toString()),
    freeUnbonded: FixedPointNumber.fromInner(stakingPool.freeUnbonded.toString()),
  });
  homaStakingPool = poolInfo;

  const freeList = await _calacFreeList(api, stakingPool.currentEra.toNumber() + 1, stakingPool.bondingDuration.toNumber());
  const eraLength = api.consts.polkadotBridge.eraLength as any;
  const expectedBlockTime = api.consts.babe.expectedBlockTime;
  const unbondingDuration = expectedBlockTime.toNumber() * eraLength.toNumber() * stakingPool.bondingDuration.toNumber();
  return {
    // ...stakingPoolHelper,
    rewardRate: mockRewardRate.toString(),
    freeList,
    unbondingDuration,
    liquidTokenIssuance: stakingPool.liquidTokenIssuance.toString(),
    defaultExchangeRate: FixedPointNumber.fromInner(stakingPool.defaultExchangeRate.toString()).toNumber(),
    bondingDuration: stakingPool.bondingDuration,
    currentEra: stakingPool.currentEra,
    communalBonded: poolInfo.getCommunalBonded().toNumber(),
    communalTotal: poolInfo.getTotalCommunalBalance().toNumber(),
    communalFreeRatio: poolInfo.getFreeUnbondedRatio().toNumber(),
    unbondingToFreeRatio: poolInfo.getUnbondingToFreeRatio().toNumber(),
    communalBondedRatio: poolInfo.getBondedRatio().toNumber(),
    liquidExchangeRate: poolInfo.liquidExchangeRate().toNumber(),
  };
}

async function fetchHomaUserInfo(api: ApiPromise, address: string) {
  const stakingPool = await (api.derive as any).homa.stakingPool();
  const start = stakingPool.currentEra.toNumber() + 1;
  const duration = stakingPool.bondingDuration.toNumber();
  const claims = [];
  for (let i = start; i < start + duration + 2; i++) {
    const claimed = (await api.query.stakingPool.claimedUnbond(address, i)) as any;
    if (claimed.gtn(0)) {
      claims[claims.length] = {
        era: i,
        claimed,
      };
    }
  }
  const unbonded = await (api.rpc as any).stakingPool.getAvailableUnbonded(address);
  return {
    unbonded: unbonded.amount || 0,
    claims,
  };
}

async function queryHomaRedeemAmount(api: ApiPromise, amount: number, redeemType: number, targetEra: number) {
  if (redeemType == 0) {
    const res = await homaStakingPool.getStakingAmountInRedeemByFreeUnbonded(new FixedPointNumber(amount));
    return {
      demand: res.demand.toNumber(),
      fee: res.fee.toNumber(),
      received: res.received.toNumber(),
    };
  } else if (redeemType == 1) {
    const unbonding = await api.query.stakingPool.unbonding(targetEra);
    const res = await homaStakingPool.getStakingAmountInClaimUnbonding(new FixedPointNumber(amount), targetEra, {
      unbonding: FixedPointNumber.fromInner(unbonding[0].toString()),
      claimedUnbonding: FixedPointNumber.fromInner(unbonding[1].toString()),
      initialClaimedUnbonding: FixedPointNumber.fromInner(unbonding[2].toString()),
    });
    return {
      atEra: res.atEra,
      demand: res.demand.toNumber(),
      fee: res.fee.toNumber(),
      received: res.received.toNumber(),
    };
  } else if (redeemType == 2) {
    const res = await homaStakingPool.getStakingAmountInRedeemByUnbond(new FixedPointNumber(amount));
    return {
      atEra: res.atEra,
      amount: res.amount.toNumber(),
    };
  }
}

export default {
  calcTokenSwapAmount,
  queryLPTokens,
  getTokenPairs,
  fetchDexPoolInfo,
  fetchHomaStakingPool,
  fetchHomaUserInfo,
  queryHomaRedeemAmount,
};
