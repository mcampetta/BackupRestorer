

;IfNotExist, %A_AppData%\BackupRestorer
;{
	FileCreateDir, %A_AppData%\BackupRestorer
	fileinstall, imobiledevice.dll, %A_AppData%\BackupRestorer\imobiledevice.dll
	fileinstall, libeay32.dll, %A_AppData%\BackupRestorer\libeay32.dll
	fileinstall, plist.dll, %A_AppData%\BackupRestorer\plist.dll
	fileinstall, ssleay32.dll, %A_AppData%\BackupRestorer\ssleay32.dll
	fileinstall, usbmuxd.dll, %A_AppData%\BackupRestorer\usbmuxd.dll
	fileinstall, idevicebackup2.exe, %A_AppData%\BackupRestorer\idevicebackup2.exe
	fileinstall, deviceconnect2.png, %A_AppData%\BackupRestorer\deviceconnect2.png
	fileinstall, deviceconnect3.png, %A_AppData%\BackupRestorer\deviceconnect3.png
	fileinstall, ideviceinfo.exe, %A_AppData%\BackupRestorer\ideviceinfo.exe
;}

pic1 = %A_AppData%\BackupRestorer\deviceconnect2.png
pic2 = %A_AppData%\BackupRestorer\deviceconnect3.png

/*
selectfolder:
FileSelectFolder, iTunesBackup, , 3
if iTunesBackup =
{ 
	MsgBox, You didn't select a folder.
	gosub, selectfolder
}
else
{
}
*/

Gui, -DPIScale
Gui, Color, FFFFFF
Gui, Font, s17, Arial
Gui, Add, Text, % dpi ("x10 y10 w773 h30 +Center +BackgroundTrans vF1"), Please connect an iOS Device to continue..
Gui, add, picture, % dpi ("x10 y40 h-1 vDeviceConnect"), %A_AppData%\BackupRestorer\deviceconnect2.png

gui, add, button, % dpi ("x658 y490 w100 h30 vNext gNext"), Next
gui, add, button, % dpi ("x658 y490 w100 h30 vFinish gFinish"), Next..
GuiControl, disable, Next
GuiControl, disable, Finish
Guicontrol, hide, finish
Gui, Font, s10, Arial
gui, add, text, % dpi ("x150 y55 w250 h30 +BackgroundTrans vbackupdatefield"), 
gui, add, text, % dpi ("x410 y55 w350 h30 +Center +BackgroundTrans vDeviceNameField"),
Gui, Font, s8, Arial
gui, add, text, % dpi ("x40 y465 w600 h15 +BackgroundTrans vstdoutfield"), 
guicontrol,, vstdoutfield2, hide
gui, add, Progress, % dpi ("x38 y490 w600 h30 vMyProgress"), 
Gui, Font, s10, Arial
;guicontrol,, MyProgress, 50, test
Gui, Show, x773 y561, Backup Restorer
;MsgBox,,, %1folders%
	
iTunesBackup := A_WorkingDir

;Determines backupdate of the backup in the same folder as this binary.
loop, %A_WorkingDir%\*.*, 2
{
	%A_Index%folders = %A_LoopFileName%
}
StringReplace, 1folders,1folders, `r,, All
StringReplace, 1folders,1folders, `n,, All
;MsgBox,,, %A_WorkingDir%\%1folders%\Manifest.plist

;Get's the name of the Device in the info.plist
manifest := A_WorkingDir "\" . 1folders "\info.plist" 
IfNotExist, %manifest%
{
	MsgBox, 16, iTunes Backup Not Found!, An iTunes backup was not found.`n`nPlease make sure that this program is run in the same folder as an iTunes Backup`n`nExample:`n`n-iTunes Backup`n  --f49dfa157f0e6b2f0627bb5a8b2e10711b73af7f`n  --BackupRestorer.exe
	ExitApp
}
;MsgBox % manifest
fileread, manifestvar, *P65001 %manifest%
;MsgBox % manifestvar
loop parse, manifestvar, `n
{
	if (nexthit == "true")
	{
		BackupDeviceName := A_LoopField
		sanatizedBackupDeviceName:=RegExReplace(BackupDeviceName, ".*(<string>)(.*)(</string>).*", "$2")
		;MsgBox % sanatizedBackupDeviceName
		;MsgBox % BackupDeviceName 
	}
	ifinstring, A_loopfield, <key>Device Name</key>
	{
	;	MsgBox,,, hit found!
	nexthit := "true"
	}
	else
	{
	nexthit := "false"
	}
}

;Get's the timestamp of info.plist in the backupdirectory.
FileGetTime, BackupDate, %manifest%, M
FormatTime, BackupDate, %BackupDate%, M/d/yyyy h:mmtt


GuiControl, -Redraw, backupdatefield
guicontrol,, backupdatefield, %sanatizedBackupDeviceName%: %Backupdate%
GuiControl, +Redraw, backupdatefield
SetTimer, checkstatus, 250
;SetTimer, progressbar, 250

checkstatus:
filedelete, %A_AppData%\BackupRestorer\status.txt
Runwait, %comspec% /c idevicebackup2.exe info "%A_WorkingDir%" >> status.txt, %A_AppData%\BackupRestorer , hide
fileread, phonestatus, *P65001 %A_AppData%\BackupRestorer\status.txt
IfInString, phonestatus, No device found, is it plugged in?
{
GuiControl, -Redraw, F1
guicontrol,, F1, Please connect an iOS Device to continue...
GuiControl, +Redraw, F1
GuiControl, -Redraw, DeviceNameField
guicontrol,, DeviceNameField, No iOS Device Connected..
GuiControl, +Redraw, DeviceNameField
guicontrol, disable, Next
;GuiControl, -Redraw, DeviceConnect
Guicontrol,, DeviceConnect, %pic1%
;GuiControl, +Redraw, DeviceConnect
;MsgBox % "Please connect the iOS device you wish to restore data to and click OK`n`nPlease note this will erase all data on the new phone"
;IfMsgBox OK
;	gosub, checkstatus
}
else
{
guicontrol,, F1, iOS Device Connected! 
guicontrol,, DeviceConnect, %pic2%
FileDelete, %A_AppData%\BackupRestorer\deviceinfo.txt
FileDelete, %A_AppData%\BackupRestorer\lockdown.txt
Runwait, %comspec% /c ideviceinfo.exe -s >> deviceinfo.txt, %A_AppData%\BackupRestorer , hide
fileread, DeviceName, *P65001 %A_AppData%\BackupRestorer\deviceinfo.txt
loop, parse, DeviceName, `n
{
	IfInString, A_LoopField, DeviceName
	{
	currentDeviceName := A_LoopField
	StringReplace, currentDeviceName,currentDeviceName, `r,, All
	StringReplace, currentDeviceName,currentDeviceName, `n,, All
	}
}
DeviceNameText := currentDeviceName . " " . truststate
guicontrol,, DeviceNameField, %DeviceNameText% 
Runwait, %comspec% /c ideviceinfo.exe 2> lockdown.txt, %A_AppData%\BackupRestorer , Hide
fileread, lockdown, *P65001 %A_AppData%\BackupRestorer\lockdown.txt
	StringReplace, lockdown,lockdown, `r,, All
	StringReplace, lockdown,lockdown, `n,, All
	StringReplace, lockdown,lockdown, %A_Space%,, All
;MsgBox % lockdown
if (lockdown == "ERROR:Couldnotconnecttolockdownd,errorcode-2")
{
	truststate := "Untrusted"
	GuiControl, disable, Next
	TimesWarned += 1
	if (TimesWarned < 1)
	{
	MsgBox,,, Please unlock your device and Trust this machine in order to continue!
	}
}
else
	{
	truststate := "Trusted"
	guicontrol, enable, Next
	FileDelete, %A_AppData%\BackupRestorer\deviceinfo2.txt
	Runwait, %comspec% /c ideviceinfo.exe >> deviceinfo2.txt, %A_AppData%\BackupRestorer , hide
	FileReadLine, deviceinfoextended, %A_AppData%\BackupRestorer\deviceinfo2.txt, 1
;	MsgBox % deviceinfoextended
	IfInString, deviceinfoextended, Unactivated
	{
	MsgBox, 48, Unactivated Device Connected, Please activate device before proceeding.`n`nStep device through activation.`n`nEx: Getting Started > Connect To WiFi > Next
	ExitApp
	}
	}
	
;guicontrol, enable, Next
;	gosub, checkstatus
}
return



Next:
MsgBox, 52, Warning! Data will be erased, Data restored from your iOS backup will not be merged with existing data.`n`nThe connected device will be erased and data restored will be only data from the backup provided.`n`nPlease backup connected device's data prior to performing this procedure if you wish to keep it's data.`n`nProceed with the restore? (YES to proceed or NO to cancel)
IfMsgBox No
    return
filedelete, %A_AppData%\BackupRestorer\oldUDID.txt
filedelete, %A_AppData%\BackupRestorer\findmyiphone.txt
FileAppend, %1folders%, %A_AppData%\BackupRestorer\oldUDID.txt
fileread, DeviceUDID, *P65001 %A_AppData%\BackupRestorer\deviceinfo.txt
loop, parse, DeviceUDID, `n
{
	IfInString, A_LoopField, UniqueDeviceID
	currentDeviceUDID := A_LoopField
	StringReplace, currentDeviceUDID,currentDeviceUDID, `r,, All
	StringReplace, currentDeviceUDID,currentDeviceUDID, `n,, All	
}
loop, parse, currentDeviceUDID, :
{
	%A_Index%currentDeviceUDID := A_LoopField
	StringReplace, %A_Index%currentDeviceUDID,%A_Index%currentDeviceUDID, `r,, All
	StringReplace, %A_Index%currentDeviceUDID,%A_Index%currentDeviceUDID, `n,, All
	StringReplace, %A_Index%currentDeviceUDID,%A_Index%currentDeviceUDID, %A_Space%,, All
}
;checks for the presence of FinyMyIphone on the device. 
Runwait, %comspec% /c ideviceinfo -q com.apple.fmip -k IsAssociated >> findmyiphone.txt, %A_AppData%\BackupRestorer , Hide
fileread, findmyiphone, *P65001 %A_AppData%\BackupRestorer\findmyiphone.txt
	StringReplace, findmyiphone,findmyiphone, `r,, All
	StringReplace, findmyiphone,findmyiphone, `n,, All
	StringReplace, findmyiphone,findmyiphone, %A_Space%,, All
;MsgBox,,, %findmyiphone%
if (findmyiphone == "true")
{
	MsgBox,,, Please disable Find My iPhone on your device before proceeding.`n`nSettings > Apple ID > iCloud > Find My iPhone > Off
	return
}

;MsgBox,,, %A_WorkingDir%\%1folders%
;commencing the folder rename 
;FileMoveDir, %A_WorkingDir%\%1folders%, %A_WorkingDir%\%2currentDeviceUDID%, R
;StdOutStream( "ping google.com" , "StdOutStream_Callback" ) 
guicontrol,, F1, Please Wait! Transferring data to device...

;MsgBox % A_WorkingDir
directoryrunfrom := A_WorkingDir
directoryrunfrom = "%directoryrunfrom%"
SetWorkingDir, %A_AppData%\BackupRestorer
;MsgBox % A_WorkingDir
GuiControl, disable, Next
guicontrol, hide, next
guicontrol, show, finish
;Clipboard := "idevicebackup2.exe --source " . 1folders " restore --system --settings --reboot " . directoryrunfrom 
;MsgBox % "idevicebackup2.exe --source " . 1folders " restore --system --settings --reboot " . directoryrunfrom 
;StdOutStream( "ping -n 3 www.google.com", "StdOutStream_Callback" )
StdOutStream( "idevicebackup2.exe --source " . 1folders " restore --system --settings --reboot " . directoryrunfrom, "StdOutStream_Callback" )
;StdOutStream( "idevicebackup2.exe --source " . 1folders " restore " . directoryrunfrom, "StdOutStream_Callback" )
SetWorkingDir, directoryrunfrom
guicontrol, enable, finish


;Runwait, %comspec% /c idevicebackup2.exe --source %1folders% restore --system --settings --reboot "%A_WorkingDir%" && Exit, %A_AppData%\BackupRestorer , Show

;	MsgBox,,, DeviceUDID is %2DeviceUDID%


;MsgBox,,, This is yet to be coded!
return

/*
progressbar:
guicontrolget, cmdtext,, stdoutfield2
;IfInString, cmdtext, reply
;{
;	MsgBox,,, %cmdtext%
;}
	loop, parse, stdoutfield2, `n
	{
		stdoutlastfield := A_LoopReadLine
	}
	If InStr(stdoutlastfield, Finished, false, 0)
	{
	targetlineinlogfile := SubStr(stdoutlastfield, 55, 4)	
	StringReplace, percent, targetlineinlogfile, `%,  , All
	StringReplace, percent,percent, `r,, All
	StringReplace, percent,percent, `n,, All
	StringReplace, percent,percent, %A_Space%,, All
	FileAppend, targetlineinlogfile: %stdoutlastfield%`n percent: %percent%`n`n, test5.txt
;	MsgBox % percent
	GuiControl, -Redraw, MyProgress
	GuiControl,, MyProgress, %percent% 
	GuiControl, +Redraw, MyProgress
	}
return
*/

finish:
Process, close, idevicebackup2.exe
Process, close, ideviceinfo.exe
;filedelete, idevicebackup2.exe
ExitApp

Guiclose:
Process, close, idevicebackup2.exe
Process, close, ideviceinfo.exe
;filedelete, idevicebackup2.exe
exitapp



;===============Custom function that returns data between two strings================
StringBetween( String, NeedleStart, NeedleEnd="" ) {

    StringGetPos, pos, String, % NeedleStart

    If ( ErrorLevel )

         Return ""

    StringTrimLeft, String, String, pos + StrLen( NeedleStart )

    If ( NeedleEnd = "" )

        Return String

    StringGetPos, pos, String, % NeedleEnd

    If ( ErrorLevel )

        Return ""

    StringLeft, String, String, pos

    Return String

}

;=======================================================================================





;========== DPI aware =============
/*
Name             : DPI
Purpose          : Return scaling factor or calculate position/values for AHK controls (font size, position (x y), width, height)
Version          : 0.31
Source           : https://github.com/hi5/dpi
AutoHotkey Forum : https://autohotkey.com/boards/viewtopic.php?f=6&t=37913
License          : see license.txt (GPL 2.0)
Documentation    : See readme.md @ https://github.com/hi5/dpi
History:
* v0.31: refactored "process" code, just one line now
* v0.3: - Replaced super global variable ###dpiset with static variable within dpi() to set dpi
        - Removed r parameter, always use Round()
        - No longer scales the Rows option and others that should be skipped (h-1, *w0, hwnd etc)
* v0.2: public release
* v0.1: first draft
*/

DPI(in="",setdpi=1)
	{
	 static dpi:=1
	 if (setdpi <> 1)
		dpi:=setdpi
	 RegRead, AppliedDPI, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	 ; If the AppliedDPI key is not found the default settings are used.
	 ; 96 is the default value.
	 if (ErrorLevel=1) OR (AppliedDPI=96)
		AppliedDPI:=96
	 if (dpi <> 1)
		AppliedDPI:=dpi
	 factor:=AppliedDPI/96
	 if !in
		Return factor

	 Loop, parse, in, %A_Space%%A_Tab%
		{
		 option:=A_LoopField
		 if RegExMatch(option,"i)(w0|h0|h-1|xp|yp|xs|ys|xm|ym)$") or RegExMatch(option,"i)(icon|hwnd)") ; these need to be bypassed
			out .= option A_Space
		 else if RegExMatch(option,"i)^\*{0,1}(x|xp|y|yp|w|h|s)[-+]{0,1}\K(\d+)",number) ; should be processed
			out .= StrReplace(option,number,Round(number*factor)) A_Space
		 else ; the rest can be bypassed as well (variable names etc)
			out .= option A_Space
		}
	 Return Trim(out)
	}
	
	
;============ redirects stdout for use in the UI in realtime =================

StdOutStream_Callback( data, n ) {
  startofstd:
  Static D
  D .= data
  D2 := StrTail(4,D)
  ;MsgBox % D
  
	guicontrolget, D3,, stdoutfield
;	MsgBox % D3
;	IfInString, D2, Finished
		if RegExMatch( D3,"([0-9]{1,2}|100)%", percentvar ,1)
		{
;		MsgBox % percentvar
		GuiControl,, MyProgress, %percentvar% 
		}
;	{
;	FileAppend, %D2%, test3.txt
;	FoundPos := RegExMatch(D2, ([0-9]{1,2}|100)% , targetlineinlogfile, 0
;	targetlineinlogfile := SubStr(D2, 55, 4)	
;	StringReplace, percent, targetlineinlogfile, `%,  , All
;	MsgBox,,, |%percent%|
;	StringReplace, percent,percent, `r,, All
;	StringReplace, percent,percent, `n,, All
;	StringReplace, percent,percent, %A_Space%,, All
;	RemoveLastLine := RegExReplace(D, "(.*)`n.*", "$1")
;	FileAppend, %D2%`n%percent%`n`n, test4.txt
;	GuiControl, -Redraw, MyProgress
;	GuiControl,, MyProgress, %percent% 
;	GuiControl, +Redraw, MyProgress
;	MsgBox,,, %D2%	
;	}
  ;Progress, %A_Index%, %A_LoopFileName%, Installing..., Draft Installation

 ; if (percent != "")
;	{
;	GuiControl,, MyProgress, %percent% 
;	}


;		gosub, startofstd
;  settimer, update, 50
  GuiControl, -Redraw, stdoutfield
  Guicontrol,, stdoutfield, %D2%
  GuiControl, +Redraw, stdoutfield
  
  if ! ( n ) {
	D := ""
	guicontrol, hide, MyProgress
	guicontrol, move, stdoutfield, % dpi ("x38 y465 w400 h60")
	guicontrol,,Finish, Exit
	guicontrol, move, Finish, % dpi ("x527 y475 w120 h40")
	;guicontrol,, stdoutfield, Device Transfer Complete!`n`nIf all went well device should reboot shorty..
    Return "Data transfer is complete!`n`nIf all went well device should reboot..."
  }
}


StdOutStream( sCmd, Callback = "" ) { ; Modified  :  SKAN 31-Aug-2013 http://goo.gl/j8XJXY                             
  Static StrGet := "StrGet"           ; Thanks to :  HotKeyIt         http://goo.gl/IsH1zs                                   
                                      ; Original  :  Sean 20-Feb-2007 http://goo.gl/mxCdn
                                    
  DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
  DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )

  VarSetCapacity( STARTUPINFO, 104, 0  )      ; STARTUPINFO          ;  http://goo.gl/fZf24
  NumPut( 68,         STARTUPINFO,  0 )      ; cbSize
  NumPut( 0x100,      STARTUPINFO, 60 )      ; dwFlags    =>  STARTF_USESTDHANDLES = 0x100 
  NumPut( hPipeWrite, STARTUPINFO, 88 )      ; hStdOutput
  NumPut( hPipeWrite, STARTUPINFO, 96 )      ; hStdError

  VarSetCapacity( PROCESS_INFORMATION, 32 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI      
  
  If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0 ;  http://goo.gl/USC5a
              , UInt,1, UInt,0x08000000, UInt,0, UInt,0
              , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION ) 
   Return "" 
   , DllCall( "CloseHandle", UInt,hPipeWrite ) 
   , DllCall( "CloseHandle", UInt,hPipeRead )
   , DllCall( "SetLastError", Int,-1 )     

  hProcess := NumGet( PROCESS_INFORMATION, 0 )                 
  hThread  := NumGet( PROCESS_INFORMATION, 8 )                      

  DllCall( "CloseHandle", UInt,hPipeWrite )

  AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )                   ;  A_IsClassic 
  VarSetCapacity( Buffer, 4096, 0 ), nSz := 0 
  
  While DllCall( "ReadFile", UInt,hPipeRead, UInt,&Buffer, UInt,4094, UIntP,nSz, Int,0 ) {

   tOutput := ( AIC && NumPut( 0, Buffer, nSz, "Char" ) && VarSetCapacity( Buffer,-1 ) ) 
              ? Buffer : %StrGet%( &Buffer, nSz, "CP850" )

   Isfunc( Callback ) ? %Callback%( tOutput, A_Index ) : sOutput .= tOutput

  }                   
 
  DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
  DllCall( "CloseHandle",  UInt,hProcess  )
  DllCall( "CloseHandle",  UInt,hThread   )
  DllCall( "CloseHandle",  UInt,hPipeRead )
  DllCall( "SetLastError", UInt,ExitCode  )

Return Isfunc( Callback ) ? %Callback%( "", 0 ) : sOutput      
}

;==========Tails the last 3 lines of variable========
StrTail(k,str) ;; Inspired by Laszlo (http://www.autohotkey.com/forum/topic6928.html)
   {
   Loop,Parse,str,`n
      {
      i := Mod(A_Index,k)
      L%i% = %A_LoopField%
      }
   L := L%i%
   Loop,% k-1
      {
      If i < 1
         SetEnv,i,%k%
      i-- ;Mod does not work here
      L := L%i% "`n" L
      }
   Return L
   }
