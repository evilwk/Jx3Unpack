GuildSalaryPanel = 
{
	aGroup = 
	{
	},
	
	nTotalMoney = 100000,
	nSalary = 10000,
	
	bCanMeModifyGroupWage = true,
	
	nPercentage = 25,
	nStartIndex = 0,
	
	szSortType = "name",
	bSortDecend = false,
	bTongSceneExist = false,
}


function GuildSalaryPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_GET_TONG_PAY_TIME")
	this:RegisterEvent("ON_SET_TONG_PAY_TIME_RESULT")
	this:RegisterEvent("TONG_EVENT_NOTIFY")
	this:RegisterEvent("UPDATE_TONG_INFO")
	this:RegisterEvent("UPDATE_TONG_INFO_FINISH")
	this:RegisterEvent("UPDATE_TONG_ROSTER_FINISH")
	this:RegisterEvent("TONG_STATE_CHANGE")
	this:RegisterEvent("ON_GET_GUILD_SALARY")
	this:RegisterEvent("ON_GET_TONG_SCENE_EXIST")
	GuildSalaryPanel.UpdateGroup()
	GuildSalaryPanel.UpdateSortCheckboxShow(this)
	GuildSalaryPanel.Sort()
	GuildSalaryPanel.Update(this)
	GuildSalaryPanel.UpdateScrollInfo(this)
	
	GuildSalaryPanel.UpdateGiveBtnState(this)
	this:SetPoint("CENTER", 0, 0, "CENTER",  0, 0)
	RemoteCallToServer("OnGetTongPayTime")
	RemoteCallToServer("OnGetTongMemberSalaryRequest")
	RemoteCallToServer("OnGetTongSceneExist")
	this:Lookup("Wnd_Salary", "Handle_PersonalMoney/Text_PMMsg"):SetText("0")
end

function GuildSalaryPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:CorrectPos()
	elseif event == "ON_GET_TONG_PAY_TIME" or event == "ON_SET_TONG_PAY_TIME_RESULT" then
		this:Lookup("Wnd_Salary/Btn_ReceiveDay", "Text_ReceiveDay"):SetText(g_tStrings.WEEK_DAY[arg0])
	elseif event == "UPDATE_TONG_INFO" or event == "TONG_EVENT_NOTIFY" or event == "UPDATE_TONG_INFO_FINISH" or event == "UPDATE_TONG_ROSTER_FINISH" or event == "TONG_STATE_CHANGE" then
		GuildSalaryPanel.UpdateGroup()
		GuildSalaryPanel.Update(this)
	elseif event == "ON_GET_GUILD_SALARY" then
		this:Lookup("Wnd_Salary", "Handle_PersonalMoney/Text_PMMsg"):SetText(arg0)
	elseif event == "ON_GET_TONG_SCENE_EXIST" then
		GuildSalaryPanel.bTongSceneExist = arg0 == 1
		GuildSalaryPanel.Update(this)
	end
end

function GuildSalaryPanel.UpdateGroup()
	local guild = GetTongClient()
	
	GuildSalaryPanel.nTotalMoney = guild.nFund
	GuildSalaryPanel.nPercentage = guild.nTotalWageRate
	GuildSalaryPanel.nSalary = math.floor(guild.nFund * guild.nTotalWageRate / 100)
	local info = guild.GetMemberInfo(GetClientPlayer().dwID)
	GuildSalaryPanel.bCanMeModifyGroupWage = info and guild.CanBaseOperate(info.nGroupID, TONG_OPERATION_INDEX.MANAGE_WAGE)
	
	local aGroup = {}
	for i = 0, 15, 1 do
		local groupInfo = guild.GetGroupInfo(i)
		if groupInfo.bEnable then
			local nWage = guild.GetGroupWageRate(i)
			local nMemberCount = guild.GetGroupMemberCount(i)
			local nTotalMoney = math.floor(GuildSalaryPanel.nSalary * nWage / 100)
			local nAverageMoney = 0
			if nMemberCount > 0 then
				nAverageMoney = math.floor(nTotalMoney / nMemberCount)
			end
			table.insert(aGroup, {szName = groupInfo.szName, nGroup = i, nNumber = nMemberCount, nAverage = nAverageMoney, nTotal = nTotalMoney, nPercetage = nWage})
		end
	end
	GuildSalaryPanel.aGroup = aGroup
end

function GuildSalaryPanel.Update(frame)
	local page = frame:Lookup("Wnd_Salary")
	local handle = page:Lookup("", "")
	frame:Lookup("", "Text_TotalMoney"):SetText(GuildSalaryPanel.nTotalMoney)
	frame:Lookup("", "Text_Salary"):SetText(GuildSalaryPanel.nSalary)
	frame:Lookup("", "Text_Percentage"):SetText(GuildSalaryPanel.nPercentage.."%")
	
	if GuildSalaryPanel.bTongSceneExist then
		frame:Lookup("", "Text_Tip"):Hide()
		page:Lookup("Btn_ReceiveDay"):Enable(true)
	else
		frame:Lookup("", "Text_Tip"):Show()
		page:Lookup("Btn_ReceiveDay"):Enable(false)
	end
	
	if GuildSalaryPanel.bCanMeModifyGroupWage and GuildSalaryPanel.bTongSceneExist then
		page:Lookup("Btn_equally"):Enable(true)
	else
		page:Lookup("Btn_equally"):Enable(false)
	end
	
	local aGroup = GuildSalaryPanel.aGroup
	local i = GuildSalaryPanel.nStartIndex
	for i = 1, 9, 1 do
		local nIndex = GuildSalaryPanel.nStartIndex + i
		local t = aGroup[nIndex]
		if t then
			local hItem = handle:Lookup("Handle_Salary"..i)
			hItem:Show()
			hItem:Lookup("Text_MemberCount"..i):SetText(t.nNumber)
			hItem:Lookup("Text_GuildTitle"..i):SetText(t.szName)
			hItem:Lookup("Text_AverageGold"..i):SetText(t.nAverage)
			hItem:Lookup("Text_SalaryTotalGold"..i):SetText(t.nTotal)
			local edit = page:Lookup("Edit_Percantage"..i)
			edit:Show()
			edit.bDisable = true
			edit:SetText(t.nPercetage)
			edit.bDisable = false
			if GuildSalaryPanel.bCanMeModifyGroupWage and GuildSalaryPanel.bTongSceneExist then
				edit:Enable(true)
			else
				edit:Enable(false)
			end
			edit.nIndex = nIndex
		else
			handle:Lookup("Handle_Salary"..i):Hide()
			page:Lookup("Edit_Percantage"..i):Hide()
		end
	end
	
	GuildSalaryPanel.UpdateSum(frame)
end

function GuildSalaryPanel.UpdateSum(frame)
	local page = frame:Lookup("Wnd_Salary")
	local nPercentage = 0
	local nTotal = 0
	local aGroup = GuildSalaryPanel.aGroup
	for i, v in ipairs(aGroup) do
		nTotal = nTotal + v.nTotal
		nPercentage = nPercentage + v.nPercetage
	end
	
	local text = page:Lookup("CheckBox_Percantage"):Lookup("", "Handle_Percantage1/Text_PercantageTotalMsg")
	text:SetText(nPercentage.."%")
	if nPercentage ~= 100 then
		text:SetFontColor(255, 0, 0)
	else
		text:SetFontColor(255, 255, 255)
	end
	page:Lookup("CheckBox_SalaryTotal"):Lookup("", "Text_STLeft"):SetText(GuildSalaryPanel.nSalary - nTotal)
	
	if GuildSalaryPanel.bCanMeModifyGroupWage then
		page:Lookup("Btn_Sure"):Enable(nPercentage == 100)
		page:Lookup("Btn_ReceiveDay"):Enable(true)
		page:Lookup("Btn_Clear"):Enable(true)
	else
		page:Lookup("Btn_Sure"):Enable(false)
		page:Lookup("Btn_ReceiveDay"):Enable(false)
		page:Lookup("Btn_Clear"):Enable(false)
	end
end

function GuildSalaryPanel.Sort()
	local szType, bDescend = GuildSalaryPanel.szSortType, GuildSalaryPanel.bDescend
	if szType == "name" then
		if bDescend then
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nGroup > b.nGroup end)
		else
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nGroup < b.nGroup end)
		end
	elseif szType == "number" then
		if bDescend then
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nNumber > b.nNumber end)
		else
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nNumber < b.nNumber end)
		end
	elseif szType == "percentage" then
		if bDescend then
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nPercetage > b.nPercetage end)
		else
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nPercetage < b.nPercetage end)
		end
	elseif szType == "total" then
		if bDescend then
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nTotal > b.nTotal end)
		else
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nTotal < b.nTotal end)
		end
	elseif szType == "average" then
		if bDescend then
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nAverage > b.nAverage end)
		else
			table.sort(GuildSalaryPanel.aGroup, function(a, b) return a.nAverage < b.nAverage end)
		end
	end
end

function GuildSalaryPanel.UpdateSortCheckboxShow(frame)
	local page = frame:Lookup("Wnd_Salary")
	local a =
	{
		["name"] = "CheckBox_SName",
		["number"] = "CheckBox_SCount",
		["percentage"] = "CheckBox_Percantage",
		["total"] = "CheckBox_SalaryTotal",
		["average"] = "CheckBox_SAverage",
	}
	for k, v in pairs(a) do
		if GuildSalaryPanel.szSortType ~= k then
			local checkBox = page:Lookup(v)
			checkBox:Check(false)
			GuildSalaryPanel.UpdateSortShow(checkBox)
		else
			local checkBox = page:Lookup(v)
			checkBox:Check(true)
			checkBox.bDescend = GuildSalaryPanel.bDescend
			GuildSalaryPanel.UpdateSortShow(checkBox)
		end
	end
end

function GuildSalaryPanel.UpdateSort(checkBox)
	local page = checkBox:GetParent()
	if page.bDisableSort then
		return
	end
	page.bDisableSort = true
	
	local a =
	{
		["CheckBox_SName"] = "name",
		["CheckBox_SCount"] = "number",
		["CheckBox_Percantage"] = "percentage",
		["CheckBox_SalaryTotal"] = "total",
		["CheckBox_SAverage"] = "average",
	}
	
	local szSortType, bDescend = GuildSalaryPanel.szSortType, GuildSalaryPanel.bDescend
	local szName = checkBox:GetName()
	for k, v in pairs(a) do
		if szName ~= k then
			page:Lookup(k):Check(false)
		else
			local checkBox = page:Lookup(k)
			checkBox:Check(true)
			szSortType = v
			bDescend = checkBox.bDescend
		end
	end
	
	if szSortType ~= GuildSalaryPanel.szSortType or bDescend ~= GuildSalaryPanel.bDescend then
		GuildSalaryPanel.szSortType = szSortType
		GuildSalaryPanel.bDescend = bDescend
		GuildSalaryPanel.Sort()
		GuildSalaryPanel.Update(page:GetRoot())
	end

	page.bDisableSort = false
end

function GuildSalaryPanel.UpdateSortShow(checkBox)
	local handle = checkBox:Lookup("", "")
	if checkBox:IsCheckBoxChecked() then
		if checkBox.bDescend then
			handle:Lookup(0):Show()
			handle:Lookup(1):Hide()
		else
			handle:Lookup(0):Hide()
			handle:Lookup(1):Show()
		end
	else
		handle:Lookup(0):Hide()
		handle:Lookup(1):Hide()
	end
end

function GuildSalaryPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_SName" or szName == "CheckBox_SCount" or szName == "CheckBox_Percantage" or 
		szName == "CheckBox_SalaryTotal" or szName == "CheckBox_SAverage" then
		GuildSalaryPanel.UpdateSortShow(this)
		GuildSalaryPanel.UpdateSort(this)
	end
end

function GuildSalaryPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_SName" or szName == "CheckBox_SCount" or szName == "CheckBox_Percantage" or 
		szName == "CheckBox_SalaryTotal" or szName == "CheckBox_SAverage" then
		GuildSalaryPanel.UpdateSortShow(this)
	end
end

function GuildSalaryPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_SName" or szName == "Handle_SCount" or szName == "Handle_Percantage" or 
		szName == "Handle_SalaryTotal" or szName == "Handle_SAverage" then
		local checkBox = this:GetParent()
		if checkBox:IsCheckBoxChecked() then
			if checkBox.bDescend then
				checkBox.bDescend = false
			else
				checkBox.bDescend = true
			end
			GuildSalaryPanel.UpdateSortShow(checkBox)
			GuildSalaryPanel.UpdateSort(checkBox)
			return 0
		end
	end
end

function GuildSalaryPanel.OnEditChanged()
	if this.nIndex and not this.bDisable then
		local nPercetage = tonumber(this:GetText()) or 0
		local nTotalMoney = math.floor(GuildSalaryPanel.nSalary * nPercetage / 100)
		local nAverageMoney = 0
		if GuildSalaryPanel.aGroup[this.nIndex].nNumber > 0 then
			nAverageMoney = math.floor(nTotalMoney / GuildSalaryPanel.aGroup[this.nIndex].nNumber)
		end

		GuildSalaryPanel.aGroup[this.nIndex].nPercetage = nPercetage
		GuildSalaryPanel.aGroup[this.nIndex].nAverage = nAverageMoney
		GuildSalaryPanel.aGroup[this.nIndex].nTotal = nTotalMoney
		
		local page = this:GetRoot():Lookup("Wnd_Salary")
		
		local i = this.nIndex - GuildSalaryPanel.nStartIndex
		page:Lookup("", "Handle_Salary"..i.."/Text_AverageGold"..i):SetText(nAverageMoney)
		page:Lookup("", "Handle_Salary"..i.."/Text_SalaryTotalGold"..i):SetText(nTotalMoney)
		
		GuildSalaryPanel.UpdateSum(this:GetRoot())
	elseif this:GetName() == "Edit_GiveMoney" then
		GuildSalaryPanel.UpdateGiveBtnState(this:GetRoot())
	end
end

function GuildSalaryPanel.UpdateGiveBtnState(frame)
	local edit = frame:Lookup("Wnd_Salary/Edit_GiveMoney")
	local btn = frame:Lookup("Wnd_Salary/Btn_GiveMoney")
	local nMoney = tonumber(edit:GetText())
	btn:Enable(nMoney and nMoney > 0)
end

function GuildSalaryPanel.UpdateScrollInfo(frame)
	local page = this:GetRoot():Lookup("Wnd_Salary")
	local nCount = #(GuildSalaryPanel.aGroup)
	local nScrollStep = nCount - 9
	if nScrollStep < 0 then
		nScrollStep = 0
	end
	
	page:Lookup("Scroll_Salary"):SetStepCount(nScrollStep)
	if nScrollStep > 0 then
		page:Lookup("Scroll_Salary"):Show()
		page:Lookup("Btn_Up"):Show()
		page:Lookup("Btn_Down"):Show()	
	else
		page:Lookup("Scroll_Salary"):Hide()
		page:Lookup("Btn_Up"):Hide()
		page:Lookup("Btn_Down"):Hide()
	end	
end

function GuildSalaryPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local page = this:GetParent()
	page:Lookup("Btn_Up"):Enable(nCurrentValue ~= 0)
	page:Lookup("Btn_Down"):Enable(nCurrentValue ~= this:GetStepCount())
	GuildSalaryPanel.nStartIndex = nCurrentValue
	GuildSalaryPanel.Update(this:GetRoot())
end

function GuildSalaryPanel.OnLButtonDown()
	if this:GetName() == "Btn_ReceiveDay" then
		if not GuildSalaryPanel.bTongSceneExist then
			return
		end
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end

		local nWeekday = TimeToDate(GetCurrentTime()).weekday
		local hBtn = this
		local text = this:Lookup("", "Text_ReceiveDay")
		local xT, yT = text:GetAbsPos()
		local wT, hT = text:GetSize()
		local menu = 
		{
			nMiniWidth = wT,
			x = xT, y = yT + hT,
			fnCancelAction = function() 
				if hBtn:IsValid() then
					local x, y = Cursor.GetPos()
					local xA, yA = hBtn:GetAbsPos()
					local w, h = hBtn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						hBtn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData)
				local msg =
				{
					szMessage = FormatLinkString(g_tStrings.GUILD_SET_PAY_DAY_SURE,"font=162", 
						g_tStrings.WEEK_DAY[UserData], GetMoneyTipText(10000, 106)),
					bRichText = true,
					szName = "GS_Set_WD_Confirm",
					{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnSetTongPayTime", UserData) end},
					{szOption = g_tStrings.STR_HOTKEY_CANCEL},
				}
				MessageBox(msg)
			end,
			fnAutoClose = function() return not IsGuildSalaryPanelOpened() end,
		}
		for i = 0, 6, 1 do
			table.insert(menu, {szOption = g_tStrings.WEEK_DAY[i], bDisable = i == nWeekday, UserData = i})
		end
		PopupMenu(menu)
		return true
	else
		return GuildSalaryPanel.OnLButtonHold()
	end
end

function GuildSalaryPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_Salary"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_Salary"):ScrollNext(1)
	end
end

function GuildSalaryPanel.OnMouseWheel()
	local szName = this:GetName()
	if szName == "GuildSalaryPanel" then
		local nDistance = Station.GetMessageWheelDelta()
		this:Lookup("Wnd_Salary/Scroll_Salary"):ScrollNext(nDistance)
		return 1
	end
end

function GuildSalaryPanel.IsChangedSalary()
	local guild = GetTongClient()
	local aGroup = GuildSalaryPanel.aGroup
	for i, v in ipairs(aGroup) do
		if v.nPercetage ~= guild.GetGroupWageRate(v.nGroup) then
			return true
		end
	end
	
	return false
end

function GuildSalaryPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		if not GuildSalaryPanel.IsChangedSalary() then
			CloseGuildSalaryPanel()
			return
		end
		
		local result = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		local aGroup = GuildSalaryPanel.aGroup
		for i, v in ipairs(aGroup) do
			result[v.nGroup + 1] = v.nPercetage
		end
		local bChanged = false
		local guild = GetTongClient()
		for i = 0, 15, 1 do
			if guild.GetGroupWageRate(i) ~= result[i + 1] then
				bChanged = true
				break
			end
		end
		
		if bChanged then
			if GuildSalaryPanel.nTotalMoney >= 1000 then
				local msg =
				{
					szMessage = FormatLinkString(g_tStrings.GUILD_CHANGE_PAY_SURE, "font=162", GetMoneyTipText(10000000, 106)),
					bRichText = true,
					szName = "GS_MW_Sure",
					{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnModifyTongWageRate", result) GetTongClient().ApplyTongInfo() CloseGuildSalaryPanel() end},
					{szOption = g_tStrings.STR_HOTKEY_CANCEL},
				}
				MessageBox(msg)		
			else
				local msg =
				{
					szMessage = FormatLinkString(g_tStrings.GUILD_CHANGE_PAY_NOT_ENOUGH_MONEY, "font=162", GetMoneyTipText(10000000, 106)),
					bRichText = true,
					szName = "GS_MW_Sure",
					{szOption = g_tStrings.STR_HOTKEY_SURE},
				}
				MessageBox(msg)			
			end
		end
	elseif szName == "Btn_Clear" then
		local aGroup = GuildSalaryPanel.aGroup
		for i, v in ipairs(aGroup) do
			v.nAverage = 0
			v.nTotal = 0
			v.nPercetage = 0
		end
		GuildSalaryPanel.Update(this:GetRoot())
	elseif szName == "Btn_equally" then
		local nCount = 0
		local aGroup = GuildSalaryPanel.aGroup
		for i, v in ipairs(aGroup) do
			nCount = nCount + v.nNumber
		end
		if nCount > 0 then
			local fAverage = 100 / nCount;
			for i, v in ipairs(aGroup) do
				v.nPercetage = math.floor(v.nNumber * fAverage)
				v.nTotal = math.floor(GuildSalaryPanel.nSalary * v.nPercetage / 100)
				if v.nNumber > 0 then
					v.nAverage = math.floor(v.nTotal / v.nNumber)
				else
					v.nAverage = 0
				end
			end	
			GuildSalaryPanel.Update(this:GetRoot())
		end
	elseif szName == "Btn_Cancel" or szName == "Btn_Close" then
		CloseGuildSalaryPanel()
	elseif szName == "Btn_GiveMoney" then
		if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TONG_DONATE, "msg") then
			return
		end
				
	    local nHave = GetClientPlayer().GetMoney()
	    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nHave)
	    local nMoney = tonumber(this:GetParent():Lookup("Edit_GiveMoney"):GetText())
	    if nMoney > nGold then
			local msg =
			{
				szMessage = g_tStrings.GUILD_GIVE_NOT_ENOUGH_MONEY,
				szName = "GS_GiveMoney_Fail",
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
			MessageBox(msg)
		else
			local nMoney = GoldSilverAndCopperToMoney(nMoney, 0, 0)
			local msg =
			{
				szMessage = FormatLinkString(g_tStrings.GUILD_SET_GIVE_SURE, "font=162", GetMoneyTipText(nMoney, 106)), 
				bRichText = true,
				szName = "GS_GiveMoney_Sure",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() 
					if nMoney > GetClientPlayer().GetMoney() then
						local msg =
						{
							szMessage = g_tStrings.GUILD_GIVE_NOT_ENOUGH_MONEY,
							szName = "GS_GiveMoney_Fail",
							{szOption = g_tStrings.STR_HOTKEY_SURE},
						}
						MessageBox(msg)
					else
						GetTongClient().SaveMoney(nMoney) 
						GetTongClient().ApplyTongInfo() 
					end
					end},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
	    end
	end
end

function OpenGuildSalaryPanel(bDisableSound)
	Wnd.OpenWindow("GuildSalaryPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsGuildSalaryPanelOpened()
	local frame = Station.Lookup("Normal/GuildSalaryPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseGuildSalaryPanel(bDisableSound)
	Wnd.CloseWindow("GuildSalaryPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end


