Keyboard = 
{
	m_keyboard =
	{
		[1]={"a","A"},
		[2]={"b","B"},
		[3]={"c","C"},
		[4]={"d","D"},
		[5]={"e","E"},
		[6]={"f","F"},
		[7]={"g","G"},
		[8]={"h","H"},
		[9]={"i","I"},
		[10]={"j","J"},
		[11]={"k","K"},
		[12]={"l","L"},
		[13]={"m","M"},
		[14]={"n","N"},
		[15]={"o","O"},
		[16]={"p","P"},
		[17]={"q","Q"},
		[18]={"r","R"},
		[19]={"s","S"},
		[20]={"t","T"},
		[21]={"u","U"},
		[22]={"v","V"},
		[23]={"w","W"},
		[24]={"x","X"},
		[25]={"y","Y"},
		[26]={"z","Z"},
		[27]={"`","~"},
		[28]={"1","!"},
		[29]={"2","@"},
		[30]={"3","#"},
		[31]={"4","$"},
		[32]={"5","%"},
		[33]={"6","^"},
		[34]={"7","&"},
		[35]={"8","*"},
		[36]={"9","("},
		[37]={"0",")"},
		[38]={"-","_"},
		[39]={"=","+"},
		[40]={"[","{"},
		[41]={"]","}"},
		[42]={"\\","|"},
		[43]={";",":"},
		[44]={"'","\""},
		[45]={",","<"},
		[46]={".",">"},
		[47]={"/","?"}
	};
}

local lc_KeyboardRegistry = {}

function Keyboard.ShuffleKeyboard()
	local c = #Keyboard.m_keyboard
	for i = 1, c do
		local n = math.random(c)
		local t = Keyboard.m_keyboard[n]
		Keyboard.m_keyboard[n] = Keyboard.m_keyboard[i]
		Keyboard.m_keyboard[i] = t
	end
end;

function Keyboard.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	Keyboard.UpdateKeyboard(this)
	 Keyboard.OnEvent("UI_SCALED")
end

function Keyboard.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 200)
	end
end

function Keyboard.UpdateKeyboard(frame)
	local shift = frame:Lookup("CheckBox_KbShift"):IsCheckBoxChecked()
	for i = 1, #Keyboard.m_keyboard do
		local btn = frame:Lookup(string.format("Btn_Kb%02d", i))
		btn:Lookup("", string.format("Text_Kb%02dA", i)):SetText(Keyboard.m_keyboard[i][2])
		btn:Lookup("", string.format("Text_Kb%02dB", i)):SetText(Keyboard.m_keyboard[i][1])
		if shift then
			btn:Lookup("", string.format("Text_Kb%02dA", i)):SetFontScheme(162)
			btn:Lookup("", string.format("Text_Kb%02dB", i)):SetFontScheme(109)
		else
			btn:Lookup("", string.format("Text_Kb%02dA", i)):SetFontScheme(109)
			btn:Lookup("", string.format("Text_Kb%02dB", i)):SetFontScheme(162)
		end
	end
end;

function Keyboard.GetInputEdit(szKey)
	if lc_KeyboardRegistry[szKey] then
		local szEdit = lc_KeyboardRegistry[szKey]
		local hEdit = Station.Lookup(szEdit)
		return hEdit
	end
end

function Keyboard.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_KbShift" then
		Keyboard.UpdateKeyboard(this:GetRoot())
	end
end

function Keyboard.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_KbShift" then
		Keyboard.UpdateKeyboard(this:GetRoot())
	end
end

function Keyboard.OnLButtonClick()
	local frame = this:GetRoot()
	local szName = this:GetName()
	local hEdit = Keyboard.GetInputEdit(Keyboard.szKey)
	
	if szName == "Btn_KbRandom" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Keyboard.ShuffleKeyboard()
		Keyboard.UpdateKeyboard(frame)
	
	elseif szName == "Btn_KbBackspace" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		if hEdit then
			hEdit:Backspace()
		end
	else
		local i = tonumber(string.sub(szName, string.len("Btn_Kb") + 1))
		local shift = frame:Lookup("CheckBox_KbShift"):IsCheckBoxChecked()
		local j = 1
		if shift then
			j = 2
		end
		local szCh = Keyboard.m_keyboard[i][j]
		if hEdit then
			hEdit:InsertText(szCh)
		end
	end
end

function IsKeyboardOpened()
	local frame = Station.Lookup("Topmost1/Keyboard")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenKeyboard(bDisableSound, szKey)
	Keyboard.szKey = szKey
	
	if IsKeyboardOpened() then
		return
	end
	
	Wnd.OpenWindow("Keyboard")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseKeyboard(bDisableSound)
	if not IsKeyboardOpened() then
		return
	end
	
	Wnd.CloseWindow("Keyboard")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function Keyboard_Register(szKey, szEdit)
	lc_KeyboardRegistry[szKey] = szEdit
end
