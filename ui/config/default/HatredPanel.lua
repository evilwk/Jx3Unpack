HatredPanel = 
{
	szShowType = "party",
	bShowDetail = true,
	DefaultAnchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT", x = -400, y = -300},
	Anchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT", x = -400, y = -300},
	nSafe = 32,
	nWarning = 31,
	nDanger = 30,
	bShowForceColor = true,
	nVersion = 0,
}
local CURRENT_VERSION = 1

RegisterCustomData("HatredPanel.szShowType")
RegisterCustomData("HatredPanel.bShowForceColor")
RegisterCustomData("HatredPanel.bShowDetail")
RegisterCustomData("HatredPanel.Anchor")
RegisterCustomData("HatredPanel.nVersion")

function HatredPanel.OnFrameCreate()
	this:RegisterEvent("CHARACTER_THREAT_RANKLIST")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("HATRED_PANEL_ANCHOR_CHANGED")
	this:RegisterEvent("PARTY_UPDATE_BASE_INFO")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("UPDATE_SELECT_TARGET")
	this:RegisterEvent("HATRED_PANEL_SHOW_FOCE_COLOR_CHANGED")
	this:RegisterEvent("UI_SCALED")
	
	local szIniFile = "UI/Config/Default/HatredPanel.ini"
	local hList = this:Lookup("", "Handle_HaredList")
	hList.Clear()
	for i = 1, 10, 1 do
		hList:AppendItemFromIni(szIniFile, "Handle_Hatred")
	end
	hList:FormatAllItemPos()
	
	if HatredPanel.bShowDetail then
		this:Lookup("CheckBox_Minimize"):Check(true)
	else
		this:Lookup("CheckBox_Minimize"):Check(false)
	end
	
	HatredPanel.UpdateThreatList(this)
	HatredPanel.UpdateAnchor(this)
end

function HatredPanel.OnFrameBreathe()
	if not this.nCount or this.nCount > 16 then
		this.nCount = 0
		HatredPanel.ApplyThreatList(this)
	end
	
	this.nCount = this.nCount + 1
end

function HatredPanel.OnEvent(event)
	if event == "CHARACTER_THREAT_RANKLIST" then
		if arg0 == HatredPanel.dwID then
			local t = {}
			for k, v in pairs(arg1) do
				table.insert(t, {k, v})
			end
			table.sort(t, function(a, b) return a[2] > b[2] end)
			HatredPanel.aThreatRankList = t
			HatredPanel.dwTargetID = arg2
			if arg2 and arg1[arg2] then
				HatredPanel.dwTargetRank = arg1[arg2]
				if HatredPanel.dwTargetRank == 0 then
					HatredPanel.dwTargetRank = 65535
				end
			else
				HatredPanel.dwTargetRank = 65535
			end
			HatredPanel.UpdateThreatList(this)
		end	
	elseif event == "CUSTOM_DATA_LOADED" then
		if HatredPanel.bShowDetail then
			this:Lookup("CheckBox_Minimize"):Check(true)
		else
			this:Lookup("CheckBox_Minimize"):Check(false)
		end
		HatredPanel.UpdateAnchor(this)
	elseif event == "HATRED_PANEL_ANCHOR_CHANGED" then
		HatredPanel.UpdateAnchor(this)
	elseif event == "PARTY_UPDATE_BASE_INFO" or event == "SYNC_ROLE_DATA_END" or event == "UPDATE_SELECT_TARGET" then
		HatredPanel.UpdateThreatList(this)
	elseif event == "HATRED_PANEL_SHOW_FOCE_COLOR_CHANGED" then
		HatredPanel.UpdateThreatList(this)
	elseif event == "UI_SCALED" then
		HatredPanel.UpdateAnchor(this)	
	end
end

function HatredPanel.OnFrameDragEnd()
	this:CorrectPos()
	HatredPanel.Anchor = GetFrameAnchor(this)
end

function HatredPanel.UpdateThreatList(frame)
	local player = GetClientPlayer()
	if player and player.IsInParty() then
		frame:Show()
	else
		frame:Hide()
		return
	end
	
	local handle = frame:Lookup("", "")
	local hList = handle:Lookup("Handle_HaredList")	
	local t = HatredPanel.aThreatRankList or {}
	if HatredPanel.dwID and HatredPanel.dwID ~= 0 then
		local npc = GetNpc(HatredPanel.dwID)
		local szName = g_tStrings.HATRED_COLLECT
		if npc then
			szName = szName.."("..npc.szName..")"
		else
			t = {}
		end
		handle:Lookup("Text_Title"):SetText(szName)
	else
		handle:Lookup("Text_Title"):SetText(g_tStrings.HATRED_COLLECT)
	end
	
	if not HatredPanel.bShowDetail then
		hList:Hide()
		handle:Lookup("Image_Ruler"):Hide()
		handle:Lookup("Text_SafeZone"):Hide()
		
		local img = handle:Lookup("Image_Bg")
		local w, _ = img:GetSize()
		h = 30
		img:SetSize(w, h)
		handle:SetSize(w, h)
		frame:SetSize(w, h)
		frame:CorrectPos()
		return
	else
		hList:Show()
		handle:Lookup("Image_Ruler"):Show()
		handle:Lookup("Text_SafeZone"):Show()
	end	
	
	local clientTeam = GetClientTeam()
	local h = 0
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		local a = t[i + 1]
		if a then
			hI:Show()
			local szName = ""
			local dwID = a[1]
			local dwForceID = 0
			if IsPlayer(dwID) then
				local p = GetPlayer(dwID)
				if p then
					szName = p.szName
					dwForceID = p.dwForceID
				elseif clientTeam.IsPlayerInTeam(dwID) then
					szName = clientTeam.GetClientTeamMemberName(dwID)
					dwForceID = clientTeam.GetClientTeamMemberForceID(dwID)
				end
			else
				local npc = GetNpc(dwID)
				if npc then
					szName = npc.szName
				end
			end
			
			local r, g, b = 255, 255, 255
			--if player.dwID == dwID then
			--	r, g, b = 255, 255, 0
			--else
			if HatredPanel.bShowForceColor and g_tIdentityColor[dwForceID] then
				r, g, b = g_tIdentityColor[dwForceID].r, g_tIdentityColor[dwForceID].g, g_tIdentityColor[dwForceID].b
			end
			
			local text = hI:Lookup("Text_Name")
			text:SetText(szName)
			text:SetFontColor(r, g, b)
			
			local fP = a[2] / HatredPanel.dwTargetRank
			text = hI:Lookup("Text_Value")
			text:SetText(math.floor(fP * 100).."%")
			text:SetFontColor(r, g, b)
			
			local img = hI:Lookup("Image_Player")
			if fP <= 0.8 then
				img:SetFrame(HatredPanel.nSafe)
			elseif fP <= 1.0 then
				img:SetFrame(HatredPanel.nWarning)
			else
				img:SetFrame(HatredPanel.nDanger)
			end
			img:SetPercentage(fP * 100 / 120)
			
			local _, hI = hI:GetSize()
			h = h + hI
		else
			hI:Hide()
		end
	end
	
	local w, _ = hList:GetSize()
	hList:SetSize(w, h)
	
	local img = handle:Lookup("Image_Bg")
	local w, _ = img:GetSize()
	h = h + 60
	img:SetSize(w, h)
	handle:SetSize(w, h)
	frame:SetSize(w, h)
	frame:CorrectPos()
end

function HatredPanel.UpdateAnchor(frame)
	frame:SetPoint(HatredPanel.Anchor.s, 0, 0, HatredPanel.Anchor.r, HatredPanel.Anchor.x, HatredPanel.Anchor.y)
	frame:CorrectPos()
end

function HatredPanel.ApplyThreatList(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local dwType, dwID = player.GetTarget()
	if dwType == TARGET.PLAYER then
		local p = GetPlayer(dwID)
		if p then
			dwType, dwID = p.GetTarget()
		end
	end

	if dwType == TARGET.NPC then
		ApplyCharacterThreatRankList(dwID)
	end
	
	if HatredPanel.dwID ~= dwID then
		HatredPanel.dwID = dwID
		HatredPanel.aThreatRankList = {}
		HatredPanel.UpdateThreatList(frame)
	end	
end

function HatredPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		HatredPanel.bShowDetail = true
		HatredPanel.UpdateThreatList(this:GetRoot())
	end
end

function HatredPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		HatredPanel.bShowDetail = false
		HatredPanel.UpdateThreatList(this:GetRoot())	
	end
end


function OpenHatredPanel(bDisableSound)
	if IsHatredPanelOpened() then
		return
	end
	
	Station.OpenWindow("HatredPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsHatredPanelOpened()
	local frame = Station.Lookup("Normal/HatredPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseHatredPanel(bDisableSound)
	if not IsHatredPanelOpened() then
		return
	end
	
	Station.CloseWindow("HatredPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function HatredPanel_SetAnchorDefault()
	HatredPanel.Anchor.s = HatredPanel.DefaultAnchor.s
	HatredPanel.Anchor.r = HatredPanel.DefaultAnchor.r
	HatredPanel.Anchor.x = HatredPanel.DefaultAnchor.x
	HatredPanel.Anchor.y = HatredPanel.DefaultAnchor.y
	FireEvent("HATRED_PANEL_ANCHOR_CHANGED")
end

RegisterEvent("HATRED_PANEL_ANCHOR_CHANGED", HatredPanel_SetAnchorDefault)

local UpdateHatredPanelShow = function()
	if HatredPanel.szShowType == "close" then 
		CloseHatredPanel(true)
	elseif HatredPanel.szShowType == "copy" then
		local player = GetClientPlayer()
		if player then
			local _, nMapType = GetMapParams(player.GetMapID())
			if nMapType == 1 then
				OpenHatredPanel(true)
			else
				CloseHatredPanel(true)
			end
		else
			CloseHatredPanel(true)
		end
	elseif HatredPanel.szShowType == "party" then
		local player = GetClientPlayer()
		if player and player.IsInParty() then
			OpenHatredPanel(true)
		else
			CloseHatredPanel(true)
		end
	else
		OpenHatredPanel(true)
	end
end

function SetHatredPanelShowForceColor(bShow)
	if HatredPanel.bShowForceColor ~= bShow then
		HatredPanel.bShowForceColor = bShow
		FireEvent("HATRED_PANEL_SHOW_FOCE_COLOR_CHANGED")
	end
end

function IsHatredPanelShowForceColor()
	return HatredPanel.bShowForceColor
end

function GetShowHatredPanelType()
	return HatredPanel.szShowType
end

function SetShowHatredPanelType(szType)
	if HatredPanel.szShowType ~= szType then
		HatredPanel.szShowType = szType
		UpdateHatredPanelShow()
	end
end

function HatredPanel.ProcessVersion()
	HatredPanel.szShowType = "party"
	HatredPanel.bShowForceColor = true
end

local function OnCustomDataLoaded()
	if arg0 ~= "Role" then 
		return 
	end 
		
	if CURRENT_VERSION ~= HatredPanel.nVersion then
		if CURRENT_VERSION == 1 then
			HatredPanel.ProcessVersion()
		end
	end
	HatredPanel.nVersion = CURRENT_VERSION
	
	UpdateHatredPanelShow()
end

local function OnPartyMsgNotify()
	if arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_CREATED or arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_JOINED then
		if HatredPanel.szShowType == "party" then
			OpenHatredPanel(true)
		else
			CloseHatredPanel(true)
		end
	end
end

local function OnTeamDelMember()
	if GetClientPlayer().dwID == arg1 then
		if HatredPanel.szShowType == "party" then
			CloseHatredPanel(true)
		end
	end
end

RegisterEvent("PARTY_DISBAND", UpdateHatredPanelShow)
RegisterEvent("PARTY_DELETE_MEMBER", OnTeamDelMember)
RegisterEvent("PARTY_MESSAGE_NOTIFY", OnPartyMsgNotify)
RegisterEvent("CUSTOM_DATA_LOADED", OnCustomDataLoaded)
RegisterEvent("SYNC_ROLE_DATA_END", UpdateHatredPanelShow)
RegisterEvent("PLAYER_ENTER_SCENE",  function () if GetClientPlayer().dwID == arg0 then UpdateHatredPanelShow() end end)
