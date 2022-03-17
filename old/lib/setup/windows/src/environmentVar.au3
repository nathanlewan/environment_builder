#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile_x64=..\environmentVar.exe
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
		   $rootDir = StringReplace( $rootDir, "\lib\setup\windows","",0)
	Global $envRcFileLocation = $rootDir & "\.envrc.bat"
	Global $envRcTempFileLocation = $rootDir & "\.tmp_envrc.bat"
	Global $envRcTempOverrideFileLocation = $rootDir & "\.tmp_ovr_envrc.bat"





; functions

	func locateExe()

			ConsoleWrite ( @CRLF & "root directory:                      " & $rootDir )
			ConsoleWrite ( @CRLF & "exe path:                            " & $fullExePath )
			ConsoleWrite ( @CRLF & "envrc file location:                 " & $envRcFileLocation )
			ConsoleWrite ( @CRLF & "[temp] envrc file location:          " & $envRcTempFileLocation )
			ConsoleWrite ( @CRLF & "[temp override] envrc file location: " & $envRcTempOverrideFileLocation )

			ConsoleWrite ( @CRLF & "number of args passed:               " & $CMDLine[0] )

	EndFunc



	func printHelp()

		ConsoleWrite ( @CRLF )
		ConsoleWrite ( @CRLF & "please pass one of the following flags: " )
		ConsoleWrite ( @CRLF & "    -importEnvironmentVars [<path to conf file> | <blank for default location] [permanent | not-permanent | blank]" )
		ConsoleWrite ( @CRLF & "    -removeEnvironmentVars <path to conf file>" )
		ConsoleWrite ( @CRLF & "    -launchConsoleEnvironment <path to conf file>" )
		ConsoleWrite ( @CRLF & "    -compileEnvRc <path to initial envrc.bat> <path to override envrc.bat>" )
		ConsoleWrite ( @CRLF & "    -extractZip <path to zip file> <path to extration location>" )

		ConsoleWrite ( @CRLF & "    -help" )
		ConsoleWrite ( @CRLF )

	EndFunc



	func envRcToArray($rcFileLoc)

		; grab envRc and create final array
		local $envrcRaw = FileReadToArray($rcFileLoc)
		local $finalArray = [["",""]]

		; cycle through first file
		For $i = 0 to UBound($envrcRaw) -1

			if $envrcRaw[$i] = '@ECHO OFF' then ContinueLoop
			if $envrcRaw[$i] = 'cls' then ContinueLoop

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



	func importEnvironmentVars($rcArray,$permanent)

		For $i = 0 to UBound($rcArray) -1

			EnvSet($rcArray[$i][0],$rcArray[$i][1])

			if $permanent = "permanent" then
				Run(@ComSpec & ' /c setx ' & $rcArray[$i][0] & ' "' & $rcArray[$i][1] & '"', @SystemDir)
			EndIf

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

		Local $sortedArray = _ArraySort($finalArray)

		; write heading
		FileWriteLine($envRcFileLocation,'@ECHO OFF')

		For $i = 0 to UBound($finalArray) -1
			FileWriteLine($envRcFileLocation,'set ' & $finalArray[$i][0] & '=' & $finalArray[$i][1])
		next

		; write end
		FileWriteLine($envRcFileLocation,'cls')

	EndFunc



	func extractZip($zipFile, $location)

		ConsoleWrite(@CRLF & $zipFile & @CRLF)
		ConsoleWrite($location & @CRLF)
		global $value = _Zip_UnzipAll($zipFile, $location, 20)
		ConsoleWrite(@CRLF & @error & @CRLF)

	EndFunc



	func removeEnvironmentVars($rcArray)

		For $i = 0 to UBound($rcArray) -1
			RegDelete("HKCU\Environment", $rcArray[$i][0])
		Next

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

		local $envArray

		; if we have -importEnvironmentVars + [something], determine what that something is
		if $CMDLine[0] = 2  Then

			; if [something] = 'permanent', we are using the default file location, and setting them permanently in env vars
			if $CMDLine[2] = "permanent" Then

				ConsoleWrite("using default file location: " & $envRcFileLocation & @CRLF)
				ConsoleWrite("permanently setting environment vars")
				$envArray = envRcToArray($envRcFileLocation)
				importEnvironmentVars($envArray,"permanent")

			; if [something] = anything other than 'permanent', treat as a file location
			Else

				ConsoleWrite("path to file supplied: " & $CMDLine[2])
				$envArray = envRcToArray($CMDLine[2])
				importEnvironmentVars($envArray,"not-permanent")

			EndIf

		; if we have -importEnvironmentVars + [something1] + [something2], determine what that something is
		ElseIf $CMDLine[0] = 3 then

			; if [something2] = permanent, assume [something1] is a path to a file, and set env vars permanently
			if $CMDLine[3] = "permanent" Then

				ConsoleWrite("path to file supplied: " & $CMDLine[2])
				$envArray = envRcToArray($CMDLine[2])
				importEnvironmentVars($envArray,"permanent")

			Else

				ConsoleWrite("path to file supplied: " & $CMDLine[2])
				$envArray = envRcToArray($CMDLine[2])
				importEnvironmentVars($envArray,"not-permanent")

			EndIf


		Else

			ConsoleWrite("using default file location: " & $envRcFileLocation)
			$envArray = envRcToArray($envRcFileLocation)

		EndIf





	case $CMDLine[1] = "-removeEnvironmentVars"

		ConsoleWrite(@CRLF & "take envrc.bat and remove variables listed from environment" & @CRLF)

		if $CMDLine[0] = 2  Then
			ConsoleWrite("path to file supplied")
			local $envArray = envRcToArray($CMDLine[2])
		Else
			ConsoleWrite("using default file location")
			local $envArray = envRcToArray($envRcFileLocation)
		EndIf

		removeEnvironmentVars($envArray)



	case $CMDLine[1] = "-launchConsoleEnvironment"

		ConsoleWrite(@CRLF & "launch console with environment set up" & @CRLF)
		Run(@ComSpec & ' /k ' & $rootDir & '\.envrc.bat',$rootDir,@SW_SHOW,$RUN_CREATE_NEW_CONSOLE)

	case $CMDLine[1] = "-compileEnvRc"

		ConsoleWrite(@CRLF & "take two raw envrc temp files and combine into final envrc.bat" & @CRLF)

		if $CMDLine[0] = 3 Then
			ConsoleWrite("path to file supplied")
			local $tmpFile = $CMDLine[2]
			local $tmpOverrideFile = $CMDLine[3]
		Else
			local $tmpFile = $envRcTempFileLocation
			local $tmpOverrideFile = $envRcTempOverrideFileLocation
		EndIf


		compileEnvRc($tmpFile,$tmpOverrideFile)



	case $CMDLine[1] = "-extractZip"

		ConsoleWrite(@CRLF & "extract zip file with no dependencies" & @CRLF)
		extractZip($CMDLine[2],$CMDLine[3])


EndSelect

