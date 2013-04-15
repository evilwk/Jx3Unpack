GuildAddMember = 
{
	nStartIndex = 1,
	
	tApplyList = 
	{
		
	}
}

function GuildAddMember.OnFrameCreate()
	this:RegisterEvent("ON_GET_APPLY_JOININ_TONGLIST")
	InitFrameAutoPosInfo(this, 0.5, nil, "GuildPanel", function() CloseGuildAddMember(true) end)
	this:Lookup("PageSet_Total/Page_Recruit/Btn_Sure"):Enable(false)
	local page = this:Lookup("PageSet_Total/Page_Request")
	for i = 1, 11, 1 do
		page:Lookup("CheckBox_"..i):Hide()
	end
end

function GuildAddMember.OnEvent(event)
	if event == "ON_GET_APPLY_JOININ_TONGLIST" then
		GuildAddMember.tApplyList = arg0
		GuildAddMember.UpdateApplyList(this:Lookup("PageSet_Total/Page_Request"))
	end
end

function GuildAddMember.UpdateApplyList(page)
	local a = GuildAddMember.tApplyList or {}
	for i = 1, 11, 1 do
		local c = page:Lookup("CheckBox_"..i)
		local nIndex = GuildAddMember.nStartIndex + i - 1
		local aI = a[nIndex]
		if aI then
			c:Show()
			local img = c:Lookup("", "Image_School"..i)
			local szPath, nFrame = GetForceImage(aI.dwForceID)
			img:FromUITex(szPath, nFrame)
			c:Lookup("", "Text_Name"..i):SetText(aI.szName)
			c:Lookup("", "Text_Level"..i):SetText(aI.nLevel)
			c.dwID = aI.dwID
			c.nIndex = nIndex
			c.bDisable = true
			c:Check(false)
			c.bDisable = false
		else
			c:Hide()
		end
	end
	GuildAddMember.UpdateApplyPageInfo(page)
	GuildAddMember.UpdateBtnState(page)
end

function GuildAddMember.UpdateApplyPageInfo(page)
	local nBegin = GuildAddMember.nStartIndex
	local nEnd = nBegin + 10
	local nTotal = 0
	if GuildAddMember.tApplyList then
		nTotal = #(GuildAddMember.tApplyList)
	end
	if nEnd > nTotal then
		nEnd = nTotal
	end
	
	if nBegin > nEnd then
		nBegin = nEnd
	end
	
	local text = page:Lookup("", "Text_Page")
	text:SetText(nBegin.."-"..nEnd.."("..nTotal..")")
	if nBegin <= 1 then
		page:Lookup("Btn_Back"):Enable(false)
	else
		page:Lookup("Btn_Back"):Enable(true)
	end
	
	if nEnd >= nTotal then
		page:Lookup("Btn_Next"):Enable(false)
	else
		page:Lookup("Btn_Next"):Enable(true)
	end
	
end

function GuildAddMember.UpdtePlayerList(page)
	local handle = page:Lookup("", "Handle_List")
	handle:Clear()
	
	local player = GetClientPlayer()
	local aAroundPlayer = player.GetAroundPlayerID()
	
	for k, v in pairs(aAroundPlayer) do
		local playerOther = GetPlayer(v)
		if playerOther then
			handle:AppendItemFromIni("UI/Config/Default/GuildAddMember.ini", "Handle_Item", "")
			local hI = handle:Lookup(handle:GetItemCount() - 1)
			hI.dwID = v
			hI.szName = playerOther.szName
			hI:Lookup("Text_Name"):SetText(playerOther.szName)
		end
	end
	
	GuildAddMember.UpdateScrollInfo(handle)
end

function GuildAddMember.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Name" then
		local szText = this:GetText()
		if szText == "" then
			this:GetParent():Lookup("Btn_Sure"):Enable(false)
		else
			local guild = GetTongClient()
			local player = GetClientPlayer()
			local info = guild.GetMemberInfo(player.dwID)
			local bAuthor = guild.CanAdvanceOperate(info.nGroupID, guild.GetDefaultGroupID(), TONG_OPERATION_INDEX.ADD_TO_GROUP)
			this:GetParent():Lookup("Btn_Sure"):Enable(bAuthor)		
		end
		if not this.bDisable then
			local handle = this:GetParent():Lookup("", "Handle_List")
			local nCount = handle:GetItemCount() - 1
			local bHave = false
			for i = 0, nCount, 1 do
				local hI = handle:Lookup(i)
				if hI.szName == szText then
					GuildAddMember.SelectPlayer(hI)
					bHave = true
					break
				end
			end
			if not bHave then
				GuildAddMember.UnselectPlayer(handle)
			end
		end
	end
end

function GuildAddMember.OnEditSpecialKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		return 1
	end
end

function GuildAddMember.OnItemLButtonDown()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			GuildAddMember.SelectPlayer(this)
		end
	end
end

function GuildAddMember.OnItemLButtonDBClick()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			GuildAddMember.SelectPlayer(this)
		end
		GuildAddMember.Add(this:GetParent():GetParent():GetParent())
	end
end

function GuildAddMember.OnItemMouseEnter()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			this:Lookup("Image_Sel"):Show()
			this:Lookup("Image_Sel"):SetAlpha(127)
		end
	end
end

function GuildAddMember.OnItemMouseLeave()
	if this:GetParent():GetName() == "Handle_List" then
		if not this.bSel then
			this:Lookup("Image_Sel"):Hide()
		end
	end
end

function GuildAddMember.UpdateShow(hI)
	local img = hI:Lookup(0)
	if img then
		if hI.bSel then
			img:Show()
			img:SetAlpha(255)
		else
			if hI.bOver then
				img:Show()
				img:SetAlpha(128)
			else
				img:Hide()
			end
		end
	end
end

function GuildAddMember.UpdateBtnState(page)
	local bSel = false
	local bAll = true
	for i = 1, 11, 1 do
		local c = page:Lookup("CheckBox_"..i)
		if c:IsVisible() then
			if c:IsCheckBoxChecked() then
				bSel = true
			else
				bAll = false
			end
		end
	end
	if not bSel then
		bAll = false
	end
	
	local guild = GetTongClient()
	local player = GetClientPlayer()
	local info = guild.GetMemberInfo(player.dwID)
	local bAuthor = guild.CanAdvanceOperate(info.nGroupID, guild.GetDefaultGroupID(), TONG_OPERATION_INDEX.ADD_TO_GROUP)
	
	page:Lookup("Btn_Add"):Enable(bSel and bAuthor)
	page:Lookup("Btn_End"):Enable(bSel and bAuthor)
	
	local c = page:Lookup("CheckBox_Choose")
	c.bDisable = true
	c:Check(bAll)
	c.bDisable = false
end

function GuildAddMember.OnCheckBoxCheck()
	local szName = this:GetName()
	local page = this:GetParent()
	if page:GetName() == "Page_Request" then
		if szName == "CheckBox_Choose" then
			if not this.bDisable then
				for i = 1, 11, 1 do
					local c = page:Lookup("CheckBox_"..i)
					c.bDisable = true
					c:Check(true)
					c.bDisable = false
				end
				GuildAddMember.UpdateBtnState(page)
			end
		else
			if not this.bDisable then
				GuildAddMember.UpdateBtnState(page)
			end
		end
	end
end

function GuildAddMember.OnCheckBoxUncheck()
	local szName = this:GetName()
	local page = this:GetParent()
	if page:GetName() == "Page_Request" then	
		if szName == "CheckBox_Choose" then
			if not this.bDisable then
				for i = 1, 11, 1 do
					local c = page:Lookup("CheckBox_"..i)
					c.bDisable = true
					c:Check(false)
					c.bDisable = false
				end
				GuildAddMember.UpdateBtnState(page)
			end
		else
			if not this.bDisable then
				GuildAddMember.UpdateBtnState(page)
			end
		end
	end
end

function GuildAddMember.SelectPlayer(hI)
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
	local edit = hP:GetParent():GetParent():Lookup("Edit_Name")
	edit.bDisable = true
	edit:SetText(hI.szName)
	edit.bDisable = false
end

function GuildAddMember.UnselectPlayer(handle)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		hI:Lookup("Image_Sel"):Hide()
		hI.bSel = false
	end
end

function GuildAddMember.Add(page)
	local szPlayer = page:Lookup("Edit_Name"):GetText()
	local player = GetClientPlayer()
	local team = GetClientTeam();
	
	InvitePlayerJoinTong(szPlayer)
	AddContactPeople(szPlayer)
	
	CloseGuildAddMember()
end

function GuildAddMember.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Cancel" then
		CloseGuildAddMember()
	elseif szName == "Btn_Sure" then
		GuildAddMember.Add(this:GetParent())
	elseif szName == "Btn_Back" then
		GuildAddMember.nStartIndex = GuildAddMember.nStartIndex - 11
		if GuildAddMember.nStartIndex < 1 then
			GuildAddMember.nStartIndex = 1
		end
		GuildAddMember.UpdateApplyList(this:GetParent())
	elseif szName == "Btn_Next" then
		GuildAddMember.nStartIndex = GuildAddMember.nStartIndex + 11
		local nCount = 0
		if GuildAddMember.tApplyList then
			nCount = #(GuildAddMember.tApplyList)
		end
		if GuildAddMember.nStartIndex > nCount then
			GuildAddMember.nStartIndex = nCount
		end
		GuildAddMember.UpdateApplyList(this:GetParent())		
	elseif szName == "Btn_Add" then
		GuildAddMember.AddApply(this:GetParent())
	elseif szName == "Btn_End" then
		GuildAddMember.RefuseApply(this:GetParent())
	end
end

function GuildAddMember.AddApply(page)
	for i = 11, 1, -1 do
		local c = page:Lookup("CheckBox_"..i)
		if c:IsVisible() and c:IsCheckBoxChecked() then
			RemoteCallToServer("On_Tong_AddApplyJoinPlayer", c.dwID)
			RemoteCallToServer("On_Tong_DelApplyJoin", c.dwID)
			table.remove(GuildAddMember.tApplyList, c.nIndex)
		end
	end
	
	if GuildAddMember.nStartIndex > #(GuildAddMember.tApplyList) then
		GuildAddMember.nStartIndex = GuildAddMember.nStartIndex - 11
		if GuildAddMember.nStartIndex < 1 then
			GuildAddMember.nStartIndex = 1
		end
	end
	
	GuildAddMember.UpdateApplyList(page)	
end

function GuildAddMember.RefuseApply(page)
	for i = 11, 1, -1 do
		local c = page:Lookup("CheckBox_"..i)
		if c:IsVisible() and c:IsCheckBoxChecked() then
			RemoteCallToServer("On_Tong_DelApplyJoin", c.dwID)
			table.remove(GuildAddMember.tApplyList, c.nIndex)
		end
	end
	
	if GuildAddMember.nStartIndex > #(GuildAddMember.tApplyList) then
		GuildAddMember.nStartIndex = GuildAddMember.nStartIndex - 11
		if GuildAddMember.nStartIndex < 1 then
			GuildAddMember.nStartIndex = 1
		end
	end
	
	GuildAddMember.UpdateApplyList(page)
end

function GuildAddMember.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local page = handle:GetParent():GetParent()
	local wA, hA = handle:GetAllItemSize()
	local w, h = handle:GetSize()
	local nStep = (hA - h) / 10
	if nStep > 0 then
		page:Lookup("Scroll_List"):Show()
		page:Lookup("Btn_Up"):Show()
		page:Lookup("Btn_Down"):Show()
	else
		page:Lookup("Scroll_List"):Hide()
		page:Lookup("Btn_Up"):Hide()
		page:Lookup("Btn_Down"):Hide()
	end
	page:Lookup("Scroll_List"):SetStepCount((hA - h) / 10)
end

function GuildAddMember.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local page = this:GetParent()
	if nCurrentValue == 0 then
		page:Lookup("Btn_Up"):Enable(false)
	else
		page:Lookup("Btn_Up"):Enable(true)
	end
	if nCurrentValue == this:GetStepCount() then
		page:Lookup("Btn_Down"):Enable(false)
	else
		page:Lookup("Btn_Down"):Enable(true)
	end
	
    local handle = page:Lookup("", "Handle_List")
    handle:SetItemStartRelPos(0, - nCurrentValue * 10)
end

function GuildAddMember.OnLButtonDown()
	GuildAddMember.OnLButtonHold()
end

function GuildAddMember.OnLButtonHold()
    local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)
    end
end

function GuildAddMember.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	return 1
end

function GuildAddMember.OnMouseWheel()
	if this:GetName() == "GuildAddMember" then
		return 1
	end
	return 0
end

function OpenGuildAddMember(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsGuildAddMemberOpened() then
		return
	end
	
	local frame = Wnd.OpenWindow("GuildAddMember")
	GuildAddMember.UpdtePlayerList(frame:Lookup("PageSet_Total/Page_Recruit"))
	
	RemoteCallToServer("On_Tong_GetApplyJoinInList")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsGuildAddMemberOpened()
	local frame = Station.Lookup("Normal/GuildAddMember")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseGuildAddMember(bDisableSound)
	if not IsGuildAddMemberOpened() then
		return
	end
	
	Wnd.CloseWindow("GuildAddMember")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end


