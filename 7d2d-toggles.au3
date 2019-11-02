; 7d2d toggles v0.1.0 by romdeau23
; https://github.com/romdeau23/7d2d-toggles

#include <MsgBoxConstants.au3>
#include <WinAPIvkeysConstants.au3>
#include <Misc.au3>
#include <AutoItConstants.au3>

; Globals
Global Const $DEBUG = False
Global Const $TITLE = "7D2D toggles"
Global Const $WIN = WinWaitActive("7 Days To Die", "", 60)
Global Const $USER32 = DllOpen("user32.dll")
Global Const $TIMER = TimerInit()
Global $mainLoopIndex = 0

; Check game window
If 0 == $WIN Then
	MsgBox($MB_ICONERROR, $TITLE, "No active 7 Days To Die window found after 60 seconds.")

	Exit
EndIf

; Config
Global Const $SHIFT_TAP_THRESHOLD = 500

; Keys
Global Const $KEYS = [ _
	Hex($VK_LSHIFT, 2), _
	Hex($VK_W, 2), _
	Hex($VK_A, 2), _
	Hex($VK_S, 2), _
	Hex($VK_D, 2), _
	Hex($VK_E, 2), _
	Hex($VK_XBUTTON2, 2), _
	Hex($VK_ADD, 2), _
	Hex($VK_TAB, 2), _
	Hex($VK_ESCAPE, 2) _
]

Global Const $KEY_NAMES = [ _
	"LSHIFT", _
	"W", _
	"A", _
	"S", _
	"D", _
	"E", _
	"XBUTTON2", _
	"ADD", _
	"TAB", _
	"ESCAPE" _
]

Global Const $NUM_KEYS = UBound($KEYS)
Global Const $KEY_SHIFT = 0
Global Const $KEY_W = 1
Global Const $KEY_A = 2
Global Const $KEY_S = 3
Global Const $KEY_D = 4
Global Const $KEY_E = 5
Global Const $KEY_XBUTTON2 = 6
Global Const $KEY_ADD = 7
Global Const $KEY_TAB = 8
Global Const $KEY_ESCAPE = 9

; Key handlers
Global $KEY_DOWN_HANDLERS = [ _
	"Noop", _			; LSHIFT
	"StopAutorun", _	; W
	"Noop", _			; A
	"StopAutorun", _	; S
	"Noop", _			; D
	"Reset", _			; E
	"ToggleMouse", _	; XBUTTON2
	"ToggleAutorun", _ 	; ADD
	"Reset", _			; TAB
	"Reset" _			; ESCAPE
]

Global Const $KEY_UP_HANDLERS = [ _
	"StartSprinting", _	; LSHIFT
	"StopSprinting", _	; W
	"Noop", _			; A
	"Noop", _			; S
	"Noop", _			; D
	"Noop", _			; E
	"Noop", _			; XBUTTON2
	"Noop", _			; ADD
	"Noop", _			; TAB
	"Noop" _			; ESCAPE
]

; Toggles
Global $toggles = [ _
	[False, "Send", "{SHIFTDOWN}", "Send", "{SHIFTUP}"], _
	[False, "Send", "{w down}", "Send", "{w up}"], _
	[False, "MouseDown", $MOUSE_CLICK_MAIN, "MouseUp", $MOUSE_CLICK_MAIN] _
]

Global Const $NUM_TOGGLES = UBound($toggles)
Global Const $TOGGLE_NAMES = ["SHIFT", "W", "MOUSE"]
Global Const $TOGGLE_SHIFT = 0
Global Const $TOGGLE_W = 1
Global Const $TOGGLE_MOUSE = 2
Global Const $TOGGLE_PROP_STATE = 0
Global Const $TOGGLE_PROP_DOWN_FN = 1
Global Const $TOGGLE_PROP_DOWN_ARG = 2
Global Const $TOGGLE_PROP_UP_FN = 3
Global Const $TOGGLE_PROP_UP_ARG = 4

Global Const $KEY_TOGGLES = [ _
	$TOGGLE_SHIFT, _
	$TOGGLE_W, _
	Null, _
	Null, _
	Null, _
	Null, _
	Null, _
	Null, _
	Null, _
	Null _
]

; Timer diffs for keys that are currently down
Global $keyDownTimes[$NUM_KEYS]

For $i = 0 To $NUM_KEYS - 1
	$keyDownTimes[$i] = Null
Next

; Functions
Func Debug($msg, $arg1 = Null, $arg2 = Null, $arg3 = Null, $arg4 = Null, $arg5 = Null, $arg6 = Null, $arg7 = Null, $arg8 = Null)
	If $DEBUG Then
		If @NumParams > 1 Then
			$msg = StringFormat($msg, $arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8)
		EndIf

		ConsoleWrite("@" & $mainLoopIndex & " ")
		ConsoleWrite($msg)
		ConsoleWrite(@LF)
	EndIf
EndFunc

; Toggle functions
Func ToggleDown($toggleIdx)
	If Not $toggles[$toggleIdx][$TOGGLE_PROP_STATE] Then
		Debug("ToggleDown(%s) %s(%s)", $TOGGLE_NAMES[$toggleIdx], $toggles[$toggleIdx][$TOGGLE_PROP_DOWN_FN], $toggles[$toggleIdx][$TOGGLE_PROP_DOWN_ARG])
		Call($toggles[$toggleIdx][$TOGGLE_PROP_DOWN_FN], $toggles[$toggleIdx][$TOGGLE_PROP_DOWN_ARG])
		$toggles[$toggleIdx][$TOGGLE_PROP_STATE] = True
	EndIf
EndFunc

Func ToggleUp($toggleIdx)
	If $toggles[$toggleIdx][$TOGGLE_PROP_STATE] Then
		Debug("ToggleUp(%s) %s(%s)", $TOGGLE_NAMES[$toggleIdx], $toggles[$toggleIdx][$TOGGLE_PROP_UP_FN], $toggles[$toggleIdx][$TOGGLE_PROP_UP_ARG])
		Call($toggles[$toggleIdx][$TOGGLE_PROP_UP_FN], $toggles[$toggleIdx][$TOGGLE_PROP_UP_ARG])
		$toggles[$toggleIdx][$TOGGLE_PROP_STATE] = False
	EndIf
EndFunc

Func ToggleReset($toggleIdx)
	Debug("ToggleReset(%s) %s(%s)", $TOGGLE_NAMES[$toggleIdx], $toggles[$toggleIdx][$TOGGLE_PROP_UP_FN], $toggles[$toggleIdx][$TOGGLE_PROP_UP_ARG])
	Call($toggles[$toggleIdx][$TOGGLE_PROP_UP_FN], $toggles[$toggleIdx][$TOGGLE_PROP_UP_ARG])
	$toggles[$toggleIdx][$TOGGLE_PROP_STATE] = False
EndFunc

Func Toggle($toggleIdx)
	If $toggles[$toggleIdx][$TOGGLE_PROP_STATE] Then
		ToggleUp($toggleIdx)
		Return False
	Else
		ToggleDown($toggleIdx)
		Return True
	EndIf
EndFunc

Func Reset()
	For $i = 0 To $NUM_TOGGLES - 1
		ToggleUp($i)
	Next
EndFunc

; Keys
Func IsKeyDown($keyIdx)
	Return $keyDownTimes[$keyIdx] <> Null
EndFunc

Func IsKeyToggled($keyIdx)
	Local $toggleIdx = $KEY_TOGGLES[$keyIdx]

	If $toggleIdx <> Null Then
		Return $toggles[$toggleIdx][$TOGGLE_PROP_STATE]
	EndIf

	Return False
EndFunc

; Key handlers
Func Noop()
EndFunc

Func ToggleMouse()
	Toggle($TOGGLE_MOUSE)
EndFunc

Func ToggleAutorun()
	If Toggle($TOGGLE_W) Then
		ToggleDown($TOGGLE_SHIFT)
	EndIf
EndFunc

Func StopAutorun()
	ToggleUp($TOGGLE_W)
	ToggleUp($TOGGLE_SHIFT)
EndFunc

Func StartSprinting($shiftHeldFor)
	If $shiftHeldFor < $SHIFT_TAP_THRESHOLD And IsKeyDown($KEY_W) Then
		Debug("Will sprint")
		ToggleDown($TOGGLE_SHIFT)
	Else
		Debug("Won't sprint (shift held for %s, W key down = %s)", $shiftHeldFor, IsKeyDown($KEY_W))
	EndIf
EndFunc

Func StopSprinting()
	ToggleUp($TOGGLE_SHIFT)
EndFunc

; Main
While 1
	$mainLoopIndex += 1

	If Not WinActive($WIN) Then
		If Not WinExists($WIN) Then
			Debug("Game window no longer exists, exiting")
			Exit
		EndIf

		Reset()
		Sleep(1000)

		ContinueLoop
	EndIf

	For $i = 0 To $NUM_KEYS - 1
		If _IsPressed($KEYS[$i], $USER32) Then
			; record initial key down time
			If $keyDownTimes[$i] == Null Then
				$keyDownTimes[$i] = TimerDiff($TIMER)

				; run key down handler (unless pressed by toggle)
				If Not IsKeyToggled($i) Then
					Debug("[DOWN] %s %s()", $KEY_NAMES[$i], $KEY_DOWN_HANDLERS[$i])
					Call($KEY_DOWN_HANDLERS[$i])
				EndIf
			EndIf
		ElseIf IsKeyToggled($i) Then
			; toggle cancelled by user
			Debug("[CANCEL] %s", $KEY_NAMES[$i])
			ToggleReset($KEY_TOGGLES[$i])
			$keyDownTimes[$i] = Null
		ElseIf $keyDownTimes[$i] <> Null Then
			; run key up handler
			Debug("[UP] %s %s()", $KEY_NAMES[$i], $KEY_UP_HANDLERS[$i])
			Call($KEY_UP_HANDLERS[$i], TimerDiff($TIMER) - $keyDownTimes[$i])
			$keyDownTimes[$i] = Null
		EndIf
	Next

	Sleep(50)
WEnd
