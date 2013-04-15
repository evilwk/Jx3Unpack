BattleTipPanel = {
	DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 300},
	Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = 300}
}

RegisterCustomData("BattleTipPanel.Anchor")

function BattleTipPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ENTER_BATTLE_TIP_ANCHOR_CHANGED")
	this:RegisterEvent("OnBattleTipNotify")

	BattleTipPanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.STR_BATTLE_TIP_TITLE, true)
	this:Lookup("", ""):Hide()
end

function BattleTipPanel.OnFrameDragEnd()
	this:CorrectPos()
	BattleTipPanel.Anchor = GetFrameAnchor(this)
end

function BattleTipPanel.UpdateAnchor(hFrame)
	hFrame:SetPoint(BattleTipPanel.Anchor.s, 0, 0, BattleTipPanel.Anchor.r, BattleTipPanel.Anchor.x, BattleTipPanel.Anchor.y)
	hFrame:CorrectPos()
end

function BattleTipPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		BattleTipPanel.UpdateAnchor(this)
		
	elseif szEvent == "ON_ENTER_CUSTOM_UI_MODE" or szEvent == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, true)
		
	elseif szEvent == "ENTER_BATTLE_TIP_ANCHOR_CHANGED" then
		BattleTipPanel.UpdateAnchor(this)
		
	elseif szEvent == "CUSTOM_DATA_LOADED" then
		BattleTipPanel.UpdateAnchor(this)
		
	elseif szEvent == "OnBattleTipNotify" then
		if arg0 and g_tStrings.tBattleTip[arg0] then
			local hTotal = this:Lookup("", "")
			local szTip = g_tStrings.tBattleTip[arg0]
			szTip = FormatString(szTip, arg1 or "")
			
			BattleTipPanel.AdjustSize(this, math.ceil(#szTip / 2))
			
			hTotal:Lookup("Text_CampText"):SetText(szTip)
			hTotal:SetAlpha(255)
			hTotal:Show()
		end
	end
end

function BattleTipPanel.OnFrameBreathe()
	local hTotal = this:Lookup("", "")
	if hTotal:IsVisible() then
		local nLeft = hTotal:GetAlpha() - 5
		if nLeft < 0 then
			hTotal:Hide()
		else
			hTotal:SetAlpha(nLeft)
		end
	end
end

function BattleTipPanel.AdjustSize(frame, nLen)
	local nMinSize = 480
	local nPer = nMinSize / 20
	local hTotal = frame:Lookup("", "")
	local hImgS  = hTotal:Lookup("Image_Bg")
	local hImgM  = hTotal:Lookup("Image_BgM")
	local hImgE  = hTotal:Lookup("Image_BgE")
	local hText  = hTotal:Lookup("Text_CampText")
	
	local nSize = math.max(nLen * nPer, nMinSize)
	local nW1 = hImgS:GetSize()
	local nW2 = hImgE:GetSize()
	
	local _, nH = frame:GetSize()
	frame:SetSize(nSize, nH)

	local _, nHT = hTotal:GetSize()
	hTotal:SetSize(nSize, nHT)
	
	local nWM = nSize - nW1 - nW2
	local _, nHM = hImgM:GetSize()
	hImgM:SetSize(nWM, nHM)
	
	local _, nHTex = hText:GetSize()
	hText:SetSize(nSize, nHTex)
	
	hTotal:FormatAllItemPos()
end

function IsBattleTipPanel()
	local hFrame = Station.Lookup("Normal/BattleTipPanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function OpenBattleTipPanel(bDisableSound)
	if IsBattleTipPanel() then
		return
	end
	local hFrame = Station.Lookup("Normal/BattleTipPanel")
	if hFrame then
		hFrame:Show()
	else
		Wnd.OpenWindow("BattleTipPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseBattleTipPanel(bDisableSound)
	if not IsBattleTipPanel() then
		return
	end
	
	local hFrame = Station.Lookup("Normal/BattleTipPanel")
	if hFrame then
		hFrame:Hide()
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end


function BattleTipPanel_SetAnchorDefault()
	BattleTipPanel.Anchor = clone(BattleTipPanel.DefaultAnchor)
	FireEvent("ENTER_BATTLE_TIP_ANCHOR_CHANGED")
end

local function OnPlayerEnterScene()
	local hPlayer = GetClientPlayer()
	if hPlayer and hPlayer.dwID == arg0 then
		if not IsInBattleField() then
			CloseBattleTipPanel()
		else
			OpenBattleTipPanel()
		end
	end
end

--RegisterEvent("PLAYER_ENTER_SCENE", OnPlayerEnterScene)
RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", BattleTipPanel_SetAnchorDefault)