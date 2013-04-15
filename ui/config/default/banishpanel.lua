BanishPanel = {}

function BanishPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	BanishPanel.OnEvent("UI_SCALED")
end

function BanishPanel.OnFrameBreathe()
	BanishPanel.UpdateTime(this)
	
	player = GetClientPlayer()
	if player then
		if player.GetMapID() ~= BanishPanel.dwBanishMapID then
			CloseBanishPanel();
		end
	end
end

function BanishPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 220)
	end
end

function BanishPanel.UpdateTime(frame)
	local h = frame:Lookup("", "Handle_Msg")
	local nTime = math.floor((BanishPanel.nEndTime - GetTickCount()) / 1000)
	if not h.nTime or h.nTime ~= nTime then
		if nTime < 0 then
			CloseBanishPanel()
			return
		end
		h.nTime = nTime
		
		local szText = ""
		if BanishPanel.szReason == "refresh_copy" then
			szText = "<text>text="..EncodeComponentsString(g_tStrings.MSG_INSTANCES_BANISH).."font=106</text>"
		elseif BanishPanel.szReason == "party_copy" then
			szText = "<text>text="..EncodeComponentsString(g_tStrings.MSG_INSTANCES_BANISH1).."font=106</text>"
		elseif BanishPanel.szReason == "guild" then
			szText = "<text>text="..EncodeComponentsString(g_tStrings.MSG_INSTANCES_BANISH_GUILD).."font=106</text>"
		end
		szText = szText.."<text>text="..EncodeComponentsString(nTime..g_tStrings.STR_BUFF_H_TIME_S).."font=101</text>"
		if BanishPanel.szReason == "refresh_copy" then
			szText = szText.."<text>text="..EncodeComponentsString(g_tStrings.MSG_INSTANCES_BANISH2).."font=106</text>"
		elseif BanishPanel.szReason == "party_copy" then
			szText = szText.."<text>text="..EncodeComponentsString(g_tStrings.MSG_INSTANCES_BANISH2).."font=106</text>"
		elseif BanishPanel.szReason == "guild" then
			szText = szText.."<text>text="..EncodeComponentsString(g_tStrings.MSG_INSTANCES_BANISH2_GUILD).."font=106</text>"
		end		
		h:Clear()
		h:AppendItemFromString(szText)
		h:FormatAllItemPos()
	end
end

function OpenBanishPanel(nTime, szReason, bDisableSound)
	if IsBanishPanelOpened() then
		bDisableSound = true
	end

	BanishPanel.nEndTime = GetTickCount() + nTime * 1000
	BanishPanel.szReason = szReason
	local frame = Wnd.OpenWindow("BanishPanel")
	BanishPanel.UpdateTime(frame)
	player = GetClientPlayer();
	
	if player then
		BanishPanel.dwBanishMapID = player.GetMapID();
	end
	
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function IsBanishPanelOpened()
	local frame = Station.Lookup("Topmost/BanishPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseBanishPanel(bDisableSound)
	Wnd.CloseWindow("BanishPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)	
	end	
end