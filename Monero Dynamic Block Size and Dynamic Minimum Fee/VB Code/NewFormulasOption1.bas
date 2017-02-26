Attribute VB_Name = "NewFormulasOption1"
Option Explicit


Function getBlockRewardPenalty(ByVal R As Double, ByVal M As Double, ByVal W As Double, ByVal W_0 As Double, ByVal T_0 As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless
'W_0 - minimum block size expansion factor, unitless
'T_0 - typical transaction size, bytes

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Correction for cases below min. free block size,
'ie count only what's pouring over the min. limit.
If M < M_0 Then
    W = W * M / M_0
    M = M_0
End If

'Block expansion factor needed to fit a single typical TX above the median
Dim W_T As Double
W_T = 1 + T_0 / M

'Dynamic scaling parameter, unitless
Dim k As Double
k = ((W_T * (2 - W_T) + (W_0 - 2) * W_0) / ((W_T - 2) * (W_T - 1) ^ 2))

'P - block reward penalty, monero
Dim P As Double

'Penalty function
If M * W <= M_0 Then
    P = 0
Else
    If W_0 < W_T Then
        'Transition - penalty according to the new formula
        If W_T <= W Then
            'Dynamic scaling factor (k * (W - 2) + 1) keeps the
            'expansion price for W = W_T constant but linearly
            'scales back to 1 for W = 2.
            P = (k * (W - 2) + 1) * (W - 1) ^ 2 * R
        Else
            'Scaling factor (k * (W - 2) + 1) fixed as if W = W_T
            'otherwise we we would end up with negative and 0 penalties
            'due to linear function being used.
            P = (k * (W_T - 2) + 1) * (W - 1) ^ 2 * R
        End If
    Else
        'Penalty according to the old formula
        P = getBlockRewardPenaltyOld(R, M, W)
    End If
End If

getBlockRewardPenalty = P

End Function


Function getNeutralFee(ByVal R As Double, ByVal M As Double, ByVal W As Double, ByVal W_0 As Double, ByVal T_0 As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless
'W_0 - minimum block size expansion factor, unitless
'T_0 - typical transaction size, bytes

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Correction for cases below min. free block size,
'ie count only what's pouring over the min. limit.
If M < M_0 Then
    W = W * M / M_0
    M = M_0
End If

'Block expansion factor needed to fit a single typical TX above the median
Dim W_T As Double
W_T = 1 + T_0 / M

'Dynamic scaling parameter, unitless
Dim k As Double
k = ((W_T * (2 - W_T) + (W_0 - 2) * W_0) / ((W_T - 2) * (W_T - 1) ^ 2))

'F_n - neutral fee, monero / byte
Dim F_n As Double

If M * W <= M_0 Then
    F_n = 0
Else
    If W_0 < W_T Then
        'Neutral fee matching new penalty formula
        If W_T <= W Then
            F_n = (k * (W - 2) + 1) * (R / M) * (W - 1)
        Else
            F_n = (k * (W_T - 2) + 1) * (R / M) * (W - 1)
        End If
    Else
        'Neutral fee matching old penalty formula
        F_n = getNeutralFeeOld(R, M, W)
    End If
End If

getNeutralFee = F_n

End Function
Function getOptimumFee(ByVal R As Double, ByVal M As Double, ByVal W As Double, ByVal W_0 As Double, ByVal T_0 As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless
'W_0 - minimum block size expansion factor, unitless
'T_0 - typical transaction size, bytes

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Correction for cases below min. free block size,
'ie count only what's pouring over the min. limit.
If M < M_0 Then
    W = W * M / M_0
    M = M_0
End If

'Block expansion factor needed to fit a single typical TX above the median
Dim W_T As Double
W_T = 1 + T_0 / M

'Dynamic scaling parameter, unitless
Dim k As Double
k = ((W_T * (2 - W_T) + (W_0 - 2) * W_0) / ((W_T - 2) * (W_T - 1) ^ 2))

'F_o - optimum fee, monero / byte
Dim F_o As Double

If M * W <= M_0 Then
    F_o = 0
Else
    If W_0 < W_T Then
        'Optimum fee matching new penalty formula
        If W_T <= W Then
            F_o = (k * (3 * W - 5) + 2) * (R / M) * (W - 1)
        Else
            'For W < W_T, there is no optimum (miner extra profit function doesn't have a maximum).
            F_o = 0
        End If
    Else
        'Optimum fee matching old penalty formula
        F_o = getOptimumFeeOld(R, M, W)
    End If
End If

getOptimumFee = F_o

End Function
Function getMinimumFee(ByVal R As Double, ByVal M As Double, ByVal W_0 As Double, ByVal T_0 As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Will keep the fee constant until we start pouring over the min. free block size.
If M <= M_0 Then M = M_0

'Block expansion factor needed to fit a single typical TX above the median
Dim W_T As Double
W_T = 1 + T_0 / M

'F_min - minimum fee, monero / byte
Dim F_min As Double

If W_0 < W_T Then
    'min. fee to be just enough to make adding a single typical TX above the median neutral
    F_min = getNeutralFee(R, M, W_T, W_0, T_0)
Else
    'min. fee to be just enough to make expanding the block with an expansion factor of W_0 neutral
    F_min = getNeutralFee(R, M, W_0, W_0, T_0)
End If

getMinimumFee = F_min

End Function
