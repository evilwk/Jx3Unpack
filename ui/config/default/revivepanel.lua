RevivePanel = {}

local lc_dwNanPinMapID = 22
local lc_dwKunGunMapID = 30

local function GetCampTipString()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return ""
	end
	
	if hPlayer.nCamp == CAMP.GOOD then
		return g_tStrings.STR_CAMP_FIGHT_GTIP
	end
	
	if hPlayer.nCamp == CAMP.EVIL then
		return g_tStrings.STR_CAMP_FIGHT_CTIP
	end
	return ""
end

local function IsInCampFightAndInNP_GL()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return false
	end
	
	if hPlayer.nCamp == CAMP.NEUTRAL then
		return false
	end
	
	local hScene = hPlayer.GetScene()
	if not hScene then
		return false
	end
	
	if hScene.dwMapID ~= lc_dwNanPinMapID and hScene.dwMapID ~= lc_dwKunGunMapID then
		return false
	end
	
	local dwMapID = GetInCampFightCity()
	if dwMapID then
		return true
	end
	return false;
end

function RevivePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")

	RevivePanel.OnEvent("UI_SCALED")
end

local IsRevivePanelOpened = function()
	local frame = Station.Lookup("Topmost/RevivePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

local CloseRevivePanel = function()
	if not IsRevivePanelOpened() then
		return
	end
	
	RevivePanel.bHaveReciveEvent = nil
	
	Wnd.CloseWindow("RevivePanel")
	PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
end

local OpenRevivePanel = function()
	if IsRevivePanelOpened() then
		return
	end
	
	RevivePanel.bHaveReciveEvent = true
	Wnd.OpenWindow("RevivePanel")
					
	if IsInCampFightAndInNP_GL() then
		local szCamTip = GetCampTipString()
		OutputMessage("MSG_SYS", szCamTip.."\n")
	end
				
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
end

function RevivePanel.UpdateReviveState(frame)
	local btnSure   = frame:Lookup("Btn_Sure")
	local btnCancel = frame:Lookup("Btn_Cancel")
	local handle    = frame:Lookup("", "Handle_Message")
	
	handle:Clear()
	btnSure:Enable(false)
	btnCancel:Enable(false)
			
	if RevivePanel.bReviveByPlayer  then
		local szName = g_tStrings.STR_REVIVE_SOME_BODY
		
		if RevivePanel.dwPlayerID and IsPlayer(RevivePanel.dwPlayerID) then
			local player = GetPlayer(RevivePanel.dwPlayerID)
			if player then 
				szName = player.szName 
			end
		elseif RevivePanel.dwPlayerID then
			local npc = GetNpc(RevivePanel.dwPlayerID)
			if npc then
				szName = npc.szName 
			end
		end
		
		if RevivePanel.dwPlayerID and RevivePanel.dwPlayerID == GetClientPlayer().dwID then
			handle:AppendItemFromString(GetFormatText(g_tStrings.STR_REVIVE_SELF_REVIVE, 162))
		else
			handle:AppendItemFromString(GetFormatText(FormatString(g_tStrings.STR_REVIVE_PLAYER_REVIVE_YOU, szName), 162))
		end
		if IsInCampFightAndInNP_GL() then
			local szCamTip =  GetFormatText(GetCampTipString(), nil, 255,0,0)
			handle:AppendItemFromString(szCamTip)
		end
		
		handle:FormatAllItemPos()
		
		btnSure:Show()
		btnSure:Enable(true)
		btnSure:Lookup("", ""):Lookup(0):SetText(g_tStrings.STR_HOTKEY_SURE)
		
		btnCancel:Enable(true)
		btnCancel:Lookup("", ""):Lookup(0):SetText(g_tStrings.STR_HOTKEY_CANCEL)
	else
		btnSure:Lookup("",""):Lookup(0):SetText(g_tStrings.STR_REVIVE_PLAYER_REVIVE_SITU)
		btnCancel:Lookup("",""):Lookup(0):SetText(g_tStrings.STR_REVIVE_PLAYER_REVIVE_ALTAR)
		
		if RevivePanel.bReviveInSitu then
			btnSure:Enable(true)
		end
		
		if RevivePanel.bReviveInAltar then
			btnCancel:Enable(true)
		end
	end
	
	local thisSave = this
	this = frame
	RevivePanel.OnFrameBreathe()
	this = thisSave
end

function RevivePanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState ~= MOVE_STATE.ON_DEATH then
		CloseRevivePanel()
		return
	end
		
	if RevivePanel.bHaveReciveEvent then
		if RevivePanel.bReviveByPlayer then
			return
		end
	
		local handle = this:Lookup("", "Handle_Message")
		handle:Clear()
		
		local szTime = ""
		local nTime = math.floor((RevivePanel.nEndTime - GetTickCount()) / 1000)
		if nTime < 0 then
			nTime = 0
		end
		
		local nH, nM, nS = GetTimeToHourMinuteSecond(nTime)
		if nH > 0 then
			szTime = nH..g_tStrings.STR_BUFF_H_TIME_H
		end
		
		if nH > 0 or nM > 0 then
			szTime = szTime..nM..g_tStrings.STR_BUFF_H_TIME_M_SHORT
		end
		szTime = szTime..nS..g_tStrings.STR_BUFF_H_TIME_S
		
		local szInfo = g_tStrings.tReviveInfo[RevivePanel.nMessageID] or ""
		szInfo = string.gsub(szInfo, "%$(%w+)", {time=szTime})
		
		handle:AppendItemFromString(szInfo)
		if IsInCampFightAndInNP_GL() then
			local szCamTip =  GetFormatText(GetCampTipString(), nil, 255,0,0)
			handle:AppendItemFromString(szCamTip)
		end
		handle:FormatAllItemPos()
	end
end

function RevivePanel.OnEvent(event)
	if event == "SYNC_PLAYER_REVIVE" then
			--Output(tostring(arg0).." arg0 "..tostring(arg1).." arg1 "..tostring(arg2).." arg2 "..tostring(arg3).." arg3 "..tostring(arg4).." arg4 "..tostring(arg5).." arg5\n")
			RevivePanel.bReviveInSitu   = arg0
			RevivePanel.bReviveInAltar  = arg1
			RevivePanel.bReviveByPlayer = arg2
			
			local nFrame = tonumber(arg3) or 0
			RevivePanel.nEndTime = (nFrame / GLOBAL.GAME_FPS)* 1000 + GetTickCount()
			
			RevivePanel.dwPlayerID = arg4
			RevivePanel.nMessageID = arg5
			
			OpenRevivePanel()
			local frame = Station.Lookup("Topmost/RevivePanel")
			if frame then
				RevivePanel.UpdateReviveState(frame)

			end
	elseif event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 120)
	end
end

function RevivePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		if RevivePanel.bReviveByPlayer then --被玩家复活
			GetClientPlayer().DoDeathRespond(REVIVE_TYPE.BY_PLAYER)
		else	--自己复活
			GetClientPlayer().DoDeathRespond(REVIVE_TYPE.IN_SITU)
		end
		CloseRevivePanel()
		
	elseif szName == "Btn_Cancel" then
		if RevivePanel.bReviveByPlayer then --拒绝被玩家复活
			GetClientPlayer().DoDeathRespond(REVIVE_TYPE.CANCEL_BY_PLAYER)
			RevivePanel.bReviveByPlayer = false
			RevivePanel.UpdateReviveState(this:GetRoot())
			
			PlaySound(SOUND.UI_SOUND,g_sound.Button)
		else	--复活点复活
			GetClientPlayer().DoDeathRespond(REVIVE_TYPE.IN_ALTAR)
			CloseRevivePanel()
		end
	end
end

function RevivePanel.OnFrameDragEnd()
	this:CorrectPos()
end

RegisterEvent("SYNC_PLAYER_REVIVE", function(event) RevivePanel.OnEvent(event) end)