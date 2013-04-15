local GMCHECK_FILE = "ui/Config/Default/GMCheck.ini"
local STEP_SIZE = 10
local ITEM_TYPE = 5
local ITEM_ID = 4905

GMCheck = {}

function GMCheck.OnFrameCreate()
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseGMCheck(true) end)
end

function GMCheck.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_List01" then
		GMCheck.SelectPlayer(this)
	end
end

function GMCheck.OnLButtonDown()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_Up" then
		hFrame:Lookup("Scroll_Message"):ScrollPrev()
	elseif szName == "Btn_Down" then
		hFrame:Lookup("Scroll_Message"):ScrollNext()
	end
end

function GMCheck.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	
	if szName == "Handle_Message" then
		hFrame:Lookup("Scroll_Message"):ScrollNext(nDistance)
	end
	return 1
end


function GMCheck.OnLButtonHold()
	GMCheck.OnLButtonDown()
end

function GMCheck.OnLButtonClick()
	local szName = this:GetName()
	local szPlayer = this:GetRoot():Lookup("Edit_Player"):GetText()
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg = 
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = g_tStrings.PLAYER_NOT_EMPTY,
		szName = "OnPlayer2GMRequest",
		fnAutoClose = function() return not IsGMCheckOpened() end,
		{szOption = g_tStrings.STR_RETURN},
	}
	if szName == "Btn_GoodBye" or szName == "Btn_Close" then
		CloseGMCheck()
	elseif szName == "Btn_Transmit" then
		if szPlayer == "" then
			MessageBox(tMsg)
		else
			GMCheck.TransferToPlayer(this:GetRoot())
		end
	elseif szName == "Btn_SendMessage" then
		if szPlayer == "" then
			MessageBox(tMsg)
		else
			OpenGMMessage(szPlayer, true)
		end
	end
end

function GMCheck.TransferToPlayer(hFrame)
	local szName = hFrame:Lookup("Edit_Player"):GetText()
	RemoteCallToServer("OnGMTransferToPlayer", szName)
end

function GMCheck.SelectPlayer(hSelect)
	local hHandle = hSelect:GetParent()
	local nCount = hHandle:GetItemCount()
	
	for i = 0, nCount - 1 do
		local hChild = hHandle:Lookup(i)
		hChild:Lookup("Image_Cover"):Hide()
	end
	
	hSelect:Lookup("Image_Cover"):Show()
	
	hHandle:GetRoot():Lookup("Edit_Player"):SetText(hSelect.szName)
end

function GMCheck.OnScrollBarPosChanged()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	local hFrame = this:GetRoot()
	
	if szName == "Scroll_Message" then
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up"):Enable(false)
		else
			hFrame:Lookup("Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_Down"):Enable(false)
		else
			hFrame:Lookup("Btn_Down"):Enable(true)
		end
	    hFrame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end

function GMCheck.UpdatePlayerList(hHandle)
	local hPlayer = GetClientPlayer()
	local tAroundPlayer = hPlayer.GetAroundPlayerID()
	
	hHandle:Clear()
	for k, v in ipairs(tAroundPlayer) do
		local hOtherPlayer = GetPlayer(v)
		if hOtherPlayer then
			local hList = hHandle:AppendItemFromIni(GMCHECK_FILE, "Handle_List01")
			local szSceneName = Table_GetMapName(hOtherPlayer.GetScene().dwMapID)
			
			hList:Lookup("Text_Name01"):SetText(hOtherPlayer.szName)
			hList:Lookup("Text_Level01"):SetText(hOtherPlayer.nLevel)
			hList:Lookup("Text_Sence01"):SetText(szSceneName)
			hList.szName = hOtherPlayer.szName
		end
	end
	
	hHandle:FormatAllItemPos()
	GMCheck.UpdatePlayerListScroll(hHandle, true)
end

function GMCheck.UpdatePlayerListScroll(hList, bHome)
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Scroll_Message")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	
	local nStepCount = (fHeightAll - fHeight) / STEP_SIZE
	if nStepCount > 0 then
		hScroll:Show()
		hFrame:Lookup("Btn_Up"):Show()
		hFrame:Lookup("Btn_Down"):Show()
	else
		hScroll:Hide()
		hFrame:Lookup("Btn_Up"):Hide()
		hFrame:Lookup("Btn_Down"):Hide()
	end
	hScroll:SetStepCount(nStepCount)
	if bHome then
		hScroll:ScrollHome()
	end
end

function OpenGMCheck(bDisableSound)
	if IsGMCheckOpened() then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer or not hPlayer.GetItemByIndex(ITEM_TYPE, ITEM_ID) then
		return
	end
	
	local hFrame = Wnd.OpenWindow("GMCheck")
	local hList = hFrame:Lookup("", "Handle_List")
	
	GMCheck.UpdatePlayerList(hList)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function CloseGMCheck(bDisableSound)
	if not IsGMCheckOpened() then
		return
	end
	
	Wnd.CloseWindow("GMCheck")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsGMCheckOpened()
	local hFrame = Station.Lookup("Normal/GMCheck")
	if hFrame then
		return true
	end
	
	return false
end
