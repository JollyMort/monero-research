Attribute VB_Name = "OldFormulation"
Function getNeutralFeeOld(ByVal baseReward As Double, ByVal medianBlockSize As Double, ByVal targetExpansionFactor As Double) As Double

Dim F_n As Double
Dim M As Double
Dim R As Double
Dim W As Double
Dim T As Double
Dim W0 As Double

'Function inputs
R = baseReward
M = medianBlockSize
W = targetExpansionFactor

W0 = 1.0012

F_n = (R / M) * (W - 1)

getNeutralFeeOld = F_n

End Function

Function getOptimumFeeOld(ByVal baseReward As Double, ByVal medianBlockSize As Double, ByVal targetExpansionFactor As Double) As Double

Dim F_o As Double
Dim M As Double
Dim R As Double
Dim W As Double
Dim T As Double
Dim W0 As Double

'Function inputs
R = baseReward
M = medianBlockSize
W = targetExpansionFactor

W0 = 1.0012

F_o = 2 * (R / M) * (W - 1)

getOptimumFeeOld = F_o

End Function

Function getBlockRewardPenaltyOld(ByVal baseReward As Double, ByVal medianBlockSize As Double, ByVal blockSize As Double) As Double

Dim B As Double
Dim M As Double
Dim R As Double
Dim P As Double
Dim W As Double
Dim T As Double
Dim T0 As Double
Dim W0 As Double
Dim a As Double

'Function inputs
R = baseReward
B = blockSize
M = medianBlockSize

'Actual block expansion factor
W = B / M

P = (W - 1) ^ 2 * R

getBlockRewardPenaltyOld = P

End Function

