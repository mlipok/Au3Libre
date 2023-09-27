
#include "..\LibreOfficeWriter.au3"
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $oDoc, $oViewCursor, $oFrame
	Local $iTransparency

	;Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOWriter_DocCreate(True, False)
	If (@error > 0) Then _ERROR("Failed to Create a new Writer Document. Error:" & @error & " Extended:" & @extended)

	;Retrieve the document view cursor to insert text with.
	$oViewCursor = _LOWriter_DocGetViewCursor($oDoc)
	If (@error > 0) Then _ERROR("Failed to retrieve the View Cursor Object for the Writer Document. Error:" & @error & " Extended:" & @extended)

	;Insert a Frame into the document at the Viewcursor position, and 3000x3000 Micrometers wide.
	$oFrame = _LOWriter_FrameCreate($oDoc, $oViewCursor, Null, 3000, 3000)
	If (@error > 0) Then _ERROR("Failed to create a Frame. Error:" & @error & " Extended:" & @extended)

	;Modify the Frame Background Color settings. Background color = $LOW_COLOR_TEAL, Background color is transparent = False
	_LOWriter_FrameAreaColor($oFrame, $LOW_COLOR_TEAL, False)
	If (@error > 0) Then _ERROR("Failed to set Frame settings. Error:" & @error & " Extended:" & @extended)

	;Modify the Frame Transparency settings to 55% transparent
	_LOWriter_FrameTransparency($oFrame, 55)
	If (@error > 0) Then _ERROR("Failed to set Frame settings. Error:" & @error & " Extended:" & @extended)

	;Retrieve the current Frame Transparency. Return will be an Integer.
	$iTransparency = _LOWriter_FrameTransparency($oFrame)
	If (@error > 0) Then _ERROR("Failed to retrieve Frame settings. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "The Frame's current Transparecny percentage is: " & $iTransparency)

	MsgBox($MB_OK, "", "Press ok to close the document.")

	;Close the document.
	_LOWriter_DocClose($oDoc, False)
	If (@error > 0) Then _ERROR("Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc

Func _ERROR($sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	Exit
EndFunc

