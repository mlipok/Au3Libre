;~ #AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include-once
#include "LibreOfficeWriterConstants.au3"
#include "LibreOfficeWriter_Internal.au3"

; #INDEX# =======================================================================================================================
; Title .........: Libre Office Writer (LOWriter)
; AutoIt Version : v3.3.16.1
; UDF Version    : 0.0.0.3
; Description ...: Provides basic functionality through Autoit for interacting with Libre Office Writer.
; Author(s) .....: donnyh13
; Sources . . . .:  jguinch -- Printmgr.au3, used (_PrintMgr_EnumPrinter);
;					mLipok -- OOoCalc.au3, used (__OOoCalc_ComErrorHandler_UserFunction,_InternalComErrorHandler,
;						-- WriterDemo.au3, used _CreateStruct;
;					Andrew Pitonyak & Laurent Godard (VersionGet);
;					Leagnus & GMK -- OOoCalc.au3, used (SetPropertyValue)
; Dll ...........:
; Note...........: Tips/templates taken from OOoCalc UDF written by user GMK; also from Word UDF by user water.
;					I found the book by Andrew Pitonyak very helpful also, titled, "OpenOffice.org Macros Explained;
;						OOME Third Edition".
;					Of course, this UDF is written using the English version of LibreOffice, and may only work for the English
;						version of LibreOffice installations. Many functions in this UDF may or may not work with OpenOffice
;						Writer, however some settings are definitely for LibreOffice only.
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_LOWriter_ComError_UserFunction
;_LOWriter_ConvertColorFromLong
;_LOWriter_ConvertColorToLong
;_LOWriter_ConvertFromMicrometer
;_LOWriter_ConvertToMicrometer
;_LOWriter_VersionGet
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOWriter_ComError_UserFunction
; Description ...: Set a UserFunction to receive the Fired COM Error Error outside of the UDF.
; Syntax ........: _LOWriter_ComError_UserFunction([$vUserFunction = Default[, $vParam1 = Null[, $vParam2 = Null[, $vParam3 = Null[, $vParam4 = Null[, $vParam5 = Null]]]]]])
; Parameters ....: $vUserFunction       - [optional] a Function or Keyword. Default value is Default. Accepts a Function, or the
;				   +						Keyword Default and Null. If set to a User function, the function may have up to 5
;				   +						required parameters.
;                  $vParam1             - [optional] a variant value. Default is Null. Any optional parameter to be called with
;				   +						the user function.
;                  $vParam2             - [optional] a variant value. Default is Null. Any optional parameter to be called with
;				   +						the user function.
;                  $vParam3             - [optional] a variant value. Default is Null. Any optional parameter to be called with
;				   +						the user function.
;                  $vParam4             - [optional] a variant value. Default is Null. Any optional parameter to be called with
;				   +						the user function.
;                  $vParam5             - [optional] a variant value. Default is Null. Any optional parameter to be called with
;				   +						the user function.
; Return values .: Success: 1 or UserFunction.
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = In correct entry. Not a Function, or Default keyword or Null Keyword.
;				   --Success--
;				   @Error 0 @Extended 0 Return 1 = Successfully set the UserFunction.
;				   @Error 0 @Extended 0 Return 2 = Successfully cleared the set UserFunction.
;				   @Error 0 @Extended 0 Return Function = Returns the set UserFunction.
; Author ........: mLipok
; Modified ......: donnyh13 - Added a clear UserFunction without error option. Also added parameters option.
; Remarks .......: The first parameter passed to the User function will always be the COM Error object. See below.
;						Every COM Error will be passed to that function. The user can then read the following properties. (As
;							Found in the COM Reference section in Autoit HelpFile.) Using the first parameter in the
;							UserFunction. For Example MyFunc($oMyError)
;							$oMyError.number The Windows HRESULT value from a COM call
;							$oMyError.windescription The FormatWinError() text derived from .number
;							$oMyError.source Name of the Object generating the error (contents from ExcepInfo.source)
;							$oMyError.description Source Object's description of the error (contents from ExcepInfo.description)
;							$oMyError.helpfile Source Object's helpfile for the error (contents from ExcepInfo.helpfile)
;							$oMyError.helpcontext Source Object's helpfile context id number (contents from
;								ExcepInfo.helpcontext)
;							$oMyError.lastdllerror The number returned from GetLastError()
;							$oMyError.scriptline The script line on which the error was generated
;				    		NOTE: Not all properties will necessarily contain data, some will be blank.
;						If MsgBox or ConsoleWrite functions are passed to this function, the error details will be displayed
;							using that function automatically.
;						If called with Default keyword, the current UserFunction, if set, will be returned.
;				    	If called with Null keyword, the currently set UserFunction is cleared and only the internal
;							ComErrorHandler will be called for COM Errors.
;						The stored UserFunction (besides MsgBox and ConsoleWrite) will be called as follows:
;							UserFunc($oComError,$vParam1,$vParam2,$vParam3,$vParam4,$vParam5)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOWriter_ComError_UserFunction($vUserFunction = Default, $vParam1 = Null, $vParam2 = Null, $vParam3 = Null, $vParam4 = Null, $vParam5 = Null)
	#forceref $vParam1, $vParam2, $vParam3, $vParam4, $vParam5
	; If user does not set a function, UDF must use internal function to avoid AutoItError.
	Local Static $vUserFunction_Static = Default
	Local $avUserFuncWParams[@NumParams]

	If $vUserFunction = Default Then
		; just return stored static User Function variable
		Return $vUserFunction_Static
	ElseIf IsFunc($vUserFunction) Then
		;If User called Parameters, then add to array.
		If @NumParams > 1 Then
			$avUserFuncWParams[0] = $vUserFunction
			For $i = 1 To @NumParams - 1
				$avUserFuncWParams[$i] = Eval("vParam" & $i)
				; set static variable
			Next
			$vUserFunction_Static = $avUserFuncWParams
		Else
			$vUserFunction_Static = $vUserFunction
		EndIf
		Return SetError($__LOW_STATUS_SUCCESS, 0, 1)
	ElseIf $vUserFunction = Null Then
		;Clear User Function.
		$vUserFunction_Static = Default
		Return SetError($__LOW_STATUS_SUCCESS, 0, 2)
	Else
		; return error as an incorrect parameter was passed to this function
		Return SetError($__LOW_STATUS_INPUT_ERROR, 1, 0)
	EndIf
EndFunc   ;==>_LOWriter_ComError_UserFunction

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOWriter_ConvertColorFromLong
; Description ...: Convert Long color code to Hex, RGB, HSB or CMYK.
; Syntax ........: _LOWriter_ConvertColorFromLong([$iHex = Null[, $iRGB = Null[, $iHSB = Null[, $iCMYK = Null]]]])
; Parameters ....: $iHex                - [optional] an integer value. Default is Null.
;                  $iRGB                - [optional] an integer value. Default is Null.
;                  $iHSB                - [optional] an integer value. Default is Null.
;                  $iCMYK               - [optional] an integer value. Default is Null.
; Return values .: Success: Hex or Array.
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = No parameters set.
;				   @Error 1 @Extended 2 Return 0 = No parameters set to an integer.
;				   --Success--
;				   @Error 0 @Extended 1 Return Hex Color Integer. Long integer converted To Hexadecimal. (Without the "0x"
;				   +								prefix)
;				   @Error 0 @Extended 2 Return Array. Array containing Long integer converted To Red, Green, Blue,(RGB).
;				   +								$Array[3] = [R,G,B] = $Array[0] = R, etc.
;				   @Error 0 @Extended 3 Return Array. Array containing Long integer converted To Hue, Saturation, Brightness,
;				   +								(HSB). $Array[3] = [H,S,B] $Array[0] = H, etc.
;				   @Error 0 @Extended 4 Return Array. Array containing Long integer converted To Cyan, Yellow, Magenta, Black,
;				   +								(CMYK). $Array[4] = [C,M,Y,K] $Array[0] = C, etc.
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To retrieve a Hex(adecimal) color code, place the Long Color code into $iHex, To retrieve a R(ed)G(reen)B(lue)
;					color code, place Null in $iHex, and the Long color code into $iRGB, etc. for the other color types.
;					Hex returns as a string variable, all others (RGB, HSB, CMYK) return an array. Array[0] = R, Array [1] = G
;					etc.
;					Note: The Hexadecimal figure returned doesn't contain the usual "0x", as LibeOffice does not implement it in
;						its numbering system.
; Related .......: _LOWriter_ConvertColorToLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOWriter_ConvertColorFromLong($iHex = Null, $iRGB = Null, $iHSB = Null, $iCMYK = Null)
	Local $nRed, $nGreen, $nBlue, $nResult, $nMaxRGB, $nMinRGB, $nHue, $nSaturation, $nBrightness, $nCyan, $nMagenta, $nYellow, $nBlack
	Local $dHex
	Local $aiReturn[0]

	If (@NumParams = 0) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 1, 0)
	Select
		Case IsInt($iHex) ;Long TO Hex
			$nRed = Int(Mod(($iHex / 65536), 256))
			$nGreen = Int(Mod(($iHex / 256), 256))
			$nBlue = Int(Mod($iHex, 256))

			$dHex = Hex($nRed, 2) & Hex($nGreen, 2) & Hex($nBlue, 2)
			Return SetError($__LOW_STATUS_SUCCESS, 1, $dHex)

		Case IsInt($iRGB) ;Long to RGB
			$nRed = Int(Mod(($iRGB / 65536), 256))
			$nGreen = Int(Mod(($iRGB / 256), 256))
			$nBlue = Int(Mod($iRGB, 256))
			ReDim $aiReturn[3]
			$aiReturn[0] = $nRed
			$aiReturn[1] = $nGreen
			$aiReturn[2] = $nBlue
			Return SetError($__LOW_STATUS_SUCCESS, 2, $aiReturn)
		Case IsInt($iHSB) ;Long TO HSB

			$nRed = (Mod(($iHSB / 65536), 256)) / 255
			$nGreen = (Mod(($iHSB / 256), 256)) / 255
			$nBlue = (Mod($iHSB, 256)) / 255

			;get Max RGB Value
			$nResult = ($nRed > $nGreen) ? $nRed : $nGreen
			$nMaxRGB = ($nResult > $nBlue) ? $nResult : $nBlue
			;get Min RGB Value
			$nResult = ($nRed < $nGreen) ? $nRed : $nGreen
			$nMinRGB = ($nResult < $nBlue) ? $nResult : $nBlue

			;Determine Brightness
			$nBrightness = $nMaxRGB
			;Determine Hue
			$nHue = 0
			Select
				Case $nRed = $nGreen = $nBlue ; Red, Green, and BLue are equal.
					$nHue = 0
				Case ($nRed >= $nGreen) And ($nGreen >= $nBlue) ;Red Highest, Blue Lowest
					$nHue = (60 * (($nGreen - $nBlue) / ($nRed - $nBlue)))
				Case ($nRed >= $nBlue) And ($nBlue >= $nGreen) ;Red Highest, Green Lowest
					$nHue = (60 * (6 - (($nBlue - $nGreen) / ($nRed - $nGreen))))
				Case ($nGreen >= $nRed) And ($nRed >= $nBlue) ;Green Highest, Blue Lowest
					$nHue = (60 * (2 - (($nRed - $nBlue) / ($nGreen - $nBlue))))
				Case ($nGreen >= $nBlue) And ($nBlue >= $nRed) ;Green Highest, Red Lowest
					$nHue = (60 * (2 + (($nBlue - $nRed) / ($nGreen - $nRed))))
				Case ($nBlue >= $nGreen) And ($nGreen >= $nRed) ;Blue Highest, Red Lowest
					$nHue = (60 * (4 - (($nGreen - $nRed) / ($nBlue - $nRed))))
				Case ($nBlue >= $nRed) And ($nRed >= $nGreen) ;Blue Highest, Green Lowest
					$nHue = (60 * (4 + (($nRed - $nGreen) / ($nBlue - $nGreen))))
			EndSelect

			;Determine Saturation
			$nSaturation = ($nMaxRGB = 0) ? 0 : (($nMaxRGB - $nMinRGB) / $nMaxRGB)

			$nHue = ($nHue > 0) ? Round($nHue) : 0
			$nSaturation = Round(($nSaturation * 100))
			$nBrightness = Round(($nBrightness * 100))

			ReDim $aiReturn[3]
			$aiReturn[0] = $nHue
			$aiReturn[1] = $nSaturation
			$aiReturn[2] = $nBrightness

			Return SetError($__LOW_STATUS_SUCCESS, 3, $aiReturn)
		Case IsInt($iCMYK) ;Long to CMYK

			$nRed = (Mod(($iCMYK / 65536), 256))
			$nGreen = (Mod(($iCMYK / 256), 256))
			$nBlue = (Mod($iCMYK, 256))

			$nRed = Round(($nRed / 255), 3)
			$nGreen = Round(($nGreen / 255), 3)
			$nBlue = Round(($nBlue / 255), 3)


			;get Max RGB Value
			$nResult = ($nRed > $nGreen) ? $nRed : $nGreen
			$nMaxRGB = ($nResult > $nBlue) ? $nResult : $nBlue

			$nBlack = (1 - $nMaxRGB)
			$nCyan = ((1 - $nRed - $nBlack) / (1 - $nBlack))
			$nMagenta = ((1 - $nGreen - $nBlack) / (1 - $nBlack))
			$nYellow = ((1 - $nBlue - $nBlack) / (1 - $nBlack))

			$nCyan = Round(($nCyan * 100))
			$nMagenta = Round(($nMagenta * 100))
			$nYellow = Round(($nYellow * 100))
			$nBlack = Round(($nBlack * 100))

			ReDim $aiReturn[4]
			$aiReturn[0] = $nCyan
			$aiReturn[1] = $nMagenta
			$aiReturn[2] = $nYellow
			$aiReturn[3] = $nBlack
			Return SetError($__LOW_STATUS_SUCCESS, 4, $aiReturn)
		Case Else
			Return SetError($__LOW_STATUS_INPUT_ERROR, 2, 0) ;no parameters set to an integer
	EndSelect

EndFunc   ;==>_LOWriter_ConvertColorFromLong

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOWriter_ConvertColorToLong
; Description ...: Convert Hex, RGB, HSB or CMYK to Long color code.
; Syntax ........: _LOWriter_ConvertColorToLong([$vVal1 = Null[, $vVal2 = Null[, $vVal3 = Null[, $vVal4 = Null]]]])
; Parameters ....: $vVal1               - [optional] a variant value. Default is Null. See remarks.
;                  $vVal2               - [optional] a variant value. Default is Null. See remarks.
;                  $vVal3               - [optional] a variant value. Default is Null. See remarks.
;                  $vVal4               - [optional] a variant value. Default is Null. See remarks.
; Return values .: Success: Integer.
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = No parameters set.
;				   @Error 1 @Extended 2 Return 0 = One parameter called, but not in String format(Hex).
;				   @Error 1 @Extended 3 Return 0 = Hex parameter contains non Hex characters.
;				   @Error 1 @Extended 4 Return 0 = Hex parameter not 6 characters long.
;				   @Error 1 @Extended 5 Return 0 = Hue parameter contains more than just digits.
;				   @Error 1 @Extended 6 Return 0 = Saturation parameter contains more than just digits.
;				   @Error 1 @Extended 7 Return 0 = Brightness parameter contains more than just digits.
;				   @Error 1 @Extended 8 Return 0 = Three parameters called but not all Integers (RGB) and not all Strings (HSB).
;				   @Error 1 @Extended 9 Return 0 = Four parameters called but not all Integers(CMYK).
;				   @Error 1 @Extended 10 Return 0 = Too many or too few parameters called.
;				   --Success--
;				   @Error 0 @Extended 1 Return Integer. Long Int. Color code converted from Hexadecimal.
;				   @Error 0 @Extended 2 Return Integer. Long Int. Color code converted from Red, Green, Blue, (RGB).
;				   @Error 0 @Extended 3 Return Integer. Long Int. Color code converted from (H)ue, (S)aturation, (B)rightness,
;				   @Error 0 @Extended 4 Return Integer. Long Int. Color code converted from (C)yan, (Y)ellow, (M)agenta, (B)lack
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To Convert a Hex(adecimal) color code, insert the Hex code into $vVal1 in String Format.
;					To convert a R(ed)G(reen)B(lue color code, insert R in $vVal1 in Integer format, G in $vVal2 in Integer
;					format, and B in $vVal3 in Integer format.
;					To convert H(ue)S(aturation)B(rightness) color code, insert H in $vVal1 in String format, B in $vVal2 in
;						String format, and B in $vVal3 in string format.
;					To convert C(yan)Y(ellow)M(agenta)(Blac)K enter C in $vVal1 in Integer format, Y in $vVal2 in Integer
;						Format, M in $vVal3 in Integer format, and K in $vVal4 in Integer format.
;					Note: The Hexadecimal figure entered cannot contain the usual "0x", as LibeOffice does not implement it in
;						its numbering system.
; Related .......: _LOWriter_ConvertColorFromLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOWriter_ConvertColorToLong($vVal1 = Null, $vVal2 = Null, $vVal3 = Null, $vVal4 = Null) ;RGB = Int, CMYK = Int, HSB = String, Hex = String.
	Local Const $STR_STRIPALL = 8
	Local $iRed, $iGreen, $iBlue, $iLong, $iHue, $iSaturation, $iBrightness
	Local $dHex
	Local $nMaxRGB, $nMinRGB, $nChroma, $nHuePre, $nCyan, $nMagenta, $nYellow, $nBlack

	If (@NumParams = 0) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 1, 0)
	Switch @NumParams
		Case 1 ;Hex
			If Not IsString($vVal1) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 2, 0) ;not a string
			$vVal1 = StringStripWS($vVal1, $STR_STRIPALL)
			$dHex = $vVal1

			;From Hex to RGB
			If (StringLen($dHex) = 6) Then
				If StringRegExp($dHex, "[^0-9a-fA-F]") Then Return SetError($__LOW_STATUS_INPUT_ERROR, 3, 0) ;$dHex contains non Hex characters.

				$iRed = BitAND(BitShift("0x" & $dHex, 16), 0xFF)
				$iGreen = BitAND(BitShift("0x" & $dHex, 8), 0xFF)
				$iBlue = BitAND("0x" & $dHex, 0xFF)

				$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
				Return SetError($__LOW_STATUS_SUCCESS, 1, $iLong) ;Long from Hex

			Else
				Return SetError($__LOW_STATUS_INPUT_ERROR, 4, 0) ;Wrong length of string.
			EndIf

		Case 3 ;RGB and HSB; HSB is all strings, RGB all Integers.
			If (IsInt($vVal1) And IsInt($vVal2) And IsInt($vVal3)) Then ;RGB
				$iRed = $vVal1
				$iGreen = $vVal2
				$iBlue = $vVal3

				;RGB to Long
				$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
				Return SetError($__LOW_STATUS_SUCCESS, 2, $iLong) ;Long from RGB

			ElseIf IsString($vVal1) And IsString($vVal2) And IsString($vVal3) Then ;Hue Saturation and Brightness (HSB)

				;HSB to RGB
				$vVal1 = StringStripWS($vVal1, $STR_STRIPALL)
				$vVal2 = StringStripWS($vVal2, $STR_STRIPALL)
				$vVal3 = StringStripWS($vVal3, $STR_STRIPALL) ;Strip WS so I can check string length in HSB conversion.

				$iHue = Number($vVal1)
				If (StringLen($vVal1)) <> (StringLen($iHue)) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 5, 0) ;String contained more than just digits
				$iSaturation = Number($vVal2)
				If (StringLen($vVal2)) <> (StringLen($iSaturation)) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 6, 0) ;String contained more than just digits
				$iBrightness = Number($vVal3)
				If (StringLen($vVal3)) <> (StringLen($iBrightness)) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 7, 0) ;String contained more than just digits

				$nMaxRGB = ($iBrightness / 100)
				$nChroma = (($iSaturation / 100) * ($iBrightness / 100))
				$nMinRGB = ($nMaxRGB - $nChroma)
				$nHuePre = ($iHue >= 300) ? (($iHue - 360) / 60) : ($iHue / 60)

				Switch $nHuePre
					Case (-1) To 1.0
						$iRed = $nMaxRGB
						If $nHuePre < 0 Then
							$iGreen = $nMinRGB
							$iBlue = ($iGreen - $nHuePre * $nChroma)
						Else
							$iBlue = $nMinRGB
							$iGreen = ($iBlue + $nHuePre * $nChroma)
						EndIf
					Case 1.1 To 3.0
						$iGreen = $nMaxRGB
						If (($nHuePre - 2) < 0) Then
							$iBlue = $nMinRGB
							$iRed = ($iBlue - ($nHuePre - 2) * $nChroma)
						Else
							$iRed = $nMinRGB
							$iBlue = ($iRed + ($nHuePre - 2) * $nChroma)
						EndIf
					Case 3.1 To 5
						$iBlue = $nMaxRGB
						If (($nHuePre - 4) < 0) Then
							$iRed = $nMinRGB
							$iGreen = ($iRed - ($nHuePre - 4) * $nChroma)
						Else
							$iGreen = $nMinRGB
							$iRed = ($iGreen + ($nHuePre - 4) * $nChroma)
						EndIf
				EndSwitch

				$iRed = Round(($iRed * 255))
				$iGreen = Round(($iGreen * 255))
				$iBlue = Round(($iBlue * 255))

				$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
				Return SetError($__LOW_STATUS_SUCCESS, 3, $iLong) ;Return Long from HSB
			Else
				Return SetError($__LOW_STATUS_INPUT_ERROR, 8, 0) ;Wrong parameters
			EndIf
		Case 4 ;CMYK
			If Not (IsInt($vVal1) And IsInt($vVal2) And IsInt($vVal3) And IsInt($vVal4)) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 9, 0) ;CMYK not integers.

			;CMYK to RGB
			$nCyan = ($vVal1 / 100)
			$nMagenta = ($vVal2 / 100)
			$nYellow = ($vVal3 / 100)
			$nBlack = ($vVal4 / 100)

			$iRed = Round((255 * (1 - $nBlack) * (1 - $nCyan)))
			$iGreen = Round((255 * (1 - $nBlack) * (1 - $nMagenta)))
			$iBlue = Round((255 * (1 - $nBlack) * (1 - $nYellow)))

			$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
			Return SetError($__LOW_STATUS_SUCCESS, 4, $iLong) ;Long from CMYK
		Case Else
			Return SetError($__LOW_STATUS_INPUT_ERROR, 10, 0) ;wrong number of Parameters
	EndSwitch
EndFunc   ;==>_LOWriter_ConvertColorToLong

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOWriter_ConvertFromMicrometer
; Description ...: Convert from Micrometer to Inch, Centimeter, Millimeter, or Printer's Points.
; Syntax ........: _LOWriter_ConvertFromMicrometer([$nInchOut = Null[, $nCentimeterOut = Null[, $nMillimeterOut = Null[, $nPointsOut = Null]]]])
; Parameters ....: $nInchOut            - [optional] a general number value. Default is Null. The Micrometers to convert to
;				   +						Inches. See remarks.
;                  $nCentimeterOut      - [optional] a general number value. Default is Null. The Micrometers to convert to
;				   +						Centimeters. See remarks.
;                  $nMillimeterOut      - [optional] a general number value. Default is Null. The Micrometers to convert to
;				   +						Millimeters. See remarks.
;                  $nPointsOut          - [optional] a general number value. Default is Null. The Micrometers to convert to
;				   +						Printer's Points. See remarks.
; Return values .: Success: Number
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $nInchOut not set to Null and not a number.
;				   @Error 1 @Extended 2 Return 0 = $nCentimeterOut not set to Null and not a number.
;				   @Error 1 @Extended 3 Return 0 = $nMillimeterOut not set to Null and not a number.
;				   @Error 1 @Extended 4 Return 0 = $nPointsOut not set to Null and not a number.
;				   @Error 1 @Extended 5 Return 0 = No parameters set to other than Null.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Error converting from Micrometers to Inch.
;				   @Error 3 @Extended 2 Return 0 = Error converting from Micrometers to Centimeter.
;				   @Error 3 @Extended 3 Return 0 = Error converting from Micrometers to Millimeter.
;				   @Error 3 @Extended 4 Return 0 = Error converting from Micrometers to Printer's Points.
;				   --Success--
;				   @Error 0 @Extended 1 Return Number. Converted from Micrometers to Inch.
;				   @Error 0 @Extended 2 Return Number. Converted from Micrometers to Centimeter.
;				   @Error 0 @Extended 3 Return Number. Converted from Micrometers to Millimeter.
;				   @Error 0 @Extended 4 Return Number. Converted from Micrometers to Printer's Points.
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To skip a parameter, set it to Null. If you are converting to Inches, place the Micrometers in $nInchOut, if
;					converting to Millimeters, $nInchOut and $nCentimeter are set to Null, and $nCMillimetersOut is set.  A
;					Micrometer is 1000th of a centimeter, and is used in almost all Libre Office functions that contain a
;					measurement parameter.
; Related .......:  _LOWriter_ConvertToMicrometer
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOWriter_ConvertFromMicrometer($nInchOut = Null, $nCentimeterOut = Null, $nMillimeterOut = Null, $nPointsOut = Null)
	Local $nReturnValue

	If ($nInchOut <> Null) Then
		If Not IsNumber($nInchOut) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 1, 0)
		$nReturnValue = __LOWriter_UnitConvert($nInchOut, $__LOWCONST_CONVERT_UM_INCH)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 1, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 1, $nReturnValue)
	EndIf

	If ($nCentimeterOut <> Null) Then
		If Not IsNumber($nCentimeterOut) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 2, 0)
		$nReturnValue = __LOWriter_UnitConvert($nCentimeterOut, $__LOWCONST_CONVERT_UM_CM)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 2, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 2, $nReturnValue)
	EndIf

	If ($nMillimeterOut <> Null) Then
		If Not IsNumber($nMillimeterOut) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 3, 0)
		$nReturnValue = __LOWriter_UnitConvert($nMillimeterOut, $__LOWCONST_CONVERT_UM_MM)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 3, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 3, $nReturnValue)
	EndIf

	If ($nPointsOut <> Null) Then
		If Not IsNumber($nPointsOut) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 4, 0)
		$nReturnValue = __LOWriter_UnitConvert($nPointsOut, $__LOWCONST_CONVERT_UM_PT)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 4, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 4, $nReturnValue)
	EndIf

	Return SetError($__LOW_STATUS_INPUT_ERROR, 5, 0) ;NO Unit set.
EndFunc   ;==>_LOWriter_ConvertFromMicrometer

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOWriter_ConvertToMicrometer
; Description ...: Convert from Inch, Centimeter, Millimeter, or Printer's Points to Micrometer.
; Syntax ........: _LOWriter_ConvertToMicrometer([$nInchIn = Null[, $nCentimeterIn = Null[, $nMillimeterIn = Null[, $nPointsIn = Null]]]])
; Parameters ....: $nInchIn             - [optional] a general number value. Default is Null. The Inches to convert to
;				   +							Micrometers. See remarks.
;                  $nCentimeterIn       - [optional] a general number value. Default is Null. The Centimeters to convert to
;				   +							Micrometers. See remarks.
;                  $nMillimeterIn       - [optional] a general number value. Default is Null. The Millimeters to convert to
;				   +							Micrometers. See remarks.
;                  $nPointsIn           - [optional] a general number value. Default is Null. The Printer's Points to convert to
;				   +							Micrometers. See remarks.
; Return values .: Success: Integer
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $nInchIn not set to Null and not a number.
;				   @Error 1 @Extended 2 Return 0 = $nCentimeterIn not set to Null and not a number.
;				   @Error 1 @Extended 3 Return 0 = $nMillimeterIn not set to Null and not a number.
;				   @Error 1 @Extended 4 Return 0 = $nPointsIn not set to Null and not a number.
;				   @Error 1 @Extended 5 Return 0 = No parameters set to other than Null.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Error converting from Inch to Micrometers.
;				   @Error 3 @Extended 2 Return 0 = Error converting from Centimeter to Micrometers.
;				   @Error 3 @Extended 3 Return 0 = Error converting from Millimeter to Micrometers.
;				   @Error 3 @Extended 4 Return 0 = Error converting from Printer's Points to Micrometers.
;				   --Success--
;				   @Error 0 @Extended 1 Return Integer. Converted Inches to Micrometers.
;				   @Error 0 @Extended 2 Return Integer. Converted Centimeters to Micrometers.
;				   @Error 0 @Extended 3 Return Integer. Converted Millimeters to Micrometers.
;				   @Error 0 @Extended 4 Return Integer. Converted Printer's Points to Micrometers.
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To skip a parameter, set it to Null. If you are converting from Inches, place the inches in $nInchIn, if
;					converting from Centimeters, $nInchIn is set to Null, and $nCentimeters is set. A Micrometer is 1000th of a
;					centimeter, and is used in almost all Libre Office functions that contain a measurement parameter.
; Related .......: _LOWriter_ConvertFromMicrometer
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOWriter_ConvertToMicrometer($nInchIn = Null, $nCentimeterIn = Null, $nMillimeterIn = Null, $nPointsIn = Null)
	Local $nReturnValue

	If ($nInchIn <> Null) Then
		If Not IsNumber($nInchIn) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 1, 0)
		$nReturnValue = __LOWriter_UnitConvert($nInchIn, $__LOWCONST_CONVERT_INCH_UM)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 1, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 1, $nReturnValue)
	EndIf

	If ($nCentimeterIn <> Null) Then
		If Not IsNumber($nCentimeterIn) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 2, 0)
		$nReturnValue = __LOWriter_UnitConvert($nCentimeterIn, $__LOWCONST_CONVERT_CM_UM)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 2, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 2, $nReturnValue)
	EndIf

	If ($nMillimeterIn <> Null) Then
		If Not IsNumber($nMillimeterIn) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 3, 0)
		$nReturnValue = __LOWriter_UnitConvert($nMillimeterIn, $__LOWCONST_CONVERT_MM_UM)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 3, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 3, $nReturnValue)
	EndIf

	If ($nPointsIn <> Null) Then
		If Not IsNumber($nPointsIn) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 4, 0)
		$nReturnValue = __LOWriter_UnitConvert($nPointsIn, $__LOWCONST_CONVERT_PT_UM)
		If @error Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 4, 0)
		Return SetError($__LOW_STATUS_SUCCESS, 4, $nReturnValue)
	EndIf

	Return SetError($__LOW_STATUS_INPUT_ERROR, 5, 0) ;NO Unit set.

EndFunc   ;==>_LOWriter_ConvertToMicrometer

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOWriter_VersionGet
; Description ...: Retrieve the current Office version.
; Syntax ........: _LOWriter_VersionGet([$bSimpleVersion = False[, $bReturnName = False]])
; Parameters ....: $bSimpleVersion      - [optional] a boolean value. Default is False. If True, returns a two digit version
;				   +						number, such as "7.3", else returns the complex version number, such as "7.3.2.4".
;                  $bReturnName         - [optional] a boolean value. Default is True. If True returns the Program Name, such
;				   +						as "LibreOffice", appended before the version, "LibreOffice 7.3".
; Return values .: Success: String
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $bSimpleVersion not a Boolean.
;				   @Error 1 @Extended 2 Return 0 = $bReturnName not a Boolean.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Error creating "com.sun.star.ServiceManager" Object.
;				   @Error 2 @Extended 2 Return 0 = Error creating "com.sun.star.configuration.ConfigurationProvider" Object.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Error setting property value.
;				   --Success--
;				   @Error 0 @Extended 0 Return String = Success. Returns the Office version in String format.
; Author ........: Laurent Godard as found in Andrew Pitonyak's book; Zizi64 as found on OpenOffice forum.
; Modified ......: donnyh13, modified for Autoit ccompatibility and error checking.
; Remarks .......: From Macro code by Zizi64 found at:
;					https://forum.openoffice.org/en/forum/viewtopic.php?t=91542&sid=7f452d65e58ac1cd3cc6063350b5ada0
;					And Andrew Pitonyak in "Useful Macro Information For OpenOffice.org" Pages 49, 50.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOWriter_VersionGet($bSimpleVersion = False, $bReturnName = False)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOWriter_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $sAccess = "com.sun.star.configuration.ConfigurationAccess", $sVersionName, $sVersion, $sReturn
	Local $oSettings, $oConfigProvider
	Local $aParamArray[1]

	If Not IsBool($bSimpleVersion) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 1, 0)
	If Not IsBool($bReturnName) Then Return SetError($__LOW_STATUS_INPUT_ERROR, 2, 0)

	Local $oServiceManager = ObjCreate("com.sun.star.ServiceManager")
	If Not IsObj($oServiceManager) Then Return SetError($__LOW_STATUS_INIT_ERROR, 1, 0)

	$oConfigProvider = $oServiceManager.createInstance("com.sun.star.configuration.ConfigurationProvider")
	If Not IsObj($oConfigProvider) Then Return SetError($__LOW_STATUS_INIT_ERROR, 2, 0)

	$aParamArray[0] = __LOWriter_SetPropertyValue("nodepath", "/org.openoffice.Setup/Product")
	If (@error > 0) Then Return SetError($__LOW_STATUS_PROCESSING_ERROR, 1, 0)

	$oSettings = $oConfigProvider.createInstanceWithArguments($sAccess, $aParamArray)

	$sVersionName = $oSettings.getByName("ooName")

	$sVersion = ($bSimpleVersion) ? $oSettings.getByName("ooSetupVersion") : $oSettings.getByName("ooSetupVersionAboutBox")

	$sReturn = ($bReturnName) ? ($sVersionName & " " & $sVersion) : $sVersion

	Return SetError($__LOW_STATUS_SUCCESS, 0, $sReturn)
EndFunc   ;==>_LOWriter_VersionGet
