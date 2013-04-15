SelectMacroIconPanel = 
{
	aIcon = 
	{
		1,	2,	3,	4,	5,	6,	7,	8,
		11,	12,	13,	14,	15,	16,	17,	18,
		21,	22,	23,	24,	25,	26,	27,	28,
		31,	32,	33,	34,	35,	36,	37,	38,
		41,	42,	43,	44,	45,	46,	47,	48,
		51,	52,	53,	54,	55,	56,	57,	58,
		61,	62,	63,	64,	65,	66,	67,	68,
		71,	72,	73,	74,	75,	76,	77,	78,
	}
}

function SelectMacroIconPanel.OnFrameCreate()
	local szIniFile = "UI/Config/Default/SelectMacroIconPanel.ini"
	local hIcon = this:Lookup("", "Handle_Icon")
	hIcon:Clear()
	for i = 1, 8, 1 do
		for j = 1, 8, 1 do
			local nIndex = (i - 1) * 8 + j
			local nIcon = SelectMacroIconPanel.aIcon[nIndex]
			if not nIcon then
				break
			end
			
			local box = hIcon:AppendItemFromIni(szIniFile, "Box_Icon")
			box.bIcon = true
			box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
			box:SetObjectIcon(nIcon)
			box:SetRelPos((j - 1) * 50, (i - 1) * 50)
		end
	end
	hIcon:FormatAllItemPos()
end

function SelectMacroIconPanel.OnFrameBreathe()
	local activeFrame = Station.GetActiveFrame()
	if activeFrame ~= this or (this.fnAutoClose and this.fnAutoClose()) then
		CloseSelectMacroIconPanel(true)
	end
end

function SelectMacroIconPanel.OnItemMouseEnter()
	if this.bIcon then
		this:SetObjectMouseOver(true)
	end
end

function SelectMacroIconPanel.OnItemMouseLeave()
	if this.bIcon then
		this:SetObjectMouseOver(false)
	end
end

function SelectMacroIconPanel.OnItemLButtonDown()
	if this.bIcon then
		this:SetObjectPressed(true)
	end
end

function SelectMacroIconPanel.OnItemLButtonUp()
	if this.bIcon then
		this:SetObjectPressed(false)
	end
end

function SelectMacroIconPanel.OnItemLButtonClick()
	if this.bIcon then
		local frame = this:GetRoot()
		local nIcon = this:GetObjectIcon()
		local fnSelect = frame.fnSelect
		CloseSelectMacroIconPanel()
		if fnSelect then
			fnSelect(nIcon)
		end
	end
end

function SelectMacroIconPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		Station.CloseWindow(frame:GetName())
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsSelectMacroIconPanelOpened()
	local frame = Station.Lookup("Topmost/SelectMacroIconPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseSelectMacroIconPanel(bDisableSound)
	if not IsSelectMacroIconPanelOpened() then
		return
	end
	Station.CloseWindow("SelectMacroIconPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function SelectMacroIcon(fnSelect, fnAutoClose, Rect)
	if IsSelectMacroIconPanelOpened() then
		return
	end
	
	local frame = Station.OpenWindow("SelectMacroIconPanel")
	frame.fnSelect = fnSelect
	frame.fnAutoClose = fnAutoClose
	Station.SetActiveFrame(frame)
	frame:CorrectPos(Rect[1], Rect[2], Rect[3], Rect[4], ALW.RIGHT_LEFT)
	
	PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
end