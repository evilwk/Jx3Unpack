AddFriendPanel = {}

function AddFriendPanel.OnFrameCreate()
	if AddFriendPanel.purpose == "guild" then
		InitFrameAutoPosInfo(this, 0.5, nil, "GuildPanel", function() CloseAddFriendPanel(true) end)
	else
		InitFrameAutoPosInfo(this, 0.5, nil, "PartyPanel", function() CloseAddFriendPanel(true) end)
	end
end

function AddFriendPanel.UpdtePlayerList(frame)
	local handle = frame:Lookup("", "Handle_List")
	handle:Clear()
	
	local player = GetClientPlayer()
	local aAroundPlayer = player.GetAroundPlayerID()
	
	for k, v in pairs(aAroundPlayer) do
		local playerOther = GetPlayer(v)
		if playerOther then
			handle:AppendItemFromIni("UI/Config/Default/AddFriendPanel.ini", "Handle_Item", "")
			local hI = handle:Lookup(handle:GetItemCount() - 1)
			hI.dwID = v
			hI.szName = playerOther.szName
			hI:Lookup("Text_Name"):SetText(playerOther.szName)
		end
	end
	
	AddFriendPanel.UpdateScrollInfo(handle)
end

function AddFriendPanel.UpdatePurpose(frame)

	local text = frame:Lookup("", "Text_Title")
	if AddFriendPanel.purpose == "party" then
		text:SetText(g_tStrings.ADD_TEAMMATE)
	elseif AddFriendPanel.purpose == "friend" then
		text:SetText(g_tStrings.ADD_FRIEND)
	elseif AddFriendPanel.purpose == "enemy" then
		text:SetText(g_tStrings.ADD_ENEMY)
	elseif AddFriendPanel.purpose == "blacklist" then
		text:SetText(g_tStrings.ADD_BLACKLIST)
	elseif AddFriendPanel.purpose == "guild" then
		text:SetText(g_tStrings.ADD_GUILD)
	end
end

function AddFriendPanel.OnFrameBreathe()
	local edit = this:Lookup("Edit_Name")
	local szText = edit:GetText()
	
	if szText == "" then
		this:Lookup("Btn_Sure"):Enable(false)
		return
	end
	
	this:Lookup("Btn_Sure"):Enable(true)
end

function AddFriendPanel.OnEditChanged()
	if this:GetName() == "Edit_Name" and not this.bDisable then
		local szText = this:GetText()
		local handle = this:GetParent():Lookup("", "Handle_List")
		local nCount = handle:GetItemCount() - 1
		local bHave = false
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.szName == szText then
				AddFriendPanel.SelectPlayer(hI)
				bHave = true
				break
			end
		end
		if not bHave then
			AddFriendPanel.UnselectPlayer(handle)
		end
	end
end

function AddFriendPanel.OnEditSpecialKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		return 1
	end
end

function AddFriendPanel.OnItemLButtonDown()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			AddFriendPanel.SelectPlayer(this)
		end
	end
end

function AddFriendPanel.OnItemLButtonUp()
end

function AddFriendPanel.OnItemLButtonClick()
end

function AddFriendPanel.OnItemLButtonDBClick()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			AddFriendPanel.SelectPlayer(this)
		end
		AddFriendPanel.Add(this:GetRoot())
	end	
end

function AddFriendPanel.OnItemMouseEnter()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			this:Lookup("Image_Sel"):Show()
			this:Lookup("Image_Sel"):SetAlpha(127)
		end
	end
end

function AddFriendPanel.OnItemMouseLeave()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			this:Lookup("Image_Sel"):Hide()
		end
	end
end

function AddFriendPanel.SelectPlayer(hI)
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB:Lookup("Image_Sel"):Hide()
		hB.bSel = false
	end
	hI:Lookup("Image_Sel"):Show()
	hI:Lookup("Image_Sel"):SetAlpha(255)
	hI.bSel = true
	local edit = hI:GetRoot():Lookup("Edit_Name")
	edit.bDisable = true
	edit:SetText(hI.szName)
	edit.bDisable = false
end

function AddFriendPanel.UnselectPlayer(handle)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		hI:Lookup("Image_Sel"):Hide()
		hI.bSel = false
	end
end

function AddFriendPanel.Add(frame)
	local szPlayer = frame:Lookup("Edit_Name"):GetText()
	local player = GetClientPlayer()
	local team = GetClientTeam();
	if AddFriendPanel.purpose == "party" then
		team.InviteJoinTeam(szPlayer)
		AddContactPeople(szPlayer)
	elseif AddFriendPanel.purpose == "friend" then
		player.AddFellowship(szPlayer)
	elseif AddFriendPanel.purpose == "enemy" then
		if not IsPlayerNeutral() then
			RemoteCallToServer("OnPrepareAddFoe", szPlayer)
		end
	elseif AddFriendPanel.purpose == "blacklist" then
		player.AddBlackList(szPlayer)
		if not GetClientPlayer().IsAchievementAcquired(981) then
			RemoteCallToServer("OnClientAddAchievement", "BlackList_First_Add")
		end
	elseif AddFriendPanel.purpose == "guild" then
		InvitePlayerJoinTong(szPlayer)
		AddContactPeople(szPlayer)
	end
	CloseAddFriendPanel()
end

function AddFriendPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Cancel" then
		CloseAddFriendPanel()
	elseif szName == "Btn_Sure" then
		AddFriendPanel.Add(this:GetRoot())
	end
end

function AddFriendPanel.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local frame = handle:GetRoot()
	local wA, hA = handle:GetAllItemSize()
	local w, h = handle:GetSize()
	local nStep = (hA - h) / 10
	if nStep > 0 then
		frame:Lookup("Scroll_List"):Show()
		frame:Lookup("Btn_Up"):Show()
		frame:Lookup("Btn_Down"):Show()
	else
		frame:Lookup("Scroll_List"):Hide()
		frame:Lookup("Btn_Up"):Hide()
		frame:Lookup("Btn_Down"):Hide()
	end
	frame:Lookup("Scroll_List"):SetStepCount((hA - h) / 10)
end

function AddFriendPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	if nCurrentValue == 0 then
		frame:Lookup("Btn_Up"):Enable(false)
	else
		frame:Lookup("Btn_Up"):Enable(true)
	end
	if nCurrentValue == this:GetStepCount() then
		frame:Lookup("Btn_Down"):Enable(false)
	else
		frame:Lookup("Btn_Down"):Enable(true)
	end
	
    local handle = frame:Lookup("", "Handle_List")
    handle:SetItemStartRelPos(0, - nCurrentValue * 10)
end

function AddFriendPanel.OnLButtonDown()
	AddFriendPanel.OnLButtonHold()
end

function AddFriendPanel.OnLButtonHold()
    local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)
    end
end

function AddFriendPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	return 1
end

function OpenAddFriendPanel(purpose, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsAddFriendPanelOpened(purpose) then
		return
	end
	
	if IsAddFriendPanelOpened() then
		CloseAddFriendPanel(true)
	end
	
	AddFriendPanel.purpose = purpose
	
	local frame = Wnd.OpenWindow("AddFriendPanel")
	AddFriendPanel.UpdtePlayerList(frame)
	AddFriendPanel.UpdatePurpose(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsAddFriendPanelOpened(purpose)
	local frame = Station.Lookup("Normal/AddFriendPanel")
	if frame and frame:IsVisible() then
		if purpose then
			if AddFriendPanel.purpose == purpose then
				return true
			end
		else
			return true
		end
	end
	return false
end

function CloseAddFriendPanel(bDisableSound)
	if not IsAddFriendPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("AddFriendPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end


