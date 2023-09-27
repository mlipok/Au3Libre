#include <MsgBoxConstants.au3>
#include "..\LibreOfficeWriter.au3"

Example()

Func Example()
	Local $oDoc, $oViewCursor, $oTable
	Local $bReturn

	;Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOWriter_DocCreate(True, False)
	If (@error > 0) Then _ERROR("Failed to Create a new Writer Document. Error:" & @error & " Extended:" & @extended)

	;Retrieve the document view cursor to insert text with.
	$oViewCursor = _LOWriter_DocGetViewCursor($oDoc)
	If (@error > 0) Then _ERROR("Failed to retrieve the View Cursor Object for the Writer Document. Error:" & @error & " Extended:" & @extended)

	;Create a Table, 2 rows, 2 columns
	$oTable = _LOWriter_TableCreate($oDoc, 2, 2, Null, Null, "AutoitTest")
	If (@error > 0) Then _ERROR("Failed to create Text Table. Error:" & @error & " Extended:" & @extended)

	;Insert the Table into the document.
	$oTable = _LOWriter_TableInsert($oDoc, $oViewCursor, $oTable)
	If (@error > 0) Then _ERROR("Failed to insert Text Table. Error:" & @error & " Extended:" & @extended)

	;Check if the document has a table by the name of "AutoitTest"
	$bReturn = _LOWriter_DocHasTableName($oDoc, "AutoitTest")
	If (@error > 0) Then _ERROR("Failed to look for Text Table name. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "Does this document contain a Table named ""AutoitTest""? True/ False. " & $bReturn)

	;Delete the table.
	_LOWriter_TableDelete($oDoc, $oTable)
	If (@error > 0) Then _ERROR("Failed to delete Text Table. Error:" & @error & " Extended:" & @extended)

	;Check again, if the document has a table by the name of "AutoitTest"
	$bReturn = _LOWriter_DocHasTableName($oDoc, "AutoitTest")
	If (@error > 0) Then _ERROR("Failed to look for Text Table name. Error:" & @error & " Extended:" & @extended)

	MsgBox($MB_OK, "", "Now does this document contain a Table named ""AutoitTest""? True/ False. " & $bReturn)

	MsgBox($MB_OK, "", "Press ok to close the document.")

	;Close the document.
	_LOWriter_DocClose($oDoc, False)
	If (@error > 0) Then _ERROR("Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc

Func _ERROR($sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	Exit
EndFunc
