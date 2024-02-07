#include <MsgBoxConstants.au3>

#include "..\LibreOfficeCalc.au3"

Example()

Func Example()
	Local $oDoc, $oSheet, $oCell, $oCellRange
	Local $avSettings

	; Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOCalc_DocCreate(True, False)
	If @error Then _ERROR($oDoc, "Failed to Create a new Calc Document. Error:" & @error & " Extended:" & @extended)

	; Retrieve the active Sheet.
	$oSheet = _LOCalc_SheetGetActive($oDoc)
	If @error Then _ERROR($oDoc, "Failed to retrieve the currently active Sheet Object. Error:" & @error & " Extended:" & @extended)

	; Retrieve Cell B2
	$oCell = _LOCalc_RangeGetCellByName($oSheet, "B2")
	If @error Then _ERROR($oDoc, "Failed to retrieve Cell Object. Error:" & @error & " Extended:" & @extended)

	; Set the Cell's Border Width to $LOC_BORDERWIDTH_THICK for all four sides.
	_LOCalc_CellBorderWidth($oCell, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THICK)
	If @error Then _ERROR($oDoc, "Failed to set the Cell's settings. Error:" & @error & " Extended:" & @extended)

	; Set the Cell's Border Style to $LOC_BORDERSTYLE_DOUBLE for all four sides.
	_LOCalc_CellBorderStyle($oCell, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DOUBLE)
	If @error Then _ERROR($oDoc, "Failed to set the Cell's settings. Error:" & @error & " Extended:" & @extended)

	; Retrieve the current settings. Return will be an array with element values in order of function parameter.
	$avSettings = _LOCalc_CellBorderStyle($oCell)
	If @error Then _ERROR($oDoc, "Failed to retrieve the Cell's current settings. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "Cell B2's Border Style settings are as follows (See UDF Constants): " & @CRLF & _
			"Top Border Style: " & $avSettings[0] & @CRLF & _
			"Bottom Border Style: " & $avSettings[1] & @CRLF & _
			"Left Border Style: " & $avSettings[2] & @CRLF & _
			"Right Border Style: " & $avSettings[3] & @CRLF & _
			"Vertical Border Style: " & $avSettings[4] & @CRLF & _
			"Horizontal Border Style: " & $avSettings[5] & @CRLF & _
			"Top-Left to Bottom-Right Diagonal Border Style: " & $avSettings[6] & @CRLF & _
			"Bottom-Left to Top-Right Diagonal Border Style: " & $avSettings[7] & @CRLF & @CRLF & _
			"Press ok to set Border Style settings for a range.")

	; Retrieve Cell Range D2-E5
	$oCellRange = _LOCalc_RangeGetCellByName($oSheet, "D2", "E5")
	If @error Then _ERROR($oDoc, "Failed to retrieve Cell Object. Error:" & @error & " Extended:" & @extended)

	; Set the Cell's Border Width to $LOC_BORDERWIDTH_THICK for all four sides, and $LOC_BORDERWIDTH_THIN for the vertical and diagonal borders.
	_LOCalc_CellBorderWidth($oCellRange, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THICK, $LOC_BORDERWIDTH_THIN, $LOC_BORDERWIDTH_THIN, $LOC_BORDERWIDTH_THIN, $LOC_BORDERWIDTH_THIN)
	If @error Then _ERROR($oDoc, "Failed to set the Cell Range's settings. Error:" & @error & " Extended:" & @extended)

	; Set the Cell's Border Style to $LOC_BORDERSTYLE_DOUBLE for all four sides, and $LOC_BORDERSTYLE_DASH_DOT_DOT for the vertical and diagonal borders.
	_LOCalc_CellBorderStyle($oCellRange, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DOUBLE, $LOC_BORDERSTYLE_DASH_DOT_DOT, $LOC_BORDERSTYLE_DASH_DOT_DOT, $LOC_BORDERSTYLE_DASH_DOT_DOT, $LOC_BORDERSTYLE_DASH_DOT_DOT)
	If @error Then _ERROR($oDoc, "Failed to set the Cell Range's settings. Error:" & @error & " Extended:" & @extended)

	; Retrieve the current settings. Return will be an array with element values in order of function parameter.
	$avSettings = _LOCalc_CellBorderStyle($oCellRange)
	If @error Then _ERROR($oDoc, "Failed to retrieve the Cell Range's current settings. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "Cell Range D2-E5's Border Style settings are as follows (See UDF Constants): " & @CRLF & _
			"Top Border Style: " & $avSettings[0] & @CRLF & _
			"Bottom Border Style: " & $avSettings[1] & @CRLF & _
			"Left Border Style: " & $avSettings[2] & @CRLF & _
			"Right Border Style: " & $avSettings[3] & @CRLF & _
			"Vertical Border Style: " & $avSettings[4] & @CRLF & _
			"Horizontal Border Style: " & $avSettings[5] & @CRLF & _
			"Top-Left to Bottom-Right Diagonal Border Style: " & $avSettings[6] & @CRLF & _
			"Bottom-Left to Top-Right Diagonal Border Style: " & $avSettings[7])

	MsgBox($MB_OK, "", "Press ok to close the document.")

	; Close the document.
	_LOCalc_DocClose($oDoc, False)
	If @error Then _ERROR($oDoc, "Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc

Func _ERROR($oDoc, $sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	If IsObj($oDoc) Then _LOCalc_DocClose($oDoc, False)
	Exit
EndFunc
