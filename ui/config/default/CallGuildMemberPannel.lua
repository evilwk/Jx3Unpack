CallGuildMemberPannel = {}

function CallGuildMemberPannel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
end

function CallGuildMemberPannel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function CallGuildMemberPannel.Update(frame)
	local text = frame:Lookup("", "Text_Name")
	local item = GetItem(CallGuildMemberPannel.dwItemID)
	if item then
		text:SetText(GetItemNameByItem(item))
		text:SetFontColor(GetItemFontColorByQuality(item.nQuality))
	end
	
	local szIniFile = "UI/Config/default/CallGuildMemberPannel.ini"
	
	local hList = frame:Lookup("", "Handle_List")
	hList:Clear()
	
	local aList = CallGuildMemberPannel.tEvokeList or {}
	
	for k, v in pairs(aList) do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_C")
		hI.dwID = v.dwID
		hI.szName = v.szName
		hI.dwForceID = v.dwForceID
		hI.nLevel = v.nLevel
		
		local textN = hI:Lookup("Text_N")
		local textL = hI:Lookup("Text_L")
	
		textN:SetText(v.szName)	
		textL:SetText(FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, v.nLevel))
		
		local szPath, nFrame = GetForceImage(v.dwForceID) 
		local imgSchool = hI:Lookup("Image_School")
		imgSchool:FromUITex(szPath, nFrame)
	end
	
	frame:Lookup("", "Text_NoFriend"):Show(hList:GetItemCount() == 0)
	
	CallGuildMemberPannel.UpdateFriendScrollInfo(hList)
	
	frame:Lookup("Btn_Sure"):Enable(false)
end

function CallGuildMemberPannel.UpdateFriendScrollInfo(hList)
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Scroll_List")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	frame:Lookup("Btn_Up"):Show()
    	frame:Lookup("Btn_Down"):Show()
    else
    	scroll:Hide()
    	frame:Lookup("Btn_Up"):Hide()
    	frame:Lookup("Btn_Down"):Hide()
    end
end

function CallGuildMemberPannel.OnScrollBarPosChanged()
	local frame = this:GetParent()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	frame:Lookup("Btn_Up"):Enable(nCurrentValue ~= 0)
	frame:Lookup("Btn_Down"):Enable(nCurrentValue ~= this:GetStepCount())
	frame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - 10 * nCurrentValue)
end

function CallGuildMemberPannel.OnMouseWheel()
	local szName = this:GetName()
	local nDistance = Station.GetMessageWheelDelta()
	if szName == "CallGuildMemberPannel" then
		this:Lookup("Scroll_List"):ScrollNext(nDistance)
		return 1
	end
end

function CallGuildMemberPannel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev()
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext()
	end
end

function CallGuildMemberPannel.OnLButtonDown()
	CallGuildMemberPannel.OnLButtonHold()
end

function CallGuildMemberPannel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCallGuildMemberPannel()
	elseif szName == "Btn_Sure" then
		CallGuildMemberPannel.DoEvoke(this:GetRoot())
	end
end

function CallGuildMemberPannel.DoEvoke(frame)
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	local aSel = {}
	local szName = ""
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			table.insert(aSel, hB.dwID)
			if szName ~= "" then
				szName = szName..g_tStrings.STR_COMMA.."["..hB.szName.."]"
			else
				szName = "["..hB.szName.."]"
			end
		end
	end
	
	local dwItemID = CallGuildMemberPannel.dwItemID
	
	local item = GetItem(dwItemID)
	
	local f = function() 
		RemoteCallToServer("OnItemEvoke", dwItemID, aSel)
		CloseCallGuildMemberPannel()	
	end
	local msg = 
	{
		szMessage = FormatLinkString(g_tStrings.CALL_GUILD_MEMBER_SURE, "font=162", 
			GetFormatText("["..GetItemNameByItem(item).."]", "166"..GetItemFontColorByQuality(item.nQuality, true)),
			GetFormatText(szName, 162)
		), 
		bRichText = true,
		szName = "ITEM_EVOKE_GUILD_MEMBER",
		fnAutoClose = function() return not IsCallGuildMemberPannelOpened() end,		
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = f },
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	MessageBox(msg)
end

function CallGuildMemberPannel.SelOrUnselFriend(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	local nSelCount = 0
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			nSelCount = nSelCount + 1
		end
	end

	if hI.bSel then
		hI.bSel = false
		nSelCount = nSelCount - 1
		if nSelCount <= 0 then
			hI:GetRoot():Lookup("Btn_Sure"):Enable(false)
		end
	else

		if nSelCount >= 5 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.CALL_GUILD_MEMBER_LIMIT)
			return
		end
		hI.bSel = true
		hI:GetRoot():Lookup("Btn_Sure"):Enable(true)
	end
	CallGuildMemberPannel.UpdateFriendShow(hI)
end


function CallGuildMemberPannel.OnItemLButtonClick()
	CallGuildMemberPannel.SelOrUnselFriend(this)
end

function CallGuildMemberPannel.OnItemLButtonDBClick()
	CallGuildMemberPannel.SelOrUnselFriend(this)
end

function CallGuildMemberPannel.OnItemMouseEnter()
	this.bOver = true
	CallGuildMemberPannel.UpdateFriendShow(this)
end

function CallGuildMemberPannel.OnItemMouseLeave()
	this.bOver = false
	CallGuildMemberPannel.UpdateFriendShow(this)
end

function CallGuildMemberPannel.UpdateFriendShow(hI)
	local img = hI:Lookup("Image_S")
	if not img then
		return
	end
	
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function OpenCallGuildMemberPannel(dwItemID, tEvokeList, bDisableSound)
	CallGuildMemberPannel.dwItemID = dwItemID
	CallGuildMemberPannel.tEvokeList = tEvokeList
	
	local frame = Wnd.OpenWindow("CallGuildMemberPannel")
	CallGuildMemberPannel.Update(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsCallGuildMemberPannelOpened()
	local frame = Station.Lookup("Normal/CallGuildMemberPannel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseCallGuildMemberPannel(bDisableSound)
	if not IsCallGuildMemberPannelOpened() then
		return
	end
	Wnd.CloseWindow("CallGuildMemberPannel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end