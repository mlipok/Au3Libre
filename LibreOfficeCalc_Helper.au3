#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include-once

; Main LibreOffice Includes
#include "LibreOffice_Constants.au3"

; Common includes for Calc
#include "LibreOfficeCalc_Constants.au3"
#include "LibreOfficeCalc_Internal.au3"

; Other includes for Calc

; #INDEX# =======================================================================================================================
; Title .........: LibreOffice UDF
; AutoIt Version : v3.3.16.1
; Description ...: Functions used for creating, modifying and retrieving data for use in various functions in LibreOffice UDF.
; Author(s) .....: donnyh13, mLipok
; Dll ...........:
;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _LOCalc_ComError_UserFunction
; _LOCalc_ConvertColorFromLong
; _LOCalc_ConvertFromMicrometer
; _LOCalc_ConvertToMicrometer
; _LOCalc_FormatKeyCreate
; _LOCalc_FormatKeyDelete
; _LOCalc_FormatKeyExists
; _LOCalc_FormatKeyGetStandard
; _LOCalc_FormatKeyGetString
; _LOCalc_FormatKeyList
; _LOCalc_PathConvert
; _LOCalc_VersionGet
; _LOCalc_ConvertColorToLong
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_ComError_UserFunction
; Description ...: Set a UserFunction to receive the Fired COM Error Error outside of the UDF.
; Syntax ........: _LOCalc_ComError_UserFunction([$vUserFunction = Default[, $vParam1 = Null[, $vParam2 = Null[, $vParam3 = Null[, $vParam4 = Null[, $vParam5 = Null]]]]]])
; Parameters ....: $vUserFunction       - [optional] a Function or Keyword. Default value is Default. Accepts a Function, or the Keyword Default and Null. If set to a User function, the function may have up to 5 required parameters.
;                  $vParam1             - [optional] a variant value. Default is Null. Any optional parameter to be called with the user function.
;                  $vParam2             - [optional] a variant value. Default is Null. Any optional parameter to be called with the user function.
;                  $vParam3             - [optional] a variant value. Default is Null. Any optional parameter to be called with the user function.
;                  $vParam4             - [optional] a variant value. Default is Null. Any optional parameter to be called with the user function.
;                  $vParam5             - [optional] a variant value. Default is Null. Any optional parameter to be called with the user function.
; Return values .: Success: 1 or UserFunction.
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $vUserFunction Not a Function, or Default keyword, or Null Keyword.
;				   --Success--
;				   @Error 0 @Extended 0 Return 1 = Successfully set the UserFunction.
;				   @Error 0 @Extended 0 Return 2 = Successfully cleared the set UserFunction.
;				   @Error 0 @Extended 0 Return Function = Returning the set UserFunction.
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
;							$oMyError.helpfile Source Object's help file for the error (contents from ExcepInfo.helpfile)
;							$oMyError.helpcontext Source Object's help file context id number (contents from ExcepInfo.helpcontext)
;							$oMyError.lastdllerror The number returned from GetLastError()
;							$oMyError.scriptline The script line on which the error was generated
;				    		NOTE: Not all properties will necessarily contain data, some will be blank.
;				   If MsgBox or ConsoleWrite functions are passed to this function, the error details will be displayed using that function automatically.
;				   If called with Default keyword, the current UserFunction, if set, will be returned.
;				   If called with Null keyword, the currently set UserFunction is cleared and only the internal ComErrorHandler will be called for COM Errors.
;				   The stored UserFunction (besides MsgBox and ConsoleWrite) will be called as follows: UserFunc($oComError,$vParam1,$vParam2,$vParam3,$vParam4,$vParam5)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_ComError_UserFunction($vUserFunction = Default, $vParam1 = Null, $vParam2 = Null, $vParam3 = Null, $vParam4 = Null, $vParam5 = Null)
	#forceref $vParam1, $vParam2, $vParam3, $vParam4, $vParam5
	; If user does not set a function, UDF must use internal function to avoid AutoItError.
	Local Static $vUserFunction_Static = Default
	Local $avUserFuncWParams[@NumParams]

	If $vUserFunction = Default Then
		; just return stored static User Function variable
		Return $vUserFunction_Static
	ElseIf IsFunc($vUserFunction) Then
		; If User called Parameters, then add to array.
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
		Return SetError($__LO_STATUS_SUCCESS, 0, 1)
	ElseIf $vUserFunction = Null Then
		; Clear User Function.
		$vUserFunction_Static = Default
		Return SetError($__LO_STATUS_SUCCESS, 0, 2)
	Else
		; return error as an incorrect parameter was passed to this function
		Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	EndIf
EndFunc   ;==>_LOCalc_ComError_UserFunction

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_ConvertColorFromLong
; Description ...: Convert Long color code to Hex, RGB, HSB or CMYK.
; Syntax ........: _LOCalc_ConvertColorFromLong([$iHex = Null[, $iRGB = Null[, $iHSB = Null[, $iCMYK = Null]]]])
; Parameters ....: $iHex                - [optional] an integer value. Default is Null. Convert Long Color Integer to Hexadecimal.
;                  $iRGB                - [optional] an integer value. Default is Null. Convert Long Color Integer to R.G.B.
;                  $iHSB                - [optional] an integer value. Default is Null. Convert Long Color Integer to H.S.B.
;                  $iCMYK               - [optional] an integer value. Default is Null. Convert Long Color Integer to C.M.Y.K.
; Return values .: Success: String or Array.
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = No parameters set.
;				   @Error 1 @Extended 2 Return 0 = No parameters set to an integer.
;				   --Success--
;				   @Error 0 @Extended 1 Return String. Long integer converted To Hexadecimal (as a String). (Without the "0x" prefix)
;				   @Error 0 @Extended 2 Return Array. Array containing Long integer converted To Red, Green, Blue,(RGB). $Array[0] = R,  $Array[1] = G, etc.
;				   @Error 0 @Extended 3 Return Array. Array containing Long integer converted To Hue, Saturation, Brightness, (HSB). $Array[0] = H, $Array[1] = S, etc.
;				   @Error 0 @Extended 4 Return Array. Array containing Long integer converted To Cyan, Magenta, Yellow, Black, (CMYK). $Array[0] = C, $Array[1] = M, etc.
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To retrieve a Hexadecimal color value, call the Long Color code in $iHex, To retrieve a R(ed)G(reen)B(lue) color value, call Null in $iHex, and call the Long color code into $iRGB, etc. for the other color types.
;				   Hex returns as a string variable, all others (RGB, HSB, CMYK) return an array.
;				   Note: The Hexadecimal figure returned doesn't contain the usual "0x", as LibeOffice does not implement it in its numbering system.
; Related .......: _LOCalc_ConvertColorToLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_ConvertColorFromLong($iHex = Null, $iRGB = Null, $iHSB = Null, $iCMYK = Null)
	Local $nRed, $nGreen, $nBlue, $nResult, $nMaxRGB, $nMinRGB, $nHue, $nSaturation, $nBrightness, $nCyan, $nMagenta, $nYellow, $nBlack
	Local $dHex
	Local $aiReturn[0]

	If (@NumParams = 0) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	Select
		Case IsInt($iHex) ; Long TO Hex
			$nRed = Int(Mod(($iHex / 65536), 256))
			$nGreen = Int(Mod(($iHex / 256), 256))
			$nBlue = Int(Mod($iHex, 256))

			$dHex = Hex($nRed, 2) & Hex($nGreen, 2) & Hex($nBlue, 2)
			Return SetError($__LO_STATUS_SUCCESS, 1, $dHex)

		Case IsInt($iRGB) ; Long to RGB
			$nRed = Int(Mod(($iRGB / 65536), 256))
			$nGreen = Int(Mod(($iRGB / 256), 256))
			$nBlue = Int(Mod($iRGB, 256))
			ReDim $aiReturn[3]
			$aiReturn[0] = $nRed
			$aiReturn[1] = $nGreen
			$aiReturn[2] = $nBlue
			Return SetError($__LO_STATUS_SUCCESS, 2, $aiReturn)
		Case IsInt($iHSB) ; Long TO HSB

			$nRed = (Mod(($iHSB / 65536), 256)) / 255
			$nGreen = (Mod(($iHSB / 256), 256)) / 255
			$nBlue = (Mod($iHSB, 256)) / 255

			; get Max RGB Value
			$nResult = ($nRed > $nGreen) ? ($nRed) : ($nGreen)
			$nMaxRGB = ($nResult > $nBlue) ? ($nResult) : ($nBlue)
			; get Min RGB Value
			$nResult = ($nRed < $nGreen) ? ($nRed) : ($nGreen)
			$nMinRGB = ($nResult < $nBlue) ? ($nResult) : ($nBlue)

			; Determine Brightness
			$nBrightness = $nMaxRGB
			; Determine Hue
			$nHue = 0
			Select
				Case $nRed = $nGreen = $nBlue ; Red, Green, and Blue are equal.
					$nHue = 0
				Case ($nRed >= $nGreen) And ($nGreen >= $nBlue) ; Red Highest, Blue Lowest
					$nHue = (60 * (($nGreen - $nBlue) / ($nRed - $nBlue)))
				Case ($nRed >= $nBlue) And ($nBlue >= $nGreen) ; Red Highest, Green Lowest
					$nHue = (60 * (6 - (($nBlue - $nGreen) / ($nRed - $nGreen))))
				Case ($nGreen >= $nRed) And ($nRed >= $nBlue) ; Green Highest, Blue Lowest
					$nHue = (60 * (2 - (($nRed - $nBlue) / ($nGreen - $nBlue))))
				Case ($nGreen >= $nBlue) And ($nBlue >= $nRed) ; Green Highest, Red Lowest
					$nHue = (60 * (2 + (($nBlue - $nRed) / ($nGreen - $nRed))))
				Case ($nBlue >= $nGreen) And ($nGreen >= $nRed) ; Blue Highest, Red Lowest
					$nHue = (60 * (4 - (($nGreen - $nRed) / ($nBlue - $nRed))))
				Case ($nBlue >= $nRed) And ($nRed >= $nGreen) ; Blue Highest, Green Lowest
					$nHue = (60 * (4 + (($nRed - $nGreen) / ($nBlue - $nGreen))))
			EndSelect

			; Determine Saturation
			$nSaturation = ($nMaxRGB = 0) ? (0) : (($nMaxRGB - $nMinRGB) / $nMaxRGB)

			$nHue = ($nHue > 0) ? (Round($nHue)) : (0)
			$nSaturation = Round(($nSaturation * 100))
			$nBrightness = Round(($nBrightness * 100))

			ReDim $aiReturn[3]
			$aiReturn[0] = $nHue
			$aiReturn[1] = $nSaturation
			$aiReturn[2] = $nBrightness

			Return SetError($__LO_STATUS_SUCCESS, 3, $aiReturn)
		Case IsInt($iCMYK) ; Long to CMYK

			$nRed = (Mod(($iCMYK / 65536), 256))
			$nGreen = (Mod(($iCMYK / 256), 256))
			$nBlue = (Mod($iCMYK, 256))

			$nRed = Round(($nRed / 255), 3)
			$nGreen = Round(($nGreen / 255), 3)
			$nBlue = Round(($nBlue / 255), 3)

			; get Max RGB Value
			$nResult = ($nRed > $nGreen) ? ($nRed) : ($nGreen)
			$nMaxRGB = ($nResult > $nBlue) ? ($nResult) : ($nBlue)

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
			Return SetError($__LO_STATUS_SUCCESS, 4, $aiReturn)
		Case Else
			Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0) ; no parameters set to an integer
	EndSelect

EndFunc   ;==>_LOCalc_ConvertColorFromLong

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_ConvertFromMicrometer
; Description ...: Convert from Micrometer to Inch, Centimeter, Millimeter, or Printer's Points.
; Syntax ........: _LOCalc_ConvertFromMicrometer([$nInchOut = Null[, $nCentimeterOut = Null[, $nMillimeterOut = Null[, $nPointsOut = Null]]]])
; Parameters ....: $nInchOut            - [optional] a general number value. Default is Null. The Micrometers to convert to Inches. See remarks.
;                  $nCentimeterOut      - [optional] a general number value. Default is Null. The Micrometers to convert to Centimeters. See remarks.
;                  $nMillimeterOut      - [optional] a general number value. Default is Null. The Micrometers to convert to Millimeters. See remarks.
;                  $nPointsOut          - [optional] a general number value. Default is Null. The Micrometers to convert to Printer's Points. See remarks.
; Return values .: Success: Number
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $nInchOut not a number.
;				   @Error 1 @Extended 2 Return 0 = $nCentimeterOut not a number.
;				   @Error 1 @Extended 3 Return 0 = $nMillimeterOut not a number.
;				   @Error 1 @Extended 4 Return 0 = $nPointsOut not a number.
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
; Remarks .......: To skip a parameter, set it to Null.
;				   If you are converting to Inches, place the Micrometers in $nInchOut, if
;					converting to Millimeters, $nInchOut and $nCentimeter are set to Null, and $nMillimetersOut is set.  A
;					Micrometer is 1000th of a centimeter, and is used in almost all Libre Office functions that contain a
;					measurement parameter.
; Related .......: _LOCalc_ConvertToMicrometer
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_ConvertFromMicrometer($nInchOut = Null, $nCentimeterOut = Null, $nMillimeterOut = Null, $nPointsOut = Null)
	Local $nReturnValue

	If ($nInchOut <> Null) Then
		If Not IsNumber($nInchOut) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
		$nReturnValue = __LOCalc_UnitConvert($nInchOut, $__LOCONST_CONVERT_UM_INCH)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0)
		Return SetError($__LO_STATUS_SUCCESS, 1, $nReturnValue)
	EndIf

	If ($nCentimeterOut <> Null) Then
		If Not IsNumber($nCentimeterOut) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
		$nReturnValue = __LOCalc_UnitConvert($nCentimeterOut, $__LOCONST_CONVERT_UM_CM)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 2, 0)
		Return SetError($__LO_STATUS_SUCCESS, 2, $nReturnValue)
	EndIf

	If ($nMillimeterOut <> Null) Then
		If Not IsNumber($nMillimeterOut) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
		$nReturnValue = __LOCalc_UnitConvert($nMillimeterOut, $__LOCONST_CONVERT_UM_MM)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 3, 0)
		Return SetError($__LO_STATUS_SUCCESS, 3, $nReturnValue)
	EndIf

	If ($nPointsOut <> Null) Then
		If Not IsNumber($nPointsOut) Then Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0)
		$nReturnValue = __LOCalc_UnitConvert($nPointsOut, $__LOCONST_CONVERT_UM_PT)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 4, 0)
		Return SetError($__LO_STATUS_SUCCESS, 4, $nReturnValue)
	EndIf

	Return SetError($__LO_STATUS_INPUT_ERROR, 5, 0) ; NO Unit set.
EndFunc   ;==>_LOCalc_ConvertFromMicrometer

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_ConvertToMicrometer
; Description ...: Convert from Inch, Centimeter, Millimeter, or Printer's Points to Micrometer.
; Syntax ........: _LOCalc_ConvertToMicrometer([$nInchIn = Null[, $nCentimeterIn = Null[, $nMillimeterIn = Null[, $nPointsIn = Null]]]])
; Parameters ....: $nInchIn             - [optional] a general number value. Default is Null. The Inches to convert to Micrometers. See remarks.
;                  $nCentimeterIn       - [optional] a general number value. Default is Null. The Centimeters to convert to Micrometers. See remarks.
;                  $nMillimeterIn       - [optional] a general number value. Default is Null. The Millimeters to convert to Micrometers. See remarks.
;                  $nPointsIn           - [optional] a general number value. Default is Null. The Printer's Points to convert to Micrometers. See remarks.
; Return values .: Success: Integer
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $nInchIn not a number.
;				   @Error 1 @Extended 2 Return 0 = $nCentimeterIn not a number.
;				   @Error 1 @Extended 3 Return 0 = $nMillimeterIn not a number.
;				   @Error 1 @Extended 4 Return 0 = $nPointsIn not a number.
;				   @Error 1 @Extended 5 Return 0 = No parameters set to other than Null.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Error converting from Inches to Micrometers.
;				   @Error 3 @Extended 2 Return 0 = Error converting from Centimeters to Micrometers.
;				   @Error 3 @Extended 3 Return 0 = Error converting from Millimeters to Micrometers.
;				   @Error 3 @Extended 4 Return 0 = Error converting from Printer's Points to Micrometers.
;				   --Success--
;				   @Error 0 @Extended 1 Return Integer. Converted Inches to Micrometers.
;				   @Error 0 @Extended 2 Return Integer. Converted Centimeters to Micrometers.
;				   @Error 0 @Extended 3 Return Integer. Converted Millimeters to Micrometers.
;				   @Error 0 @Extended 4 Return Integer. Converted Printer's Points to Micrometers.
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To skip a parameter, set it to Null. If you are converting from Inches, call inches in $nInchIn, if
;					converting from Centimeters, $nInchIn is called with Null, and $nCentimeters is set. A Micrometer is 1000th of a
;					centimeter, and is used in almost all Libre Office functions that contain a measurement parameter.
; Related .......: _LOCalc_ConvertFromMicrometer
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_ConvertToMicrometer($nInchIn = Null, $nCentimeterIn = Null, $nMillimeterIn = Null, $nPointsIn = Null)
	Local $nReturnValue

	If ($nInchIn <> Null) Then
		If Not IsNumber($nInchIn) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
		$nReturnValue = __LOCalc_UnitConvert($nInchIn, $__LOCONST_CONVERT_INCH_UM)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0)
		Return SetError($__LO_STATUS_SUCCESS, 1, $nReturnValue)
	EndIf

	If ($nCentimeterIn <> Null) Then
		If Not IsNumber($nCentimeterIn) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
		$nReturnValue = __LOCalc_UnitConvert($nCentimeterIn, $__LOCONST_CONVERT_CM_UM)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 2, 0)
		Return SetError($__LO_STATUS_SUCCESS, 2, $nReturnValue)
	EndIf

	If ($nMillimeterIn <> Null) Then
		If Not IsNumber($nMillimeterIn) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
		$nReturnValue = __LOCalc_UnitConvert($nMillimeterIn, $__LOCONST_CONVERT_MM_UM)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 3, 0)
		Return SetError($__LO_STATUS_SUCCESS, 3, $nReturnValue)
	EndIf

	If ($nPointsIn <> Null) Then
		If Not IsNumber($nPointsIn) Then Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0)
		$nReturnValue = __LOCalc_UnitConvert($nPointsIn, $__LOCONST_CONVERT_PT_UM)
		If @error Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 4, 0)
		Return SetError($__LO_STATUS_SUCCESS, 4, $nReturnValue)
	EndIf

	Return SetError($__LO_STATUS_INPUT_ERROR, 5, 0) ; NO Unit set.

EndFunc   ;==>_LOCalc_ConvertToMicrometer

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_FormatKeyCreate
; Description ...: Create a Format Key.
; Syntax ........: _LOCalc_FormatKeyCreate(ByRef $oDoc, $sFormat)
; Parameters ....: $oDoc                - [in/out] an object. A Document object returned by a previous _LOCalc_DocOpen, _LOCalc_DocConnect, or _LOCalc_DocCreate function.
;                  $sFormat             - a string value. The format key String to create.
; Return values .: Success: Integer
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $oDoc not an Object.
;				   @Error 1 @Extended 2 Return 0 = $sFormat not a String.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Failed to Create "com.sun.star.lang.Locale" Object.
;				   @Error 2 @Extended 2 Return 0 = Failed to retrieve Number Formats Object.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Attempted to Create or Retrieve the Format key, but failed.
;				   --Success--
;				   @Error 0 @Extended 0 Return Integer = Success. Format Key was successfully created, returning Format Key integer.
;				   @Error 0 @Extended 1 Return Integer = Success. Format Key already existed, returning Format Key integer.
; Author ........: donnyh13
; Modified ......:
; Remarks .......:
; Related .......: _LOCalc_FormatKeyDelete, _LOCalc_FormatKeyGetStandard
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_FormatKeyCreate(ByRef $oDoc, $sFormat)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $iFormatKey
	Local $tLocale
	Local $oFormats

	If Not IsObj($oDoc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsString($sFormat) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
	$tLocale = __LOCalc_CreateStruct("com.sun.star.lang.Locale")
	If Not IsObj($tLocale) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)
	$oFormats = $oDoc.getNumberFormats()
	If Not IsObj($oFormats) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)
	$iFormatKey = $oFormats.queryKey($sFormat, $tLocale, False)
	If ($iFormatKey > -1) Then Return SetError($__LO_STATUS_SUCCESS, 1, $iFormatKey) ; Format already existed
	$iFormatKey = $oFormats.addNew($sFormat, $tLocale)
	If ($iFormatKey > -1) Then Return SetError($__LO_STATUS_SUCCESS, 0, $iFormatKey) ; Format created

	Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0) ; Failed to create or retrieve Format
EndFunc   ;==>_LOCalc_FormatKeyCreate

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_FormatKeyDelete
; Description ...: Delete a User-Created Format Key from a Document.
; Syntax ........: _LOCalc_FormatKeyDelete(ByRef $oDoc, $iFormatKey)
; Parameters ....: $oDoc                - [in/out] an object. A Document object returned by a previous _LOCalc_DocOpen, _LOCalc_DocConnect, or _LOCalc_DocCreate function.
;                  $iFormatKey          - an integer value. The User-Created format Key to delete.
; Return values .: Success: 1
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $oDoc not an Object.
;				   @Error 1 @Extended 2 Return 0 = $iFormatKey not an Integer.
;				   @Error 1 @Extended 3 Return 0 = Format Key called in $iFormatKey not found in Document.
;				   @Error 1 @Extended 4 Return 0 = Format Key called in $iFormatKey not User-Created.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Failed to Create "com.sun.star.lang.Locale" Object.
;				   @Error 2 @Extended 2 Return 0 = Failed to retrieve Number Formats Object.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Failed to delete key.
;				   --Success--
;				   @Error 0 @Extended 0 Return 1 = Success. Format Key was successfully deleted.
; Author ........: donnyh13
; Modified ......:
; Remarks .......:
; Related .......: _LOCalc_FormatKeyList, _LOCalc_FormatKeyCreate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_FormatKeyDelete(ByRef $oDoc, $iFormatKey)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $tLocale
	Local $oFormats

	If Not IsObj($oDoc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsInt($iFormatKey) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
	If Not _LOCalc_FormatKeyExists($oDoc, $iFormatKey) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0) ; Key not found.
	$tLocale = __LOCalc_CreateStruct("com.sun.star.lang.Locale")
	If Not IsObj($tLocale) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)
	$oFormats = $oDoc.getNumberFormats()
	If Not IsObj($oFormats) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)
	If ($oFormats.getbykey($iFormatKey).UserDefined() = False) Then Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0) ; Key not User Created.

	$oFormats.removeByKey($iFormatKey)

	Return (_LOCalc_FormatKeyExists($oDoc, $iFormatKey) = False) ? (SetError($__LO_STATUS_SUCCESS, 0, 1)) : (SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0))
EndFunc   ;==>_LOCalc_FormatKeyDelete

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_FormatKeyExists
; Description ...: Check if a Document contains a certain Format Key.
; Syntax ........: _LOCalc_FormatKeyExists(ByRef $oDoc, $iFormatKey, Const $iFormatType)
; Parameters ....: $oDoc                - [in/out] an object. A Document object returned by a previous _LOCalc_DocOpen, _LOCalc_DocConnect, or _LOCalc_DocCreate function.
;                  $iFormatKey          - an integer value. The Format Key to look for.
;                  $iFormatType         - [optional] an integer value (0-15881). Default is $LOC_FORMAT_KEYS_ALL. The Format Key type to search in. Values can be BitOr'd together. See Constants, $LOC_FORMAT_KEYS_* as defined in LibreOfficeCalc_Constants.au3.
; Return values .: Success: Boolean
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $oDoc not an Object.
;				   @Error 1 @Extended 2 Return 0 = $iFormatKey not an Integer.
;				   @Error 1 @Extended 3 Return 0 = $iFormatType not an Integer.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Failed to Create "com.sun.star.lang.Locale" Object.
;				   @Error 2 @Extended 2 Return 0 = Failed to retrieve Number Formats Object.
;				   @Error 2 @Extended 3 Return 0 = Failed to obtain Array of Date/Time Formats.
;				   --Success--
;				   @Error 0 @Extended 0 Return True = Success. Format Key exists in document.
;				   @Error 0 @Extended 1 Return False = Success. Format Key does not exist in document.
; Author ........: donnyh13
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_FormatKeyExists(ByRef $oDoc, $iFormatKey, $iFormatType = $LOC_FORMAT_KEYS_ALL)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $oFormats
	Local $aiFormatKeys[0]
	Local $tLocale

	If Not IsObj($oDoc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsInt($iFormatKey) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
	If Not IsInt($iFormatType) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
	$tLocale = __LOCalc_CreateStruct("com.sun.star.lang.Locale")
	If Not IsObj($tLocale) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)
	$oFormats = $oDoc.getNumberFormats()
	If Not IsObj($oFormats) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)
	$aiFormatKeys = $oFormats.queryKeys($iFormatType, $tLocale, False)
	If Not IsArray($aiFormatKeys) Then Return SetError($__LO_STATUS_INIT_ERROR, 3, 0)

	For $i = 0 To UBound($aiFormatKeys) - 1
		If ($aiFormatKeys[$i] = $iFormatKey) Then Return SetError($__LO_STATUS_SUCCESS, 0, True) ; Doc does contain format Key
		Sleep((IsInt($i / $__LOCCONST_SLEEP_DIV)) ? (10) : (0))
	Next

	Return SetError($__LO_STATUS_SUCCESS, 1, False) ; Doc does not contain format Key
EndFunc   ;==>_LOCalc_FormatKeyExists

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_FormatKeyGetStandard
; Description ...: Retrieve the Standard Format for a specific Format Key Type.
; Syntax ........: _LOCalc_FormatKeyGetStandard(ByRef $oDoc, $iFormatKeyType)
; Parameters ....: $oDoc                - [in/out] an object. A Document object returned by a previous _LOCalc_DocOpen, _LOCalc_DocConnect, or _LOCalc_DocCreate function.
;                  $iFormatKeyType      - an integer value (1-8196). The Format Key type to retrieve the standard Format for. See Constants $LOC_FORMAT_KEYS_* as defined in LibreOfficeCalc_Constants.au3.
; Return values .: Success: Integer
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $oDoc not an Object.
;				   @Error 1 @Extended 2 Return 0 = $iFormatKeyType not an Integer, less than 1 or greater than 8196. See Constants $LOC_FORMAT_KEYS_* as defined in LibreOfficeCalc_Constants.au3.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Failed to create a "com.sun.star.lang.Locale" Struct.
;				   @Error 2 @Extended 2 Return 0 = Failed to retrieve Number Formats Object.
;				   --Processing Errors--
;				   @Error 3 @Extended 1 Return 0 = Failed to retrieve the Standard Format for the requested Format Key Type.
;				   --Success--
;				   @Error 0 @Extended 0 Return Integer = Success. Returning the Standard Format for the requested Format Key Type.
; Author ........: donnyh13
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_FormatKeyGetStandard(ByRef $oDoc, $iFormatKeyType)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $oFormats
	Local $tLocale
	Local $iStandard

	If Not IsObj($oDoc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not __LOCalc_IntIsBetween($iFormatKeyType, $LOC_FORMAT_KEYS_DEFINED, $LOC_FORMAT_KEYS_DURATION) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)

	$tLocale = __LOCalc_CreateStruct("com.sun.star.lang.Locale")
	If Not IsObj($tLocale) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)
	$oFormats = $oDoc.getNumberFormats()
	If Not IsObj($oFormats) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)

	$iStandard = $oFormats.getStandardFormat($iFormatKeyType, $tLocale)
	If Not IsInt($iStandard) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0)

	Return SetError($__LO_STATUS_SUCCESS, 0, $iStandard)
EndFunc   ;==>_LOCalc_FormatKeyGetStandard

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_FormatKeyGetString
; Description ...: Retrieve a Format Key String.
; Syntax ........: _LOCalc_FormatKeyGetString(ByRef $oDoc, $iFormatKey)
; Parameters ....: $oDoc                - [in/out] an object. A Document object returned by a previous _LOCalc_DocOpen, _LOCalc_DocConnect, or _LOCalc_DocCreate function.
;                  $iFormatKey          - an integer value. The Format Key to retrieve the string for.
; Return values .:Success: String
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $oDoc not an Object.
;				   @Error 1 @Extended 2 Return 0 = $iFormatKey not an Integer.
;				   @Error 1 @Extended 3 Return 0 = $iFormatKey not found in Document.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Failed to retrieve requested Format Key Object.
;				   --Success--
;				   @Error 0 @Extended 0 Return String = Success. Returning Format Key's Format String.
; Author ........: donnyh13
; Modified ......:
; Remarks .......:
; Related .......: _LOCalc_FormatKeyList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_FormatKeyGetString(ByRef $oDoc, $iFormatKey)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $oFormatKey

	If Not IsObj($oDoc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsInt($iFormatKey) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
	If Not _LOCalc_FormatKeyExists($oDoc, $iFormatKey) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
	$oFormatKey = $oDoc.getNumberFormats().getByKey($iFormatKey)
	If Not IsObj($oFormatKey) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0) ; Key not found.

	Return SetError($__LO_STATUS_SUCCESS, 0, $oFormatKey.FormatString())
EndFunc   ;==>_LOCalc_FormatKeyGetString

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_FormatKeyList
; Description ...: Retrieve an Array of Date/Time Format Keys.
; Syntax ........: _LOCalc_FormatKeyList(ByRef $oDoc[, $bIsUser = False[, $bUserOnly = False[, $iFormatKeyType = Null]]])
; Parameters ....: $oDoc                - [in/out] an object. A Document object returned by a previous _LOCalc_DocOpen, _LOCalc_DocConnect, or _LOCalc_DocCreate function.
;                  $bIsUser             - [optional] a boolean value. Default is False. If True, Adds a third column to the return Array with a boolean, whether each Key is user-created or not.
;                  $bUserOnly           - [optional] a boolean value. Default is False. If True, only user-created Format Keys are returned.
;                  $iFormatKeyType      - [optional] an integer value (0-15881). Default is $LOC_FORMAT_KEYS_ALL. The Format Key type to retrieve a list for. Values can be BitOr'd together. See Constants, $LOC_FORMAT_KEYS_* as defined in LibreOfficeCalc_Constants.au3.
; Return values .: Success: Array
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $oDoc not an Object.
;				   @Error 1 @Extended 2 Return 0 = $bIsUser not a Boolean.
;				   @Error 1 @Extended 3 Return 0 = $bUserOnly not a Boolean.
;				   @Error 1 @Extended 4 Return 0 = $iFormatKeyType not an Integer.
;				   --Initialization Errors--
;				   @Error 2 @Extended 1 Return 0 = Failed to create "com.sun.star.lang.Locale" Object.
;				   @Error 2 @Extended 2 Return 0 = Failed to retrieve NumberFormats Object.
;				   @Error 2 @Extended 3 Return 0 = Failed to obtain Array of Format Keys.
;				   --Success--
;				   @Error 0 @Extended ? Return Array = Success. Returning a 2 or 3 column Array, depending on current $bIsUser setting.
;				   +						Column One (Array[0][0]) will contain the Format Key integer,
;				   +						Column two (Array[0][1]) will contain the Format Key String,
;				   +						If $bIsUser is set to True, Column Three (Array[0][2]) will contain a Boolean, True if the Format Key is User-created, else false.
;				   +						@Extended is set to the number of Keys returned.
; Author ........: donnyh13
; Modified ......:
; Remarks .......:
; Related .......: _LOCalc_FormatKeyDelete, _LOCalc_FormatKeyGetString, _LOCalc_FormatKeyGetStandard
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_FormatKeyList(ByRef $oDoc, $bIsUser = False, $bUserOnly = False, $iFormatKeyType = $LOC_FORMAT_KEYS_ALL)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $oFormats
	Local $aiFormatKeys
	Local $avFormats[0][3]
	Local $tLocale
	Local $iColumns = 3, $iCount = 0

	If Not IsObj($oDoc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsBool($bIsUser) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
	If Not IsBool($bUserOnly) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
	$iColumns = ($bIsUser = True) ? ($iColumns) : (2)

	If Not IsInt($iFormatKeyType) Then Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0)

	$tLocale = __LOCalc_CreateStruct("com.sun.star.lang.Locale")
	If Not IsObj($tLocale) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)
	$oFormats = $oDoc.getNumberFormats()
	If Not IsObj($oFormats) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)
	$aiFormatKeys = $oFormats.queryKeys($iFormatKeyType, $tLocale, False)
	If Not IsArray($aiFormatKeys) Then Return SetError($__LO_STATUS_INIT_ERROR, 3, 0)

	ReDim $avFormats[UBound($aiFormatKeys)][$iColumns]

	For $i = 0 To UBound($aiFormatKeys) - 1

		If ($bUserOnly = True) Then
			If ($oFormats.getbykey($aiFormatKeys[$i]).UserDefined() = True) Then
				$avFormats[$iCount][0] = $aiFormatKeys[$i]
				$avFormats[$iCount][1] = $oFormats.getbykey($aiFormatKeys[$i]).FormatString()
				If ($bIsUser = True) Then $avFormats[$iCount][2] = $oFormats.getbykey($aiFormatKeys[$i]).UserDefined()
				$iCount += 1
			EndIf
		Else
			$avFormats[$i][0] = $aiFormatKeys[$i]
			$avFormats[$i][1] = $oFormats.getbykey($aiFormatKeys[$i]).FormatString()
			If ($bIsUser = True) Then $avFormats[$i][2] = $oFormats.getbykey($aiFormatKeys[$i]).UserDefined()
		EndIf
		Sleep((IsInt($i / $__LOCCONST_SLEEP_DIV)) ? (10) : (0))
	Next

	If ($bUserOnly = True) Then ReDim $avFormats[$iCount][$iColumns]

	Return SetError($__LO_STATUS_SUCCESS, UBound($avFormats), $avFormats)
EndFunc   ;==>_LOCalc_FormatKeyList

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_PathConvert
; Description ...: Converts the input path to or from a LibreOffice URL notation path.
; Syntax ........: _LOCalc_PathConvert($sFilePath[, $iReturnMode = $LOC_PATHCONV_AUTO_RETURN])
; Parameters ....: $sFilePath           - a string value. Full path to convert in String format.
;                  $iReturnMode         - [optional] an integer value (0-2). Default is $__g_iAutoReturn. The type of path format to return. See Constants, $LOC_PATHCONV_* as defined in LibreOfficeCalc_Constants.au3.
; Return values .: Success: String.
;				   Failure: 0 and sets the @Error and @Extended flags to non-zero.
;				   --Input Errors--
;				   @Error 1 @Extended 1 Return 0 = $sFilePath is not a string
;				   @Error 1 @Extended 2 Return 0 = $iReturnMode not a Integer, less than 0, or greater than 2, see constants, $LOC_PATHCONV_* as defined in LibreOfficeCalc_Constants.au3.
;				   --Success--
;				   @Error 0 @Extended 1 Return String = Returning converted File Path from Libre Office URL.
;				   @Error 0 @Extended 2 Return String = Returning converted path from File Path to Libre Office URL.
; Author ........: donnyh13
; Modified ......:
; Remarks .......: LibeOffice URL notation is based on the Internet Standard RFC 1738, which means only [0-9],[a-zA-Z] are
;					allowed in paths, most other characters need to be converted into ISO 8859-1 (ISO Latin) such as is found
;					in internet URL's (spaces become %20). See: StarOfficeTM 6.0 Office SuiteA SunTM ONE Software Offering,
;					Basic Programmer's Guide; Page 74
;					The user generally should not even need this function, as I have endeavored to convert any URLs to the
;						appropriate computer path format and any input computer paths to a Libre Office URL.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_PathConvert($sFilePath, $iReturnMode = $LOC_PATHCONV_AUTO_RETURN)
	Local Const $STR_STRIPLEADING = 1
	Local $asURLReplace[9][2] = [["%", "%25"], [" ", "%20"], ["\", "/"], [";", "%3B"], ["#", "%23"], ["^", "%5E"], ["{", "%7B"], ["}", "%7D"], ["`", "%60"]]
	Local $iPathSearch, $iFileSearch, $iPartialPCPath, $iPartialFilePath

	If Not IsString($sFilePath) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not __LOCalc_IntIsBetween($iReturnMode, $LOC_PATHCONV_AUTO_RETURN, $LOC_PATHCONV_PCPATH_RETURN) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)

	$sFilePath = StringStripWS($sFilePath, $STR_STRIPLEADING)

	$iPathSearch = StringRegExp($sFilePath, "[A-Z]\:\\") ; Search For a Computer Path, as in C:\ etc.
	$iPartialPCPath = StringInStr($sFilePath, "\") ; Search for partial computer Path containing a backslash.
	$iFileSearch = StringInStr($sFilePath, "file:///", 0, 1, 1, 9) ; Search for a full Libre path, which begins with File:///
	$iPartialFilePath = StringInStr($sFilePath, "/") ; Search For a Partial Libre path containing forward slash

	If ($iReturnMode = $LOC_PATHCONV_AUTO_RETURN) Then

		If ($iPathSearch > 0) Or ($iPartialPCPath > 0) Then ;  if file path contains partial or full PC path, set to convert to Libre URL.
			$iReturnMode = $LOC_PATHCONV_OFFICE_RETURN
		ElseIf ($iFileSearch > 0) Or ($iPartialFilePath > 0) Then ;  if file path contains partial or full Libre URL, set to convert to PC Path.
			$iReturnMode = $LOC_PATHCONV_PCPATH_RETURN
		Else ; If file path contains neither above. convert to Libre URL
			$iReturnMode = $LOC_PATHCONV_OFFICE_RETURN
		EndIf
	EndIf

	Switch $iReturnMode

		Case $LOC_PATHCONV_OFFICE_RETURN
			If $iFileSearch > 0 Then Return SetError($__LO_STATUS_SUCCESS, 2, $sFilePath)
			If ($iPathSearch > 0) Then $sFilePath = "file:///" & $sFilePath

			For $i = 0 To (UBound($asURLReplace) - 1)
				$sFilePath = StringReplace($sFilePath, $asURLReplace[$i][0], $asURLReplace[$i][1])
				Sleep((IsInt($i / $__LOCCONST_SLEEP_DIV)) ? (10) : (0))
			Next
			Return SetError($__LO_STATUS_SUCCESS, 2, $sFilePath)

		Case $LOC_PATHCONV_PCPATH_RETURN
			If ($iPathSearch > 0) Then Return SetError($__LO_STATUS_SUCCESS, 1, $sFilePath)
			If ($iFileSearch > 0) Then $sFilePath = StringReplace($sFilePath, "file:///", Null)

			For $i = 0 To (UBound($asURLReplace) - 1)
				$sFilePath = StringReplace($sFilePath, $asURLReplace[$i][1], $asURLReplace[$i][0])
				Sleep((IsInt($i / $__LOCCONST_SLEEP_DIV)) ? (10) : (0))
			Next
			Return SetError($__LO_STATUS_SUCCESS, 1, $sFilePath)

	EndSwitch

EndFunc   ;==>_LOCalc_PathConvert

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_VersionGet
; Description ...: Retrieve the current Office version.
; Syntax ........: _LOCalc_VersionGet([$bSimpleVersion = False[, $bReturnName = False]])
; Parameters ....: $bSimpleVersion      - [optional] a boolean value. Default is False. If True, returns a two digit version number, such as "7.3", else returns the complex version number, such as "7.3.2.4".
;                  $bReturnName         - [optional] a boolean value. Default is True. If True returns the Program Name, such as "LibreOffice", appended by the version, i.e. "LibreOffice 7.3".
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
; Modified ......: donnyh13, modified for AutoIt compatibility and error checking.
; Remarks .......: From Macro code by Zizi64 found at: https://forum.openoffice.org/en/forum/viewtopic.php?t=91542&sid=7f452d65e58ac1cd3cc6063350b5ada0
;				   And Andrew Pitonyak in "Useful Macro Information For OpenOffice.org" Pages 49, 50.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_VersionGet($bSimpleVersion = False, $bReturnName = False)
	Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $sAccess = "com.sun.star.configuration.ConfigurationAccess", $sVersionName, $sVersion, $sReturn
	Local $oSettings, $oConfigProvider
	Local $aParamArray[1]

	If Not IsBool($bSimpleVersion) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsBool($bReturnName) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)

	Local $oServiceManager = ObjCreate("com.sun.star.ServiceManager")
	If Not IsObj($oServiceManager) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)

	$oConfigProvider = $oServiceManager.createInstance("com.sun.star.configuration.ConfigurationProvider")
	If Not IsObj($oConfigProvider) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)

	$aParamArray[0] = __LOCalc_SetPropertyValue("nodepath", "/org.openoffice.Setup/Product")
	If (@error > 0) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0)

	$oSettings = $oConfigProvider.createInstanceWithArguments($sAccess, $aParamArray)

	$sVersionName = $oSettings.getByName("ooName")

	$sVersion = ($bSimpleVersion) ? ($oSettings.getByName("ooSetupVersion")) : ($oSettings.getByName("ooSetupVersionAboutBox"))

	$sReturn = ($bReturnName) ? ($sVersionName & " " & $sVersion) : ($sVersion)

	Return SetError($__LO_STATUS_SUCCESS, 0, $sReturn)
EndFunc   ;==>_LOCalc_VersionGet

; #FUNCTION# ====================================================================================================================
; Name ..........: _LOCalc_ConvertColorToLong
; Description ...: Convert Hex, RGB, HSB or CMYK to Long color code.
; Syntax ........: _LOCalc_ConvertColorToLong([$vVal1 = Null[, $vVal2 = Null[, $vVal3 = Null[, $vVal4 = Null]]]])
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
;				   @Error 0 @Extended 4 Return Integer. Long Int. Color code converted from (C)yan, (M)agenta, (Y)ellow, Blac(k)
; Author ........: donnyh13
; Modified ......:
; Remarks .......: To Convert a Hex(adecimal) color code, call the Hex code in $vVal1 in String Format.
;				   To convert a R(ed) G(reen) B(lue color, call R value in $vVal1 as an Integer, G in $vVal2 as an Integer, and B in $vVal3 as an Integer.
;				   To convert a H(ue) S(aturation) B(rightness) color, call H in $vVal1 as a String, S in $vVal2 as a String, and B in $vVal3 as a string.
;				   To convert C(yan) M(agenta) Y(ellow) Blac(k) call C in $vVal1 as an Integer, M in $vVal2 as an Integer, Y in $vVal3 as an Integer, and K in $vVal4 as an Integer format.
;				   Note: The Hexadecimal figure entered cannot contain the usual "0x", as LibeOffice does not implement it in its numbering system.
; Related .......: _LOCalc_ConvertColorFromLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _LOCalc_ConvertColorToLong($vVal1 = Null, $vVal2 = Null, $vVal3 = Null, $vVal4 = Null) ; RGB = Int, CMYK = Int, HSB = String, Hex = String.
	Local Const $STR_STRIPALL = 8
	Local $iRed, $iGreen, $iBlue, $iLong, $iHue, $iSaturation, $iBrightness
	Local $dHex
	Local $nMaxRGB, $nMinRGB, $nChroma, $nHuePre, $nCyan, $nMagenta, $nYellow, $nBlack

	If (@NumParams = 0) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	Switch @NumParams
		Case 1 ;Hex
			If Not IsString($vVal1) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0) ; not a string
			$vVal1 = StringStripWS($vVal1, $STR_STRIPALL)
			$dHex = $vVal1

			; From Hex to RGB
			If (StringLen($dHex) = 6) Then
				If StringRegExp($dHex, "[^0-9a-fA-F]") Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0) ; $dHex contains non Hex characters.

				$iRed = BitAND(BitShift("0x" & $dHex, 16), 0xFF)
				$iGreen = BitAND(BitShift("0x" & $dHex, 8), 0xFF)
				$iBlue = BitAND("0x" & $dHex, 0xFF)

				$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
				Return SetError($__LO_STATUS_SUCCESS, 1, $iLong) ; Long from Hex

			Else
				Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0) ; Wrong length of string.
			EndIf

		Case 3 ;RGB and HSB; HSB is all strings, RGB all Integers.
			If (IsInt($vVal1) And IsInt($vVal2) And IsInt($vVal3)) Then ; RGB
				$iRed = $vVal1
				$iGreen = $vVal2
				$iBlue = $vVal3

				; RGB to Long
				$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
				Return SetError($__LO_STATUS_SUCCESS, 2, $iLong) ; Long from RGB

			ElseIf IsString($vVal1) And IsString($vVal2) And IsString($vVal3) Then ; Hue Saturation and Brightness (HSB)

				; HSB to RGB
				$vVal1 = StringStripWS($vVal1, $STR_STRIPALL)
				$vVal2 = StringStripWS($vVal2, $STR_STRIPALL)
				$vVal3 = StringStripWS($vVal3, $STR_STRIPALL) ; Strip WS so I can check string length in HSB conversion.

				$iHue = Number($vVal1)
				If (StringLen($vVal1)) <> (StringLen($iHue)) Then Return SetError($__LO_STATUS_INPUT_ERROR, 5, 0) ; String contained more than just digits
				$iSaturation = Number($vVal2)
				If (StringLen($vVal2)) <> (StringLen($iSaturation)) Then Return SetError($__LO_STATUS_INPUT_ERROR, 6, 0) ; String contained more than just digits
				$iBrightness = Number($vVal3)
				If (StringLen($vVal3)) <> (StringLen($iBrightness)) Then Return SetError($__LO_STATUS_INPUT_ERROR, 7, 0) ; String contained more than just digits

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
				Return SetError($__LO_STATUS_SUCCESS, 3, $iLong) ; Return Long from HSB
			Else
				Return SetError($__LO_STATUS_INPUT_ERROR, 8, 0) ; Wrong parameters
			EndIf
		Case 4 ;CMYK
			If Not (IsInt($vVal1) And IsInt($vVal2) And IsInt($vVal3) And IsInt($vVal4)) Then Return SetError($__LO_STATUS_INPUT_ERROR, 9, 0) ; CMYK not integers.

			; CMYK to RGB
			$nCyan = ($vVal1 / 100)
			$nMagenta = ($vVal2 / 100)
			$nYellow = ($vVal3 / 100)
			$nBlack = ($vVal4 / 100)

			$iRed = Round((255 * (1 - $nBlack) * (1 - $nCyan)))
			$iGreen = Round((255 * (1 - $nBlack) * (1 - $nMagenta)))
			$iBlue = Round((255 * (1 - $nBlack) * (1 - $nYellow)))

			$iLong = BitShift($iRed, -16) + BitShift($iGreen, -8) + $iBlue
			Return SetError($__LO_STATUS_SUCCESS, 4, $iLong) ; Long from CMYK
		Case Else
			Return SetError($__LO_STATUS_INPUT_ERROR, 10, 0) ; wrong number of Parameters
	EndSwitch
EndFunc   ;==>_LOCalc_ConvertColorToLong
