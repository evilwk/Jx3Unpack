EnterAreaTip =
{
	DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 245},
	Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = 245}
}

RegisterCustomData("EnterAreaTip.Anchor")

function EnterAreaTip.OnFrameCreate()
	this:RegisterEvent("PLAYER_ENTER_AREA")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("ENTER_AREA_TIP_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")

	EnterAreaTip.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.ENTER_AREA, true)
	this:Lookup("", ""):Hide()
end

function EnterAreaTip.OnFrameDrag()
end

function EnterAreaTip.OnFrameDragSetPosEnd()
end

function EnterAreaTip.OnFrameDragEnd()
	this:CorrectPos()
	EnterAreaTip.Anchor = GetFrameAnchor(this)
end

function EnterAreaTip.UpdateAnchor(frame)
	frame:SetPoint(EnterAreaTip.Anchor.s, 0, 0, EnterAreaTip.Anchor.r, EnterAreaTip.Anchor.x, EnterAreaTip.Anchor.y)
	frame:CorrectPos()
end

function EnterAreaTip.OnEvent(event)
	if event == "PLAYER_ENTER_AREA" then
		if arg0 and arg0 ~= "" then
			local handle = this:Lookup("", "")
			handle:Lookup("Text_EnterArea"):SetText(arg0)
			handle:SetAlpha(255)
			handle:Show()
		end
	elseif event == "UI_SCALED" then
		EnterAreaTip.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, true)
	elseif event == "ENTER_AREA_TIP_ANCHOR_CHANGED" then
		EnterAreaTip.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		EnterAreaTip.UpdateAnchor(this)
	end
end

function EnterAreaTip.OnFrameBreathe()
	local handle = this:Lookup("", "")
	if handle:IsVisible() then
		local nLeft = handle:GetAlpha() - 3
		if nLeft < 0 then
			handle:Hide()
		else
			handle:SetAlpha(nLeft)
		end
	end
end

function EnterAreaTip_SetAnchorDefault()
	EnterAreaTip.Anchor.s = EnterAreaTip.DefaultAnchor.s
	EnterAreaTip.Anchor.r = EnterAreaTip.DefaultAnchor.r
	EnterAreaTip.Anchor.x = EnterAreaTip.DefaultAnchor.x
	EnterAreaTip.Anchor.y = EnterAreaTip.DefaultAnchor.y
	FireEvent("ENTER_AREA_TIP_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", EnterAreaTip_SetAnchorDefault)

function LoadEnterAreaTipSetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		OpenDebuffList()
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"

	local iniS = Ini.Open(szIniFile)
	if not iniS then
		OpenDebuffList()
		return
	end
	
	local szSection = "EnterAreaTip"	
	
	local Anchor = {}
	local value = iniS:ReadString(szSection, "SelfSide", EnterAreaTip.Anchor.s)
	if value then
		Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", EnterAreaTip.Anchor.r)
	if value then
		Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", EnterAreaTip.Anchor.x)
	if value then
		Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", EnterAreaTip.Anchor.y)
	if value then
		Anchor.y = value
	end
	
	if Anchor.s and Anchor.r and Anchor.x and Anchor.y then
		EnterAreaTip.Anchor = Anchor
		FireEvent("ENTER_AREA_TIP_ANCHOR_CHANGED")
	end
	
	iniS:Close()
end

RegisterLoadFunction(LoadEnterAreaTipSetting)
