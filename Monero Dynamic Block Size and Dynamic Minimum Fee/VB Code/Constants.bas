Attribute VB_Name = "Constants"
Option Explicit
Function getT0RCT() As Double
'Typical RCT transaction size, bytes
    getT0RCT = 13000
End Function
Function getT0NonRCT() As Double
'Typical non-RCT transaction size, bytes
    getT0NonRCT = 1000
End Function
Function getW0() As Double
'Minimum expansion factor, -
    getW0 = 1.012
End Function
Function getM0() As Double
'Minimum free block size, bytes
    getM0 = 60000
End Function
