## Monero Dynamic Block Size and Dynamic Minimum Fee

### Brief

Monero uses dynamic block size mechanism to control the rate at which the block size can grow. As part of consensus rules, part of the base block reward is witheld should a miner expand the size of a given block above the median size of the last 100 blocks. This is coupled with a do-not-relay minimum fee. Client software uses multipliers of the minimum fee to give priority to transactions in case of heavy network use during peak periods.

We will analyze the formulas currently in use and impact of different fee multipliers on neutral and optimum strategies for the miners and observe how they're independent of the network state. We will demonstrate how the current formulas incentivise a steady block size growth at a rate of 0.6%, as long as there's a pool of transactions offering the minimum fee to draw from.

Further, we will show how the ratio between typical transaction size and minimum block size negatively affects the effectiveness of the formulas by making block size increases discrete. To address this problem, modified formulas are presented and recommendation made for any future changes in typical transaction sizes.

Conclusion is that present dynamic block size penalty formula doesn't work as intended in situations where typical transaction size is close to median block size. The penalty formula must be changed to allow smooth transition into a network state where median block size will be sufficiently greater than the typical transaction size.

### 1. Analysis of Current Dynamic Block Size and Dynamic Minimum Fee

Current block reward penalty is given by:

`P_current = R * ((B / M) - 1) ^ 2`,

where `R` is the base block reward, `B` the block size and `M` the median block size of last 100 blocks. The penalty doesn't come in effect unless `B > M_0`, where `M_0 = 60000 bytes` is the minimum penalty-free block size. Maximum allowed block size is `2 * M`, at which the full base block reward is witheld.

The current minimum fee has originally been given as:

`F_min_current = (R / R_0) * (M_0 / M) * F_0`,

where `R_0 = 10 monero` is the reference base reward, and `F_0 = 0.002 monero / kB`.

Considering that `R_0`, `M_0` and `F_0` are constants, the expression can be rewritten as:

`F_min_current = (R / M) * (W_0 - 1)`, where

`W_0 - 1 = (M_0 * F_0) / R_0 = 0.0012`.

As we will see below, the value of `W_0` represents the block size expansion factor for which the minimum fee would entirely cover for the block penalty, making a block size of `B = M * W_0` neutral to miner profit.

We will find a general neutral fee function which will output a fee required to make block size expansion with a given factor neutral to miner profit.

Recall
 
`P_current = R * ((B / M) - 1) ^ 2`, and define

`F_A = B * F - M * F = F * (B - M)`,

where `F_A` is the additional earnings from fees should the block be expanded to a size of `B` and filled with transactions paying transaction fee `F`.

We will also define additional miner profit as

`E_A = F_A - P`.

Substituting with `W = B / M` and solving `E_A = 0` for `F`, we find

`F_n_current = (R / M) * (W - 1)`,

which is the fee required to make an expansion of the block size to `B = W * M` neutral to miner profit, as doing so would yield the same total reward for the miner as would mining a block of the size `B = M` with transaction fees of `F_n_current`.
However, while the miner doesn't lose anything compared to the base case, there is a missed opportunity because he could opt for some optimal increase `M < B < W * M` which would give him the biggest reward.

We can now observe that for `W = W_0` the expression

`F_min_current = F_n_current` holds true.

To find the optimum fee for a given block size expansion, we must find the maximum of the additional profit function

`E_A = F_A - P`.

Solving `dE_A / dW = 0` for `F` gives

`F_o_current = 2 * (R / M) * (W - 1)`.

Which shows a linear relationship between the transaction fee and optimum block size increase.

To present the impact of different fee multipliers on neutral and optimum block size expansions, we will substitute the fee with a multiplier of the minimum fee
`F = F_min_current * F_mult`,


and plug it into the neutral and optimum fee equations. Rearranging gives

`F_mult_n_current = (W - 1) / (W_0 - 1)` for the neutral fee, and

`F_mult_o_current = 2  * (W - 1) / (W_0 - 1)` for the optimum fee.

which we will plot on the chart below.

![fig1-1](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig1-1.png?raw=true)

We will further examine miner incentives by plotting the relationship between block size expansion and additional miner profit for various fee multipliers. On the same chart, we will show the optimum curve which connects the min. fee multiplier curve maximums.

![fig1-2](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig1-2.png?raw=true)

We see that each fee multiplier curve has one point of maximum profit for the miner. Another interesting point is the 2nd crossing with the horizontal axis, at which the miner would earn the same total by increasing the block size as he would if he mined a block with 0% expansion.

We can observe linear relationship between the min. fee multiplier and optimum block size expansion. For example, with the minimum fee, it's optimal for the miner to keep growing the block size with the rate of 0.6% per 100 blocks. He can keep doing this as long as there are enough transactions to fill the blocks. To increase the block size with a 6% rate, a fee multiplier of 10 is required, to increase for 60% it's 100, and ultimately a 100% increase with a 166.67 multiplier.

It's important to note that these charts are invariant to network state. They look the same for any base block reward and actual block size median.

The question is, given a pool of transactions with any fee multiplier, can a miner build such a block which would lay on the optimum curve? The answer is no, and below we will analyze why.

### 2. The Problem of Relative Typical Transaction Size

While the existing formulas show a permanent incentive to grow the block size at a rate of  0.6% for as long as there are enough transactions in the mempool, this gradual increase is not feasible to achieve in practice. This is because a miner can affect the block size only by picking transactions from the pool. Because of the ratio between a typical transaction size and minimum block size being greater than 0.6%, the miner has no easy way to achieve this target of block size increase. Of course, not all transaction have the same size nor offer the same fee, and transactions variance could be exploited to build an occasional optimal block but for some typical case it will not be feasible. In practice, the block size increases are feasible to do only in some discrete steps. To analyze this, we will define

`W_T = 1 + T_0 / M`,

where `T_0` is the size of a typical Monero transaction, and `M` the median block size as previously defined. The factor `W_T` is the smallest feasible block size expansion factor, ie such that the block size is increased above median for a single typical transaction size:

`B = M + T_0 = M * W_T`.

We can define the set of feasible block size expansions as `W_f = {1 + T_0 / M, 1 + 2 * T_0 / M, ..., 1 + n * T_0 / M}`. Each of these discrete steps can be coupled with a fee multiplier needed to make the step neutral or optimum for the miner. Any fee multiplier greater than the neutral will yield additional profit for the miner with the optimum fee multiplier maximizing the profit for a given block size increase.

The minimum feasible expansion factor `W_T` changes either with changing the `T_0` as part of protocol change affecting typical transaction sizes, or with the median block size `M` as a consequence of network state. It also defines feasible block size increase steps. Below we will examine the case for `M = 60kB` and `T_0` of xxkB and 13kB as typical sizes of non-RCT and RCT transactions.

![fig2-1](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig2-1.png?raw=true)

Above we see how the jump in transaction sizes has created a barrier to expanding the block sizes smoothly. This can also be seen on the chart below.

![fig2-2](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig2-2.png?raw=true)

Pre-RCT, the first step was at xx% increase with neutral multiplier of xx, and post-RCT it is at xx increase with neutral multiplier of xx. In addition, the fee / TX has jumped xx-fold. If somehow the network should get to a state of bigger block size, the discrete steps would become more dense and allow for smoother changes. The problem is in getting to that state in the first place. As the blocks expand, optimum steps for smaller multipliers will become feasible. With the current formulas, the median block size should be at `M = xxkB` to make the neutral step for minimum fee available or `M = xxkB` to make the optimum step for minimum fee available. This problem was present pre-RCT but with RCT it became more severe.

Below we show the difference between ideal steady growth and currently feasible one for both RCT and non-RCT transactions, with different scenarios based on relationship between block size and market price.

![fig2-3](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig2-3.png?raw=true)

As seen above, the smallest feasible min. fee is at xx$ for RCT and xx$ for non-RCT. With such a price, theres a real danger of hinder adoption and preventing transition into a state where steady growth is feasible.

### 3. Proposed Solution

The objective is to make the smallest increment feasible, while still keeping the network usage rational by preventing free block size expansion.

The idea is to scale down the penalty formula such that the neutral fee to add a signle typical transaction over the median remains constant up to the point where it would mean a 1.2% expansion, from where the original formulas would kick in again. However, full penalty must still be incurred for a 100% increase. 

The simplest way to achieve this transition is multiplying the current penalty formula with a line function:

`P_new = (k * W + l) * (W - 1) ^ 2 * R`,

where parameters `k` and `l` must be determined to accomodate the proposition above.

First, we will find `l`, such that

`P_new = R`, for `W = 2` and any `k`.

Solving the above gives

`l = 1 - 2 * k`,

and the penalty formula can now be expressed as

`P_new = (k * (W - 2) + 1) * (W - 1) ^ 2 * R`.

The parameter `k` must still be determined. We can express the above proposition of keeping the fee to accomodate a single typical transaction size increase constant as follows:

`(k * (W_T - 2) + 1) * (R / M) * (W_T - 1) = (R / M) * (W_0 - 1)`.

Solving for `k` gives

`k = ((W_T * (2 - W_T) + (W_0 - 2) * W_0) / ((W_T - 2) * (W_T - 1) ^ 2))`.

The new penalty formula will be valid while the condition `T > W_0` holds. For `T <= W_0`, the original penalty calculation will be used. The point where `T = W_0` will give the same penalty, regardless of which expression is used because `k = 1` for that case.

With the penalty formula defined, it now remains to again find expressions for neutral and optimum fees.

Again, solving `E_A = 0` for `F` gives the neutral fee expression:

`F_n = (k * (W - 2) + 1) * (R / M) * (W - 1)`, and

solving dE_A / dW for `F` gives the optimum fee expression:

`F_o = (k * (3 * W - 5) + 2) * (R / M) * (W - 1)`.

(todo: add note for W<W_T)

### 4. Wallet Fee Settings

proposed multipliers 1x 4x(default) 20x 166x

### 5. End Result

![fig5-1](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig5-1.png?raw=true)
![fig5-2](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig5-2.png?raw=true)
![fig5-3](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig5-3.png?raw=true)
![fig5-4](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/fig5-4.png?raw=true)
[fig5-5] min possible fee

### 6. A Note on Security (fireice)

regarding penalty / min. fee safe implementation?

### 7. A Note on Privacy (fireice)

regarding multipliers 1x 4x(default) 20x 166x? fyi, right now it's 1x,20x,166x iirc

### 8. Conclusion

### Appendices

1. VB Code with Constants
2. VB Code for Current Formulas (Excel user-defined functions)
3. VB Code for Proposed Formulas (Excel user-defined functions)