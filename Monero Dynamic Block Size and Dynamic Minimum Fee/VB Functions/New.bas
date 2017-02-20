Attribute VB_Name = "NewFormulation"
Function getT0() As Double
    getT0 = 13000
End Function
Function getW0() As Double
    getW0 = 1.012
End Function

Function getNeutralFee(ByVal baseReward As Double, ByVal medianBlockSize As Double, ByVal targetExpansionFactor As Double) As Double

Dim F_n As Double
Dim M As Double
Dim R As Double
Dim W As Double
Dim T As Double
Dim T0 As Double
Dim W0 As Double
Dim a As Double

'Function inputs
R = baseReward
M = medianBlockSize
W = targetExpansionFactor

'Typical transaction size
'To be adjusted together with any TX format changes which affect the typical TX size
T0 = getT0()

'Expansion factor until which it will be neutral to increase the block size for exactly 1 typical TX size above the median
'Note that once median block size grows until the target factor, the transition formulas will be in effect
'Once the target is reached, both old and new formulas will yield the same results, so the transition is without a break
W0 = getW0()

'Block expansion factor for 1 TX above the median
T = 1 + T0 / M

'Exponentiation base
a = ((W0 - 1) ^ 2 / (T - 1) ^ 2) ^ (1 / (2 - T))

If T > W0 Then
    'Neutral fee matching new penalty formulation
    F_n = a ^ (2 - W) * (R / M) * (W - 1)
Else
    'Neutral fee matching old penalty formulation
    F_n = (R / M) * (W - 1)
End If

getNeutralFee = F_n

End Function

Function getOptimumFee(ByVal baseReward As Double, ByVal medianBlockSize As Double, ByVal targetExpansionFactor As Double) As Double

Dim F_o As Double
Dim M As Double
Dim R As Double
Dim W As Double
Dim T As Double
Dim T0 As Double
Dim W0 As Double
Dim a As Double

'Function inputs
R = baseReward
M = medianBlockSize
W = targetExpansionFactor

'Typical transaction size
'To be adjusted together with any TX format changes which affect the typical TX size
T0 = getT0()

'Expansion factor until which it will be neutral to increase the block size for exactly 1 typical TX size above the median
'Note that once median block size grows until the target factor, the transition formulas will be in effect
'Once the target is reached, both old and new formulas will yield the same results, so the transition is without a break
W0 = getW0()

'Block expansion factor for 1 TX above the median
T = 1 + T0 / M

'Exponentiation base
a = ((W0 - 1) ^ 2 / (T - 1) ^ 2) ^ (1 / (2 - T))

If T > W0 Then
    F_o = (R / M) * (W - 1) * a ^ (2 - W) * (2 + Log(a) - W * Log(a))
Else
    F_o = 2 * (R / M) * (W - 1)
End If

getOptimumFee = F_o

End Function

Function getBlockRewardPenalty(ByVal baseReward As Double, ByVal medianBlockSize As Double, ByVal blockSize As Double) As Double

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

'Typical transaction size
'To be adjusted together with any TX format changes which affect the typical TX size
T0 = getT0()

'Expansion factor until which it will be neutral to increase the block size for exactly 1 typical TX size above the median
'Note that once median block size grows until the target factor, the transition formulas will be in effect
'Once the target is reached, both old and new formulas will yield the same results, so the transition is without a break
W0 = getW0()

'Actual block expansion factor
W = B / M

'Block expansion factor for 1 TX above the median
T = 1 + T0 / M

'Exponentiation base
a = ((W0 - 1) ^ 2 / (T - 1) ^ 2) ^ (1 / (2 - T))

If T > W0 Then
    'Penalty according to the new formulation
    P = a ^ (2 - W) * (W - 1) ^ 2 * R
Else
    'Penalty according to the old formulation
    'Note that for T = W0, both formulations yield the same result
    P = (W - 1) ^ 2 * R
End If

getBlockRewardPenalty = P

End Function
