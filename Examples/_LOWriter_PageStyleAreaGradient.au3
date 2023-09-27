
#include "LibreOfficeWriter.au3"
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $oDoc, $oPageStyle
	Local $avPageStyleSettings

	;Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOWriter_DocCreate(True, False)
	If (@error > 0) Then _ERROR("Failed to Create a new Writer Document. Error:" & @error & " Extended:" & @extended)

	;Retrieve the Default Page Style's Object, to modify its settings.
	$oPageStyle = _LOWriter_PageStyleGetObj($oDoc, "Default Page Style")
	If (@error > 0) Then _ERROR("Failed to retrieve Page Style Object. Error:" & @error & " Extended:" & @extended)

	;Set Page style Gradient settings to: Preset Gradient name = $LOW_GRAD_NAME_TEAL_TO_BLUE
	_LOWriter_PageStyleAreaGradient($oDoc, $oPageStyle, $LOW_GRAD_NAME_TEAL_TO_BLUE)
	If (@error > 0) Then _ERROR("Failed to modify Page Style settings. Error:" & @error & " Extended:" & @extended)

	;Retrieve the current settings. Return will be an array with elements in order of function parameters.
	$avPageStyleSettings = _LOWriter_PageStyleAreaGradient($oDoc, $oPageStyle)
	If (@error > 0) Then _ERROR("Failed to retrieve the Page style settings. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "The Page Style's current Gradient settings are as follows: " & @CRLF & _
			"The Gradient name is: " & $avPageStyleSettings[0] & @CRLF & _
			"The type of Gradient is, (see UDF constants): " & $avPageStyleSettings[1] & @CRLF & _
			"The number of steps to increment color is: " & $avPageStyleSettings[2] & @CRLF & _
			"The horizontal offset percentage for the gradient is: " & $avPageStyleSettings[3] & @CRLF & _
			"The vertical offset percentage for the gradient is: " & $avPageStyleSettings[4] & @CRLF & _
			"The rotation angle for the gradient is, in degrees: " & $avPageStyleSettings[5] & @CRLF & _
			"The percentage of area not covered by the ending color is: " & $avPageStyleSettings[6] & @CRLF & _
			"The starting color is, in Long Color format: " & $avPageStyleSettings[7] & @CRLF & _
			"The ending color is, in Long Color format: " & $avPageStyleSettings[8] & @CRLF & _
			"The starting color intensity percentage is: " & $avPageStyleSettings[9] & @CRLF & _
			"The ending color intensity percentage is: " & $avPageStyleSettings[10])

	MsgBox($MB_OK, "", "Press ok to close the document.")

	;Close the document.
	_LOWriter_DocClose($oDoc, False)
	If (@error > 0) Then _ERROR("Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc

Func _ERROR($sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	Exit
EndFunc

