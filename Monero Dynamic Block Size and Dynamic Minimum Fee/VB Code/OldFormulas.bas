Attribute VB_Name = "OldFormulas"
Option Explicit
Function getBlockRewardPenaltyOld(ByVal R As Double, ByVal M As Double, ByVal W As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Correction for cases below min. free block size,
'ie count only what's pouring over the min. limit.
If M < M_0 Then
    W = W * M / M_0
    M = M_0
End If

'P - block reward penalty, monero
Dim P As Double

If M * W <= M_0 Then
    P = 0
Else
    P = (W - 1) ^ 2 * R
End If

getBlockRewardPenaltyOld = P

End Function
Function getNeutralFeeOld(ByVal R As Double, ByVal M As Double, ByVal W As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Correction for cases below min. free block size,
'ie count only what's pouring over the min. limit.
If M < M_0 Then
    W = W * M / M_0
    M = M_0
End If

'F_n - neutral fee, monero / byte
Dim F_n As Double

If M * W <= M_0 Then
    F_n = 0
Else
    F_n = (R / M) * (W - 1)
End If

getNeutralFeeOld = F_n

End Function
Function getOptimumFeeOld(ByVal R As Double, ByVal M As Double, ByVal W As Double) As Double
'R - base block reward, monero
'M - median block size, bytes
'W - target expansion factor, unitless

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Correction for cases below min. free block size,
'ie count only what's pouring over the min. limit.
If M < M_0 Then
    W = W * M / M_0
    M = M_0
End If

'F_o - optimum fee, monero / byte
Dim F_o As Double

If M * W <= M_0 Then
    F_o = 0
Else
    F_o = 2 * (R / M) * (W - 1)
End If

getOptimumFeeOld = F_o

End Function
Function getMinimumFeeOld(ByVal R As Double, ByVal M As Double) As Double
'R - base block reward, monero
'M - median block size, bytes

'M_0 - minimum free block size, bytes
Dim M_0 As Double
M_0 = getM0()

'Will keep the fee constant until we start pouring over the min. free block size.
If M <= M_0 Then M = M_0

'F_min - minimum fee, monero / byte
Dim F_min As Double

F_min = getNeutralFeeOld(R, M, getW0())

getMinimumFeeOld = F_min

End Function
