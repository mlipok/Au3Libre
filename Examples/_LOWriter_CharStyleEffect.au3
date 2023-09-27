#include <MsgBoxConstants.au3>
#include "..\LibreOfficeWriter.au3"

Example()

Func Example()
	Local $oDoc, $oViewCursor, $oCharStyle
	Local $avCharStyleSettings

	;Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOWriter_DocCreate(True, False)
	If (@error > 0) Then _ERROR("Failed to Create a new Writer Document. Error:" & @error & " Extended:" & @extended)

	;Retrieve the document view cursor to insert text with.
	$oViewCursor = _LOWriter_DocGetViewCursor($oDoc)
	If (@error > 0) Then _ERROR("Failed to retrieve the View Cursor Object for the Writer Document. Error:" & @error & " Extended:" & @extended)

	;Insert some text before I modify the Character style.
	_LOWriter_DocInsertString($oDoc, $oViewCursor, "Some text to Demonstrate modifying a Character style.")
	If (@error > 0) Then _ERROR("Failed to insert text. Error:" & @error & " Extended:" & @extended)

	;Move the View Cursor to the start of the document
	_LOWriter_CursorMove($oViewCursor, $LOW_VIEWCUR_GOTO_START)
	If (@error > 0) Then _ERROR("Failed to move ViewCursor. Error:" & @error & " Extended:" & @extended)

	;Move the cursor right 13 spaces
	_LOWriter_CursorMove($oViewCursor, $LOW_VIEWCUR_GO_RIGHT, 13)
	If (@error > 0) Then _ERROR("Failed to move ViewCursor. Error:" & @error & " Extended:" & @extended)

	;Select the word "Demonstrate".
	_LOWriter_CursorMove($oViewCursor, $LOW_VIEWCUR_GO_RIGHT, 11, True)
	If (@error > 0) Then _ERROR("Failed to move ViewCursor. Error:" & @error & " Extended:" & @extended)

	;Set the Character style to "Example" Character style.
	_LOWriter_CharStyleSet($oDoc, $oViewCursor, "Example")
	If (@error > 0) Then _ERROR("Failed to set the Character style. Error:" & @error & " Extended:" & @extended)

	;Retrieve the "Example" object.
	$oCharStyle = _LOWriter_CharStyleGetObj($oDoc, "Example")
	If (@error > 0) Then _ERROR("Failed to retrieve Character style object. Error:" & @error & " Extended:" & @extended)

	;Set "Example" Character style Font effects to $LOW_RELIEF_EMBOSSED relief type.
	_LOWriter_CharStyleEffect($oCharStyle, $LOW_RELIEF_EMBOSSED)
	If (@error > 0) Then _ERROR("Failed to set the Character style settings. Error:" & @error & " Extended:" & @extended)

	;Retrieve the current settings. Return will be an array with element values in order of function parameter.
	$avCharStyleSettings = _LOWriter_CharStyleEffect($oCharStyle)
	If (@error > 0) Then _ERROR("Failed to retrieve the Character style settings. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "The Character style's current Font effects settings are as follows: " & @CRLF & _
			"Relief style (See UDF Constants): " & $avCharStyleSettings[0] & @CRLF & _
			"Case style (See UDF Constants): " & $avCharStyleSettings[1] & @CRLF & _
			"Are the words hidden? True/False: " & $avCharStyleSettings[2] & @CRLF & _
			"Are the words outlined? True/False: " & $avCharStyleSettings[3] & @CRLF & _
			"Do the words have a shadow? True/False: " & $avCharStyleSettings[4] & @CRLF & @CRLF & _
			"I will now set Case to $LOW_CASEMAP_SM_CAPS, and Relief to $LOW_RELIEF_NONE.")

	;Set "Example" Character style Font effects to $LOW_RELIEF_NONE relief type, Case to $LOW_CASEMAP_SM_CAPS
	_LOWriter_CharStyleEffect($oCharStyle, $LOW_RELIEF_NONE, $LOW_CASEMAP_SM_CAPS)
	If (@error > 0) Then _ERROR("Failed to set the Character style settings. Error:" & @error & " Extended:" & @extended)

	;Retrieve the current settings. Return will be an array with element values in order of function parameter.
	$avCharStyleSettings = _LOWriter_CharStyleEffect($oCharStyle)
	If (@error > 0) Then _ERROR("Failed to retrieve the Character style settings. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "The Character style's current Font effects settings are as follows: " & @CRLF & _
			"Relief style (See UDF Constants): " & $avCharStyleSettings[0] & @CRLF & _
			"Case style (See UDF Constants): " & $avCharStyleSettings[1] & @CRLF & _
			"Are the words hidden? True/False: " & $avCharStyleSettings[2] & @CRLF & _
			"Are the words outlined? True/False: " & $avCharStyleSettings[3] & @CRLF & _
			"Do the words have a shadow? True/False: " & $avCharStyleSettings[4])

	MsgBox($MB_OK, "", "Press ok to close the document.")

	;Close the document.
	_LOWriter_DocClose($oDoc, False)
	If (@error > 0) Then _ERROR("Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc

Func _ERROR($sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	Exit
EndFunc
