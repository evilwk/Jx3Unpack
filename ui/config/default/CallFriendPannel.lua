CallFriendPannel = {}

function CallFriendPannel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
end

function CallFriendPannel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function CallFriendPannel.Update(frame)
	local text = frame:Lookup("", "Text_Name")
	local item = GetItem(CallFriendPannel.dwItemID)
	if item then
		text:SetText(GetItemNameByItem(item))
		text:SetFontColor(GetItemFontColorByQuality(item.nQuality))
	end
	
	local szIniFile = "UI/Config/default/CallFriendPannel.ini"
	
	local hList = frame:Lookup("", "Handle_List")
	hList:Clear()
	
	local aList = CallFriendPannel.tEvokeList or {}
	
	for k, v in pairs(aList) do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_C")
		hI.dwID = v.dwID
		hI.szName = v.szName
		hI.dwForceID = v.dwForceID
		hI.nLevel = v.nLevel
		hI.nAttraction = v.nAttraction
		
		local textN = hI:Lookup("Text_N")
		local textL = hI:Lookup("Text_L")
	
		local nFont = PartyPanel.GetFellowFont(true, false, false)
		
		textN:SetFontScheme(nFont)
		textL:SetFontScheme(nFont)
		
		textN:SetText(v.szName)	
		textL:SetText(FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, v.nLevel))
		
		local szPath, nFrame = GetForceImage(v.dwForceID) 
		local imgSchool = hI:Lookup("Image_School")
		imgSchool:FromUITex(szPath, nFrame)
		
		local imgBgNormal = hI:Lookup("Image_Attraction1")
		local imgBgMarried = hI:Lookup("Image_Attraction2")
		local nFrame = 50
		if false then
			imgBgNormal:Hide()
			imgBgMarried:Show()
			nFrame = 47
		elseif false then
			imgBgNormal:Hide()
			imgBgMarried:Show()
			nFrame = 51
		else
			imgBgNormal:Show()
			imgBgMarried:Hide()
		end
		local nLevel, fP = PartyPanel.GetAttractionLevel(v.nAttraction)
		for i = 1, nLevel, 1 do
			local img = hI:Lookup(i.."H")
			img:SetFrame(nFrame)
			img:Show()
			if i == nLevel then
				img:SetPercentage(fP)
			else
				img:SetPercentage(1)
			end
		end
		for i = nLevel + 1, 7, 1 do
			hI:Lookup(i.."H"):Hide()
		end
	end
	
	CallFriendPannel.dwSel = nil
	CallFriendPannel.szName = nil
	
	frame:Lookup("", "Text_NoFriend"):Show(hList:GetItemCount() == 0)
	
	CallFriendPannel.UpdateFriendScrollInfo(hList)
	
	frame:Lookup("Btn_Sure"):Enable(false)
end

function CallFriendPannel.UpdateFriendScrollInfo(hList)
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

function CallFriendPannel.OnScrollBarPosChanged()
	local frame = this:GetParent()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	frame:Lookup("Btn_Up"):Enable(nCurrentValue ~= 0)
	frame:Lookup("Btn_Down"):Enable(nCurrentValue ~= this:GetStepCount())
	frame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - 10 * nCurrentValue)
end

function CallFriendPannel.OnMouseWheel()
	local szName = this:GetName()
	local nDistance = Station.GetMessageWheelDelta()
	if szName == "CallFriendPannel" then
		this:Lookup("Scroll_List"):ScrollNext(nDistance)
		return 1
	end
end

function CallFriendPannel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev()
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext()
	end
end

function CallFriendPannel.OnLButtonDown()
	CallFriendPannel.OnLButtonHold()
end

function CallFriendPannel.DoEvoke(dwItemID, dwID, szName)
	local item = GetItem(dwItemID)
	local f = function()
		RemoteCallToServer("OnItemEvoke", dwItemID, {dwID})
		CloseCallFriendPannel()		
	end
	local msg = 
	{
		szMessage = FormatLinkString(g_tStrings.CALL_FRIEND_SURE, "font=162", 
			GetFormatText("["..GetItemNameByItem(item).."]", "166"..GetItemFontColorByQuality(item.nQuality, true)),
			GetFormatText("["..CallFriendPannel.szName.."]", 162)
		), 
		bRichText = true,
		szName = "ITEM_EVOKE_FFRIEND",
		fnAutoClose = function() return not IsCallFriendPannelOpened() end,		
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = f },
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	MessageBox(msg)	
end

function CallFriendPannel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCallFriendPannel()
	elseif szName == "Btn_Sure" then
		CallFriendPannel.DoEvoke(CallFriendPannel.dwItemID, CallFriendPannel.dwSel, CallFriendPannel.szName)
	end
end


function CallFriendPannel.SelFriend(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			CallFriendPannel.UpdateFriendShow(hB)
			break
		end
	end
	
	hI.bSel = true
	CallFriendPannel.dwSel = hI.dwID
	CallFriendPannel.szName = hI.szName
	CallFriendPannel.UpdateFriendShow(hI)
	hI:GetRoot():Lookup("Btn_Sure"):Enable(true)
end


function CallFriendPannel.OnItemLButtonClick()
	CallFriendPannel.SelFriend(this)
end

function CallFriendPannel.OnItemLButtonDBClick()
	CallFriendPannel.DoEvoke(CallFriendPannel.dwItemID, CallFriendPannel.dwSel, CallFriendPannel.szName)
end

function CallFriendPannel.OnItemMouseEnter()
	this.bOver = true
	CallFriendPannel.UpdateFriendShow(this)
end

function CallFriendPannel.OnItemMouseLeave()
	this.bOver = false
	CallFriendPannel.UpdateFriendShow(this)
end

function CallFriendPannel.UpdateFriendShow(hI)
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

function OpenCallFriendPannel(dwItemID, tEvokeList, bDisableSound)
	CallFriendPannel.dwItemID = dwItemID
	CallFriendPannel.tEvokeList = tEvokeList
	
	local frame = Wnd.OpenWindow("CallFriendPannel")
	CallFriendPannel.Update(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsCallFriendPannelOpened()
	local frame = Station.Lookup("Normal/CallFriendPannel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseCallFriendPannel(bDisableSound)
	if not IsCallFriendPannelOpened() then
		return
	end
	Wnd.CloseWindow("CallFriendPannel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end