g_tHotKey = 
{
	--快捷键用于界面显示的表
	taVKeyToShowDesc =
	{
	--	0x0,		0x1,		0x2,		0x3,		0x4,		0x5,		0x6,		0x7,		0x8,		0x9,		0xA,		0xB,		0xC,		0xD,		0xE,		0xF,
					"LButton",	"RButton",	"Cancel",	"MButton",	"XButton1",	"XButton2",	"",			"Backspace","Tab",		"",			"",			"Clear",	"Enter",	"",			"",
		"Shift",	"Ctrl",		"Alt",		"Pause",	"CapLock",	"Hanguel",	"",			"Junja",	"Final",	"Kanji",	"",			"Esc",		"Convert",	"NonConvert","Accept",	"ModeChange",
		"Space",	"PageUp",	"PageDown",	"End",		"Home",		"Left",		"Up",		"Right",	"Down",		"Select",	"Print",	"Execute",	"PrintScreen",	"Insert",	"Delete",	"Help",
		"0",		"1",		"2",		"3",		"4",		"5",		"6",		"7",		"8",		"9",		"",			"",			"",			"",			"",			"",
		"",			"A",		"B",		"C",		"D",		"E",		"F",		"G",		"H",		"I",		"J",		"K",		"L",		"M",		"N",		"O",
		"P",		"Q",		"R",		"S",		"T",		"U",		"V",		"W",		"X",		"Y",		"Z",		"LWin",		"RWin",		"Apps",		"",			"",
		"Num0",		"Num1",		"Num2",		"Num3",		"Num4",		"Num5",		"Num6",		"Num7",		"Num8",		"Num9",		"Multiply",	"Add",		"Separator","Subtract",	"Decimal",	"Divide",
		"F1",		"F2",		"F3",		"F4",		"F5",		"F6",		"F7",		"F8",		"F9",		"F10",		"F11",		"F12",		"F13",		"F14",		"F15",		"F16",
		"F17",		"F18",		"F19",		"F20",		"F21",		"F22",		"F23",		"F24",		"",			"",			"",			"",			"",			"",			"",			"",
		"NumLock",	"ScrollLock","",		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"",			"",			"",			"",			"",			"",			"BrowserBack","BrowserForward","BrowserRefresh","BrowserStop","BrowserSearch","BrowserFavorites","BrowserHome","VolumeMute","VolumeDown","VolumeUp",
		"MediaNextTrack","MediaPrevTrack","MediaStop","MediaPlayPause","LaunchMail","LaunchMediaSelect","LaunchApp1","LaunchApp2","","","OEM1","+",		"OEMComma","-",			"OEMPeriod","OEM2",
		"OEM3",		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"[",		"\\",		"]",		"'",		"",
		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"MouseWheelUp","MouseWheelDown","MouseHover",""
	};
	
	taVKeyToShowDescShort =
	{
	--	0x0,		0x1,		0x2,		0x3,		0x4,		0x5,		0x6,		0x7,		0x8,		0x9,		0xA,		0xB,		0xC,		0xD,		0xE,		0xF,
					"LB",		"RB",		"Cancel",	"MB",		"XB1",		"XB2",		"",			"Bs",		"Tab",		"",			"",			"Clear",	"Enter",	"",			"",
		"S",		"C",		"A",		"Pa",	    "CL",	    "Hanguel",	"",			"Junja",	"Final",	"Kanji",	"",			"Esc",		"Convert",	"NC",       "Accept",	"MC",
		"Space",	"PU",   	"PD",   	"End",		"Home",		"Left",		"Up",		"Right",	"Down",		"Select",	"Print",	"Execute",	"PS"   ,	"Ins"  ,	"Del",   	"Help",
		"0",		"1",		"2",		"3",		"4",		"5",		"6",		"7",		"8",		"9",		"",			"",			"",			"",			"",			"",
		"",			"A",		"B",		"C",		"D",		"E",		"F",		"G",		"H",		"I",		"J",		"K",		"L",		"M",		"N",		"O",
		"P",		"Q",		"R",		"S",		"T",		"U",		"V",		"W",		"X",		"Y",		"Z",		"LWin",		"RWin",		"Apps",		"",			"",
		"Num0",		"Num1",		"Num2",		"Num3",		"Num4",		"Num5",		"Num6",		"Num7",		"Num8",		"Num9",		"Multiply",	"Add",		"Separator","Subtract",	"Decimal",	"Divide",
		"F1",		"F2",		"F3",		"F4",		"F5",		"F6",		"F7",		"F8",		"F9",		"F10",		"F11",		"F12",		"F13",		"F14",		"F15",		"F16",
		"F17",		"F18",		"F19",		"F20",		"F21",		"F22",		"F23",		"F24",		"",			"",			"",			"",			"",			"",			"",			"",
		"NL",	    "SL",       "",	    	"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"",			"",			"",			"",			"",			"",			"BrowserBack","BrowserForward","BrowserRefresh","BrowserStop","BrowserSearch","BrowserFavorites","BrowserHome","VolumeMute","VolumeDown","VolumeUp",
		"MediaNextTrack","MediaPrevTrack","MediaStop","MediaPlayPause","LaunchMail","LaunchMediaSelect","LaunchApp1","LaunchApp2","","","OEM1","+",		"OEMComma","-",			"OEMPeriod","OEM2",
		"OEM3",		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"[",		"\\",		"]",		"'",		"",
		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
		"MU",		"MD",		"MH",		""
	};
}