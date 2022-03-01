#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****



; other build options

	Opt("TrayIconHide", 1)		; hide the tray icon for this application
	#include <Array.au3>
	#include "libraries\_zip.au3"



; variables
	Global $fullExePath= StringReplace( @AutoItExe, "\environmentVar.exe","",0)
	Global $rootDir = StringReplace( $fullExePath, "\lib\setup\windows\src","",0)
	Global $rootDir = StringReplace( $fullExePath, "\lib\setup\windows","",0)





; functions

	func locateExe()
			ConsoleWrite ( @CRLF & "exe path: " & $fullExePath )
			ConsoleWrite ( @CRLF & "root directory: " & $rootDir )

	EndFunc

	func printHelp()
		ConsoleWrite ( @CRLF )
		ConsoleWrite ( @CRLF & "please pass one of the following flags: " )
		ConsoleWrite ( @CRLF & "    -importEnvironmentVars <path to conf file>" )
		ConsoleWrite ( @CRLF & "    -removeEnvironmentVars <path to conf file>" )
		ConsoleWrite ( @CRLF & "    -launchConsoleEnvironment <path to conf file>" )
		ConsoleWrite ( @CRLF & "    -compileEnvRc <path to initial envrc.bat> <path to override envrc.bat>" )
		ConsoleWrite ( @CRLF & "    -extractZip <path to zip file> <path to extration location>" )


		ConsoleWrite ( @CRLF & "    -help" )
		ConsoleWrite ( @CRLF )
	EndFunc

	func envRcToArray()

		; grab envRc and create final array
		local $envrcRaw = FileReadToArray(".envrc.bat")
		local $finalArray = [["",""]]

		; cycle through first file
		For $i = 0 to UBound($envrcRaw) -1

			; split and clean up variable name and variable value
			local $entryArray = StringSplit($envrcRaw[$i],"=")
			local $entryVariable = StringReplace($entryArray[1],'set ','')
			local $entryValue = StringReplace($entryArray[2],'"','')

			Local $aFill = [[$entryVariable,$entryValue]]
			_ArrayAdd($finalArray,$aFill)

		Next

		_ArrayDelete($finalArray, 0)

		return $finalArray

	EndFunc

	func importEnvironmentVars($rcArray)

		_ArrayDisplay($rcArray)

		For $i = 0 to UBound($rcArray) -1
			EnvSet($rcArray[$i][0],$rcArray[$i][1])
			consoleWrite(@CRLF & @ComSpec & 'c/ setx ' & $rcArray[$i][0] & ' "' & $rcArray[$i][1] & '"')
			Run(@ComSpec & ' /c setx ' & $rcArray[$i][0] & ' "' & $rcArray[$i][1] & '"', @SystemDir)
		Next

		EnvUpdate()

	EndFunc

	func compileEnvRc($tempFile1, $tempFileOverride)

		; grab 2 files and create final array
		local $envrcRaw = FileReadToArray($tempFile1)
		local $envrcOverride = FileReadToArray($tempFileOverride)
		local $finalArray = [["",""]]


		; cycle through first file
		For $i = 0 to UBound($envrcRaw) -1

			; split and clean up variable name and variable value
			local $entryArray = StringSplit($envrcRaw[$i],"=")
			local $entryVariable = StringReplace($entryArray[1],'set "','')
			local $entryValue = StringReplace($entryArray[2],'"','')

			; search to see if variable is set already
			local $searchResult = _ArraySearch($finalArray, $entryVariable)

			if $searchResult = "-1" Then
				Local $expandedEntryValue = StringReplace($entryValue,"%CD%", $rootDir,0)
				Local $aFill = [[$entryVariable,$expandedEntryValue]]

				_ArrayAdd($finalArray,$aFill)
			EndIf

		Next


		; cycle through next array
		For $i = 0 to UBound($envrcOverride) -1

			; split and clean up variable name and variable value
			local $entryArray = StringSplit($envrcOverride[$i],"=")
			local $entryVariable = StringReplace($entryArray[1],'set "','')
			local $entryValue = StringReplace($entryArray[2],'"','')

			; search to see if variable is set already
			local $searchResult = _ArraySearch($finalArray, $entryVariable)

			if $searchResult = "-1" Then
				Local $aFill = [[$entryVariable,$entryValue]]
				_ArrayAdd($finalArray,$aFill)
			Else
				_ArrayDelete($finalArray, $searchResult)
				Local $expandedEntryValue = StringReplace($entryValue, "%CD%", $rootDir,0)
				Local $aFill = [[$entryVariable,$expandedEntryValue]]
				_ArrayAdd($finalArray,$aFill)
			EndIf

		Next

		_ArrayDelete($finalArray, 0)

		FileDelete($tempFile1)
		FileDelete($tempFileOverride)

		For $i = 0 to UBound($finalArray) -1
			FileWriteLine('.envrc.bat','set ' & $finalArray[$i][0] & '="' & $finalArray[$i][1] & '"')
		next

	EndFunc

	func extractZip($zipFile, $location)
		ConsoleWrite(@CRLF & $zipFile & @CRLF)
		ConsoleWrite($location & @CRLF)
		global $value = _Zip_UnzipAll($zipFile, $location, 20)
		ConsoleWrite(@CRLF & @error & @CRLF)
	EndFunc




; initialization steps
locateExe()


Select
	case $CMDLine[0] < 1

		printHelp()

	case $CMDLine[1] = "-help"

		printHelp()

	case $CMDLine[1] = "-importEnvironmentVars"

		ConsoleWrite(@CRLF & "take envrc.bat and add variables to environment" & @CRLF)
		local $envArray = envRcToArray()
		importEnvironmentVars($envArray)

	case $CMDLine[1] = "-removeEnvironmentVars"

		ConsoleWrite(@CRLF & "take envrc.bat and remove variables listed from environment" & @CRLF)

	case $CMDLine[1] = "-launchConsoleEnvironment"

		ConsoleWrite(@CRLF & "launch console with environment set up" & @CRLF)

	case $CMDLine[1] = "-compileEnvRc"

		ConsoleWrite(@CRLF & "take two raw envrc temp files and combine into final envrc.bat" & @CRLF)
		compileEnvRc($CMDLine[2],$CMDLine[3])

	case $CMDLine[1] = "-extractZip"

		ConsoleWrite(@CRLF & "extract zip file with no dependencies" & @CRLF)
		extractZip($CMDLine[2],$CMDLine[3])


EndSelect

