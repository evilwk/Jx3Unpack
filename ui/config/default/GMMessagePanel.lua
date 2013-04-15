local STEP_SIZE = 10
local ITEM_TYPE = 5
local ITEM_ID = 4905
local DISABLE_TIME = 60 * 1000
local INI_PATH = "ui/Config/Default/GMMessage.ini"

local tPlayerList = {}
GMMessage = {}

function GMMessage.OnFrameCreate()
	local hPlayer = GetClientPlayer()
	if GMMessage.IsGM(hPlayer) then
		InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseGMMessage(true) end)
	end
end

function GMMessage.OnFrameBreathe()
	if not this.dwStartTime then
		return
	end 
	local hBtnClose = this:Lookup("Wnd_Main/Btn_Close")
	local dwTime = GetTickCount() - this.dwStartTime 
	if dwTime < DISABLE_TIME then
		local szTime = FixFloat((DISABLE_TIME - dwTime)/1000, 0)
		hBtnClose:Lookup("", "Text_Close"):SetText(g_tStrings.STR_CLOSE .. " " .. szTime)
		hBtnClose:Enable(false)
	else
		hBtnClose:Lookup("", "Text_Close"):SetText(g_tStrings.STR_CLOSE)
		hBtnClose:Enable(true)
	end
end

function GMMessage.OnScrollBarPosChanged()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	local hFrame = this:GetRoot()
	
	if szName == "Scroll_Message" then
		if nCurrentValue == 0 then
			hFrame:Lookup("Wnd_Main/Btn_Up"):Enable(false)
		else
			hFrame:Lookup("Wnd_Main/Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Wnd_Main/Btn_Down"):Enable(false)
		else
			hFrame:Lookup("Wnd_Main/Btn_Down"):Enable(true)
		end
	    hFrame:Lookup("Wnd_Main", "Handle_Message"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	elseif szName == "Scroll_List" then
		if nCurrentValue == 0 then
			hFrame:Lookup("Wnd_List/Btn_UpList"):Enable(false)
		else
			hFrame:Lookup("Wnd_List/Btn_UpList"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Wnd_List/Btn_DownList"):Enable(false)
		else
			hFrame:Lookup("Wnd_List/Btn_DownList"):Enable(true)
		end
	    hFrame:Lookup("Wnd_List", "Handle_ListContent"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end

function GMMessage.UpdateMessageScroll(hList)
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Wnd_Main/Scroll_Message")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = (fHeightAll - fHeight) / STEP_SIZE
	
	local bEnd = false
	if hScroll:GetScrollPos() == hScroll:GetStepCount() then
		bEnd = true
	end
	if nStepCount > 0 then
		hScroll:Show()
		hFrame:Lookup("Wnd_Main/Btn_Up"):Show()
		hFrame:Lookup("Wnd_Main/Btn_Down"):Show()
	else
		hScroll:Hide()
		hFrame:Lookup("Wnd_Main/Btn_Up"):Hide()
		hFrame:Lookup("Wnd_Main/Btn_Down"):Hide()
	end
	hScroll:SetStepCount(nStepCount)
	if bEnd then
		hScroll:ScrollEnd()
	end
end

function GMMessage.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	
	if szName == "Handle_Message" then
		hFrame:Lookup("Wnd_Main/Scroll_Message"):ScrollNext(nDistance)
	elseif szName == "Handle_ListContent" then
		hFrame:Lookup("Wnd_List/Scroll_List"):ScrollNext(nDistance)
	end
	return 1
end

function GMMessage.OnLButtonDown()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_Up" then
		hFrame:Lookup("Wnd_Main/Scroll_Message"):ScrollPrev()
	elseif szName == "Btn_Down" then
		hFrame:Lookup("Wnd_Main/Scroll_Message"):ScrollNext()
	elseif szName == "Btn_UpList" then
		hFrame:Lookup("Wnd_List/Scroll_List"):ScrollPrev()
	elseif szName == "Btn_DownList" then
		hFrame:Lookup("Wnd_List/Scroll_List"):ScrollNext()
	end
end

function GMMessage.OnLButtonHold()
	GMMessage.OnLButtonDown()
end

function GMMessage.OnLButtonClick()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_Sure" then
		local hFrame = this:GetRoot()
		local hPlayer = GetClientPlayer()
		if GMMessage.IsGM(hPlayer) then
			GMMessage.OnGM2PlayerRequest(hFrame, hFrame.szName)
		else
			GMMessage.OnPlayer2GMRequest(hFrame, hFrame.dwID)
		end
	elseif szName == "Btn_Close" then
		CloseGMMessage()
	elseif szName == "Btn_Close2" then
		hFrame:Lookup("Wnd_List"):Hide()
	elseif szName == "Btn_Cancel" then
		local hWndPlayer = hFrame:Lookup("Wnd_List")
		if hWndPlayer.nSelect then
			GMMessage.RemovePlayer(hWndPlayer.nSelect)
			GMMessage.UpdatePlayerList(hWndPlayer)
			hWndPlayer.nSelect = nil
		end
	elseif szName == "Btn_Adense" then
		local hWndPlayer = this:GetRoot():Lookup("Wnd_List")
		if hWndPlayer.nSelect then
			hFrame.szName = tPlayerList[hWndPlayer.nSelect]
			hFrame:Lookup("Wnd_Main", "Text_Name"):SetText(hFrame.szName .. "£º")
		end
	end
end

function GMMessage.OnPlayer2GMRequest(hFrame, dwGM)
	local hEdit = hFrame:Lookup("Wnd_Main/Edit_Message")
	local szMsg = hEdit:GetText()
	if szMsg == "" then
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg = 
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = g_tStrings.SEND_MSG_NOT_EMPTY,
			szName = "OnPlayer2GMRequest",
			fnAutoClose = function() return not IsGMMessageOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(tMsg)
	else
		RemoteCallToServer("OnPlayer2GMMsgRequest", dwGM, szMsg)
		local hMessage = hFrame:Lookup("Wnd_Main", "Handle_Message")
		local hPlayer = GetClientPlayer()
		hMessage:AppendItemFromString("<text>text="..EncodeComponentsString(hPlayer.szName .. "  ".. GetLocalTimeString() .. "\n" .. szMsg .. "\n\n").." font=106 </text>")
		hMessage:FormatAllItemPos()
		GMMessage.UpdateMessageScroll(hMessage)
		hEdit:ClearText()
	end
	
end

function GMMessage.OnGM2PlayerRequest(hFrame, szPlayer)
	local hEdit = hFrame:Lookup("Wnd_Main/Edit_Message")
	local szMsg = hEdit:GetText()
	
	if szMsg == "" then
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg = 
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = g_tStrings.SEND_MSG_NOT_EMPTY,
			{szOption = g_tStrings.STR_RETURN},
			szName = "OnPlayer2GMRequest",
			fnAutoClose = function() return not IsGMMessageOpened() end,
		}
		MessageBox(tMsg)
	else
		RemoteCallToServer("OnGM2PlayerMsgRequest", szPlayer, szMsg);
		local hMessage = hFrame:Lookup("Wnd_Main", "Handle_Message")
		hMessage:AppendItemFromString("<image>path=\"UI/Image/Minimap/Minimap.UITex\" frame=184</image>")
		hMessage:AppendItemFromString("<text>text="..EncodeComponentsString("GM  " .. GetLocalTimeString() .. "\n" .. szMsg .. "\n\n").." font=106 </text>")
		hMessage:FormatAllItemPos()
		GMMessage.UpdateMessageScroll(hMessage)
		GMMessage.AddPlayer(szPlayer)
		GMMessage.UpdatePlayerList(hFrame:Lookup("Wnd_List"))
		hEdit:ClearText()
	end
end

function GMMessage.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Message" and this.szName then
		local hFrame = this:GetRoot()
		hFrame.szName = this.szName
		hFrame:Lookup("Wnd_Main", "Text_Name"):SetText(this.szName .. "£º")
	elseif szName == "Handle_Player" then
		GMMessage.SelectPlayer(this)
	end
end

function GMMessage.SelectPlayer(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do 
		local hPlayer = hList:Lookup(i)
		hPlayer:Lookup("Image_Cover"):Hide()
	end
	
	hSelect:Lookup("Image_Cover"):Show()
	hSelect:GetRoot():Lookup("Wnd_List").nSelect = hSelect.nIndex
end

function GMMessage.UpdatePlayerListScroll(hList)
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Wnd_List/Scroll_List")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = (fHeightAll - fHeight) / STEP_SIZE
	
	local bEnd = false
	if hScroll:GetScrollPos() == hScroll:GetStepCount() then
		bEnd = true
	end
	if nStepCount > 0 then
		hScroll:Show()
		hFrame:Lookup("Wnd_List/Btn_UpList"):Show()
		hFrame:Lookup("Wnd_List/Btn_DownList"):Show()
	else
		hScroll:Hide()
		hFrame:Lookup("Wnd_List/Btn_UpList"):Hide()
		hFrame:Lookup("Wnd_List/Btn_DownList"):Hide()
	end
	hScroll:SetStepCount(nStepCount)
	if bEnd then
		hScroll:ScrollEnd()
	end
	
end

function GMMessage.UpdatePlayerList(hWndPlayer)
	local hPlayerList = hWndPlayer:Lookup("", "Handle_ListContent")
	hPlayerList:Clear()
	for k , v in ipairs(tPlayerList) do
		local hPlayer = hPlayerList:AppendItemFromIni(INI_PATH, "Handle_Player")
		hPlayer:Lookup("Image_Cover"):Hide()
		hPlayer:Lookup("Text_Player"):SetText(v)
		hPlayer.nIndex = k
	end
	hPlayerList:FormatAllItemPos()
	GMMessage.UpdatePlayerListScroll(hPlayerList)
end

function GMMessage.AddPlayer(szPlayer)
	if GMMessage.IsInPlayerList(szPlayer) then
		return
	end
	table.insert(tPlayerList, szPlayer)
end

function GMMessage.RemovePlayer(nIndex)
	table.remove(tPlayerList, nIndex)
end

function GMMessage.IsGM(hPlayer)
	if hPlayer and hPlayer.GetItemByIndex(ITEM_TYPE, ITEM_ID) then
		return true
	end
	
	return false
end

function GMMessage.IsInPlayerList(szPlayer)
	for k , v in ipairs(tPlayerList) do
		if v == szPlayer then
			return true
		end
	end
	
	return false
end

function GMMessage.AutoReplay(szPlayer)
	RemoteCallToServer("OnGM2PlayerMsgRequest", szPlayer, g_tStrings.MSG_GM_CHAT_REPLY);
end

function GMMessage_ReceivePlayerMsg(szName, szMsg)
	local hPlayer = GetClientPlayer()
	if not GMMessage.IsGM(hPlayer) then
		return 
	end
	local hFrame = OpenGMMessage(szName, true)
	
	local hMessage = hFrame:Lookup("Wnd_Main", "Handle_Message")
	local hWndPlayer = hFrame:Lookup("Wnd_List")
	hWndPlayer:Show()
	if not GMMessage.IsInPlayerList(szName) then
		GMMessage.AutoReplay(szName)
	else
		hMessage:AppendItemFromString("<text>text="..EncodeComponentsString(szName.. "  ".. GetLocalTimeString() .. "\n" .. szMsg .. "\n\n").." name=\"Message\" font=106 eventid=1</text>")
		local nCount = hMessage:GetItemCount()
		local hText = hMessage:Lookup(nCount - 1)
		hText.szName = szName
		hMessage:FormatAllItemPos()
	end
	GMMessage.UpdatePlayerList(hWndPlayer)
	GMMessage.UpdateMessageScroll(hMessage)
	
end

function GMMessage_ReceiveGMMsg(dwGMID, szMsg)
	local hFrame = OpenGMMessage("GM", true)
	hFrame.szName = szName
	if not hFrame.dwStartTime then
		hFrame.dwStartTime = GetTickCount()
	end
	hFrame.dwID = dwGMID
	local hMessage = hFrame:Lookup("Wnd_Main", "Handle_Message")
	local hWndPlayer = hFrame:Lookup("Wnd_List")
	hWndPlayer:Hide()
	hMessage:AppendItemFromString("<image>path=\"UI/Image/Minimap/Minimap.UITex\" frame=184</image>")
	hMessage:AppendItemFromString("<text>text="..EncodeComponentsString("GM  " .. GetLocalTimeString() .. "\n" .. szMsg .. "\n\n").." font=106 </text>")
	hMessage:FormatAllItemPos()
	GMMessage.UpdateMessageScroll(hMessage)
end

function OpenGMMessage(szName, bDisableSound)
	local hFrame = nil
	if IsGMMessageOpened() then
		hFrame = Station.Lookup("Normal/GMMessage")
		hFrame:Show()
	else
		hFrame = Wnd.OpenWindow("GMMessage")
	end
	
	hFrame.szName = szName
	hFrame:Lookup("Wnd_Main", "Text_Name"):SetText(szName .. "£º")
	GMMessage.UpdateMessageScroll(hFrame:Lookup("Wnd_Main", "Handle_Message"))
	GMMessage.UpdatePlayerList(hFrame:Lookup("Wnd_List"))
	GMMessage.UpdatePlayerListScroll(hFrame:Lookup("Wnd_List", "Handle_ListContent"))
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	
	return hFrame
end


function CloseGMMessage(bDisableSound)
	if not IsGMMessageOpened() then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if GMMessage.IsGM(hPlayer) then
		Wnd.CloseWindow("GMMessage")
	else
		local hFrame = Station.Lookup("Normal/GMMessage")
		hFrame.dwStartTime = nil
		hFrame:Hide()
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsGMMessageOpened()
	local hFrame = Station.Lookup("Normal/GMMessage")
	if hFrame then
		return true
	end
	
	return false
end