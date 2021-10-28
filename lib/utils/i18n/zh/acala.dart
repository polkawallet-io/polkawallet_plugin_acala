const Map<String, String> zhDex = {
  'acala': 'Acala Defi 中心',
  'airdrop': '空投',
  'transfer': '转账',
  'receive': '收款',
  'dex.title': '兑换',
  'dex.pay': '支付',
  'dex.receive': '收到',
  'dex.rate': '价格',
  'dex.route': '兑换路径',
  'dex.slippage': '可接受滑点',
  'dex.slippage.error': '允许的滑点范围：0.1%～49.9%',
  'dex.tx.pay': '支付',
  'dex.tx.receive': '收到',
  'dex.min': '最少收到',
  'dex.max': '最多卖出',
  'dex.fee': '交易费',
  'dex.impact': '价格影响',
  'dex.lp': '流动性',
  'dex.lp.add': '添加流动性',
  'dex.lp.remove': '提取流动性',
  'boot.title': '启动器',
  'boot.provision': '待启动',
  'boot.enabled': '已启动',
  'boot.provision.info': '该交易池将在以下条件达成时启动：',
  'boot.provision.condition.1': '流动性池达到',
  'boot.provision.condition.2': '时间达到',
  'boot.provision.or': '或',
  'boot.provision.met': '达成',
  'boot.provision.add': '添加流动性',
  'boot.ratio': '当前配比',
  'boot.total': '总量',
  'boot.my': '我提供的流动性',
  'boot.my.est': '预估',
  'boot.my.share': '份额',
  'boot.add': '添加',
  'loan.title': '生成 aUSD',
  'loan.title.KSM': '生成 kUSD',
  'loan.borrowed': '债务',
  'loan.collateral': '质押',
  'loan.ratio': '质押率',
  'loan.ratio.info':
      '\n你的债仓中质押物的市场价值（USD计价）与你生成的 aUSD 的价值之间的比例。（即：质押物价值 / aUSD 价值）\n',
  'loan.ratio.info.KSM':
      '\n你的债仓中质押物的市场价值（USD计价）与你生成的 kUSD 的价值之间的比例。（即：质押物价值 / kUSD 价值）\n',
  'loan.mint': '生成',
  'loan.payback': '销毁',
  'loan.deposit': '存入',
  'loan.deposit.col': '存入质押物',
  'loan.withdraw': '取出',
  'loan.withdraw.all': '同时取出所有质押物',
  'loan.create': '创建债仓',
  'loan.liquidate': '清算',
  'liquid.price': '清算价格',
  'liquid.ratio': '清算质押率',
  'liquid.ratio.require': '安全质押率',
  'liquid.price.new': '新的清算价格',
  'liquid.ratio.current': '当前质押率',
  'liquid.ratio.new': '新的质押率',
  'collateral.price': '价格',
  'collateral.price.current': '当前价格',
  'collateral.interest': '稳定费率',
  'collateral.require': '安全质押数量',
  'borrow.limit': '最多可生成',
  'borrow.able': '可生成',
  'withdraw.able': '可取',
  'loan.amount': '数量',
  'loan.amount.debit': '您要生成多少稳定币？',
  'loan.amount.collateral': '您要存入多少质押物？',
  'loan.max': '最大值',
  'loan.txs': '交易记录',
  'loan.warn': '债仓未清零时，余额不能小于 1aUSD，本次操作后将剩余 1aUSD 的债务。确认继续吗？',
  'loan.warn.KSM': '债仓未清零时，余额不能小于 1kUSD，本次操作后将剩余 1kUSD 的债务。确认继续吗？',
  'loan.warn.back': '返回修改',
  'loan.my': '我的债仓',
  'loan.incentive': '盈利',
  'loan.activate': '激活奖励',
  'loan.activate.1': '点击这里',
  'loan.activate.2': '激活你的奖励',
  'loan.close': '关闭债仓',
  'loan.close.dex': '通过兑换质押物关闭债仓',
  'loan.close.dex.info':
      '你的一部分质押物会通过 Swap 卖掉，以归还全部 kUSD 债务，剩余的质押物将退回你的账户。确认继续吗？',
  'loan.close.receive': '预估退回质押物',
  'txs.action': '操作类型',
  'payback.small': '剩余债务过小',
  'earn.title': '盈利',
  'earn.dex': '流动性挖矿',
  'earn.loan': '债仓挖矿',
  'earn.add': '添加流动性',
  'earn.remove': '提取流动性',
  'earn.reward.year': '年化奖励',
  'earn.fee': '交易费率',
  'earn.fee.info': '\n流动性提供者提取流动性时，会自动收到交易池赚取的交易费。\n',
  'earn.pool': '流动性池',
  'earn.stake.pool': '质押池',
  'earn.share': '份额',
  'earn.reward': '收益',
  'earn.available': '可用',
  'earn.stake': '质押',
  'earn.unStake': '提取',
  'earn.unStake.info': '注意: 挖矿活动结束前从质押池中取出 LP Token 将自动领取挖矿奖励，同时损失忠诚奖励。',
  'earn.staked': '已质押',
  'earn.claim': '领取收益',
  'earn.claim.info': '提示: 现在领取将会损失你的忠诚奖励。确认现在领取吗？',
  'earn.apy': 'APR',
  'earn.apy.0': ' APR w/o Loyalty',
  'earn.incentive': '挖矿奖励',
  'earn.saving': '存款利息',
  'earn.loyal': '忠诚奖励',
  'earn.loyal.end': '忠诚奖励结束时间',
  'earn.loyal.info': '\n如果等到挖矿活动结束后才领取奖励，将会获得额外奖励。\n',
  'earn.withStake': '同时质押',
  'earn.withStake.txt': '\n是否同时将获得的 LP Token 进行质押以赚取收益。\n',
  'earn.withStake.all': '质押全部',
  'earn.withStake.all.txt': '质押全部 LP Token',
  'earn.withStake.info': '质押 LP Token 以获得流动性挖矿收益',
  'earn.fromPool': '自动解除质押',
  'earn.fromPool.txt': '\n根据输入数量自动将 LP Token 解除质押并提取流动性。\n',
  'homa.title': 'Liquid',
  'homa.mint': '生成',
  'homa.redeem': '提取',
  'homa.now': '立即取回',
  'homa.era': '指定 Era',
  'homa.confirm': '确定',
  'homa.unbond': '等待 DOT 解锁',
  'homa.pool': '锁定资金池',
  'homa.pool.cap': '资金池上限',
  'homa.pool.bonded': '锁定数量',
  'homa.pool.ratio': '质押率',
  'homa.pool.min': '最低质押',
  'homa.pool.redeem': '最低赎回',
  'homa.pool.issuance': '发行量',
  'homa.pool.cap.error': '超出资金池上限',
  'homa.pool.low': '资金池余额不足',
  'homa.user': '我的 DOT 提取',
  'homa.user.unbonding': '解绑中',
  'homa.user.time': '解锁时间',
  'homa.user.blocks': '区块',
  'homa.user.redeemable': '可取回',
  'homa.user.stats': '我的数据',
  'homa.user.ksm': 'KSM 余额',
  'homa.user.unlocking': 'KSM 解锁中',
  'homa.user.lksm': 'LKSM 余额',
  'homa.mint.profit': '预估收益（每Era）',
  'homa.mint.warn': 'LKSM 第一阶段使用代理质押的方式。在下个阶段上线之前，提取 KSM 的功能暂不可用。详见',
  'homa.mint.warn.here': ' 这里',
  'homa.redeem.fee': '手续费',
  'homa.redeem.era': '当前 Era',
  'homa.redeem.period': '解锁周期',
  'homa.redeem.day': '天',
  'homa.redeem.free': '资金池',
  'homa.redeem.unbonding': '最长解封期',
  'homa.redeem.receive': '预计收到',
  'homa.redeem.cancel': '取消',
  'homa.redeem.hint': '取消进行中的 KSM 提取请求并取回你的 LKSM。确认继续吗？',
  'tx.fee.or': '或等额其他代币',
  'nft.title': 'NFTs',
  'nft.testnet': 'Mandala 测试网徽章',
  'nft.transfer': '发送',
  'nft.burn': '销毁',
  'nft.quantity': '数量',
  'nft.Transferable': '可转移',
  'nft.Burnable': '可销毁',
  'nft.Mintable': '可增发',
  'nft.Unmintable': '不可增发',
  'nft.ClassPropertiesMutable': '可修改',
  'nft.All': '全部',
  'nft.name': '名称',
  'nft.description': '描述',
  'nft.class': 'ClassID',
  'nft.deposit': '质押金',
  'candy.title': '领糖果',
  'candy.claim': '马上领取',
  'candy.amount': '待领取',
  'candy.claimed': '已领取',
  'cross.chain': '收款网络',
  'cross.xcm': '跨链转账',
  'cross.chain.select': '选择网络',
  'cross.exist': '收款链存活余额',
  'cross.exist.msg': '\n账户在网络上存活所需要的最小余额。\n',
  'cross.fee': '收款链手续费',
  'cross.warn': '警告',
  'transfer.exist': '存活余额',
  'transfer.fee': '预估手续费',
  'warn.fee': '因 KAR 余额不足，该笔交易可能会执行失败。',
};
