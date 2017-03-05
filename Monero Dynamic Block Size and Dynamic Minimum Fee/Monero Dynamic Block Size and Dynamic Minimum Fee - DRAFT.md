## Monero Dynamic Block Size and Dynamic Minimum Fee

### Brief

Monero uses dynamic block size mechanism to control the rate at which the block size can grow. As part of consensus rules, part of the base block reward is witheld should a miner expand the block size above the median size of the last 100 blocks. This is coupled with a do-not-relay minimum fee. Client software uses multipliers of the minimum fee to give priority to transactions in case of heavy network use during peak periods.

We will analyze the formulas currently in use and impact of different fee multipliers on neutral and optimum strategies for the miners and observe how they're independent of the network state. We will demonstrate how the current formulas incentivise a steady block size growth at a rate of 0.6% as long as there's a pool of transactions offering the minimum fee to draw from.

Further, we will show how the ratio between typical transaction size and minimum block size negatively impacts the effectiveness of the formulas by making block size increases discrete. To address this problem, two proposals are presented and analyzed.

Conclusion is that present dynamic block size penalty formula doesn't work as intended in situations where typical transaction size is close to median block size. The penalty formula must be changed to allow smooth transition into a network state where median block size will be sufficiently greater than the typical transaction size.

### 1. Analysis of Current Dynamic Block Size and Dynamic Minimum Fee

Current block reward penalty is given by:

`P_current = R * ((B / M) - 1) ^ 2`,

where `R` is the base block reward, `B` the block size and `M` the median block size of the last 100 blocks. The penalty doesn't come in effect unless `B > M_0`, where `M_0 = 60000 bytes` is the minimum penalty-free block size. Maximum allowed block size is `2 * M`, at which the full base block reward is witheld. 

![Figure 1-1](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig1-1.png?raw=true)

The current minimum fee has originally been given as:

`F_mc = (R / R_0) * (M_0 / M) * F_0`,

where `R_0 = 10 monero` is the reference base reward, and `F_0 = 0.002 monero / kB`.

Considering that `R_0`, `M_0` and `F_0` are constants, the expression can be rewritten as:

`F_min_c = (R / M) * (W_0 - 1)`, where

`W_0 - 1 = (M_0 * F_0) / R_0 = 0.0012`.

As we will see below, the value of `W_0` represents the block size expansion factor for which the minimum fee would entirely cover for the block penalty, making a block size of `B = M * W_0` neutral to miner earnings.

We will find a generalized neutral fee function which will output a fee required to make block size expansion with a given factor neutral to miner earnings.

Recall
 
`P_c = R * ((B / M) - 1) ^ 2`, and define

`F_A = B * F - M * F = F * (B - M)`,

where `F_A` is the additional reward from fees should the block be expanded to a size of `B` and filled with transactions paying transaction fee `F`.

We will also define additional miner earnings as

`E_A = F_A - P`.

Substituting with `W = B / M` we can re-write the penalty formula as

`P_c = R * (W - 1) ^ 2`, and additional reward from fees as

`F_A = F * (W - 1) * M`.


Solving `E_A = 0` for `F`, we find

`F_n_c = (R / M) * (W - 1)`, 

which is the fee required to make an expansion of the block size to `B = W * M` neutral to miner earnings, as doing so would yield the same total block reward for the miner as would mining a block of the size `B = M` with transaction fees of `F_n_c`.
While the miner doesn't lose anything compared to the base case, there is a missed opportunity because he could opt for some optimal increase `M < W_o * M < W_n * M` which would give him the biggest reward.

We can now observe that for `W = W_0` the expression

`F_min_c = F_n_c` holds true.

To find the optimum fee for a given block size expansion, we must find the maximum of the additional earnings function

`E_A = F_A - P`.

Solving `dE_A / dW = 0` for `F` gives

`F_o_c = 2 * (R / M) * (W - 1)`.

Which shows a linear relationship between the transaction fee and optimum block size increase.

It has to be noted that the case for `M < M_0` requires special attention. As we're penalizing only what goes over the minimum free block size then the actual median should be replaced with `M_0` in all the formulas. This means that for `M < M_0` we should redefine M and W as

W := B / M_0, and
M := M_0, and

then continue as usual.

To present the impact of different fee multipliers on neutral and optimum block size expansions, we will substitute the fee with a multiplier of the minimum fee

`F = F_min_c * F_mul_c`,

and plug it into the neutral and optimum fee equations. Rearranging gives

`F_mul_c = (W - 1) / (W_0 - 1)` for the neutral fee, and

`F_mul_c = 2  * (W - 1) / (W_0 - 1)` for the optimum fee.

![Figure 1-2](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig1-2.png?raw=true)

We will further examine miner incentives by plotting the relationship between block size increase and additional miner earnings for various fee multipliers. On the same chart, we will show the optimum curve which connects the min. fee multiplier curve maximums.

![Figure 1-3](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig1-3.png?raw=true)

We see that each fee multiplier curve has one point of maximum earnings for the miner. Another interesting point is the 2nd crossing with the horizontal axis, at which the miner would earn the same total by increasing the block size as he would if he mined a block with 0% expansion.

We can observe linear relationship between the min. fee multiplier and optimum block size expansion. For example, with the minimum fee, it's optimal for the miner to keep growing the median block size with the rate of 0.6% above median. He can keep doing this as long as there are enough transactions to fill the blocks. To increase the block size with a rate of 6%, a fee multiplier of 10 is required, to increase for 60% it's 100, and ultimately a 100% increase with a 166.67 multiplier.

It's important to note that these charts are invariant to network state. They look the same for any base block reward and actual block size median.

The question is, given a pool of transactions with any fee multiplier, can a miner always build such a block which would lay on the optimum curve? The answer is no, and below we will analyze why.

### 2. The Problem of Relative Typical Transaction Size

While the existing formulas show a permanent incentive to grow the block size at a rate of  0.6% for as long as there are enough transactions in the mempool, this gradual increase is not feasible to achieve in practice. This is because a miner can affect the block size only by picking transactions from the pool. Because of the ratio between a typical transaction size and minimum block size being greater than 0.6%, the miner has no easy way to achieve this target of block size increase. Of course, not all transaction have the same size nor offer the same fee, and transaction size variance could be exploited to build an occasional optimal block. However, for some typical case it will not be feasible. In practice, the block size increases are feasible to do only in some discrete steps. To analyze this, we will define

`W_T = 1 + T_0 / M`,

where `T_0` is the size of a typical Monero transaction, and `M` the median block size as previously defined. The factor `W_T` is the smallest feasible block size expansion factor, ie such that the block size is increased above median for a single typical transaction size:

`B_T = M + T_0 = M * W_T`.

We can define the set of feasible block size expansions as `W_f = {1 + T_0 / M, 1 + 2 * T_0 / M, ..., 1 + n * T_0 / M}, for any n * T_0 <= M`. Each of these discrete steps can be coupled with a fee multiplier needed to make the step neutral or optimum for the miner. Any fee multiplier greater than the neutral will yield additional profit for the miner while the optimum fee multiplier will maximize the profit for a given block size increase.

The minimum feasible expansion factor `W_T` changes either with changing the `T_0` as part of protocol change affecting typical transaction sizes, or with the median block size `M` as a consequence of network state. It also defines feasible block size increase steps. Below we will examine the case for `T_0` of 1kB and 15kB as typical sizes of non-RCT and RCT transactions.

![Figure 2-1](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig2-1.png?raw=true)

Above we see how the jump in transaction sizes has created a barrier to expanding the block sizes smoothly. We also see how this is eased once the median grows big enough as discrete steps become denser. This can also be seen on the chart below.

![Figure 2-2](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig2-2.png?raw=true)

Pre-RCT, the first step was at 1.67% increase with neutral multiplier of 1.93, and post-RCT it is at 25% increase with neutral multiplier of xx. In addition, the fee / TX has jumped 15-fold. If somehow the network should adjust to a state of bigger block size, the discrete steps would become more dense and allow for smoother changes. The problem is in getting to that state in the first place.

As the blocks expand, optimum steps for smaller multipliers will become feasible. With the current formulas, the median block size should be at `M = 1250kB` to make the neutral step with the minimum fee available or `M = 2500kB` to make the optimum step for the minimum fee available. This problem was actually present pre-RCT but with RCT it became more severe.

Below we show the difference between ideal steady growth and currently feasible one for both RCT and non-RCT transactions, with different scenarios based on relationship between block size and market price.

![Figure 2-3](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig2-3.png?raw=true)

As seen above, the smallest feasible min. fee is at xx$ for RCT and 0.03$ for non-RCT. With such a price, there's a real danger of hindering adoption and preventing transition into a state where steady growth is feasible.

The increase was not just due to the 15-fold transaction size increase, but also due to the penalty increase as adding a bigger transaction requires a bigger relative block size increase, so the price per TX actually increased 225 times!

### 3. Proposed Solution

Some trivial solutions can be considered first:

- Increase the `M_0` to 1250kB. This would immediately reduce the min. fee and postpone using the block reward penalty until the network would grow to the point where typical transaction size will be insignificant to functioning of the dynamic formulas.
- Make it penalty-free to increase the block size for a single typical transaction size above the median. This would be in the spirit of original CryptoNote design which gave a 10% increase for free. It would allow for steady growth while throttling the rate of it.

Both of the above solutions come with the drawback that they enable some increase for free.

Current formulas don't facilitate any free increases. In the same spirit, the objective of new proposals will be to make the smallest increment feasible while still keeping the network usage rational by preventing free block size expansion.

## 3.1 Fixed Minimum Feasible Fee Option

The idea is to scale down the penalty formula such that the neutral fee to add a single typical transaction above the median remains constant up to the point where it would mean a 1.2% block size increase. From there, the original formulas would kick in again. However, full penalty must still be incurred for a 100% increase.

The simplest way to achieve this transition is multiplying the current penalty formula with a linear function:

`P_n_1 = (k_1 * W + l) * (W - 1) ^ 2 * R`,

where parameters `k_1` and `l_1` must be determined to accomodate the proposition above.

First, we will find `l_1`, such that

`P_n_1 = R`, for `W = 2` and any `k_1`.

Solving for the above gives

`l_1 = 1 - 2 * k_1`,

and the penalty formula can now be expressed as

`P_n_1 = (k_1 * (W - 2) + 1) * (W - 1) ^ 2 * R`.

The parameter `k_1` must still be determined. We can express the above proposition of keeping the neutral fee to accomodate a single typical transaction size increase constant as follows:

`(k_1 * (W_T - 2) + 1) * (R / M) * (W_T - 1) = (R / M) * (W_0 - 1)`.

Solving for `k_1` gives

`k_1 = ((W_T * (2 - W_T) + (W_0 - 2) * W_0) / ((W_T - 2) * (W_T - 1) ^ 2))`.

The new penalty formula will be valid while the condition `W_0 < W_T` holds. For `W_T <= W_0`, the original penalty calculation will be used. The point where `W_T = W_0` will give the same penalty, regardless of which expression is used because `k_1 = 0` for that case.

Case where W < W_T requires special attention as the penalty would reach 0 at some 0 < W < W_T. To address this, we can simply lock the scaling factor as below:

`P_n_1 = (k_1 * (W_T - 2) + 1) * (W - 1) ^ 2 * R` for `W < W_T and W_0 < W_T`.

To summarize, we have:

`P_n_1 = (k_1 * (W_T - 2) + 1) * (W - 1) ^ 2 * R` for `W < W_T and W_0 < W_T`, 
`P_n_1 = (k_1 * (W - 2) + 1) * (W - 1) ^ 2 * R` for `W_T <= W and W_0 < W_T`, and
`P_n_1 = P_c` for `W_T <= W_0`.

Below we can see direct comparison of the current and proposed penalty formula.

![Figure 3.1-1](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-1.png?raw=true)

With the penalty formula defined, it now remains to again find expressions for neutral and optimum fees.

Solving `E_A = 0` for `F` gives the neutral fee expression:

`F_n_1 = (k_1 * (W_T - 2) + 1) * (R / M) * (W - 1)`, for `W < W_T and W_0 < W_T`,
`F_n_1 = (k_1 * (W - 2) + 1) * (R / M) * (W - 1)`, for `W_T <= W and W_0 < W_T`, and
`F_n_1 = F_n_c` for `W_T <= W_0`.

Solving dE_A / dW for `F` gives the optimum fee expression:

Undefined for `W < W_T and W_0 < W_T`,
`F_o_1 = (k_1 * (3 * W - 5) + 2) * (R / M) * (W - 1)`, for `W_T <= W and W_0 < W_T`, and
`F_o_1 = F_o_c` for `W_T <= W_0`.

Below we can see direct comparison of the current and proposed neutral and optimum fees.

![Figure 3.1-2](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-2.png?raw=true)

Again, we will analyze impact of fee multipliers, as seen below.

![Figure 3.1-3](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-3.png?raw=true)

We see how initially, only the smallest step is avalible. As soon as the median would grow, faster growth would be enabled as long as users are willing to offer higher multipliers.

Next, below we show the minimum cost of a single transaction.

![Figure 3.1-4](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-4.png?raw=true)

In this scenario, we can see how throughout the transition the cost of a single transaction remains flat if the market price is unchanged. As such, the initial proposition is achieved.

Furthermore, we will analyze the minimum cost of a full block.

![Figure 3.1-5](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-5.png?raw=true)

Normally, this cost is distributed among individual users. If a single actor would want to artificialy keep the block size at some median, he'd have to take this running cost alone.

We can define a median increase cycle as consisting of 51 consecutive blocks with some increase. This is the minimum number of blocks to affect the median. We will calculate the cost of one cycle with a minimum feasible increase, as presented below.

![Figure 3.1-6](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-6.png?raw=true)

The area below those charts will give us the cumulative cost to increase the block size from minimum free block size to some median, as seen below.

![Figure 3.1-7](https://github.com/JollyMort/monero-research/blob/master/Monero%20Dynamic%20Block%20Size%20and%20Dynamic%20Minimum%20Fee/Images/Fig3.1-7.png?raw=true)

We can see how with the new penalty & fee formulas, the growth becomes cheaper at lower rates, and it converges to original formulas if the growth should be more rapid. It's important to note that any growth can be "reset" by a single cycle of 51 small blocks, after which some attacker would have his previous efforts to increase the block size erased.

This proposal would give a nearly free ride to about 0.5MB block size, while nearly halving the cumulative cost to reach the transition point. This may not be desireable, and a second option is proposed below.


#### 3.2 Feasible Current Minimum Fee Option

The idea is to find such penalty formula where the current minimum fee would be adequate to accomodate a neutral block size increase for a single typical transaction size.

From `E_A = F_A - P`, `E_A = 0`, `W = W_T` and `F = F_min_c` we get

P_{2-0} = F_min_c * (W_T - 1) * M.

Expanding gives

P_{2-0} = (W_0 - 1) * (W_T - 1) * R.

This is a requirement to satisfy the initial proposition. Whatever the penalty function is, the result for `W = W_T` must equal the above `P_{2-0}`.

The function

`P_{2-1} = (W - 1) * (W_T - 1) * R` is

one which would satisfy that requirement. While that would work well for the special case where `W = W_0`, it must also scale up to the full penalty for `W = 2`.

Another solution is to multiply `W_0` in the `P_{2-0}` expression with some linear function `f(W)= k * W + l`, and replace the `W_T` term with `W`. This would again make the resulting function quadratic:

`P_{2-3} = (W_0 * (k_2 * W + l_2) - 1) * (W - 1) * R`.

As mentioned above, it must satisfy the requirement `P_{2-3}(W := 2) = P_c(W := 2)` and solving that equation gives

`l_2 = 2 / W_0 - 2 * k`.

The other requirement is `P_{2-3}(W := W_T) = P_{2-0}, and solving that equation gives

k_2 = ((W_0 - 1) - 1) / ((W_0 - 1) * (W_T - 2)).

To summarize, we have:

`P_n_2 = (k * (W_T - 2) + 1 / (W_0 - 1)) * (W - 1) * (W_0 - 1) * R` for `W < W_T and W_0 < W_T`, 

`P_n_2 = (k * (W - 2) + 1 / (W_0 - 1)) * (W - 1) * (W_0 - 1) * R` for `W_T <= W and W_0 < W_T`, and

`P_n_2 = P_c` for `W_T <= W_0`.

With the penalty formula defined, it now remains to again find expressions for neutral and optimum fees.

Solving `E_A = 0` for `F` gives the neutral fee expression:

`F_n_2 = (k_2 * (W_T - 2) + 1 / (W_0 - 1)) * (W - 1) * (W_0 - 1) * (R / M) * (1 / (W_T - 1))`, for `W < W_T and W_0 < W_T`,

`F_n_2 = (k_2 * (W - 2) + 1 / (W_0 - 1)) * (W - 1) * (W_0 - 1) * (R / M) * (1 / (W - 1))`, for `W_T <= W and W_0 < W_T`, and

`F_n_2 = F_n_c` for `W_T <= W_0`.

Solving dE_A / dW for `F` gives the optimum fee expression:

Undefined for `W < W_T and W_0 < W_T`,

`F_o_2 = (R / M) * (k_2 * (3 - 2 * W) + k_2 * (2 * W - 3) * W_0 + 1)`, for `W_T <= W and W_0 < W_T`, and

`F_o_2 = F_o_c` for `W_T <= W_0`.

### 4. Impact of Modifying The Constants

Recall that we have defined 3 arbitrary constants:

`M_0 = 60000 bytes` - Minimum free block size.

`W_0 = 1.0012` - Minimum fee neutral expansion factor.

`T_0 = 15000 bytes` - Typical transaction size.

The minimum free block size `M_0` defines the starting point for dynamic formulas. Changing it would maintain the same shape of curves for `M_0 < M`. However, since for `M < M_0` we're acting as if `M = M_0` and `W = B / M_0` it affects the starting minimum fee as well:

`F_min_c = (R / M_0) * (W_0 - 1)` for `M < M_0`.

We can see that doubling the `M_0` will halve the starting minimum fee, which will start to follow the dynamic formula at `M = M_0`. The rest would be unaffected.

The minimum fee expansion factor `W_0` scales everything together. Halving the `W_0` would halve the minimum growth rate, and would halve the minimum fee for any given network state. It would also double the transition zone, ie the block size at which the penalty formula transitions into old one would be doubled. With this, even the old min. fee formula would be scaled since `W_0` is used as a constant in the old fee formula as well.

The typical transaction size `T_0` affects the point at which new formulas transition into old ones. It also affects the minimum fee for any network state. Doubling it would halve the minimum fee but the post-transition growth rate with the minimum fee would remain the same. For example, if the actual typical transaction size would remain unchanged and we would only double the `T_0`, the meaning would be that, with the minimum fee, it would become feasible to add 2 transactions instead of 1 and the minimum fee per TX would be halved as well.


### 5. Wallet Fee Settings

### 6. Conclusion

### 7. Appendices

1. VB Code for Constants (MS Excel user-defined functions)
2. VB Code for Current Formulas (MS Excel user-defined functions)
3. VB Code for Proposed Formulas (MS Excel user-defined functions)