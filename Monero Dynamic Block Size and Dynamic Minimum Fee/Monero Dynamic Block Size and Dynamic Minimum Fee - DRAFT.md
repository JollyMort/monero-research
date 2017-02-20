## Monero Dynamic Block Size and Dynamic Minimum Fee

### Brief

Monero uses dynamic block size as part of consensus rules which penalizes miners should they increase the block size above the median of last 100 blocks. This is coupled with a do-not-relay minimum recommended fee. Client software uses multipliers of the minimum fee to give priority to transactions in case of heavy network use during peak periods.
We will analyze properties of the formulas chosen and impact of different fee multipliers on neutral and optimum strategies for the miners. We observe how the formulas allow for smooth increase and neutral and optimum strategies are independent of the network state.
Further, we will show how relation between typical transaction size and minimum block size affects this by making block size increases discrete. To address this problem, modified formulas are presented and recommendation made for any future changes in typical transaction sizes.

Conclusion is that present dynamic block size penalty formula doesn't work as intended in situations where typical transaction size is close to median block size. The penalty formula must be changed to allow transition into a network state where median block size will be sufficiently greater than the typical transaction size.

### Analysis of Current Dynamic Block Size and Dynamic Minimum Fee

Block reward penalty is given by:

`P = R * ((B / M) - 1) ^ 2`,

where `R` is the base reward, `B` the block size and `M` the median block size of last 100 blocks. The penalty doesn't come in effect unless `B > M_0`, where `M_0 = 60000 bytes` is the minimum penalty-free block size. Maximum block size is `2 * M`.

The minimum fee had originally been given as:

`F_min = (R / R_0) * (M_0 / M) * F_0`,

where `R_0 = 10 monero` is the reference base reward, and `F0 = 0.002 monero / kB`.

Considering that `R_0`, `M_0` and `F_0` are constants, the expression can be rewritten as:

`F_min = (R / M) * (W_0 - 1)`, where

`W_0 - 1 = (M_0 * F_0) / R_0 = 0.0012`.

The value of `W_0` represents the block size expansion factor for which the minimum fee would entirely cover for the block penalty, making a block size of `B = M * W_0` neutral for the miner.

We can see this by solving the problem phrased as: "Find the additional fee earned by expanding the block size such that it covers for the block reward lost due to expanding the block size.". We will call this the neutral fee function.

Recall
 
`P = R * ((B / M) - 1) ^ 2`, and define

`F_A = B * F - M * F = F * (B - M)`,

where `F_A` is the additional profit from fees should the block be expanded to a size of `B` and filled with transactions paying transaction fee `F`.

We will also define additional miner earnings as:

E_A = F_A - P.

Substituting with `W = B / M` and solving `E_A = 0` for `F`, we find:

`F_n = (R / M) * (W - 1)`.

Which is the fee required to make an expansion of the block size to `B = W * M` neutral for the miner, as doing so would yield the same total reward for the miner as would mining a block of size `B = M` with transaction fees of `F_n`.
However, while the miner doesn't lose anything compared to the base case, there is an opportunity loss because he could opt for some `M < B < W * M` which would give him a bigger overall reward.

We can now observe that:

F_min = F_n(W := W_0).

To find the optimum fee for a given block size expansion, we must find the maximum of the additional earnings function:

`E_A = F_A - P`.

Solving `dE_A/dW = 0` for `F` gives:

`F_o = 2 * (R / M) * (W - 1)`.

Which shows a linear relationship between the transaction fee and optimum block size increase.

To present the impact of different fee multipliers on optimum block size expansion, we will substitute the fee with a multiplier of the minimum fee:

F = F_min * F_mult,

and plug it into the neutral and optimum fee equations. Rearranging gives:

`F_mult_n = (W - 1) / (W_0 - 1)` for the neutral fee, and

`F_mult_o = 2  * (W - 1) / (W_0 - 1)` for the optimum fee.

which we plot on the chart below.

![fig1-1](https://cloud.githubusercontent.com/assets/20967651/22898042/2caa81e2-f226-11e6-9951-e4f8cc0159c1.png)

We will further examine miner incentives by plotting the relationship between block size expansion and additional miner earnings for various fee multipliers. On the same chart, we will show the optimum curve which connects maximums of each fee multiplier curve.

![fig1-2](https://cloud.githubusercontent.com/assets/20967651/22898052/34af9e2c-f226-11e6-8dd8-b1afc31bd9f7.png)

We see that each fee multiplier curve has one point of maximum earnings for the miner. Another interesting point is the 2nd crossing with the horizontal axis, at which the miner would earn the same total by increasing the block size as he would if he mined a block with 0% expansion.

We can observe linear relationship between the min. fee multiplier and optimum block size increase. For example, with the minimum fee, it's optimum for the miner to keep increasing the block size for 0.6% above median. He can keep doing this as long as there are enough transactions to fill the blocks. To increase the block size for 6%, a fee multiplier of x10 is required, to increase for 60% it's x100, etc.

It's important to note that these charts are invariant to network state. They look the same for any block reward and actual block size median.

The question is, given a mempool with enough transactions and for any fee multiplier, can a miner build such a block that would place the block on the optimum curve? The answer is no, and below we will analyze why.

### The Problem

While the existing formulas show a permanent incentive to increase the block size for 0.6% as long as there's enough transactions in the mempool, this smooth increase is not feasible to achieve in practice. This is because a miner can affect the block size only by picking transactions from the mempool. Because of the ratio between typical transaction size and minimum block size being greater than 0.6%, the miner has no easy way to achieve this target of block size increase. Of course, not all transaction have the same size nor offer the same fee, and transactions variance could be exploited to build an occasional optimum block but for some typical case it will not be feasible. In practice, the block size increases are feasible to do only in some discrete steps. To analyze this, we will define a parameter:

`T = T_0 / M`,

where T_0 is the size of a typical Monero transaction, and M the median block size as previously defined. The parameter `T` is the size of block expansion steps. This defines the set of possible block size expansions as `{0 * T, 1 * T, 2 * T, ..., n * T}`. Each of these discrete steps can be coupled with a fee multiplier needed to make the step neutral or optimum for the miner. Any fee multiplier greater than the neutral will yield additional profit for the miner with the optimum fee multiplier maximizing the profit for a given block size increase.

The ratio `T` changes either with changing the `T_0` as part of protocol change affecting typical transaction sizes, or with the median block size `M`. The parameter `T` defines feasible block size increase steps but it is not stateless as it depends on the actual median block size. Below we will examine the case for `M = 60kB` and `T_0` of 2kB and 13kB as typical sizes of non-RCT and RCT transactions.

![fig2-1](https://cloud.githubusercontent.com/assets/20967651/22898535/f7a5e020-f227-11e6-9568-40fccc60a414.png)

Above we see how the jump in transaction sizes has created a barrier to expanding the block sizes smoothly. This can also be seen on the chart below.

![fig2-2](https://cloud.githubusercontent.com/assets/20967651/22899531/6e17605a-f22b-11e6-9149-526a81731877.png)

Pre-RCT, the first step was at 3.3% increase with neutral multiplier of x2.78, and post-RCT it is at 20% increase with neutral multiplier of x16.67. In addition, the fee/TX has jumped 6-fold. If somehow the network should get to a state of bigger block size, the discrete steps would become more dense and allow for smoother changes. The problem is in getting to that state in the first place. As the blocks expand, optimum steps for smaller multipliers will become feasible. With the current formulas, the median block size should be at `M = 1079kB` to make the neutral step for minimum fee available or `M=2171kB` to make the optimum step for minimum fee available.

### Solution

The objective is to make smaller increments possible, while still keeping the network usage rational by preventing free block size expansion.

The idea is to scale down the penalty formula such that the neutral fee to add 1 TX over the median remains constant up to the point where it 1 TX would mean an 1.2% increase, where the original formulas would kick in again. At the same time, doubling the median should still cause the full penalty.

A convenient way to achieve this transition is multiplying the current penalty formula with an exponentiation function:

`P_new = a ^ (2 - W) * (W - 1) ^ 2 * R`.

The exponent `(2-W)` will ensure that increasing the block size to 2x the median will always result in a full block reward penalty.

The parameter `a` must be still be determined. It will be determined as a solution to the problem defined as: "Find such `a` for which the neutral fee to increase the block size for size of 1 typical TX above median will be the same as it would be for a network state where the size of 1 typical TX would be 1.2% of the median block size and with the original penalty formula.". We will first define one more parameter:

`W_T = 1 + T = 1 + T_0 / M`,

which is the block expansion factor such that the block size can fit 1 typical transaction above the median size.

With this, it's easy to express the above mentioned problem as:

`a ^ (2 - W_T) * (W_T - 1) ^ 2 * R = (W_0 - 1) ^ 2 * R`.

Solving for `a` gives:

`a = ((W_0 - 1) ^ 2 / (T - 1) ^ 2) ^ (1 / (2 - T))`.

The new penalty formula will be valid while the condition `T > W_0` holds. For `T <= W_0`, the original penalty calculation will be used. The point where `T = W_0` will give the same penalty, regardless of which formulation is used because `a = 1` for that case.

With the penalty formula defined, it now remains to again find expressions for neutral and optimum fees.

Again, solving E_A = 0 gives the neutral fee expression:

`F_n = a ^ (2 - W) * (R / M) * (W - 1)`, and

solving dE_A / dW gives the optimum fee expression:

`F_o = (R / M) * (W - 1) * a ^ (2 - W) * (2 + Log(a) - W * Log(a))`.

...

![fig3-1](https://cloud.githubusercontent.com/assets/20967651/23096501/550d6fc2-f61e-11e6-8085-c13f51d931da.png)

![fig3-2](https://cloud.githubusercontent.com/assets/20967651/23097734/022f561c-f63c-11e6-8962-34e706bd3eff.png)