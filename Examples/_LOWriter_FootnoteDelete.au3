#include <MsgBoxConstants.au3>

#include "..\LibreOfficeWriter.au3"

Example()

Func Example()
	Local $oDoc, $oViewCursor, $oFootNote

	; Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOWriter_DocCreate(True, False)
	If @error Then _ERROR("Failed to Create a new Writer Document. Error:" & @error & " Extended:" & @extended)

	; Retrieve the document view cursor to insert text with.
	$oViewCursor = _LOWriter_DocGetViewCursor($oDoc)
	If @error Then _ERROR("Failed to retrieve the View Cursor Object for the Writer Document. Error:" & @error & " Extended:" & @extended)

	; Insert some text.
	_LOWriter_DocInsertString($oDoc, $oViewCursor, "I have inserted a Footnote at the end of this line. ")
	If @error Then _ERROR("Failed to insert text. Error:" & @error & " Extended:" & @extended)

	; Insert a Footnote at the ViewCursor.
	$oFootNote = _LOWriter_FootnoteInsert($oDoc, $oViewCursor)
	If @error Then _ERROR("Failed to insert a Footnote. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "Press ok to delete the Footnote.")

	; Delete the footnote.
	_LOWriter_FootnoteDelete($oFootNote)
	If @error Then _ERROR("Failed to delete a Footnote. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "Press ok to close the document.")

	; Close the document.
	_LOWriter_DocClose($oDoc, False)
	If @error Then _ERROR("Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc

Func _ERROR($sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	Exit
EndFunc
