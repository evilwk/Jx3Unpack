BreatheBar = 
{
	DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 315},
	Anchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 315}
}

RegisterCustomData("BreatheBar.Anchor")

function BreatheBar.OnFrameCreate()
	this:RegisterEvent("SHOW_SWIMMING_PROGRESS")
	this:RegisterEvent("HIDE_SWIMMING_PROGRESS")
	this:RegisterEvent("PLAYER_DEATH")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("BREATHE_BAR_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	BreatheBar.UpdateAnchor(this)
	BreatheBar.UpdateCustomModeWindow(this)
end

function BreatheBar.OnFrameDrag()
end

function BreatheBar.OnFrameDragSetPosEnd()
end

function BreatheBar.OnFrameDragEnd()
	this:CorrectPos()
	BreatheBar.Anchor = GetFrameAnchor(this)
end

function BreatheBar.UpdateAnchor(frame)
	frame:SetPoint(BreatheBar.Anchor.s, 0, 0, BreatheBar.Anchor.r, BreatheBar.Anchor.x, BreatheBar.Anchor.y)
	frame:CorrectPos()
end

function BreatheBar.UpdateCustomModeWindow(frame)
	local bIn = UpdateCustomModeWindow(frame, g_tStrings.BREATH_BAR, true)
	if bIn then
		frame:Show()
	else
		if not frame.bShow then
			frame:Hide()
		end
	end
	return bIn
end

function BreatheBar.ShowProgress(frame)
	frame.bShow = true
	BreatheBar.UpdateCustomModeWindow(frame)
	frame:Show()
end

function BreatheBar.HideProgress(frame)
	frame.bShow = false
	if not BreatheBar.UpdateCustomModeWindow(frame) then
		frame:Hide()
	end
end

function BreatheBar.OnEvent(event)
	if event == "SHOW_SWIMMING_PROGRESS" or event == "SYNC_ROLE_DATA_END" then
		if GetClientPlayer().nDivingCount >= 1 then
			BreatheBar.ShowProgress(this)
		else
			BreatheBar.HideProgress(this)
		end
	elseif event == "HIDE_SWIMMING_PROGRESS" then
		BreatheBar.HideProgress(this)
	elseif event == "PLAYER_DEATH" then
	    BreatheBar.HideProgress(this)
	elseif event == "UI_SCALED" then
		BreatheBar.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		BreatheBar.UpdateCustomModeWindow(this)
	elseif event == "BREATHE_BAR_ANCHOR_CHANGED" then
		BreatheBar.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		BreatheBar.UpdateAnchor(this)
	end
end

function BreatheBar.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nDivingCount < 1 then
		BreatheBar.HideProgress(this)
		return
	end
	
	local handle = this:Lookup("", "")
	local fp = 1 - player.nDivingCount / player.nDivingFrame
	if fp > 1 then
		fp = 1
	end
	if fp < 0 then
		fp = 0
	end
	
	local img = handle:Lookup("Image_Progress")
	img:SetPercentage(fp)
		
	if fp <= 0 then
		if not handle.nCurrent then
			handle.nCurrent = 0
			handle.nAdd = 1
		else
			handle.nCurrent = handle.nCurrent + handle.nAdd
			if handle.nCurrent > 16 then
				handle.nCurrent = 16
				handle.nAdd = -1
			end
			if handle.nCurrent < 0 then
				handle.nCurrent = 0
				handle.nAdd = 1
			end
		end
		
		local nA = 255 * handle.nCurrent / 16
		
		handle:Lookup("Image_Flash"):SetAlpha(nA)		
	else
		handle:Lookup("Image_Flash"):SetAlpha(0)
	end
end

function BreatheBar_SetAnchorDefault()
	BreatheBar.Anchor.s = BreatheBar.DefaultAnchor.s
	BreatheBar.Anchor.r = BreatheBar.DefaultAnchor.r
	BreatheBar.Anchor.x = BreatheBar.DefaultAnchor.x
	BreatheBar.Anchor.y = BreatheBar.DefaultAnchor.y
	FireEvent("BREATHE_BAR_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", BreatheBar_SetAnchorDefault)

function LoadBreatheBarSetting()
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
	
	local szSection = "BreatheBar"	
	
	local Anchor = {}
	local value = iniS:ReadString(szSection, "SelfSide", BreatheBar.Anchor.s)
	if value then
		Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", BreatheBar.Anchor.r)
	if value then
		Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", BreatheBar.Anchor.x)
	if value then
		Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", BreatheBar.Anchor.y)
	if value then
		Anchor.y = value
	end
	
	if Anchor.s and Anchor.r and Anchor.x and Anchor.y then
		BreatheBar.Anchor = Anchor
		FireEvent("BREATHE_BAR_ANCHOR_CHANGED")
	end

	iniS:Close()
end

RegisterLoadFunction(LoadBreatheBarSetting)
