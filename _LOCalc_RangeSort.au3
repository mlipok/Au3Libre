#include "LibreOfficeCalc.au3"

_LOCalc_ComError_UserFunction(ConsoleWrite)

; Connect to open Calc Doc
Global $oDocument = _LOCalc_DocCreate(True)

; Get Active Sheet
Global $oSheet = _LOCalc_SheetGetActive($oDocument)

; Get Cell Range to fill with numbers
Global $oCellRange = _LOCalc_RangeGetCellByName($oSheet, "B1", "B5")
If @error Then ConsoleWrite("Cell Range 1 -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Fill Arrays with numbers
Global $aArray[5]
Global $aFill[1]

$aFill[0] = 5
$aArray[0] = $aFill
$aFill[0] = 3
$aArray[1] = $aFill
$aFill[0] = 4
$aArray[2] = $aFill
$aFill[0] = 1
$aArray[3] = $aFill
$aFill[0] = 2
$aArray[4] = $aFill

; Fill Range with numbers
_LOCalc_RangeNumbers($oCellRange, $aArray)
If @error Then ConsoleWrite("Range Fill Numbers -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Get a second Cell Range to fill with the Sort results
Global $oCellRange2 = _LOCalc_RangeGetCellByName($oSheet, "B9", "B10")
If @error Then ConsoleWrite("Cell Range 2 -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

Global Const _
		$LOC_SORT_DATA_TYPE_AUTO = 0, _ ; Automatically determine Sort Data type.
		$LOC_SORT_DATA_TYPE_NUMERIC = 1, _ ; Sort Data type is Numerical.
		$LOC_SORT_DATA_TYPE_ALPHANUMERIC = 2 ; Sort Data type is Text.

; Create a Sort Descriptor, 0 = first column in the range B1-B5.
; $LOC_SORT_DATA_TYPE_AUTO = Auto determine type of data being sorted.
; True = Ascending sort order. (12345)
Global $tDesc = _LOCalc_SortDescriptorCreate(0, $LOC_SORT_DATA_TYPE_AUTO, True)
If @error Then ConsoleWrite("Sort Desc -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Perform the sort. False = Sort rows top to bottom. (True would mean sort columns Left to Right)
; False = Range has no headers to ignore.
; False = Dont bind any formatting to the data when sorted.
; True = Copy the sort results instead of modifying the cell range itself.
; CellRange2 = where to put the sorted data copy.
_LOCalc_RangeSort($oCellRange, $tDesc, False, False, False, True, $oCellRange2)
If @error Then ConsoleWrite("Range Sort -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Two results happen with this sort, either the data is not sorted at all or the data doesn't sort properly.
; But it is still output to the copy range.
; If it sorts, it is always in descending order, even when I selected Ascending order.


;#########################


ConsoleWrite(@CRLF & "! Letters Test" & @CRLF )
; Get Cell Range to fill with Letters
$oCellRange = _LOCalc_RangeGetCellByName($oSheet, "D1", "D5")
If @error Then ConsoleWrite("Cell Range 1 -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Fill Arrays with Letter

$aFill[0] = "e"
$aArray[0] = $aFill
$aFill[0] = "a"
$aArray[1] = $aFill
$aFill[0] = "c"
$aArray[2] = $aFill
$aFill[0] = "b"
$aArray[3] = $aFill
$aFill[0] = "d"
$aArray[4] = $aFill

; Fill Range with numbers
_LOCalc_RangeData($oCellRange, $aArray)
If @error Then ConsoleWrite("Range Fill Numbers -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Get a second Cell Range to fill with the Sort results
$oCellRange2 = _LOCalc_RangeGetCellByName($oSheet, "D9", "D10")
If @error Then ConsoleWrite("Cell Range 2 -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Create a Sort Descriptor, 0 = first column in the range D1-D5.
; $LOC_SORT_DATA_TYPE_AUTO = Auto determine type of data being sorted.
; True = Ascending sort order. (abcde)
$tDesc = _LOCalc_SortDescriptorCreate(0, $LOC_SORT_DATA_TYPE_AUTO, True)
If @error Then ConsoleWrite("Sort Desc -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; Perform the sort. False = Sort rows top to bottom.
; False = Range has no headers to ignore.
; False = Dont bind any formatting to the data when sorted.
; True = Copy the sort results instead of modifying the cell range itself.
; CellRange2 = where to put the sorted data copy.
_LOCalc_RangeSort($oCellRange, $tDesc, False, False, False, True, $oCellRange2)
If @error Then ConsoleWrite("Range Sort -- Error = " & @error & @CRLF & "Ext. = " & @extended & @CRLF)

; The data doesn't sort at all, but it is still output to the copy range.

; Passing this same data to a Macro that I insert in L.O., and re-inputting the sort descriptor, using the macro, into the property array makes this work fine.
; I assume it is an incompatibility between AutoIt Data and L.O.'s expected data??
Exit






Func _LOCalc_SortDescriptorCreate($iIndex, $iDataType = $LOC_SORT_DATA_TYPE_AUTO, $bAscending = True, $bCaseSensitive = False)
Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

	Local $tSortField

If Not IsInt($iIndex) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
If Not __LOCalc_IntIsBetween($iDataType, $LOC_SORT_DATA_TYPE_AUTO, $LOC_SORT_DATA_TYPE_ALPHANUMERIC) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
If Not IsBool($bAscending) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
If Not IsBool($bCaseSensitive) Then Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0)

$tSortField = __LOCalc_CreateStruct("com.sun.star.table.TableSortField")
If Not IsObj($tSortField) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)

With $tSortField
.Field = $iIndex
.FieldType = $iDataType
.IsAscending = $bAscending
.IsCaseSensitive = $bCaseSensitive
EndWith

	Return SetError($__LO_STATUS_SUCCESS, 0, $tSortField)
EndFunc

Func _LOCalc_RangeSort(ByRef $oRange, ByRef $tSortDesc, $bSortColumns = False, $bHasHeader = False, $bBindFormat = True, $bCopyOutput = False, $oCellOutput = Null, $tSortDesc2 = Null, $tSortDesc3 = Null)
Local $oCOM_ErrorHandler = ObjEvent("AutoIt.Error", __LOCalc_InternalComErrorHandler)
	#forceref $oCOM_ErrorHandler

Local $avSortDesc
Local $atSortField[1]
Local $tCellInputAddr, $tCellAddr, $tSortRangeAddr

; Error check
	If Not IsObj($oRange) Then Return SetError($__LO_STATUS_INPUT_ERROR, 1, 0)
	If Not IsObj($tSortDesc) Then Return SetError($__LO_STATUS_INPUT_ERROR, 2, 0)
	If Not IsBool($bSortColumns) Then Return SetError($__LO_STATUS_INPUT_ERROR, 3, 0)
	If Not IsBool($bHasHeader) Then Return SetError($__LO_STATUS_INPUT_ERROR, 4, 0)
	If Not IsBool($bBindFormat) Then Return SetError($__LO_STATUS_INPUT_ERROR, 5, 0)
	If Not IsBool($bCopyOutput) Then Return SetError($__LO_STATUS_INPUT_ERROR, 6, 0)

; Retrieve Sort Descriptor for calling sort with.
	$avSortDesc = $oRange.createSortDescriptor()
	If Not IsArray($avSortDesc) Then Return SetError($__LO_STATUS_INIT_ERROR, 1, 0)

If $bSortColumns Then
If Not __LOCalc_IntIsBetween($tSortDesc.Field(), 0, $oRange.Columns.Count() - 1) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0)
Else
	If Not __LOCalc_IntIsBetween($tSortDesc.Field(), 0, $oRange.Rows.Count() - 1) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 1, 0)
EndIf

$atSortField[0] = $tSortDesc

If ($tSortDesc2 <> Null) Then
If Not IsObj($tSortDesc2) Then Return SetError($__LO_STATUS_INPUT_ERROR, 7, 0)

If $bSortColumns Then
If Not __LOCalc_IntIsBetween($tSortDesc2.Field(), 0, $oRange.Columns.Count() - 1) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 2, 0)
Else
	If Not __LOCalc_IntIsBetween($tSortDesc2.Field(), 0, $oRange.Rows.Count() - 1) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 2, 0)
EndIf

ReDim $atSortField[2]
$atSortField[1] = $tSortDesc2

EndIf

If ($tSortDesc3 <> Null) Then
If Not IsObj($tSortDesc3) Then Return SetError($__LO_STATUS_INPUT_ERROR, 8, 0)

If $bSortColumns Then
If Not __LOCalc_IntIsBetween($tSortDesc3.Field(), 0, $oRange.Columns.Count() - 1) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 3, 0)
Else
	If Not __LOCalc_IntIsBetween($tSortDesc3.Field(), 0, $oRange.Rows.Count() - 1) Then Return SetError($__LO_STATUS_PROCESSING_ERROR, 3, 0)
EndIf

ReDim $atSortField[UBound($atSortField) + 1]
$atSortField[UBound($atSortField) - 1] = $tSortDesc3

EndIf

If ($bCopyOutput = True) Then
If Not IsObj($oCellOutput) Then Return SetError($__LO_STATUS_INPUT_ERROR, 9, 0)

$tCellInputAddr = $oCellOutput.RangeAddress()
If Not IsObj($tCellInputAddr) Then Return SetError($__LO_STATUS_INIT_ERROR, 2, 0)

$tCellAddr = __LOCalc_CreateStruct("com.sun.star.table.CellAddress")
	If Not IsObj($tCellAddr) Then Return SetError($__LO_STATUS_INIT_ERROR, 3, 0)

	$tCellAddr.Sheet = $tCellInputAddr.Sheet()
	$tCellAddr.Column = $tCellInputAddr.StartColumn()
	$tCellAddr.Row = $tCellInputAddr.StartRow()

EndIf

For $i  = 0 To UBound($avSortDesc) - 1

Switch $avSortDesc[$i].Name()

	Case "IsSortColumns"
	$avSortDesc[$i].Value = $bSortColumns

	Case "ContainsHeader"
		$avSortDesc[$i].Value = $bHasHeader

	Case "SortFields"
		$avSortDesc[$i].Value = $atSortField

	Case "BindFormatsToContent"
$avSortDesc[$i].Value = $bBindFormat

	Case "CopyOutputData"
$avSortDesc[$i].Value = $bCopyOutput

	Case "OutputPosition"
		If ($bCopyOutput = True) Then $avSortDesc[$i].Value = $tCellAddr

	EndSwitch

Next

$oRange.Sort($avSortDesc)

Return SetError($__LO_STATUS_SUCCESS, 0, 1)
EndFunc

