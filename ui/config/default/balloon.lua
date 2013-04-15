BALLOON_EACH_LINE_VISIBLE_FRAME = 36
BALLOON_FADE_IN_FRAME = 3
BALLOON_FADE_OUT_FRAME = 5

BALLOON_VISIBLE_DISTANCE = 2048

g_bPlayerBalloonVisible = true
g_bNpcBalloonVisible = true

Balloon={}

RegisterCustomData("g_bPlayerBalloonVisible")
RegisterCustomData("g_bNpcBalloonVisible")

function Balloon.OnFrameCreate()
	this:RegisterEvent("CHARACTER_SAY")
	this:RegisterEvent("RENDER_FRAME_UPDATE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("PLAYER_SAY")
    
    this:Lookup("", ""):Clear()
end

function Balloon.OnEvent(event)
	if event == "RENDER_FRAME_UPDATE" then
		Balloon.AdjustAllPosition()
	elseif event == "CHARACTER_SAY" then
		local szText = Table_GetSmartDialog(arg3, arg0)
		Balloon.OnCharacterSay(arg1, arg2, szText)
	elseif event == "PLAYER_SAY" then
		Balloon.OnCharacterSay(arg1, arg2, arg0)
	elseif event == "UI_SCALED" then
		local aID = {}
		local handle = this:Lookup("", "")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bMarket then
				table.insert(aID, hI.dwCharacterID)
			end
		end
	end
end

function Balloon.AdjustPosition(handleBalloon, bForceUpdate)
	-- Extremely evil pathes, I hates, while I am loving.
	-- Prevent balloon to tingle.
	local player = GetClientPlayer() --clientplayer may b nil
	local bClientPlayer = player and player.dwID == handleBalloon.dwCharacterID 
	if bClientPlayer then
		if not handleBalloon.bClientPlayer then
			handleBalloon.bClientPlayer = true
		else
			if not bForceUpdate then
				return
			end
		end
	end

	local xScreen, yScreen, bSuccess = nil, nil, false

	if bClientPlayer then
		local x, y, z = Scene_GetCharacterTop(handleBalloon.dwCharacterID)
		if x and y and z then
			xScreen, yScreen, bSuccess = Scene_ScenePointToScreenPoint(x, y + 20, z)
			if bSuccess then
				xScreen, yScreen = Station.AdjustToOriginalPos(xScreen, yScreen)
			else
				xScreen, yScreen = Station.GetClientSize()
				xScreen = xScreen * 0.5
				yScreen = yScreen * 0.45
				bSuccess = true
			end
		end
	else
		local x, y, z = Scene_GetCharacterTop(handleBalloon.dwCharacterID)
		if x and y and z then
			xScreen, yScreen, bSuccess = Scene_ScenePointToScreenPoint(x, y + 20, z)
			if bSuccess then
				xScreen, yScreen = Station.AdjustToOriginalPos(xScreen, yScreen)
			end
		end
	end

	if bSuccess then
		local cxBalloon, cyBalloon = handleBalloon:GetSize()
		
		xScreen = xScreen - cxBalloon * 0.5
		yScreen = yScreen - cyBalloon

		handleBalloon:SetAbsPos(xScreen, yScreen)
	else
		handleBalloon:SetAbsPos(-4096, -4096)
	end
end

function Balloon.AdjustAllPosition()
    local handle = this:Lookup("", "")
    local nCount = handle:GetItemCount()
    
    if nCount == 0 then
    	return
    end

    local nIndex = 0
    while nIndex < nCount do
        local handleBalloon = handle:Lookup(nIndex)
        
		Balloon.AdjustPosition(handleBalloon)
		
		nIndex = nIndex + 1
    end
end

function Balloon.OnFrameBreathe()
    local handle = this:Lookup("", "")
    
    local nCount = handle:GetItemCount()
    if nCount == 0 then
    	return
    end
    
    local player = GetClientPlayer()
    if not player then
    	return
    end
    local scene = player.GetScene()
    if not scene then
    	return
    end
    local scene3D = KG3DEngine.GetScene(scene.dwID)
    if not scene3D then
    	return
    end
    local camera = scene3D:GetCamera()
    if not camera then
    	return
    end

	local xCameraScene, yCameraScene, zCameraScene = camera:GetPosition()
	local xCameraLogic, yCameraLogic, zCameraLogic = Scene_ScenePositionToGameWorldPosition(xCameraScene, yCameraScene, zCameraScene)
	
    local nIndex = 0
    while nIndex < nCount do
        local handleBalloon = handle:Lookup(nIndex)
        local character = nil
        if IsPlayer(handleBalloon.dwCharacterID) then
        	character = GetPlayer(handleBalloon.dwCharacterID)
        else
        	character = GetNpc(handleBalloon.dwCharacterID)
        end
        if character then
        	local xCharacter, yCharacter, zCharacter = character.GetAbsoluteCoordinate()
        	local distance = GetDistanceSq(xCameraLogic, yCameraLogic, zCameraLogic, xCharacter, yCharacter, zCharacter)
			handleBalloon:SetUserData(-distance)

			nIndex = nIndex + 1
	    else
            handle:RemoveItem(nIndex)
            nCount = nCount - 1
		end			
	end
    
    handle:Sort()
    
    nIndex = 0
	nCount = handle:GetItemCount()
    while nIndex < nCount do
        local handleBalloon = handle:Lookup(nIndex)
		local hContent = handleBalloon:Lookup("Handle_Content")
		
		local nVisibleFrame = handleBalloon.nVisibleFrame
		
		if handleBalloon.nFrameCount < nVisibleFrame then
			handleBalloon.nFrameCount = handleBalloon.nFrameCount + 1
			
			local nFrameCount = handleBalloon.nFrameCount
			if nFrameCount > nVisibleFrame then
				bRemove = true
			elseif nFrameCount <= BALLOON_FADE_IN_FRAME then
				local alpha = 255 * (nFrameCount / BALLOON_FADE_IN_FRAME)
				handleBalloon:SetAlpha(alpha)
				hContent:SetAlpha(alpha)
			elseif nFrameCount > nVisibleFrame - BALLOON_FADE_OUT_FRAME then
				local alpha = 255 * (1 - (nFrameCount - (nVisibleFrame - BALLOON_FADE_OUT_FRAME)) / BALLOON_FADE_OUT_FRAME)
				handleBalloon:SetAlpha(alpha)
				hContent:SetAlpha(alpha)
			else
				handleBalloon:SetAlpha(255)
				hContent:SetAlpha(255)
			end

			nIndex = nIndex + 1
		else
			handle:RemoveItem(nIndex)
			nCount = nCount - 1
		end
    end
end

function Balloon.OnCharacterSay(dwCharacterID, dwChannel, szText)
	if not ( 
		dwChannel == PLAYER_TALK_CHANNEL.NEARBY or 
		dwChannel == PLAYER_TALK_CHANNEL.RAID or 
		dwChannel == PLAYER_TALK_CHANNEL.TEAM or 
		dwChannel == PLAYER_TALK_CHANNEL.TONG or 
		dwChannel == PLAYER_TALK_CHANNEL.SENCE or 
		dwChannel == PLAYER_TALK_CHANNEL.BATTLE_FIELD or 
		dwChannel == PLAYER_TALK_CHANNEL.NPC_NEARBY or 
		dwChannel == PLAYER_TALK_CHANNEL.NPC_PARTY or 
		dwChannel == PLAYER_TALK_CHANNEL.NPC_SENCE or 
		dwChannel == PLAYER_TALK_CHANNEL.NPC_SAY_TO or 
		dwChannel == PLAYER_TALK_CHANNEL.NPC_YELL_TO)
	then
		return
	end

	local dwPlayerID = GetClientPlayer().dwID
	
	if dwCharacterID == 0 then
		return
	end
	
	if IsPlayer(dwCharacterID) then
		if not g_bPlayerBalloonVisible then
			return
		end
		if not GetPlayer(dwCharacterID) then
			return
		end
	else
		if not g_bNpcBalloonVisible then
			return
		end
		if not GetNpc(dwCharacterID) then
			return
		end
	end
	
	if dwCharacterID ~= dwPlayerID and GetCharacterDistance(dwCharacterID, dwPlayerID) > BALLOON_VISIBLE_DISTANCE then
		return
	end
		
    local handle = this:Lookup("", "")
    
    local szName = "B"..dwCharacterID
    local handleBalloon = handle:Lookup(szName)
    local hContent = nil
    
    if not handleBalloon then
	    handle:AppendItemFromIni("UI/Config/Default/Balloon.ini", "Handle_Balloon", szName)
	    handleBalloon = handle:Lookup(handle:GetItemCount() - 1)
	    handleBalloon.dwCharacterID = dwCharacterID
	    handleBalloon:SetAlpha(0)
		
		hContent = handleBalloon:Lookup("Handle_Content")
		hContent:SetAlpha(0)
		hContent:Show()
	else
		hContent = handleBalloon:Lookup("Handle_Content")
	end
	
	local r, g, b 
	if dwChannel == PLAYER_TALK_CHANNEL.NEARBY then
		r, g, b = GetMsgFontColor("MSG_NORMAL")
	elseif dwChannel == PLAYER_TALK_CHANNEL.RAID then
		r, g, b = GetMsgFontColor("MSG_TEAM")
	elseif dwChannel == PLAYER_TALK_CHANNEL.TEAM then
		r, g, b = GetMsgFontColor("MSG_PARTY")
	elseif dwChannel == PLAYER_TALK_CHANNEL.TONG then
		r, g, b = GetMsgFontColor("MSG_GUILD")
	elseif dwChannel == PLAYER_TALK_CHANNEL.SENCE then
		r, g, b = GetMsgFontColor("MSG_MAP")
	elseif dwChannel == PLAYER_TALK_CHANNEL.BATTLE_FIELD then
		r, g, b = GetMsgFontColor("MSG_BATTLE_FILED")
	elseif dwChannel == PLAYER_TALK_CHANNEL.NPC_NEARBY then
		r, g, b = GetMsgFontColor("MSG_NPC_NEARBY")
	elseif dwChannel == PLAYER_TALK_CHANNEL.NPC_PARTY then
		r, g, b = GetMsgFontColor("MSG_NPC_PARTY")
	elseif dwChannel == PLAYER_TALK_CHANNEL.NPC_SENCE then
		r, g, b = GetMsgFontColor("MSG_NPC_YELL")
	else
		r, g, b = GetMsgFontColor("MSG_NORMAL")
--		Log("Balloon.OnCharacterSay() dwChannel error\n")
	end
	
	local nTextLength = string.len(szText)
	szText = EmotionPanel_ParseBallonText(szText, r, g, b)

	hContent:Clear()
	hContent:SetSize(300, 131)
	hContent:AppendItemFromString(szText)
	
	hContent:FormatAllItemPos()
	hContent:SetSizeByAllItemSize()
	
	handleBalloon.nFrameCount = 0
	handleBalloon.nVisibleFrame = BALLOON_EACH_LINE_VISIBLE_FRAME * math.ceil(nTextLength / 18) + BALLOON_FADE_IN_FRAME + BALLOON_FADE_OUT_FRAME
	
	Balloon.AdjustSize(handleBalloon, hContent)
	Balloon.AdjustPosition(handleBalloon, true)
end

function Balloon.AdjustSize(handleBalloon, hContent)
	local w, h = hContent:GetSize()
	w, h = w + 20, h + 20	
	image = handleBalloon:Lookup("Image_Bg1")
	image:SetSize(w, h)	
	
	image = handleBalloon:Lookup("Image_Bg2")
	image:SetRelPos(w * 0.8 - 16, h - 4)

	handleBalloon:SetSize(10000, 10000)
	handleBalloon:FormatAllItemPos()
	handleBalloon:SetSizeByAllItemSize()
end

function ShowPlayerBalloon(bShow)
	g_bPlayerBalloonVisible = bShow
	
    local handle = Station.Lookup("Lowest/Balloon", "Handle_Total")
    if not handle then
    	return
    end
    
    local nCount = handle:GetItemCount()
    if nCount > 0 then
	    for nIndex = 0, nCount - 1, 1 do
		    local handleBalloon = handle:Lookup(nIndex)
	        
			if IsPlayer(handleBalloon.dwCharacterID) then
				if g_bPlayerBalloonVisible then
					handleBalloon:Lookup("Handle_Content"):Show()
				else
					handleBalloon:Lookup("Handle_Content"):Hide()
				end
			end
	    end
	end
end

function IsPlayerBalloonVisible()
	return g_bPlayerBalloonVisible
end

function ShowNpcBalloon(bShow)
	g_bNpcBalloonVisible = bShow
	
    local handle = Station.Lookup("Lowest/Balloon", "Handle_Total")
    if not handle then
    	return
    end
    
    local nCount = handle:GetItemCount()
    if nCount > 0 then
	    for nIndex = 0, nCount - 1, 1 do
	        local handleBalloon = handle:Lookup(nIndex)
	        
			if not IsPlayer(handleBalloon.dwCharacterID) then
				if g_bNpcBalloonVisible then
					handleBalloon:Lookup("Handle_Content"):Show()
				else
					handleBalloon:Lookup("Handle_Content"):Hide()
				end
			end
	    end
	end
end

function IsNpcBalloonVisible()
	return g_bNpcBalloonVisible
end
