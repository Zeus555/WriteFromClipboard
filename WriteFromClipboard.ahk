#NoEnv
;~ Do not read environment variables.

#SingleInstance Force
;~ Only one instance of the script; if already running, it terminates the previous instance and runs normally.

#ClipboardTimeout 2000
;~ Directive that sets the time to wait for clipboard availability in milliseconds.

#Persistent
;~ Directive that keeps the script running until an exit condition is met.

SetKeyDelay, 10, 5
;~ Sets the delay for key presses in milliseconds.

;~ Configure the script to start with Windows on first run
If (!FileExist(A_Startup . "\WriteClipboard.lnk"))
{
    FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\WriteClipboard.lnk
}

;~ Remove default system tray menu items
Menu, Tray, NoStandard
;~ Create system tray menu with License, Stop Pasting, and Exit
Menu, Tray, Add, License, ShowLicense
Menu, Tray, Add, Stop Pasting, StopPastingAction
Menu, Tray, Add, Exit, ExitScript

;~ Define the MIT License text parts for GUI display
LicenseTitle = MIT License
CopyrightText = Copyright (c) 2025 [Your Name]
LicenseBody =
(
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
)
DisclaimerText =
(
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
)

;~ Global flag to control the text pasting loop
global StopPasting := false

;~ Hotkey: Ctrl+Alt+V to paste clipboard content
^!v::
    StopPasting := false
    ClipText := Clipboard
    if (ClipText = "")
    {
        MsgBox, The clipboard is empty.
        return
    }

    SendMode Event
    ;~ Set input mode to Event for sending keystrokes

    ;~ Convert the text into an array of lines
    StringSplit, LineArray, ClipText, `n, `r

    ;~ Loop through each line
    Loop, %LineArray0%
    {
        if (StopPasting)
        {
            MsgBox, Pasting stopped.
            break
        }
        Clipboard :=""
        CurrentLine := LineArray%A_Index%
        SendRaw, %CurrentLine%
        if (A_Index < LineArray0) ; If not the last line
            Send, {Enter}
            Sleep, 200
    }
return

;~ Hotkey: Ctrl+Alt+S to stop pasting
^!s::
    StopPasting := true
return

;~ System tray menu action to stop pasting
StopPastingAction:
    StopPasting := true
return

ShowLicense:
    ;~ Create a GUI for the license dialog
    Gui, License:New, +Caption +AlwaysOnTop +Resize, License
    Gui, License:Margin, 10, 10
    Gui, License:Font, s12 w700, Segoe UI
    Gui, License:Add, Text, w550, %LicenseTitle%
    Gui, License:Font, s11 w700, Segoe UI
    Gui, License:Add, Text, w550, %CopyrightText%
    Gui, License:Font, s11 norm, Segoe UI
    Gui, License:Add, Text, w550, %LicenseBody%
    Gui, License:Font, s11 norm, Segoe UI
    Gui, License:Add, Text, w550, %DisclaimerText%
    Gui, License:Font, s11 norm, Segoe UI
    Gui, License:Add, Button, w80 x470 y+10 gCloseLicense, OK
    Gui, License:Show, w600
return

CloseLicense:
    ;~ Close the license GUI
    Gui, License:Destroy
return

ExitScript:
    ExitApp
    ;~ Close the application
return