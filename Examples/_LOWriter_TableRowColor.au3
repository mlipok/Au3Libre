#include <MsgBoxConstants.au3>

#include "..\LibreOfficeWriter.au3"

Example()

Func Example()
	Local $oDoc, $oViewCursor, $oTable, $oCell
	Local $iRows, $iColumns
	Local $avColor

	; Create a New, visible, Blank Libre Office Document.
	$oDoc = _LOWriter_DocCreate(True, False)
	If @error Then _ERROR($oDoc, "Failed to Create a new Writer Document. Error:" & @error & " Extended:" & @extended)

	; Retrieve the document view cursor to insert text with.
	$oViewCursor = _LOWriter_DocGetViewCursor($oDoc)
	If @error Then _ERROR($oDoc, "Failed to retrieve the View Cursor Object for the Writer Document. Error:" & @error & " Extended:" & @extended)

	; Create a Table, 5 rows, 3 columns.
	$oTable = _LOWriter_TableCreate($oDoc, 5, 3)
	If @error Then _ERROR($oDoc, "Failed to create Text Table. Error:" & @error & " Extended:" & @extended)

	; Insert the Table into the document at the View Cursor's location.
	$oTable = _LOWriter_TableInsert($oDoc, $oViewCursor, $oTable)
	If @error Then _ERROR($oDoc, "Failed to insert Text Table. Error:" & @error & " Extended:" & @extended)

	; Retrieve how many Rows the Table currently contains.
	$iRows = _LOWriter_TableRowGetCount($oTable)
	If @error Then _ERROR($oDoc, "Failed to retrieve Text Table Row count. Error:" & @error & " Extended:" & @extended)

	; Retrieve how many Columns the Table currently contains.
	$iColumns = _LOWriter_TableColumnGetCount($oTable)
	If @error Then _ERROR($oDoc, "Failed to retrieve Text Table Column count. Error:" & @error & " Extended:" & @extended)

	For $iRow = 0 To $iRows - 1

		For $iColumn = 0 To $iColumns - 1
			; Retrieve each cell by position in the Table.
			$oCell = _LOWriter_TableGetCellObjByPosition($oTable, $iColumn, $iRow)
			If @error Then _ERROR($oDoc, "Failed to retrieve Text Table Cell by position. Error:" & @error & " Extended:" & @extended)

			; Set Cell text String to Cell's position.
			_LOWriter_CellString($oCell, "Column " & $iColumn & @CR & " Row " & $iRow)
			If @error Then _ERROR($oDoc, "Failed to set Text Table Cell String. Error:" & @error & " Extended:" & @extended)
		Next
	Next

	; Change the 3rd row down (Row 2) background color to: $LOW_COLOR_ORANGE
	_LOWriter_TableRowColor($oTable, 2, $LOW_COLOR_ORANGE, False)
	If @error Then _ERROR($oDoc, "Failed to set the row background color settings. Error:" & @error & " Extended:" & @extended)

	; Retrieve row's current background color settings.
	$avColor = _LOWriter_TableRowColor($oTable, 2)
	If @error Then _ERROR($oDoc, "Failed to retrieve the row background color settings. Error:" & @error & " Extended:" & @extended)

	; Array elements will be in order of function's parameters.
	MsgBox($MB_OK, "", "The background color settings for the Third row down, (Row 2), is: " & @CRLF & _
			"Background color: " & $avColor[0] & @CRLF & _
			"Background color is transparent? True/False: " & $avColor[1])

	MsgBox($MB_OK, "", "Press ok to close the document.")

	; Close the document.
	_LOWriter_DocClose($oDoc, False)
	If @error Then _ERROR($oDoc, "Failed to close opened L.O. Document. Error:" & @error & " Extended:" & @extended)

EndFunc   ;==>Example

Func _ERROR($oDoc, $sErrorText)
	MsgBox($MB_OK, "Error", $sErrorText)
	If IsObj($oDoc) Then _LOWriter_DocClose($oDoc, False)
	Exit
EndFunc   ;==>_ERROR
