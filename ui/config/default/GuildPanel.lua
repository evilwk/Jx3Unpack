INI_PATH = "ui/Config/Default/GuildPanel.ini"

local tTongActivityBtn = 
{
	["Btn_Arena"] = {{2}},
	["Btn_Salary"] = {{3}},
    ["Btn_Zhujiujie"] = {{5}},
    ["Btn_StartPigRun"] = {{8}},
}

GuildPanel =
{
	bShowOffLine = false,
	szMemberSort = "level",
	bMemberSortDescend = false,
	bGuildState = false,
	nSchoolFilter = -1,
	nGroupFilter = -1,
	szMemorabiliaSort = "time",
	bMemorabiliaSortDescend = false,
}

RegisterCustomData("GuildPanel.bShowOffLine")

function GuildPanel.OnFrameCreate()
	this:RegisterEvent("UPDATE_TONG_INFO")
	this:RegisterEvent("UPDATE_TONG_ROSTER")
	this:RegisterEvent("GUILD_PANEL_SORT_CHANGED")
	this:RegisterEvent("GUILD_PANEL_MSG_SORT_CHANGED")
	this:RegisterEvent("TONG_EVENT_NOTIFY")
	this:RegisterEvent("CHANGE_TONG_NOTIFY")
	this:RegisterEvent("CONTRIBUTION_UPDATE")
	this:RegisterEvent("TONG_CAMP_CHANGE")
	this:RegisterEvent("TONG_STATE_CHANGE")
	this:RegisterEvent("UPDATE_TONG_ROSTER_FINISH")
	this:RegisterEvent("UPDATE_TONG_INFO_FINISH")
	this:RegisterEvent("SYNC_TONG_HISTORY")
	this:RegisterEvent("ON_GET_TONG_WEEKLY_POINT")
	this:RegisterEvent("UPDATE_TONG_DIPLOMACY_INFO")
	this:RegisterEvent("UPDATE_TONG_SIMPLE_INFO")
    this:RegisterEvent("TONG_MASTER_CHANGE_START")
    
	GuildPanel.Init(this)
	GuildDiplomacy.OnCreate(this)
    
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseGuildPanel(true) end)
end

function GuildPanel.OnFrameBreathe()
	GuildDiplomacy.OnFrameBreathe()
end

function GuildPanel.OnEvent(event)
	GuildDiplomacy.OnEvent(event)
    if event == "TONG_MASTER_CHANGE_START" then
        local player = GetClientPlayer()
		local guild = GetTongClient()

		if not player or not guild then
			return
		end

		if guild.dwMaster == player.dwID then -- 是帮主，而且帮会名字不合法
            local tMsg =
            {
                szMessage = g_tStrings.STR_GUILD_CHANGE_MASTER_START_SUCCESS,
                szName = "tong_master_change_start_success",
                {szOption = g_tStrings.STR_HOTKEY_SURE},
            }
            MessageBox(tMsg)
		end
	elseif event == "UPDATE_TONG_INFO_FINISH" then 
		GuildPanel.UpdateMemberList(this)
		GuildPanel.UpdateBasicInfo(this)
		GuildPanel.UpdateGroupList(this)
		GuildPanel.UpdateMemorabilia(this)
		GuildPanel.UpdateMainPageInfo(this)

		local player = GetClientPlayer()
		local guild = GetTongClient()

		if not player or not guild then
			return
		end

		if guild.dwMaster == player.dwID and StringFindW(guild.szTongName, "@") then -- 是帮主，而且帮会名字不合法
			OpenGuildRename(bDisableSound)
		end
	elseif event == "UPDATE_TONG_ROSTER_FINISH" then
		GuildPanel.UpdateMemberList(this)
		GuildPanel.UpdateBasicInfo(this)
		GuildPanel.UpdateGroupList(this)
		GuildPanel.UpdateMemorabilia(this)
		GuildPanel.UpdateMainPageInfo(this)
	elseif event == "GUILD_PANEL_SORT_CHANGED" then
		GuildPanel.UpdateMemberList(this)
		GuildPanel.UpdateMemberSortCheckboxShow(this)
		GuildPanel.UpdateMemberFilterShow(this)
	elseif event == "GUILD_PANEL_MSG_SORT_CHANGED" then
		GuildPanel.UpdateMemorabiliaSortCheckBoxShow(this)
		GuildPanel.UpdateMemorabilia(this)
	elseif event == "TONG_STATE_CHANGE" then
		GetTongClient().ApplyTongInfo()
	elseif event == "TONG_EVENT_NOTIFY" then
		if not IsGuildPanelOpened() then
			return
		end
		local guild = GetTongClient()
		if arg0 == TONG_EVENT_CODE.INVITE_SUCCESS or arg0 == TONG_EVENT_CODE.KICK_OUT_SUCCESS or
			arg0 == TONG_EVENT_CODE.CHANGE_MEMBER_REMARK_SUCCESS or arg0 == TONG_EVENT_CODE.CHANGE_MEMBER_GROUP_SUCCESS then
			guild.ApplyTongRoster()
		elseif arg0 == TONG_EVENT_CODE.MODIFY_ANNOUNCEMENT_SUCCESS or
			arg0 == TONG_EVENT_CODE.MODIFY_ONLINE_MESSAGE_SUCCESS or arg0 == TONG_EVENT_CODE.MODIFY_INTRODUCTION_SUCCESS or
			arg0 == TONG_EVENT_CODE.MODIFY_RULES_SUCCESS or arg0 == TONG_EVENT_CODE.MODIFY_GROUP_NAME_SUCCESS or
			arg0 == TONG_EVENT_CODE.MODIFY_BASE_OPERATION_MASK_SUCCESS or arg0 == TONG_EVENT_CODE.MODIFY_ADVANCE_OPERATION_MASK_SUCCESS or
			arg0 == TONG_EVENT_CODE.MODIFY_GROUP_WAGE_SUCCESS or arg0 == TONG_EVENT_CODE.MODIFY_MEMORABILIA_SUCCESS or
			arg0 == TONG_EVENT_CODE.SAVE_MONEY_SUCCESS or arg0 == TONG_EVENT_CODE.CHANGE_MASTER_SUCCESS then
			guild.ApplyTongInfo()
		elseif arg0 == TONG_EVENT_CODE.MODIFY_GROUP_NAME_NO_PERMISSION_ERROR or arg0 == TONG_EVENT_CODE.MODIFY_BASE_OPERATION_MASK_NO_PERMISSION_ERROR or
			arg0 == TONG_EVENT_CODE.MODIFY_ADVANCE_OPERATION_MASK_NO_PERMISSION_ERROR or arg0 == TONG_EVENT_CODE.MODIFY_GROUP_WAGE_NO_PERMISSION_ERROR then
			GuildPanel.UpdateGroupList(this)
		elseif arg0 == TONG_EVENT_CODE.CHANGE_MEMBER_REMARK_ERROR or arg0 == TONG_EVENT_CODE.CHANGE_MEMBER_GROUP_ERROR then
			GuildPanel.UpdateMemberList(this)
		elseif arg0 == TONG_EVENT_CODE.RENAME_SUCCESS or
		 	arg0 == TONG_EVENT_CODE.RENAME_NO_RIGHT_ERROR or arg0 == TONG_EVENT_CODE.RENAME_UNNECESSARY_ERROR or
			arg0 == TONG_EVENT_CODE.RENAME_CONFLICT_ERROR or arg0 == TONG_EVENT_CODE.RENAME_ILLEGAL_ERROR then
			GuildPanel.HandleRenameResult(arg0)
		end
		GuildPanel.UpdateMainPageInfo(this)
	elseif event == "CONTRIBUTION_UPDATE" then
		GuildPanel.UpdateMainPageInfo(this)
		
		local pageSet = this:Lookup("PageSet_Total")
		local page = pageSet:Lookup("Page_Basic")
		if pageSet:GetActivePage() == page and this:IsVisible() then
			local handle = page:Lookup("", "Handle_Information")
			local hMyContribution = handle:Lookup("Handle_MyContribution")
			local imgCPercentage = hMyContribution:Lookup("Image_MyContributionP")
			FireHelpEvent("OnCommentToKnowGuild", imgCPercentage, 2)
		end
		
	elseif event == "TONG_CAMP_CHANGE" then
		GuildPanel.UpdateBasicInfo(this)
	elseif event == "CHANGE_TONG_NOTIFY" then
		if arg1 == TONG_CHANGE_REASON.DISBAND or arg1 == TONG_CHANGE_REASON.QUIT or arg1 == TONG_CHANGE_REASON.FIRED then
			CloseGuildPanel()
		end
	elseif event == "SYNC_TONG_HISTORY" then	
		GuildPanel.UpdateHistory(this, arg0, arg1, arg2)
	elseif event == "ON_GET_TONG_WEEKLY_POINT" then
		GuildPanel.nWeeklyPoint = arg0
		GuildPanel.UpdateMainPageInfo(this)
	end
end

function IsArrow(nType, itemInfo)
    return nType == ITEM_INFO_TYPE.CUSTEQUIP_INFO and itemInfo.nSub == EQUIPMENT_SUB.ARROW
end

function GuildPanel.UpdateMainPageInfo(frame)
	local handle = frame:Lookup("PageSet_Total/Page_Basic", "Handle_Information")
	local player = GetClientPlayer()
	local guild = GetTongClient()
	handle:Lookup("Handle_Assets/Image_AssetsP"):SetPercentage(guild.nFund / 1000000)
	handle:Lookup("Handle_Assets/Text_StraminaExp"):SetText(guild.nFund.. "/1000000")
	
	local hI = handle:Lookup("Handle_Development")
	local imgP = hI:Lookup("Image_DevelopmentP")
	imgP:SetPercentage(guild.nDevelopmentPoint / 70000)
	local x, y = imgP:GetRelPos()
	local w, h = imgP:GetSize()
	local img = hI:Lookup("Image_Limit")
	local wImg, hImg = img:GetSize()
	local nWeeklyPoint = GuildPanel.nWeeklyPoint or 0
	local nTotal = guild.nDevelopmentPoint + nWeeklyPoint
	if guild.nDevelopmentPoint + nWeeklyPoint > 70000 then
		nTotal = 70000
	end
	hI:Lookup("Image_Limit"):SetRelPos(x + w * (nTotal / 70000) - wImg / 2, y)
	hI:Lookup("Text_DevelopmentExp"):SetText(guild.nDevelopmentPoint.. "/70000")
	hI:FormatAllItemPos()

	local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
	local nMaxContribution = levelUp['MaxContribution'] or 0
	local nLimitContribution = player.GetContributionRemainSpace()
    
	local hMyContribution = handle:Lookup("Handle_MyContribution")
	local imgCPercentage = hMyContribution:Lookup("Image_MyContributionP")
	local imgCLimit = hMyContribution:Lookup("Image_MyContributionLimit")
    
	local cx, cy = imgCPercentage:GetRelPos()
	local cax, cay = imgCPercentage:GetAbsPos()
	local cw, ch = imgCPercentage:GetSize()
	local wCImg, hCImg = imgCLimit:GetSize()
	local nCTotal = player.nContribution + nLimitContribution
    
	nCTotal = math.min(nCTotal, nMaxContribution);
	imgCLimit:SetRelPos(cx + cw * (nCTotal / nMaxContribution) - wCImg / 2, cy)
	imgCLimit:SetAbsPos(cax + cw * (nCTotal / nMaxContribution) - wCImg / 2, cay)
                
	imgCPercentage:SetPercentage(player.nContribution / nMaxContribution)
	hMyContribution:Lookup("Text_MyContributionExp"):SetText(player.nContribution.."/"..nMaxContribution)
	
	imgCPercentage.OnItemLButtonClick=function()
		local szLinkInfo = MainMessageLine.GetCurrencyLinkInfo(g_tStrings.STR_CURRENT_CONTRIBUTION)
        if szLinkInfo and szLinkInfo ~= "" then
            FireUIEvent("EVENT_LINK_NOTIFY", szLinkInfo)
		end
	end
end

function GuildPanel.UpdateHistory(frame, nType, nStartIndex, nCount)
	local page = frame:Lookup("PageSet_Total/Page_Secret")
	if nType == TONG_HISTORY_TYPE.DONATE_FUND then
		local w = page:Lookup("Wnd_Money")
		if w:IsVisible() and w:Lookup("CheckBox_MUser"):IsCheckBoxChecked() then
			local h = w:Lookup("", "Handle_MLogContent")
			if nStartIndex == 0 then
				h:Clear()
			end
			local guid = GetTongClient()
			for i = nStartIndex, nStartIndex + nCount - 1, 1 do
				local t = guid.GetHistoryRecord(nType, i)
				if t then
					local aInfo = guid.GetMemberInfo(t.dwPlayer)
					local szName = g_tStrings.GUILD_UNKNOWN_MENBER
					if aInfo then
						szName = aInfo.szName
					end
					szName = MakeNameLink("["..szName.."]", "font=164")
					local time = TimeToDate(t.nTime)
					local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
					
					local szMsg = ""
					if t.nMoney >= 0 then
						local szMoney = GetGoldText(t.nMoney, 106)
						szMsg = FormatLinkString(g_tStrings.GUILD_ADD_FUND, "font=162", szTime, szName, szMoney)
					else
						local szMoney = GetGoldText(-t.nMoney, 106)
						szMsg = FormatLinkString(g_tStrings.GUILD_TAKE_FUND, "font=162", szTime, szName, szMoney)
					end
					h:AppendItemFromString(szMsg)
				end
			end
			GuildPanel.UpdateScrollInfo(h)
		end
	elseif nType == TONG_HISTORY_TYPE.SYSTEM_CHANGE_FUND then
		local w = page:Lookup("Wnd_Money")
		if w:IsVisible() and w:Lookup("CheckBox_MSystem"):IsCheckBoxChecked() then
			local h = w:Lookup("", "Handle_MLogContent")
			if nStartIndex == 0 then
				h:Clear()
			end
			local guid = GetTongClient()
			for i = nStartIndex, nStartIndex + nCount - 1, 1 do
				local t = guid.GetHistoryRecord(nType, i)
				if t then			
					local szEvent = GetFormatText(g_tStrings.GUILD_EVENT_TYPE[t.wType], 163)

					local time = TimeToDate(t.nTime)
					local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
				
					local szMsg = ""
					if t.nMoney >= 0 then
						local szMoney = GetMoneyTipText(GoldSilverAndCopperToMoney(t.nMoney, 0,0), 106)
						szMsg = FormatLinkString(g_tStrings.GUILD_SYS_ADD_FUND, "font=162", szTime, szEvent, szMoney)
					else
						local szMoney = GetMoneyTipText(GoldSilverAndCopperToMoney(-t.nMoney,0,0), 106)
						szMsg = FormatLinkString(g_tStrings.GUILD_SYS_TAKE_FUND, "font=162", szTime, szEvent, szMoney)
					end
					h:AppendItemFromString(szMsg)			
				end
			end
			GuildPanel.UpdateScrollInfo(h)
		end
	elseif nType == TONG_HISTORY_TYPE.ITEM_CHANGE then
		local w = page:Lookup("Wnd_Goods")
		if w:IsVisible() and w:Lookup("CheckBox_GUser"):IsCheckBoxChecked() then
			local h = w:Lookup("", "Handle_GLogContent")
			if nStartIndex == 0 then
				h:Clear()
			end
			local guid = GetTongClient()
			for i = nStartIndex, nStartIndex + nCount - 1, 1 do
				local t = guid.GetHistoryRecord(nType, i)
				if t then
					local aInfo = guid.GetMemberInfo(t.dwPlayer)
					local szName = g_tStrings.GUILD_UNKNOWN_MENBER
					if aInfo then
						szName = aInfo.szName
					end
					szName = MakeNameLink("["..szName.."]", "font=164")
					
					local itemInfo, nType = GetItemInfo(t.nItemType, t.nItemIndex)
					if itemInfo then
						local szItemName = GetItemNameByItemInfo(itemInfo, t.nStackNum)
						local szColor = GetItemFontColorByQuality(itemInfo.nQuality, true)
						local szItem = ""
						if itemInfo.nGenre == ITEM_GENRE.BOOK then
							szItem = MakeBookLink("["..szItemName.."]", "font=164 "..szColor, 0, t.nItemType, t.nItemIndex, t.nStackNum)	
						else
							szItem = MakeItemInfoLink("["..szItemName.."]", "font=164 "..szColor, 0, t.nItemType, t.nItemIndex)	
						end
						if not IsArrow(nType, itemInfo) and not itemInfo.bCanStack then
							t.nStackNum = 1
						end

						local time = TimeToDate(t.nTime)
						local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
	
						local szMsg = ""
						if t.bTake then
							szMsg = FormatLinkString(g_tStrings.GUILD_TAKE_ITEM, "font=162", szTime, szName, szItem, t.nStackNum)
						else
							szMsg = FormatLinkString(g_tStrings.GUILD_ADD_ITEM, "font=162", szTime, szName, szItem, t.nStackNum)
						end
						
						h:AppendItemFromString(szMsg)
					end					
				end
			end
			GuildPanel.UpdateScrollInfo(h)
		end
	elseif nType == TONG_HISTORY_TYPE.SYSTEM_ITEM_CHANGE then
		local w = page:Lookup("Wnd_Goods")
		if w:IsVisible() and w:Lookup("CheckBox_GSystem"):IsCheckBoxChecked() then
			local h = w:Lookup("", "Handle_GLogContent")
			if nStartIndex == 0 then
				h:Clear()
			end
			local guid = GetTongClient()
			for i = nStartIndex, nStartIndex + nCount - 1, 1 do
				local t = guid.GetHistoryRecord(nType, i)
				if t then
					local itemInfo = GetItemInfo(t.nItemType, t.nItemIndex)
					if itemInfo then
						local szItemName = GetItemNameByItemInfo(itemInfo, t.nStackNum)
						local szColor = GetItemFontColorByQuality(itemInfo.nQuality, true)
						local szItem = ""
						if itemInfo.nGenre == ITEM_GENRE.BOOK then
							szItem = MakeBookLink("["..szItemName.."]", "font=164 "..szColor, 0, t.nItemType, t.nItemIndex, t.nStackNum)
						else
							szItem = MakeItemInfoLink("["..szItemName.."]", "font=164 "..szColor, 0, t.nItemType, t.nItemIndex)	
						end
						if not IsArrow(nType, itemInfo) and not itemInfo.bCanStack then
							t.nStackNum = 1
						end					
						
						local time = TimeToDate(t.nTime)
						local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
			
						local szEvent = GetFormatText(g_tStrings.GUILD_EVENT_TYPE[t.wType], 163)
			
						local szMsg = ""
						if t.bAdd then
							szMsg = FormatLinkString(g_tStrings.GUILD_SYS_ADD_ITEM, "font=162", szTime, szEvent, szItem, t.nStackNum)
						else
							szMsg = FormatLinkString(g_tStrings.GUILD_SYS_TAKE_ITEM, "font=162", szTime, szEvent, szItem, t.nStackNum)
						end
						
						h:AppendItemFromString(szMsg)
					end					
				end
			end
			GuildPanel.UpdateScrollInfo(h)
		end	
	elseif nType == TONG_HISTORY_TYPE.ADD_DEVELOPMENT_POINT then
		local w = page:Lookup("Wnd_Dep")
		if w:IsVisible() and w:Lookup("CheckBox_DUser"):IsCheckBoxChecked() then
			local h = w:Lookup("", "Handle_DLogContent")
			if nStartIndex == 0 then
				h:Clear()
			end
			local guid = GetTongClient()
			for i = nStartIndex, nStartIndex + nCount - 1, 1 do
				local t = guid.GetHistoryRecord(nType, i)
				if t then
					local aInfo = guid.GetMemberInfo(t.dwPlayer)
					local szName = g_tStrings.GUILD_UNKNOWN_MENBER
					if aInfo then
						szName = aInfo.szName
					end
					szName = MakeNameLink("["..szName.."]", "font=164")
					
					local time = TimeToDate(t.nTime)
					local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
		
					local szMsg = ""
					if t.nAddPoint >= 0 then
						szMsg = FormatLinkString(g_tStrings.GUILD_ADD_POINT, "font=162", szTime, szName, t.nAddPoint)
					else
						szMsg = FormatLinkString(g_tStrings.GUILD_TAKE_POINT, "font=162", szTime, szName, -t.nAddPoint)
					end
					h:AppendItemFromString(szMsg)			
				end
			end
			GuildPanel.UpdateScrollInfo(h)
		end	
	elseif nType == TONG_HISTORY_TYPE.SYSTEM_CHANGE_DEVELOPMENT_POINT then
		local w = page:Lookup("Wnd_Dep")
		if w:IsVisible() and w:Lookup("CheckBox_DSystem"):IsCheckBoxChecked() then
			local h = w:Lookup("", "Handle_DLogContent")
			if nStartIndex == 0 then
				h:Clear()
			end
			local guid = GetTongClient()
			for i = nStartIndex, nStartIndex + nCount - 1, 1 do
				local t = guid.GetHistoryRecord(nType, i)
				if t then
					local szEvent = GetFormatText(g_tStrings.GUILD_EVENT_TYPE[t.wType], 163)
					
					local time = TimeToDate(t.nTime)
					local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
		
					local szMsg = ""
					if t.nAddPoint >= 0 then
						szMsg = FormatLinkString(g_tStrings.GUILD_SYS_ADD_POINT, "font=162", szTime, szEvent, t.nAddPoint)
					else
						szMsg = FormatLinkString(g_tStrings.GUILD_SYS_TAKE_POINT, "font=162", szTime, szEvent, -t.nAddPoint)
					end
					h:AppendItemFromString(szMsg)
				end
			end
			GuildPanel.UpdateScrollInfo(h)
		end
	end
end

function GuildPanel.OnEventNotify(event)
	if event == "TONG_EVENT_NOTIFY" then
		local v = g_tStrings.STR_GUILD_ERROR[arg0]
		if v and v[1] ~= "" then
			if arg1 and arg1 ~= "" then
				local szFont = GetMsgFontString(v[2])
				OutputMessage(v[2], FormatLinkString(v[1], szFont, MakeNameLink("["..arg1.."]", szFont)), true)
			else
				OutputMessage(v[2], v[1])
			end
		end
		if arg0 == TONG_EVENT_CODE.MODIFY_ONLINE_MESSAGE_SUCCESS and GuildPanel.szOnlineMessage then
			GetClientPlayer().Talk(PLAYER_TALK_CHANNEL.TONG, "", {{type = "text", text = g_tStrings.STR_GUILD_ONLINE_MSG_C..GuildPanel.szOnlineMessage}})
			GuildPanel.szOnlineMessage = nil
		elseif arg0 == TONG_EVENT_CODE.MODIFY_ANNOUNCEMENT_SUCCESS and GuildPanel.szAnnouncement then
			GetClientPlayer().Talk(PLAYER_TALK_CHANNEL.TONG, "", {{type = "text", text = g_tStrings.STR_GUILD_ANNOUNCE_C..GuildPanel.szAnnouncement}})
			GuildPanel.szAnnouncement = nil
		elseif arg0 == TONG_EVENT_CODE.MODIFY_INTRODUCTION_SUCCESS and GuildPanel.szIntroduction then
			GetClientPlayer().Talk(PLAYER_TALK_CHANNEL.TONG, "", {{type = "text", text = g_tStrings.STR_GUILD_INTRODUCTION_C..GuildPanel.szIntroduction}})
			GuildPanel.szIntroduction = nil
		elseif arg0 == TONG_EVENT_CODE.MODIFY_RULES_SUCCESS and GuildPanel.szRules then
			GetClientPlayer().Talk(PLAYER_TALK_CHANNEL.TONG, "", {{type = "text", text = g_tStrings.STR_GUILD_RULE_C..GuildPanel.szRules}})
			GuildPanel.szRules = nil
		end
	end
end

function GuildPanel.Init(frame)
	GuildPanel.UpdateAddOnPanelShow(frame)

	local pageSet = frame:Lookup("PageSet_Total")
	local pageBasic = pageSet:Lookup("Page_Basic")
	GuildPanel.UpdateScrollInfo(pageBasic:Lookup("", "Handle_ListBasic"))

	local pageNotice = pageBasic:Lookup("PageSet_Info/Page_Notice")
	GuildPanel.UpdateScrollInfo(pageNotice:Lookup("", "Handle_NoticeCotent"))
	GuildPanel.UpdateNoticeState(pageNotice)

	local pageTips = pageBasic:Lookup("PageSet_Info/Page_Tips")
	GuildPanel.UpdateScrollInfo(pageTips:Lookup("", "Handle_TipsCotent"))
	GuildPanel.UpdateTipState(pageTips)

	local pageSecret = pageSet:Lookup("Page_Secret")
	GuildPanel.UpdateScrollInfo(pageSecret:Lookup("Wnd_Big", "Handle_ListBig"))
	GuildPanel.SelectPage(pageSecret:Lookup("", "Handle_List"):Lookup(0))

	GuildPanel.UpdateMemberSortCheckboxShow(frame)

	local pageManage = pageSet:Lookup("Page_Manage")
	GuildPanel.UpdateScrollInfo(pageManage:Lookup("", "Handle_MList"))
	GuildPanel.UpdateAccessPage(pageManage:Lookup("CheckBox_BasicM"))
end

function GuildPanel.Update(frame)
	local guild = GetTongClient()
	guild.ApplyTongInfo()
	guild.ApplyTongRoster()
	
	local page = frame:Lookup("PageSet_Total/Page_Secret")
	if page:IsVisible() then
		local w = page:Lookup("Wnd_Money")
		if w:IsVisible() then
			if w:Lookup("CheckBox_MUser"):IsCheckBoxChecked() then
				guild.SyncHistory(TONG_HISTORY_TYPE.DONATE_FUND)
			end
			
			if w:Lookup("CheckBox_MSystem"):IsCheckBoxChecked() then
				guild.SyncHistory(TONG_HISTORY_TYPE.SYSTEM_CHANGE_FUND)
			end
		end
		
		w = page:Lookup("Wnd_Goods")
		if w:IsVisible() then
			if w:Lookup("CheckBox_GUser"):IsCheckBoxChecked() then
				guild.SyncHistory(TONG_HISTORY_TYPE.ITEM_CHANGE)
			end
			
			if w:Lookup("CheckBox_GSystem"):IsCheckBoxChecked() then
				guild.SyncHistory(TONG_HISTORY_TYPE.SYSTEM_ITEM_CHANGE)
			end
		end

		w = page:Lookup("Wnd_Dep")
		if w:IsVisible() then
			if w:Lookup("CheckBox_DUser"):IsCheckBoxChecked() then
				guild.SyncHistory(TONG_HISTORY_TYPE.ADD_DEVELOPMENT_POINT)
			end
			
			if w:Lookup("CheckBox_DSystem"):IsCheckBoxChecked() then
				guild.SyncHistory(TONG_HISTORY_TYPE.SYSTEM_CHANGE_DEVELOPMENT_POINT)
			end
		end
	end
	
	GuildPanel.UpdateGroupList(frame)
	GuildPanel.UpdateMemberList(frame)
	GuildPanel.UpdateBasicInfo(frame)
	GuildPanel.UpdateMemorabilia(frame)
	RemoteCallToServer("On_Tong_GetWeeklyPointRemain")
end

function GuildPanel.GetMemorabilia()
	local guild = GetTongClient()
	local t = guild.GetMemorabilia() or {}
	if GuildPanel.szMemorabiliaSort == "message" then
		if GuildPanel.bMemorabiliaSortDescend then
			table.sort(t, function(a, b) return a.szDescription < b.szDescription end)
		else
			table.sort(t, function(a, b) return a.szDescription > b.szDescription end)
		end
	else
		if GuildPanel.bMemorabiliaSortDescend then
			table.sort(t, function(a, b) return a.nTime < b.nTime end)
		else
			table.sort(t, function(a, b) return a.nTime > b.nTime end)
		end
	end
	return t
end

function GuildPanel.UpdateMemorabilia(frame)
	local page = frame:Lookup("PageSet_Total/Page_Secret/Wnd_Big")
	local hList = page:Lookup("", "Handle_ListBig")
	hList:Clear()

	local t = GuildPanel.GetMemorabilia()

	local szIniFile = "UI/Config/Default/GuildAddPanel.ini"
	for k, v in pairs(t) do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_Msg")
		hI.bMsg = true
		hI.dwID = v.dwID
		hI.nTime = v.nTime
		hI.szText = v.szDescription
		local img = hI:Lookup("Image_Select")
		local textT = hI:Lookup("Text_Time")
		local textM = hI:Lookup("Text_Message")
		local time = TimeToDate(v.nTime)
		textT:SetText(FormatString(g_tStrings.STR_TIME_3, time.year, time.month, time.day))
		textM:SetText(v.szDescription)
		textM:AutoSize()
		local wM, hM = textM:GetSize()
		local wT, hT = textT:GetSize()
		textT:SetText(wT, hM)
		local w, h = hI:GetSize()
		hI:SetSize(w, hM)
		img:SetSize(w, hM)
	end
	GuildPanel.UpdateScrollInfo(hList)

	GuildPanel.SelectMessageByID(page, page.dwID)
end

function GuildPanel.GetLastOnLineTimeText(nTime)
	if nTime == 0 then
		return g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
	end
	local szTime = ""
	local nDelta = GetCurrentTime() - nTime
	if nDelta < 0 then
		nDelta = 0
	end

	local nYear = math.floor(nDelta / (3600 * 24 * 365))
	if nYear > 0 then
		szTime = FormatString(g_tStrings.STR_GUILD_TIME_YEAR_BEFORE, nYear)
	else
		local nD = math.floor(nDelta / (3600 * 24))
		if nD > 0 then
			szTime = FormatString(g_tStrings.STR_GUILD_TIME_DAY_BEFORE, nD)
		else
			local nH = math.floor(nDelta / 3600)
			if nH > 0 then
				szTime = FormatString(g_tStrings.STR_GUILD_TIME_HOUR_BEFORE, nH)
			else
				szTime = g_tStrings.STR_GUILD_TIME_IN_ONE_HOUR
			end
		end
	end
	return szTime
end
function GuildPanel.GetMasterChangeLeaveTime()
    local hTongClient = GetTongClient()
    local szTime = ""
    
    if hTongClient.dwNextMaster > 0 then
        szTime = ""
		local nDelta = hTongClient.nChangeMasterTime - GetCurrentTime()
		if nDelta < 0 then
			nDelta = 0
		end
		local nD = math.floor(nDelta / (3600 * 24))
		if nD > 0 then
			local nL = math.floor((nDelta % (3600 * 24)) / 3600)
			szTime = FormatString(g_tStrings.STR_GUILD_TIME_DAY_LATER, nD, nL)
		else
			local nH = math.floor(nDelta / 3600)
			if nH > 0 then
				szTime = FormatString(g_tStrings.STR_GUILD_TIME_HOUR_LATER, nH)
			else
				szTime = g_tStrings.STR_GUILD_TIME_IN_ONE_HOUR
			end
		end
     end
    return szTime
end

function GuildPanel.UpdateBasicInfo(frame)
	local guild = GetTongClient()
	local player = GetClientPlayer()
	local TimeNow = GetCurrentTime()

	local hTotal = frame:Lookup("", "")
	hTotal:Lookup("Text_Title"):SetText(guild.szTongName)
	local imgN = hTotal:Lookup("Image_Neutral")
	local imgG = hTotal:Lookup("Image_Good")
	local imgE = hTotal:Lookup("Image_Evil")
	local textC = hTotal:Lookup("Text_GCamp")
	textC:SetText(FormatString(g_tStrings.STR_GUILD_CAMP_BELONG, g_tStrings.STR_GUILD_CAMP_NAME[guild.nCamp]))
	if guild.nCamp == CAMP.GOOD then
		imgN:Hide()
		imgG:Show()
		imgE:Hide()
	elseif guild.nCamp == CAMP.EVIL then
		imgN:Hide()
		imgG:Hide()
		imgE:Show()
	else
		imgN:Show()
		imgG:Hide()
		imgE:Hide()
	end

	local pageSet = frame:Lookup("PageSet_Total")
	local pageBasic = pageSet:Lookup("Page_Basic")

	local pageNotice = pageBasic:Lookup("PageSet_Info/Page_Notice")
	local hList = pageNotice:Lookup("", "Handle_NoticeCotent")
	hList:Lookup("Text_NoticeCotent"):SetText(guild.szAnnouncement)
	GuildPanel.UpdateScrollInfo(hList)
	pageNotice:Lookup("Edit_Notice"):SetText(guild.szAnnouncement)
	GuildPanel.UpdateNoticeState(pageNotice)

    local hTextTongMasterChange = pageBasic:Lookup("", "Text_TongMasterChange")
	local text = pageBasic:Lookup("", "Text_Warning")
	if guild.nState == TONG_STATE.NORMAL then
		text:SetText("")
	else
		local szTime = ""
		local nDelta = guild.GetStateTimer() - GetCurrentTime()
		if nDelta < 0 then
			nDelta = 0
		end
		local nD = math.floor(nDelta / (3600 * 24))
		if nD > 0 then
			local nL = math.floor((nDelta % (3600 * 24)) / 3600)
			szTime = FormatString(g_tStrings.STR_GUILD_TIME_DAY_LATER, nD, nL)
		else
			local nH = math.floor(nDelta / 3600)
			if nH > 0 then
				szTime = FormatString(g_tStrings.STR_GUILD_TIME_HOUR_LATER, nH)
			else
				szTime = g_tStrings.STR_GUILD_TIME_IN_ONE_HOUR
			end
		end

		local szState = ""
		if guild.nState == TONG_STATE.TRIAL then
			szState = g_tStrings.STR_GUILD_STATE_CREATE
		elseif guild.nState == TONG_STATE.DISBAND then
			szState = g_tStrings.STR_GUILD_STATE_DESTORY
		end
		text:SetText(FormatString(g_tStrings.STR_GUILD_DISBAND_WARING, szState, szTime))
	end

    if guild.dwNextMaster > 0 and guild.nState == TONG_STATE.NORMAL then
        local szTime = GuildPanel.GetMasterChangeLeaveTime()
        local szNextMaster = guild.GetMemberInfo(guild.dwNextMaster).szName
        local szText = FormatString(g_tStrings.STR_GUILD_CHANGE_MASTER_ING, szTime, szNextMaster)
        hTextTongMasterChange:SetText(szText)
    else
        hTextTongMasterChange:SetText("")
    end
	local info = guild.GetMemberInfo(player.dwID)
	if info then
		--pageBasic:Lookup("Btn_Add"):Enable(guild.CanAdvanceOperate(info.nGroupID, guild.GetDefaultGroupID(), TONG_OPERATION_INDEX.ADD_TO_GROUP))
		pageBasic:Lookup("Btn_Add"):Enable(true)
		pageBasic:Lookup("Btn_Leave"):Enable(info.nGroupID ~= guild.GetMasterGroupID())
	end

	local nTotal, nOnline = guild.GetMemberCount()
	pageBasic:Lookup("", "Text_Members"):SetText(FormatString(g_tStrings.STR_GUILD_MEMBER_INFO, nTotal, nOnline))

	local pageTips = pageBasic:Lookup("PageSet_Info/Page_Tips")
	hList = pageTips:Lookup("", "Handle_TipsCotent")
	hList:Lookup("Text_TipsCotent"):SetText(guild.szOnlineMessage)
	GuildPanel.UpdateScrollInfo(hList)
	pageTips:Lookup("Edit_Tips"):SetText(guild.szOnlineMessage)
	GuildPanel.UpdateTipState(pageTips)

	local pageSecret = pageSet:Lookup("Page_Secret")

	local pageSaid = pageSecret:Lookup("Wnd_Said")
	local h = pageSaid:Lookup("", "")

	local info = guild.GetMemberInfo(guild.dwMaster)
	h:Lookup("Text_GuildName"):SetText(FormatString(g_tStrings.STR_GUILD_NAME_1, guild.szTongName))
	h:Lookup("Text_Camp"):SetText(FormatString(g_tStrings.STR_GUILD_CAMP, g_tStrings.STR_GUILD_CAMP_T[guild.nCamp]))

	if info then
        local szText = FormatString(g_tStrings.STR_GUILD_BOSS, info.szName)
        if guild.dwNextMaster > 0 then
            local szTime = GuildPanel.GetMasterChangeLeaveTime()
            local szNextMaster = guild.GetMemberInfo(guild.dwNextMaster).szName
            szText = szText .. FormatString(g_tStrings.STR_GUILD_CHANGE_MASTER_INFO, szTime, szNextMaster)
        end
		h:Lookup("Text_Boss"):SetText(szText)
	end
--	h:Lookup("Text_InstitutionTime"):SetText(FormatString(g_tStrings.STR_GUILD_CREATE_TIME, guild.szTongName))
	h:Lookup("Text_MembersNumber"):SetText(FormatString(g_tStrings.STR_GUILD_NUM_COUNT, nTotal))
	h:Lookup("Text_MaxMNumber"):SetText(FormatString(g_tStrings.STR_GUILD_MAX_NUM_COUNT, guild.nMaxMemberCount))
	h:Lookup("Text_TotalMoney"):SetText(guild.nFund)
	h:Lookup("Text_TotalDep"):SetText(guild.nDevelopmentPoint)

	if guild.nCamp == CAMP.NEUTRAL then
		h:Lookup("Text_CampChange"):SetText(g_tStrings.SIGN_CAMP)
	elseif guild.nCampReverseTime == 0 and guild.nCampReverseCoolDownTime < TimeNow then
		h:Lookup("Text_CampChange"):SetText(g_tStrings.ALLOW_CHANGE_CAMP)
	elseif guild.nCampReverseTime >= TimeNow then
		local nCamp = guild.nCamp
		if nCamp == CAMP.GOOD then
			nCamp = CAMP.EVIL
		elseif nCamp == CAMP.EVIL then
			nCamp = CAMP.GOOD
		end
		local time = TimeToDate(guild.nCampReverseTime)
		local szTime = FormatString(g_tStrings.STR_TIME_4, time.year, time.month, time.day, string.format("%02d",time.hour), string.format("%02d",time.minute))
		h:Lookup("Text_CampChange"):SetText(FormatString(g_tStrings.WILL_CHANGE_CAMP, szTime, g_tStrings.STR_GUILD_CAMP_NAME[nCamp]))
	else
		local time = TimeToDate(guild.nCampReverseCoolDownTime)
		local szTime = FormatString(g_tStrings.STR_TIME_4, time.year, time.month, time.day, string.format("%02d",time.hour), string.format("%02d",time.minute))
		h:Lookup("Text_CampChange"):SetText(FormatString(g_tStrings.ALLOW_CHANGE_CAMP_AGAIN, szTime))
	end

	hList = h:Lookup("Handle_Introduction")
	hList:Lookup("Text_Introduction"):SetText(guild.szIntroduction)
	GuildPanel.UpdateScrollInfo(hList)
	pageSaid:Lookup("Edit_Tell"):SetText(guild.szIntroduction)
	GuildPanel.UpdateIntroduction(pageSaid)

	local pageSystem = pageSecret:Lookup("Wnd_System")
	hList = pageSystem:Lookup("", "Handle_Rule")
	hList:Lookup("Text_Rule"):SetText(guild.szRules)
	GuildPanel.UpdateScrollInfo(hList)
	pageSystem:Lookup("Edit_System"):SetText(guild.szRules)
	GuildPanel.UpdateRules(pageSystem)
	GuildPanel.UpdateMainPageInfo(frame)
end

function GuildPanel.GetMemberSort()
	if GuildPanel.bGuildState then
		local a =
		{
			["name"] = "name",
			["level"] = "group",
			["school"] = "development_contribution",
			["map"] = "join_time",
			["remark"] = "last_offline_time",
		}
		return a[GuildPanel.szMemberSort]
	else
		return GuildPanel.szMemberSort
	end
end

function GuildPanel.UpdateMemberList(frame)
	local page = frame:Lookup("PageSet_Total/Page_Basic")
	local hList = page:Lookup("", "Handle_ListBasic")
	hList:Clear()
	local TimeNow = GetCurrentTime()
	local szIniFile = "UI/Config/Default/GuildAddPanel.ini"

    local guild = GetTongClient()
    local nListHeight = 308
    if guild.dwNextMaster > 0 then
        nListHeight = nListHeight - 20
    end
    hList:SetSize(520, nListHeight)

	if GuildPanel.bGuildState then
		local aPlayer = guild.GetMemberList(GuildPanel.bShowOffLine, GuildPanel.GetMemberSort(), not GuildPanel.bMemberSortDescend, GuildPanel.nGroupFilter, -1)
		for k, v in pairs(aPlayer) do
			local info = guild.GetMemberInfo(v)
			local groupInfo = guild.GetGroupInfo(info.nGroupID)
			local hPlayer = hList:AppendItemFromIni(szIniFile, "Handle_Player", "Member")
			hPlayer.dwID = info.dwID
			local textName = hPlayer:Lookup("Name")
			local textLevel = hPlayer:Lookup("Level")
			local textSchool = hPlayer:Lookup("School")
			local textMap = hPlayer:Lookup("Map")
			local textDesc = hPlayer:Lookup("Desc")

			textName:SetText(info.szName)
			textLevel:SetText(groupInfo.szName)
			textSchool:SetText(info.nDevelopmentContribution)
			local time = TimeToDate(info.nJoinTime)
			textMap:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))
			if info.bIsOnline then
				textDesc:SetText(g_tStrings.STR_GUILD_ONLINE)

				textName:SetFontScheme(18)
				textLevel:SetFontScheme(18)
				textSchool:SetFontScheme(18)
				textMap:SetFontScheme(18)
				textDesc:SetFontScheme(18)
			else
				textDesc:SetText(GuildPanel.GetLastOnLineTimeText(info.nLastOfflineTime))

				textName:SetFontScheme(161)
				textLevel:SetFontScheme(161)
				textSchool:SetFontScheme(161)
				textMap:SetFontScheme(161)
				textDesc:SetFontScheme(161)
			end

			hPlayer.bFresher = TimeNow - info.nJoinTime <= 7 * 24 * 3600
            hPlayer.bMaster = false
			if guild.dwMaster == info.dwID then
				textName:SetFontScheme(27)
				textLevel:SetFontScheme(27)
				textSchool:SetFontScheme(27)
				textMap:SetFontScheme(27)
				textDesc:SetFontScheme(27)
                hPlayer.bMaster = true
			elseif hPlayer.bFresher then
				textName:SetFontScheme(166)
				textLevel:SetFontScheme(166)
				textSchool:SetFontScheme(166)
				textMap:SetFontScheme(166)
				textDesc:SetFontScheme(166)			
			end
            hPlayer.bNextMaster = false
            if guild.dwNextMaster > 0 then
                 if guild.dwNextMaster == info.dwID then
                    hPlayer.bNextMaster = true
                 end
                 if guild.dwMaster == info.dwID or hPlayer.bNextMaster then
                    textName:SetFontScheme(164)
                    textLevel:SetFontScheme(164)
                    textSchool:SetFontScheme(164)
                    textMap:SetFontScheme(164)
                    textDesc:SetFontScheme(164)
                 end
            end
		end
	else
		local aPlayer = guild.GetMemberList(GuildPanel.bShowOffLine, GuildPanel.GetMemberSort(), not GuildPanel.bMemberSortDescend, -1, GuildPanel.nSchoolFilter)
		for k, v in pairs(aPlayer) do
			local info = guild.GetMemberInfo(v)
			local hPlayer = hList:AppendItemFromIni(szIniFile, "Handle_Player", "Member")
			hPlayer.dwID = info.dwID
			local textName = hPlayer:Lookup("Name")
			local textLevel = hPlayer:Lookup("Level")
			local textSchool = hPlayer:Lookup("School")
			local textMap = hPlayer:Lookup("Map")
			local textDesc = hPlayer:Lookup("Desc")

			textName:SetText(info.szName)

			textLevel:SetText(info.nLevel)
			textSchool:SetText(GetForceTitle(info.nForceID))
			textDesc:SetText(info.szRemark)
			if info.bIsOnline then
				local szMap = Table_GetMapName(info.dwMapID)
				textMap:SetText(szMap)

				textName:SetFontScheme(18)
				textLevel:SetFontScheme(18)
				textSchool:SetFontScheme(18)
				textMap:SetFontScheme(18)
				textDesc:SetFontScheme(18)
			else
				textMap:SetText(g_tStrings.STR_GUILD_OFFLINE)

				textName:SetFontScheme(161)
				textLevel:SetFontScheme(161)
				textSchool:SetFontScheme(161)
				textMap:SetFontScheme(161)
				textDesc:SetFontScheme(161)
			end

            hPlayer.bMaster = false
			hPlayer.bFresher = TimeNow - info.nJoinTime <= 7 * 24 * 3600
			if guild.dwMaster == info.dwID then
				textName:SetFontScheme(27)
				textLevel:SetFontScheme(27)
				textSchool:SetFontScheme(27)
				textMap:SetFontScheme(27)
				textDesc:SetFontScheme(27)
                hPlayer.bMaster = true
			elseif hPlayer.bFresher then
				textName:SetFontScheme(166)
				textLevel:SetFontScheme(166)
				textSchool:SetFontScheme(166)
				textMap:SetFontScheme(166)
				textDesc:SetFontScheme(166)			
			end
			
            hPlayer.bNextMaster = false
            if guild.dwNextMaster > 0 then
                 if guild.dwNextMaster == info.dwID then
                    hPlayer.bNextMaster = true
                 end
                 if guild.dwMaster == info.dwID or hPlayer.bNextMaster then
                    textName:SetFontScheme(164)
                    textLevel:SetFontScheme(164)
                    textSchool:SetFontScheme(164)
                    textMap:SetFontScheme(164)
                    textDesc:SetFontScheme(164)
                 end
            end
		end
	end

	GuildPanel.UpdateScrollInfo(hList)
	GuildPanel.SelectMemberByID(page, page.dwID)
end

function GuildPanel.UpdateGroupList(frame)
	local pageManage = frame:Lookup("PageSet_Total/Page_Manage")
	local hList = pageManage:Lookup("", "Handle_MList")
	hList:Clear()

	local szIniFile = "UI/Config/Default/GuildAddPanel.ini"

	local guild = GetTongClient()
	for i = 0, 15, 1 do
		local groupInfo = guild.GetGroupInfo(i)
		if groupInfo.bEnable then
			local hGroup = hList:AppendItemFromIni(szIniFile, "HI_Rank", "Group")
			hGroup.dwGroup = i
			hGroup:Lookup("Text_Rank"):SetText(groupInfo.szName)
		end
	end

	GuildPanel.UpdateScrollInfo(hList)
	GuildPanel.SelectGroupByID(pageManage, pageManage.dwGroup)
end

function GuildPanel.SelectGroupByID(page, dwGroup)
	local hList = page:Lookup("", "Handle_MList")
	local hSel = nil
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwGroup == dwGroup then
			hSel = hI
			break
		end
	end
	if not hSel then
		hSel = hList:Lookup(0)
	end

	if not hSel then
		return
	end

	GuildPanel.SelectGroup(hSel, false)
	if not hSel:IsVisible() then
		local x, y = hSel:GetAbsPos()
		local w, h = hSel:GetSize()
		local xL, yL = hList:GetAbsPos()
		local wL, hL = hList:GetSize()
		if y < yL then
			page:Lookup("Scroll_List"):ScrollPrev(math.ceil((yL - y) / 10))
		elseif y + h > yL + hL then
			page:Lookup("Scroll_List"):ScrollNext(math.ceil((y + h - yL - hL) / 10))
		end
	end
end

function GuildPanel.SelectMemberByID(page, dwID)
	local hList = page:Lookup("", "Handle_ListBasic")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == dwID then
			GuildPanel.SelectMember(hI, false)
			if not hI:IsVisible() then
				local x, y = hI:GetAbsPos()
				local w, h = hI:GetSize()
				local xL, yL = hList:GetAbsPos()
				local wL, hL = hList:GetSize()
				if y < yL then
					page:Lookup("Scroll_List"):ScrollPrev(math.ceil((yL - y) / 10))
				elseif y + h > yL + hL then
					page:Lookup("Scroll_List"):ScrollNext(math.ceil((y + h - yL - hL) / 10))
				end
			end
			return
		end
	end
	page.bSel = false
	page.dwID = nil
	GuildPanel.UpdateAddOnPanelShow(page:GetRoot())
end

function GuildPanel.SelectMessageByID(page, dwID)
	local hList = page:Lookup("", "Handle_ListBig")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == dwID then
			GuildPanel.SelectMessage(hI, false)
			if not hI:IsVisible() then
				local x, y = hI:GetAbsPos()
				local w, h = hI:GetSize()
				local xL, yL = hList:GetAbsPos()
				local wL, hL = hList:GetSize()
				if y < yL then
					page:Lookup("Scroll_ListBig"):ScrollPrev(math.ceil((yL - y) / 10))
				elseif y + h > yL + hL then
					page:Lookup("Scroll_ListBig"):ScrollNext(math.ceil((y + h - yL - hL) / 10))
				end
			end
			return
		end
	end
	page.bSel = false
	page.dwID = nil
	GuildPanel.UpdateMemorabiliaState(page)
end

function GuildPanel.OnActivePage()
	local nLast = this:GetLastActivePageIndex()
	local nPage = this:GetActivePageIndex()
	if nLast ~= -1 and nPage ~= nLast then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end

	if this:GetName() == "PageSet_Total" then
		GuildPanel.UpdateAddOnPanelShow(this:GetRoot())
	end
end

function GuildPanel.UpdateAddOnPanelShow(frame)
	local pageSet = frame:Lookup("PageSet_Total")
	local activePage = pageSet:GetActivePage()

	local pageBasic = pageSet:Lookup("Page_Basic")

	local bShowMemberS = false
	if activePage == pageBasic then
		if activePage.bSel and not activePage.bClose then
			bShowMemberS = true
		end
	end

	local w, h = pageSet:GetSize()
	local wndMembers = frame:Lookup("Wnd_Members")
	if bShowMemberS then
		wndMembers:Show()
		local w1 = wndMembers:GetSize()
		w = w1 + w
	else
		wndMembers:Hide()
	end

	frame:SetSize(w, h)
	CorrectAutoPosFrameAfterClientResize()
end

function GuildPanel.UpdateScrollInfo(hList)
	local scroll, btnUp, btnDown

	local szName = hList:GetName()

	if szName == "Handle_ListBasic" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_List")
		btnUp = page:Lookup("Btn_Up")
		btnDown = page:Lookup("Btn_Down")
	elseif szName == "Handle_NoticeCotent" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_Notice")
		btnUp = page:Lookup("Btn_NoticeUp")
		btnDown = page:Lookup("Btn_NoticeDown")
	elseif szName == "Handle_TipsCotent" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_Tips")
		btnUp = page:Lookup("Btn_TipsUp")
		btnDown = page:Lookup("Btn_TipsDown")
	elseif szName == "Handle_ListBig" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_ListBig")
		btnUp = page:Lookup("Btn_BigUp")
		btnDown = page:Lookup("Btn_BigDown")
	elseif szName == "Handle_Introduction" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_Introduction")
		btnUp = page:Lookup("Btn_IntroductionUp")
		btnDown = page:Lookup("Btn_IntroductionDown")
	elseif szName == "Handle_Rule" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_Rule")
		btnUp = page:Lookup("Btn_RuleUp")
		btnDown = page:Lookup("Btn_RuleDown")
	elseif szName == "Handle_MList" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_MList")
		btnUp = page:Lookup("Btn_MUp")
		btnDown = page:Lookup("Btn_MDown")
	elseif szName == "Handle_MLogContent" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_ListMoney")
		btnUp = page:Lookup("Btn_MoneyUp")
		btnDown = page:Lookup("Btn_MoneyDown")
	elseif szName == "Handle_GLogContent" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_ListGoods")
		btnUp = page:Lookup("Btn_GoodsUp")
		btnDown = page:Lookup("Btn_GoodsDown")
	elseif szName == "Handle_DLogContent" then
		local page = hList:GetParent():GetParent()
		scroll = page:Lookup("Scroll_ListDep")
		btnUp = page:Lookup("Btn_DepUp")
		btnDown = page:Lookup("Btn_DepDown")
	end

	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 and hList:IsVisible() then
    	scroll:Show()
    	btnUp:Show()
    	btnDown:Show()
    else
    	scroll:Hide()
    	btnUp:Hide()
    	btnDown:Hide()
    end
end

function GuildPanel.OnScrollBarPosChanged()
	local szName = this:GetName()
	local page = this:GetParent()
	local hList, btnUp, btnDown
	if szName == "Scroll_List" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_ListBasic"), page:Lookup("Btn_Up"), page:Lookup("Btn_Down")
	elseif szName == "Scroll_Notice" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_NoticeCotent"), page:Lookup("Btn_NoticeUp"), page:Lookup("Btn_NoticeDown")
	elseif szName == "Scroll_Tips" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_TipsCotent"), page:Lookup("Btn_TipsUp"), page:Lookup("Btn_TipsDown")
	elseif szName == "Scroll_ListBig" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_ListBig"), page:Lookup("Btn_BigUp"), page:Lookup("Btn_BigDown")
	elseif szName == "Scroll_Introduction" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_Introduction"), page:Lookup("Btn_IntroductionUp"), page:Lookup("Btn_IntroductionDown")
	elseif szName == "Scroll_Rule" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_Rule"), page:Lookup("Btn_RuleUp"), page:Lookup("Btn_RuleDown")
	elseif szName == "Scroll_MList" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_MList"), page:Lookup("Btn_MUp"), page:Lookup("Btn_MDown")
	elseif szName == "Scroll_ListMoney" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_MLogContent"), page:Lookup("Btn_MoneyUp"), page:Lookup("Btn_MoneyDown")
	elseif szName == "Scroll_ListGoods" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_GLogContent"), page:Lookup("Btn_GoodsUp"), page:Lookup("Btn_GoodsDown")
	elseif szName == "Scroll_ListDep" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_DLogContent"), page:Lookup("Btn_DepUp"), page:Lookup("Btn_DepDown")
	end

	local nCurrentValue = this:GetScrollPos()
	btnUp:Enable(nCurrentValue ~= 0)
	btnDown:Enable(nCurrentValue ~= this:GetStepCount())
    hList:SetItemStartRelPos(0, - nCurrentValue * 10)
end

function GuildPanel.OnMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Page_Basic" then
		this:Lookup("Scroll_List"):ScrollNext(nDistance)
		return 1
	elseif szName == "Page_Notice" then
		this:Lookup("Scroll_Notice"):ScrollNext(nDistance)
		return 1
	elseif szName == "Page_Tips" then
		this:Lookup("Scroll_Tips"):ScrollNext(nDistance)
		return 1
	elseif szName == "Wnd_Said" then
		this:Lookup("Scroll_Introduction"):ScrollNext(nDistance)
		return 1
	elseif szName == "Wnd_System" then
		this:Lookup("Scroll_Rule"):ScrollNext(nDistance)
		return 1
	elseif szName == "Wnd_Big" then
		this:Lookup("Scroll_ListBig"):ScrollNext(nDistance)
		return 1
	elseif szName == "Wnd_Money" then
		this:Lookup("Scroll_ListMoney"):ScrollNext(nDistance)
		return 1	
	elseif szName == "Wnd_Goods" then
		this:Lookup("Scroll_ListGoods"):ScrollNext(nDistance)
		return 1	
	elseif szName == "Wnd_Dep" then
		this:Lookup("Scroll_ListDep"):ScrollNext(nDistance)
		return 1	
	elseif szName == "Page_Manage" then
		this:Lookup("Scroll_MList"):ScrollNext(nDistance)
		return 1
	elseif szName == "GuildPanel" then
		return 1
	end
end

function GuildPanel.UpdateMemberSort(checkBox)
	local page = checkBox:GetParent()
	if page.bDisableSort then
		return
	end
	page.bDisableSort = true

	local szSort, bDescend, bShowOffLine, bGuildState = GuildPanel.szMemberSort, GuildPanel.bMemberSortDescend, GuildPanel.bShowOffLine, GuildPanel.bGuildState
	local szName = checkBox:GetName()
	if szName == "CheckBox_State" then
		bGuildState = checkBox:IsCheckBoxChecked()
		if bGuildState and szSort == "school" then
			szSort = "name"
		end
	elseif szName == "CheckBox_Show" then
		bShowOffLine = checkBox:IsCheckBoxChecked()
	else
		local a =
		{
			["CheckBox_Name"] = "name",
			["CheckBox_Level"] = "level",
			["CheckBox_Type"] = "school",
			["CheckBox_Place"] = "map",
			["CheckBox_Remarks"] = "remark",
		}
		for k, v in pairs(a) do
			if szName ~= k then
				page:Lookup(k):Check(false)
			else
				local checkBox = page:Lookup(k)
				checkBox:Check(true)
				szSort = v
				bDescend = checkBox.bDescend
			end
		end
	end
	GuildPanel.SetMemberSort(szSort, bDescend, bShowOffLine, bGuildState)
	page.bDisableSort = false
end

function GuildPanel.UpdateMemorabiliaSort(checkBox)
	local page = checkBox:GetParent()
	if page.bDisableSort then
		return
	end
	page.bDisableSort = true

	local szSort, bDescend = GuildPanel.szMemorabiliaSort, GuildPanel.bMemberSortDescend
	local szName = checkBox:GetName()
	local a =
	{
		["CheckBox_Time"] = "time",
		["CheckBox_Thing"] = "message",
	}
	for k, v in pairs(a) do
		if szName ~= k then
			page:Lookup(k):Check(false)
		else
			local checkBox = page:Lookup(k)
			checkBox:Check(true)
			szSort = v
			bDescend = checkBox.bDescend
		end
	end
	GuildPanel.SetMemorabiliaSort(szSort, bDescend)
	page.bDisableSort = false
end

function GuildPanel.UpdateMemberSortCheckboxShow(frame)
	local page = frame:Lookup("PageSet_Total/Page_Basic")
	local a =
	{
		["name"] = "CheckBox_Name",
		["level"] = "CheckBox_Level",
		["school"] = "CheckBox_Type",
		["map"] = "CheckBox_Place",
		["remark"] = "CheckBox_Remarks",
	}
	for k, v in pairs(a) do
		if GuildPanel.szMemberSort ~= k then
			local checkBox = page:Lookup(v)
			checkBox:Check(false)
			GuildPanel.UpdateMemberSortShow(checkBox)
		else
			local checkBox = page:Lookup(v)
			checkBox:Check(true)
			checkBox.bDescend = GuildPanel.bMemberSortDescend
			GuildPanel.UpdateMemberSortShow(checkBox)
		end
	end
	page:Lookup("CheckBox_Show"):Check(GuildPanel.bShowOffLine)
end

function GuildPanel.UpdateMemorabiliaSortCheckBoxShow(frame)
	local page = frame:Lookup("PageSet_Total/Page_Secret/Wnd_Big")
	local a =
	{
		["time"] = "CheckBox_Time",
		["message"] = "CheckBox_Thing",
	}
	for k, v in pairs(a) do
		if GuildPanel.szMemorabiliaSort ~= k then
			local checkBox = page:Lookup(v)
			checkBox:Check(false)
			GuildPanel.UpdateMemberSortShow(checkBox)
		else
			local checkBox = page:Lookup(v)
			checkBox:Check(true)
			checkBox.bDescend = GuildPanel.bMemberSortDescend
			GuildPanel.UpdateMemberSortShow(checkBox)
		end
	end
end

function GuildPanel.SetMemberSort(szSort, bDescend, bShowOffLine, bGuildState)
	if szSort ~= GuildPanel.szMemberSort or bDescend ~= GuildPanel.bMemberSortDescend or
		bShowOffLine ~= GuildPanel.bShowOffLine or bGuildState ~= GuildPanel.bGuildState then
		GuildPanel.szMemberSort = szSort
		GuildPanel.bMemberSortDescend = bDescend
		GuildPanel.bShowOffLine = bShowOffLine
		GuildPanel.bGuildState = bGuildState
		FireEvent("GUILD_PANEL_SORT_CHANGED")
	end
end

function GuildPanel.SetMemorabiliaSort(szSort, bDescend)
	if szSort ~= GuildPanel.szMemorabiliaSort or bDescend ~= GuildPanel.bMemorabiliaSortDescend then
		GuildPanel.szMemorabiliaSort = szSort
		GuildPanel.bMemorabiliaSortDescend = bDescend
		FireEvent("GUILD_PANEL_MSG_SORT_CHANGED")
	end
end

function GuildPanel.SetMemberFilter(nGroupFilter, nSchoolFilter)
	if nGroupFilter ~= GuildPanel.nGroupFilter or nSchoolFilter ~= GuildPanel.nSchoolFilter then
		GuildPanel.nGroupFilter = nGroupFilter
		GuildPanel.nSchoolFilter = nSchoolFilter
		FireEvent("GUILD_PANEL_SORT_CHANGED")
	end
end

function GuildPanel.UpdateMemberFilterShow(frame)
	local btn = frame:Lookup("PageSet_Total/Page_Basic/Btn_Level")
	if GuildPanel.bGuildState then
		btn:GetParent():Lookup("", "Text_Filter"):SetText(g_tStrings.STR_GUILD_GROUP1)
		if GuildPanel.nGroupFilter >= 0 and GuildPanel.nGroupFilter < 16 then
			local guild = GetTongClient()
			local groupInfo = guild.GetGroupInfo(GuildPanel.nGroupFilter)
			btn:Lookup("", "Text_LevelB"):SetText(groupInfo.szName)
		else
			btn:Lookup("", "Text_LevelB"):SetText(g_tStrings.STR_GUILD_ALL)
		end
	else
		btn:GetParent():Lookup("", "Text_Filter"):SetText(g_tStrings.STR_GUILD_SCHOOL1)
		if GuildPanel.nSchoolFilter >= 0 and GuildPanel.nSchoolFilter < 10 then
			btn:Lookup("", "Text_LevelB"):SetText(GetForceTitle(GuildPanel.nSchoolFilter))
		else
			btn:Lookup("", "Text_LevelB"):SetText(g_tStrings.STR_GUILD_ALL)
		end
	end
end

function GuildPanel.UpdateGuildState(page)
	local checkBox = page:Lookup("CheckBox_State")
	if checkBox:IsCheckBoxChecked() then
		page:Lookup("CheckBox_Name", "Text_Name"):SetText(g_tStrings.STR_GUILD_NAME)
		page:Lookup("CheckBox_Level", "Text_Level1"):SetText(g_tStrings.STR_GUILD_GROUP)
		local c = page:Lookup("CheckBox_Type")
		c:Lookup("", "Text_Type"):SetText(g_tStrings.STR_GUILD_CONTRIBUTION)
		page:Lookup("CheckBox_Place", "Text_Place"):SetText(g_tStrings.STR_GUILD_JOIN_TIME)
		page:Lookup("CheckBox_Remarks", "Text_Remarks"):SetText(g_tStrings.STR_GUILD_LAST_ONLINE_TIME)
		checkBox:Lookup("", "Text_StateC"):SetText(g_tStrings.STR_GUILD_STATE)
	else
		page:Lookup("CheckBox_Name", "Text_Name"):SetText(g_tStrings.STR_GUILD_NAME)
		page:Lookup("CheckBox_Level", "Text_Level1"):SetText(g_tStrings.STR_GUILD_LEVEL)
		local c = page:Lookup("CheckBox_Type")
		c:Lookup("", "Text_Type"):SetText(g_tStrings.STR_GUILD_SCHOOL)
		page:Lookup("CheckBox_Place", "Text_Place"):SetText(g_tStrings.STR_GUILD_MAP)
		page:Lookup("CheckBox_Remarks", "Text_Remarks"):SetText(g_tStrings.STR_GUILD_REMARK)
		checkBox:Lookup("", "Text_StateC"):SetText(g_tStrings.STR_GUILD_MEMBER_STATE)
	end
end

function GuildPanel.UpdateNoticeState(page)
	local checkBox = page:Lookup("CheckBox_NoticeState")
	local guild = GetTongClient()
	local player = GetClientPlayer()
	local info = guild.GetMemberInfo(player.dwID)
	if info then
		local bEnable = guild.CanBaseOperate(info.nGroupID, TONG_OPERATION_INDEX.MODIFY_ANNOUNCEMENT)
		checkBox:Enable(bEnable)
		if not bEnable then
			checkBox:Check(false)
		end
	end
	if checkBox:IsCheckBoxChecked() then
		page:Lookup("Edit_Notice"):Show()
		page:Lookup("", "Image_Notice"):Show()
		local hList = page:Lookup("", "Handle_NoticeCotent")
		hList:Hide()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_NoticeState"):SetText(g_tStrings.STR_GUILD_PUT_ANNOUNCE)
	else
		page:Lookup("Edit_Notice"):Hide()
		page:Lookup("", "Image_Notice"):Hide()
		local hList = page:Lookup("", "Handle_NoticeCotent")
		hList:Show()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_NoticeState"):SetText(g_tStrings.STR_GUILD_EDIT_ANNOUNCE)
	end
end

function GuildPanel.UpdateTipState(page)
	local checkBox = page:Lookup("CheckBox_TipsState")
	local guild = GetTongClient()
	local player = GetClientPlayer()
	local info = guild.GetMemberInfo(player.dwID)
	if info then
		local bEnable = guild.CanBaseOperate(info.nGroupID, TONG_OPERATION_INDEX.MODIFY_ONLINE_MESSAGE)
		checkBox:Enable(bEnable)
		if not bEnable then
			checkBox:Check(false)
		end
	end
	if checkBox:IsCheckBoxChecked() then
		page:Lookup("Edit_Tips"):Show()
		page:Lookup("", "Image_Tips"):Show()
		local hList = page:Lookup("", "Handle_TipsCotent")
		hList:Hide()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_TipsState"):SetText(g_tStrings.STR_GUILD_PUT_ONLINE_MSG)
	else
		page:Lookup("Edit_Tips"):Hide()
		page:Lookup("", "Image_Tips"):Hide()
		local hList = page:Lookup("", "Handle_TipsCotent")
		hList:Show()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_TipsState"):SetText(g_tStrings.STR_GUILD_EDIT_ONLINE_MSG)
	end
end

function GuildPanel.UpdateIntroduction(page)
	local checkBox = page:Lookup("CheckBox_Said")
	local guild = GetTongClient()
	local player = GetClientPlayer()
	local info = guild.GetMemberInfo(player.dwID)
	if info then
		local bEnable = guild.CanBaseOperate(info.nGroupID, TONG_OPERATION_INDEX.MODIFY_INTRODUCTION)
		checkBox:Enable(bEnable)
		if not bEnable then
			checkBox:Check(false)
		end
	end
	if checkBox:IsCheckBoxChecked() then
		page:Lookup("Edit_Tell"):Show()
		page:Lookup("", "Image_Tell"):Show()
		local hList = page:Lookup("", "Handle_Introduction")
		hList:Hide()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_SaidC"):SetText(g_tStrings.STR_GUILD_PUT_INTRODUCTION)
	else
		page:Lookup("Edit_Tell"):Hide()
		page:Lookup("", "Image_Tell"):Hide()
		local hList = page:Lookup("", "Handle_Introduction")
		hList:Show()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_SaidC"):SetText(g_tStrings.STR_GUILD_EDIT_INTRODUCTION)
	end
end

function GuildPanel.UpdateRules(page)
	local checkBox = page:Lookup("CheckBox_System")
	local guild = GetTongClient()
	local player = GetClientPlayer()
	local info = guild.GetMemberInfo(player.dwID)
	if info then
		local bEnable = guild.CanBaseOperate(info.nGroupID, TONG_OPERATION_INDEX.MODIFY_RULES)
		checkBox:Enable(bEnable)
		if not bEnable then
			checkBox:Check(false)
		end
	end
	if checkBox:IsCheckBoxChecked() then
		page:Lookup("Edit_System"):Show()
		page:Lookup("", "Image_System"):Show()
		local hList = page:Lookup("", "Handle_Rule")
		hList:Hide()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_SystemC"):SetText(g_tStrings.STR_GUILD_PUT_RULE)
	else
		page:Lookup("Edit_System"):Hide()
		page:Lookup("", "Image_System"):Hide()
		local hList = page:Lookup("", "Handle_Rule")
		hList:Show()
		GuildPanel.UpdateScrollInfo(hList)
		checkBox:Lookup("", "Text_SystemC"):SetText(g_tStrings.STR_GUILD_EDIT_RULE)
	end
end

function GuildPanel.ModifyAnnouncement(page)
	local guild = GetTongClient()
	local szEdit = page:Lookup("Edit_Notice"):GetText()
	if szEdit ~= guild.szAnnouncement then
		GuildPanel.szAnnouncement = szEdit
		guild.ApplyModifyAnnouncement(szEdit)
		local hList = page:Lookup("", "Handle_NoticeCotent")
		hList:Lookup("Text_NoticeCotent"):SetText(szEdit)
		GuildPanel.UpdateScrollInfo(hList)
	end
end

function GuildPanel.ModifyOnlineMessage(page)
	local guild = GetTongClient()
	local szEdit = page:Lookup("Edit_Tips"):GetText()
	if szEdit ~= guild.szOnlineMessage then
		GuildPanel.szOnlineMessage = szEdit
		guild.ApplyModifyOnlineMessage(szEdit)
		local hList = page:Lookup("", "Handle_TipsCotent")
		hList:Lookup("Text_TipsCotent"):SetText(szEdit)
		GuildPanel.UpdateScrollInfo(hList)
	end
end

function GuildPanel.ModifyIntroduction(page)
	local guild = GetTongClient()
	local szEdit = page:Lookup("Edit_Tell"):GetText()
	if szEdit ~= guild.szIntroduction then
		GuildPanel.szIntroduction = szEdit
		guild.ApplyModifyIntroduction(szEdit)
		local hList = page:Lookup("", "Handle_Introduction")
		hList:Lookup("Text_Introduction"):SetText(szEdit)
		GuildPanel.UpdateScrollInfo(hList)
	end
end

function GuildPanel.ModifyRules(page)
	local guild = GetTongClient()
	local szEdit = page:Lookup("Edit_System"):GetText()
	if szEdit ~= guild.szRules then
		GuildPanel.szRules = szEdit
		guild.ApplyModifyRules(szEdit)
		local hList = page:Lookup("", "Handle_Rule")
		hList:Lookup("Text_Rule"):SetText(szEdit)
		GuildPanel.UpdateScrollInfo(hList)
	end
end

function GuildPanel.UpdateBankRights(wndBank)
	if wndBank.bIgnore then
		return
	end
	wndBank.bIgnore = true
	local bEnableAllStore = true
	local bEnableAllTake = true
	local bAllStore = true
	local bAllTake = true
	for i = 1, 9, 1 do
		local c = wndBank:Lookup("CheckBox_BankStore"..i)
		if not c:IsCheckBoxActive() then
			bEnableAllStore = false
		end
		if not c:IsCheckBoxChecked() then
			bAllStore = false
		end
		
		c = wndBank:Lookup("CheckBox_BankTake"..i)
		if not c:IsCheckBoxActive() then
			bEnableAllTake = false
		end
		if not c:IsCheckBoxChecked() then
			bAllTake = false
		end
	end
	
	local c = wndBank:Lookup("CheckBox_AllStore")
	c:Check(bAllStore)
	c:Enable(bEnableAllStore)
	
	c = wndBank:Lookup("CheckBox_AllTake")
	c:Check(bAllTake)
	c:Enable(bEnableAllTake)
	
	c = wndBank:Lookup("CheckBox_AllSelect")
	c:Check(bAllStore and bAllTake)
	c:Enable(bEnableAllTake and bEnableAllTake)
	wndBank.bIgnore = false
end

function GuildPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Name" or szName == "CheckBox_Level" or szName == "CheckBox_Type" or
		szName == "CheckBox_Place" or szName == "CheckBox_Remarks" then
		GuildPanel.UpdateMemberSortShow(this)
		GuildPanel.UpdateMemberSort(this)
	elseif szName == "CheckBox_Show" then
		GuildPanel.UpdateMemberSort(this)
	elseif szName == "CheckBox_State" then
		GuildPanel.UpdateGuildState(this:GetParent())
		GuildPanel.UpdateMemberSort(this)
	elseif szName == "CheckBox_NoticeState" then
		GuildPanel.UpdateNoticeState(this:GetParent())
	elseif szName == "CheckBox_TipsState" then
		GuildPanel.UpdateTipState(this:GetParent())
	elseif szName == "CheckBox_Said" then
		GuildPanel.UpdateIntroduction(this:GetParent())
	elseif szName == "CheckBox_System" then
		GuildPanel.UpdateRules(this:GetParent())
	elseif szName == "CheckBox_MSystem" then
		local h = this:GetParent():Lookup("", "Handle_MLogContent")
		h:Clear()
		GuildPanel.UpdateScrollInfo(h)
		this:GetParent():Lookup("CheckBox_MUser"):Check(false)
		GetTongClient().SyncHistory(TONG_HISTORY_TYPE.SYSTEM_CHANGE_FUND)
	elseif szName == "CheckBox_MUser" then
		local h = this:GetParent():Lookup("", "Handle_MLogContent")
		h:Clear()
		GuildPanel.UpdateScrollInfo(h)
		this:GetParent():Lookup("CheckBox_MSystem"):Check(false)
		GetTongClient().SyncHistory(TONG_HISTORY_TYPE.DONATE_FUND)
	elseif szName == "CheckBox_GSystem" then
		local h = this:GetParent():Lookup("", "Handle_GLogContent")
		h:Clear()
		GuildPanel.UpdateScrollInfo(h)
		this:GetParent():Lookup("CheckBox_GUser"):Check(false)
		GetTongClient().SyncHistory(TONG_HISTORY_TYPE.SYSTEM_ITEM_CHANGE)
	elseif szName == "CheckBox_GUser" then
		local h = this:GetParent():Lookup("", "Handle_GLogContent")
		h:Clear()
		GuildPanel.UpdateScrollInfo(h)
		this:GetParent():Lookup("CheckBox_GSystem"):Check(false)
		GetTongClient().SyncHistory(TONG_HISTORY_TYPE.ITEM_CHANGE)
	elseif szName == "CheckBox_DSystem" then
		local h = this:GetParent():Lookup("", "Handle_DLogContent")
		h:Clear()
		GuildPanel.UpdateScrollInfo(h)
		this:GetParent():Lookup("CheckBox_DUser"):Check(false)
		GetTongClient().SyncHistory(TONG_HISTORY_TYPE.SYSTEM_CHANGE_DEVELOPMENT_POINT)
	elseif szName == "CheckBox_DUser" then
		local h = this:GetParent():Lookup("", "Handle_DLogContent")
		h:Clear()
		GuildPanel.UpdateScrollInfo(h)
		this:GetParent():Lookup("CheckBox_DSystem"):Check(false)
		GetTongClient().SyncHistory(TONG_HISTORY_TYPE.ADD_DEVELOPMENT_POINT)
	elseif this.bAccessCheckBox then
		GuildPanel.UpdateAccessPage(this)
	elseif this:GetParent():GetName() == "Wnd_Manage" then
		local page = this:GetParent():GetParent()
		if not page.bIgnorApply then
			page:Lookup("Btn_Apply"):Enable(true)
		end
	elseif this.bAccess and this:GetParent():GetName() == "Wnd_BankRights" then
		local wndBank = this:GetParent()
		local page = wndBank:GetParent()
		if not page.bIgnorApply then
			page:Lookup("Btn_Apply"):Enable(true)
		end
		GuildPanel.UpdateBankRights(wndBank)		
	elseif szName == "CheckBox_AllSelect" then
		local wndBank = this:GetParent()
		if not wndBank.bIgnore then
			wndBank.bIgnore = true
			for i = 1, 9, 1 do
				local c = wndBank:Lookup("CheckBox_BankStore"..i)
				if c:IsCheckBoxActive() then
					c:Check(true)
				end
				local c = wndBank:Lookup("CheckBox_BankTake"..i)
				if c:IsCheckBoxActive() then
					c:Check(true)
				end
			end
			wndBank.bIgnore = false
			GuildPanel.UpdateBankRights(wndBank)
		end
	elseif szName == "CheckBox_AllStore" then
		local wndBank = this:GetParent()
		if not wndBank.bIgnore then
			wndBank.bIgnore = true
			for i = 1, 9, 1 do
				local c = wndBank:Lookup("CheckBox_BankStore"..i)
				if c:IsCheckBoxActive() then
					c:Check(true)
				end
			end
			wndBank.bIgnore = false
			GuildPanel.UpdateBankRights(wndBank)
		end
	elseif szName == "CheckBox_AllTake" then
		local wndBank = this:GetParent()
		if not wndBank.bIgnore then
			wndBank.bIgnore = true
			for i = 1, 9, 1 do
				local c = wndBank:Lookup("CheckBox_BankTake"..i)
				if c:IsCheckBoxActive() then
					c:Check(true)
				end
			end
			wndBank.bIgnore = false
			GuildPanel.UpdateBankRights(wndBank)
		end
	elseif szName == "CheckBox_Time" or szName == "CheckBox_Thing" then
		GuildPanel.UpdateMemberSortShow(this)
		GuildPanel.UpdateMemorabiliaSort(this)
	elseif szName == "CheckBox_TongTechTree" then
		OpenTongTechTreePanel()
		this:Check(false)
	elseif szName == "CheckBox_Salary" then
		OpenGuildSalaryPanel()
		this:Check(false)
	elseif szName == "CheckBox_Diplomatic" then
		GuildDiplomacy.OnDiplomacyPageActive()
	elseif szName == "CheckBox_arena" then
		OpenTongArena();
		this:Check(false)
	elseif szName == "CheckBox_Ploy" then
		GuildPanel.UpdateTongActivityList(this:GetRoot())
	else
		local bProcess = GuildDiplomacy.OnCheckBoxCheck()
		if bProcess then
			return
		end
	end
end

function GuildPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Name" or szName == "CheckBox_Level" or szName == "CheckBox_Type" or
		szName == "CheckBox_Place" or szName == "CheckBox_Remarks" then
		GuildPanel.UpdateMemberSortShow(this)
	elseif szName == "CheckBox_Show" then
		GuildPanel.UpdateMemberSort(this)
	elseif szName == "CheckBox_State" then
		GuildPanel.UpdateGuildState(this:GetParent())
		GuildPanel.UpdateMemberSort(this)
	elseif szName == "CheckBox_NoticeState" then
		GuildPanel.UpdateNoticeState(this:GetParent())
		GuildPanel.ModifyAnnouncement(this:GetParent())
	elseif szName == "CheckBox_TipsState" then
		GuildPanel.UpdateTipState(this:GetParent())
		GuildPanel.ModifyOnlineMessage(this:GetParent())
	elseif szName == "CheckBox_Said" then
		GuildPanel.UpdateIntroduction(this:GetParent())
		GuildPanel.ModifyIntroduction(this:GetParent())
	elseif szName == "CheckBox_System" then
		GuildPanel.UpdateRules(this:GetParent())
		GuildPanel.ModifyRules(this:GetParent())
	elseif this:GetParent():GetName() == "Wnd_Manage" then
		local page = this:GetParent():GetParent()
		if not page.bIgnorApply then
			page:Lookup("Btn_Apply"):Enable(true)
		end
	elseif this.bAccess and this:GetParent():GetName() == "Wnd_BankRights" then
		local wndBank = this:GetParent()
		local page = wndBank:GetParent()
		if not page.bIgnorApply then
			page:Lookup("Btn_Apply"):Enable(true)
		end
		GuildPanel.UpdateBankRights(wndBank)		
	elseif szName == "CheckBox_AllSelect" then
		local wndBank = this:GetParent()
		if not wndBank.bIgnore then
			wndBank.bIgnore = true
			for i = 1, 9, 1 do
				local c = wndBank:Lookup("CheckBox_BankStore"..i)
				if c:IsCheckBoxActive() then
					c:Check(false)
				end
				local c = wndBank:Lookup("CheckBox_BankTake"..i)
				if c:IsCheckBoxActive() then
					c:Check(false)
				end
			end
			wndBank.bIgnore = false
			GuildPanel.UpdateBankRights(wndBank)
		end
	elseif szName == "CheckBox_AllStore" then
		local wndBank = this:GetParent()
		if not wndBank.bIgnore then
			wndBank.bIgnore = true
			for i = 1, 9, 1 do
				local c = wndBank:Lookup("CheckBox_BankStore"..i)
				if c:IsCheckBoxActive() then
					c:Check(false)
				end
			end
			wndBank.bIgnore = false
			GuildPanel.UpdateBankRights(wndBank)
		end
	elseif szName == "CheckBox_AllTake" then
		local wndBank = this:GetParent()
		if not wndBank.bIgnore then
			wndBank.bIgnore = true
			for i = 1, 9, 1 do
				local c = wndBank:Lookup("CheckBox_BankTake"..i)
				if c:IsCheckBoxActive() then
					c:Check(false)
				end
			end
			wndBank.bIgnore = false
			GuildPanel.UpdateBankRights(wndBank)
		end		
	elseif szName == "CheckBox_Time" or szName == "CheckBox_Thing" then
		GuildPanel.UpdateMemberSortShow(this)
		GuildPanel.UpdateMemorabiliaSort(this)
	end
end

function GuildPanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_RankName" then
		local page = this:GetParent()
		if not page.bIgnorApply then
			page:Lookup("Btn_Apply"):Enable(true)
		end
		page.bChanged = true
	else
		local bProcess = GuildDiplomacy.OnEditChanged()
		if bProcess then
			return
		end
	end
end

function GuildPanel.OnItemLButtonDown()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if this.bSel then
			return
		end
		GuildPanel.SelectPage(this)
	elseif szName == "Member" then
		GuildPanel.SelectMember(this, true)
	elseif szName == "Group" then
		GuildPanel.SelectGroup(this, true)
	elseif szName == "TreeLeaf_TongActivity" then
		local hItem = this
		if hItem.bTongActivityClass or hItem.bTongActivitySubClass then
			if hItem:IsExpand() then
				hItem:Collapse()
			else
				hItem:Expand()
			end
			local hList = hItem:GetParent()
			hList:FormatAllItemPos()
			FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Content", "GuildPanel", false)
		end
		
		GuildPanel.SelectTongActivity(hItem)
	elseif this.bMsg then
		GuildPanel.SelectMessage(this)
	else 
		OnItemLinkDown(this)	
	end
end

function GuildPanel.OnItemRButtonDown()
	local szName = this:GetName()
	if szName == "Member" then
		GuildPanel.SelectMember(this, true)

		local player = GetClientPlayer()
		local guild = GetTongClient()
		local info = guild.GetMemberInfo(this.dwID)
		local pInfo = guild.GetMemberInfo(player.dwID)
		local szMemberName = info.szName
		local dwID = this.dwID

		local fnKick = function()
			local msg =
			{
				szMessage = FormatString(g_tStrings.STR_GUILD_KICK_SURE, GetTongClient().GetMemberInfo(dwID).szName),
				szName = "DeleteGuildMemberConfirm",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetTongClient().ApplyKickOutMember(dwID) end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		end

		local fnChangeMaster = function()
            local hTongClient = GetTongClient()
            local hMember = hTongClient.GetMemberInfo(dwID)
			local szName = hMember.szName
            local nLevel = hMember.nLevel
            if nLevel >= 30 then
                local szMsg = FormatLinkString(g_tStrings.STR_GUILD_CHANGE_MASTER_SURE, "font=162", GetFormatText(szName, 166), GetFormatText(g_tStrings.STR_GUILD_CHANGE_MASTER_INPUT, 163))
                local fnAction = function(szInput)
                    if szInput == g_tStrings.STR_GUILD_CHANGE_MASTER_INPUT then
                        GetTongClient().ChangeMaster(dwID)
                    else
                        local msg =
                        {
                            szMessage = g_tStrings.STR_GUILD_CHANGE_MASTER_ERROR,
                            szName = "ChangeMasterSureError",
                            {szOption = g_tStrings.STR_HOTKEY_SURE},
                        }
                        MessageBox(msg)
                    end
                end
                GetUserInput(szMsg, fnAction, nil, nil, nil, "", 32, nil, true)
            else
                local tMsg =
                {
                    szMessage = g_tStrings.STR_GUILD_CAN_NOT_CHANGE_MASTER,
                    szName = "CannotChangeMaster",
                    {szOption = g_tStrings.STR_HOTKEY_SURE},
                }
                MessageBox(tMsg)
            end
		end
        
        local fnCancleChangeMaster  = function()
            local tMsg =
            {
                szMessage = g_tStrings.STR_GUILD_CANCLE_CHANGE_MASTER_SURE,
                szName = "CacleChangeMaster",
                {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetTongClient().CancelChangeMaster() end, },
                {szOption = g_tStrings.STR_HOTKEY_CANCEL},
            }
            MessageBox(tMsg)
        end

		local menu =
		{
			fnAutoClose = function() return not IsGuildPanelOpened() end,
			{szOption = g_tStrings.STR_SAY_SECRET, bDisable = dwID == player.dwID, fnAction = function() EditBox_TalkToSomebody(szMemberName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = dwID == player.dwID or not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szMemberName) AddContactPeople(szMemberName) end},
			{bDevide = true},
			{szOption = g_tStrings.STR_GUILD_ROMOVE_MEMBER, bDisable = not guild.CheckAdvanceOperationGroup(pInfo.nGroupID, info.nGroupID, 0), fnAction = fnKick},
			{bDevide = true},
			{szOption = g_tStrings.STR_MAKE_FRIEND, bDisable = dwID == player.dwID, fnAction = function() GetClientPlayer().AddFellowship(szMemberName) AddContactPeople(szMemberName) end},
		    {bDevide = true}
		}

        if guild.dwNextMaster > 0 and (player.dwID == guild.dwNextMaster or player.dwID == guild.dwMaster) then
            if guild.dwNextMaster == dwID or guild.dwMaster == dwID then
                table.insert(menu, {szOption = g_tStrings.STR_GUILD_CANCLE_CHANGE_MASTER, bDisable = dwID == false, fnAction = fnCancleChangeMaster})
            end
        else
            table.insert(menu, {szOption = g_tStrings.STR_GUILD_CHANGE_MASTER_1, bDisable = dwID == player.dwID or player.dwID ~= guild.dwMaster, fnAction = fnChangeMaster})
        end
        table.insert(menu, {bDevide = true})
		if guild.CheckAdvanceOperationGroup(pInfo.nGroupID, info.nGroupID, 0) then
			local hI = this
			local fnMove = function(UserData, bCheck)
				GetTongClient().ChangeMemberGroup(dwID, UserData)
				GuildPanel.UpdateMemberList(hI:GetRoot())
			end

			local move = {}

			for i = 0, 15, 1 do
				local groupInfo = guild.GetGroupInfo(i)
				if groupInfo.bEnable and guild.CheckAdvanceOperationGroup(pInfo.nGroupID, i, 0) then
					table.insert(move, {szOption = groupInfo.szName, UserData = i, fnAction = fnMove})
				end
			end

			if #move > 0 then
				move.szOption = g_tStrings.STR_GUILD_MOVE_TO_GROUP
				table.insert(menu, move)
			end
		end

		PopupMenu(menu)
	end
end

function GuildPanel.OnItemLButtonUp()
end

function GuildPanel.UpdateMemberSortShow(checkBox)
	local handle = checkBox:Lookup("", "")
	if checkBox:IsCheckBoxChecked() then
		if checkBox.bDescend then
			handle:Lookup(1):Show()
			handle:Lookup(2):Hide()
		else
			handle:Lookup(1):Hide()
			handle:Lookup(2):Show()
		end
	else
		handle:Lookup(1):Hide()
		handle:Lookup(2):Hide()
	end
end

function GuildPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_Name" or szName == "Handle_Level1" or szName == "Handle_Type" or szName == "Handle_Place" or szName == "Handle_Remarks" then
		local checkBox = this:GetParent()
		if checkBox:IsCheckBoxChecked() then
			if checkBox.bDescend then
				checkBox.bDescend = false
			else
				checkBox.bDescend = true
			end
			GuildPanel.UpdateMemberSortShow(checkBox)
			GuildPanel.UpdateMemberSort(checkBox)
			return 0
		end
	elseif szName == "Handle_Time" or szName == "Handle_Thing1" then
		local checkBox = this:GetParent()
		if checkBox:IsCheckBoxChecked() then
			if checkBox.bDescend then
				checkBox.bDescend = false
			else
				checkBox.bDescend = true
			end
			GuildPanel.UpdateMemberSortShow(checkBox)
			GuildPanel.UpdateMemorabiliaSort(checkBox)
			return 0
		end

	end
end

function GuildPanel.OnItemLButtonDBClick()
	local szName = this:GetName()
	if szName == "Handle_Name" or szName == "Handle_Level1" or szName == "Handle_Type" or szName == "Handle_Place" or szName == "Handle_Remarks" then
		return GuildPanel.OnItemLButtonClick()
	elseif szName == "Handle_Time" or szName == "Handle_Thing1" then
		return GuildPanel.OnItemLButtonClick()
	end
end

function GuildPanel.OnItemMouseEnter()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if not this.bSel then
			this:Lookup(0):Show()
			this:Lookup(0):SetAlpha(127)
		end
	elseif szName == "Member" then
		this.bOver = true
		GuildPanel.UpdateMemberShow(this)
		local x, y = Cursor.GetPos()
        local hTongClient = GetTongClient()
        if hTongClient.dwNextMaster > 0 and (this.bMaster or this.bNextMaster) then
            local szTime = GuildPanel.GetMasterChangeLeaveTime()
            local szNextMaster = hTongClient.GetMemberInfo(hTongClient.dwNextMaster).szName
            local szTip = FormatString(g_tStrings.STR_GUILD_CHANGE_MASTER_ING, szTime, szNextMaster)
            OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, 40, 40})
         elseif this.bFresher then
			OutputTip("<text>text=" ..EncodeComponentsString(g_tStrings.GUILD_FRESHER_MEMBER_TIP).."font=106 </text>", 400, {x, y, 40, 40})
		end
	elseif szName == "Group" then
		this.bOver = true
		GuildPanel.UpdateGroupShow(this)
	elseif szName == "Null_CampTip" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local guild = GetTongClient()
		local szTip = g_tStrings.STR_GUILD_CAMP_TIP[guild.nCamp]
		if szTip then
			OutputTip(szTip, 300, {x, y, w, h})
		end
	elseif szName == "Text_Members" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = FormatString(g_tStrings.STR_GUILD_NUM_TIP, GetTongClient().nMaxMemberCount)
		OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, w, h})
	elseif szName == "Image_AssetsBg" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = FormatString(g_tStrings.GUILD_MONEY_TIP, GetTongClient().nFund, 1000000)
		OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, w, h})
	elseif szName == "Image_DevelopmentBg" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local nWeeklyPoint = GuildPanel.nWeeklyPoint or 0
		local nDevelopmentPoint = GetTongClient().nDevelopmentPoint
		local szTip = FormatString(g_tStrings.GUILD_DEVELOPMENT_TIP, nDevelopmentPoint, 70000, nWeeklyPoint)
		OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, w, h})
	elseif szName == "Image_MyContributionBg" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		local guild = GetTongClient()
		local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
		local nMaxContribution = levelUp['MaxContribution'] or 0
		local szTip = FormatString(g_tStrings.GUILD_CONTRIBUTION_TIP, player.nContribution, nMaxContribution)
		local nLimit = player.GetContributionRemainSpace()
		szTip = szTip..g_tStrings.STR_COMMA..g_tStrings.STR_CURRENCY_REMAIN_GET .. nLimit
        
		OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, w, h})	
	elseif szName == "Image_Limit" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local nWeeklyPoint = GuildPanel.nWeeklyPoint or 0
		local szTip = FormatString(g_tStrings.GUILD_DEVELOPMENT_WEEKLY_TIP, nWeeklyPoint)
		OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, w, h})	
	elseif szName == "Image_MyContributionLimit" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local nLimit = GetClientPlayer().GetContributionRemainSpace()
		local szTip = g_tStrings.STR_CURRENCY_REMAIN_GET .. nLimit
		OutputTip("<text>text=" ..EncodeComponentsString(szTip).."font=106 </text>", 400, {x, y, w, h})	
	elseif szName == "TreeLeaf_TongActivity" then
		this.bMouse = true
		GuildPanel.UpdateTongActivityTitle(this)
	end
	
	local szType = this:GetType()
	if szType == "Text" and this:IsLink() then
		local nFont = this:GetFontScheme()
		this.nFont = nFont
		this:SetFontScheme(164)
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	end
end

function GuildPanel.OnItemMouseLeave()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if not this.bSel then
			this:Lookup(0):Hide()
		end
	elseif szName == "Member" then
		this.bOver = false
		GuildPanel.UpdateMemberShow(this)
		HideTip()
	elseif szName == "Group" then
		this.bOver = false
		GuildPanel.UpdateGroupShow(this)
	elseif szName == "Null_CampTip" then
		HideTip()
	elseif szName == "Text_Members" then
		HideTip()
	elseif szName == "Image_AssetsBg" then
		HideTip()
	elseif szName == "Image_DevelopmentBg" then
		HideTip()
	elseif szName == "Image_MyContributionBg" then
		HideTip()
	elseif szName == "Image_Limit" then
		HideTip()
	elseif szName == "TreeLeaf_TongActivity" then
		this.bMouse = false
		GuildPanel.UpdateTongActivityTitle(this)
	end
	
	local szType = this:GetType()
	if szType == "Text" and this:IsLink() then
		if this.nFont then
			this:SetFontScheme(this.nFont)
			local hHandle = this:GetParent()
			hHandle:FormatAllItemPos()
		end
	end
end

function GuildPanel.UpdateMemberShow(hI)
	local img = hI:Lookup("Image_Sel")
	if img then
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
end

function GuildPanel.UpdateGroupShow(hI)
	local img = hI:Lookup("TN_Rank")
	if img then
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
end

function GuildPanel.SelectMember(hI, bUser)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			GuildPanel.UpdateMemberShow(hB)
			break
		end
	end

	hI.bSel = true

	local page = hList:GetParent():GetParent()
	page.bSel = true
	if bUser then
		page.bClose = false
	end
	page.dwID = hI.dwID
	GuildPanel.UpdateAddOnPanelShow(page:GetRoot())
	GuildPanel.UpdateSelectMemberInfo(page:GetRoot())
	GuildPanel.UpdateMemberShow(hI)
end

function GuildPanel.SelectMessage(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			GuildPanel.UpdateMessageShow(hB)
			break
		end
	end

	hI.bSel = true
	GuildPanel.UpdateMessageShow(hI)

	local page = hList:GetParent():GetParent()
	page.bSel = true
	page.dwID = hI.dwID
	page.szText = hI.szText
	page.nTime = hI.nTime
	GuildPanel.UpdateMemorabiliaState(page)
end

function GuildPanel.UpdateMemorabiliaState(page)
	local player = GetClientPlayer()
	local guild = GetTongClient()
	local info = guild.GetMemberInfo(player.dwID)
	local bEnable = info and guild.CanBaseOperate(info.nGroupID, TONG_OPERATION_INDEX.DEVELOP_TECHNOLOGY)
	local edit = page:Lookup("Edit_Msg")
	local editYear = page:Lookup("Edit_Year")
	local editMonth = page:Lookup("Edit_Month")
	local editDay = page:Lookup("Edit_Day")
	local btnP = page:Lookup("Btn_Publish")
	local btnC = page:Lookup("Btn_Change")
	local btnD = page:Lookup("Btn_DeleteMsg")

	local time = TimeToDate(page.nTime)

	if bEnable then
		if page.bSel then
			edit:Enable(true)
			edit:SetText(page.szText)
			editYear:SetText(time.year)
			editMonth:SetText(time.month)
			editDay:SetText(time.day)
			btnP:Enable(true)
			btnC:Enable(true)
			btnD:Enable(true)
		else
			edit:Enable(true)
			edit:SetText("")
			editYear:SetText("")
			editMonth:SetText("")
			editDay:SetText("")
			btnP:Enable(true)
			btnC:Enable(false)
			btnD:Enable(false)
		end
	else
		edit:SetText("")
		editYear:SetText("")
		editMonth:SetText("")
		editDay:SetText("")
		edit:Enable(false)
		btnP:Enable(false)
		btnC:Enable(false)
		btnD:Enable(false)
	end
end

function GuildPanel.UpdateMessageShow(hI)
	local img = hI:Lookup("Image_Select")
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

function GuildPanel.SelectGroup(hI, bUser)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			GuildPanel.UpdateGroupShow(hB)
			break
		end
	end

	hI.bSel = true

	local page = hList:GetParent():GetParent()
	page.dwGroup = hI.dwGroup
	GuildPanel.UpdateSelectGroupInfo(page)
	GuildPanel.UpdateGroupShow(hI)
end

function GuildPanel.SelectPage(hI)
	local hP = hI:GetParent()
	local page = hP:GetParent():GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB:Lookup(0):Hide()
		hB.bSel = false

		local szLeft = string.sub(hB:GetName(), 4, -1)
		local hWnd = page:Lookup("Wnd_"..szLeft)
		if hWnd then
			hWnd:Hide()
		end
	end
	hI:Lookup(0):Show()
	hI:Lookup(0):SetAlpha(255)
	hI.bSel = true
	local szLeft = string.sub(hI:GetName(), 4, -1)
	local szWndName = "Wnd_"..szLeft
	
	local w = page:Lookup(szWndName)
--	if szWndName == "Wnd_Big" then--屏蔽帮会大事记
--		w:Hide()
--	else
		w:Show()
--	end
	
	if szWndName == "Wnd_Money" then
		if w:Lookup("CheckBox_MSystem"):IsCheckBoxChecked() then
			GetTongClient().SyncHistory(TONG_HISTORY_TYPE.SYSTEM_CHANGE_FUND)
		elseif w:Lookup("CheckBox_MUser"):IsCheckBoxChecked() then
			GetTongClient().SyncHistory(TONG_HISTORY_TYPE.DONATE_FUND)
		else
			w:Lookup("CheckBox_MUser"):Check(true)
		end
	elseif szWndName == "Wnd_Goods" then
		if w:Lookup("CheckBox_GSystem"):IsCheckBoxChecked() then
			GetTongClient().SyncHistory(TONG_HISTORY_TYPE.SYSTEM_ITEM_CHANGE)
		elseif w:Lookup("CheckBox_GUser"):IsCheckBoxChecked() then
			GetTongClient().SyncHistory(TONG_HISTORY_TYPE.ITEM_CHANGE)
		else
			w:Lookup("CheckBox_GUser"):Check(true)
		end
	elseif szWndName == "Wnd_Dep" then
		if w:Lookup("CheckBox_DSystem"):IsCheckBoxChecked() then
			GetTongClient().SyncHistory(TONG_HISTORY_TYPE.SYSTEM_CHANGE_DEVELOPMENT_POINT)
		elseif w:Lookup("CheckBox_DUser"):IsCheckBoxChecked() then
			GetTongClient().SyncHistory(TONG_HISTORY_TYPE.ADD_DEVELOPMENT_POINT)
		else
			w:Lookup("CheckBox_DUser"):Check(true)
		end
	end
	
	GuildPanel.UpdateAddOnPanelShow(page:GetRoot())
end

function GuildPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Level" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		if not this:IsEnabled() then
			return
		end

		if GuildPanel.bGuildState then
			local btn = this
			local frame = this:GetRoot()
			local text = this:Lookup("", "Text_LevelB")
			local xA, yA = text:GetAbsPos()
			local w, h = text:GetSize()
			local menu =
			{
				nMiniWidth = w,
				x = xA, y = yA + h,
				fnCancelAction = function()
					if btn:IsValid() then
						local x, y = Cursor.GetPos()
						local xA, yA = btn:GetAbsPos()
						local w, h = btn:GetSize()
						if x >= xA and x < xA + w and y >= yA and y <= yA + h then
							btn.bIgnor = true
						end
					end
				end,
				fnAction = function(UserData, bCheck)
					if frame:IsValid() then
						GuildPanel.SetMemberFilter(UserData, GuildPanel.nSchoolFilter)
					end
				end,
				fnAutoClose = function() return not IsGuildPanelOpened() end,
			}
			local guild = GetTongClient()
			for i = 0, 15, 1 do
				local groupInfo = guild.GetGroupInfo(i)
				if groupInfo.bEnable then
					table.insert(menu, {szOption = groupInfo.szName, UserData = i})
				end
			end
			table.insert(menu, {szOption = g_tStrings.STR_GUILD_ALL, UserData = -1})
			PopupMenu(menu)
			return true
		else
			local btn = this
			local frame = this:GetRoot()
			local text = this:Lookup("", "Text_LevelB")
			local xA, yA = text:GetAbsPos()
			local w, h = text:GetSize()
			local menu =
			{
				nMiniWidth = w,
				x = xA, y = yA + h,
				fnCancelAction = function()
					if btn:IsValid() then
						local x, y = Cursor.GetPos()
						local xA, yA = btn:GetAbsPos()
						local w, h = btn:GetSize()
						if x >= xA and x < xA + w and y >= yA and y <= yA + h then
							btn.bIgnor = true
						end
					end
				end,
				fnAction = function(UserData, bCheck)
					if frame:IsValid() then
						GuildPanel.SetMemberFilter(GuildPanel.nGroupFilter, UserData)
					end
				end,
				fnAutoClose = function() return not IsGuildPanelOpened() end,
			}
			local guild = GetTongClient()
			for i = 0, 10, 1 do
				local szSchool = GetForceTitle(i)
				if szSchool and szSchool ~= "" then
					table.insert(menu, {szOption = szSchool, UserData = i})
				end
			end
			table.insert(menu, {szOption = g_tStrings.STR_GUILD_ALL, UserData = -1})
			PopupMenu(menu)
			return true
		end
	elseif szName == "Btn_Doown" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		if not this:IsEnabled() then
			return
		end

		local dwID = this:GetParent().dwID
		local btn = this
		local text = this:Lookup("", "Text_Doown")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu =
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function()
				if btn:IsValid() then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				local guild = GetTongClient()
				guild.ChangeMemberGroup(dwID, UserData)
				local groupInfo = guild.GetGroupInfo(UserData)
				text:SetText(groupInfo.szName)
				if GuildPanel.bGuildState then
					local hList = text:GetRoot():Lookup("PageSet_Total/Page_Basic", "Handle_ListBasic")
					local nCount = hList:GetItemCount() - 1
					for i = 0, nCount, 1 do
						local hI = hList:Lookup(i)
						if hI.dwID == dwID then
							hI:Lookup("Level"):SetText(groupInfo.szName)
							break
						end
					end
				end
			end,
			fnAutoClose = function() return not IsGuildPanelOpened() end,
		}
		local guild = GetTongClient()
		local player = GetClientPlayer()
		local info = guild.GetMemberInfo(player.dwID)
		for i = 0, 15, 1 do
			local groupInfo = guild.GetGroupInfo(i)
			if groupInfo.bEnable and guild.CheckAdvanceOperationGroup(info.nGroupID, i, 0) then
				table.insert(menu, {szOption = groupInfo.szName, UserData = i})
			end
		end
		PopupMenu(menu)
		return true
	else
		local nRetCode = GuildDiplomacy.OnLButtonDown()
		if nRetCode ~= nil then
			return nRetCode
		end
		GuildPanel.OnLButtonHold()
	end
end

function GuildPanel.OnMouseEnter()
	if this.bAccess then
		if this.bAdvance then
			local szTip = nil
			if this:IsCheckBoxActive() then
				szTip = g_tStrings.STR_GUILD_ACCESS_1
			else
				if this:IsCheckBoxChecked() then
					szTip = g_tStrings.STR_GUILD_ACCESS_2
				else
					szTip = g_tStrings.STR_GUILD_ACCESS_3
				end
			end
			if szTip and szTip ~= "" then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				local guild = GetTongClient()
				local szGroupSel = guild.GetGroupInfo(this:GetParent():GetParent().dwGroup).szName
				local szGroupDst = guild.GetGroupInfo(this.nGroupID).szName
				OutputTip("<text>text=" ..EncodeComponentsString(FormatString(szTip, szGroupSel, szGroupDst)) .. "font=106 </text>", 300, {x, y, w, h})
			end
		else
			local szTip = g_tStrings.STR_GUILD_BASIC_ACCESS_TIP[this.nAccessGroup]
			if szTip and szTip ~= "" then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputTip(szTip, 300, {x, y, w, h})
			end
		end
	end
end

function GuildPanel.OnMouseLeave()
	if this.bAccess then
		HideTip()
	end
end

function GuildPanel.OnLButtonUp()
end

function GuildPanel.OnLButtonHold()
	local szName = this:GetName()
	local page = this:GetParent()
	if szName == "Btn_Up" then
		page:Lookup("Scroll_ListBig"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		page:Lookup("Scroll_ListBig"):ScrollNext(1)
	elseif szName == "Btn_NoticeUp" then
		page:Lookup("Scroll_Notice"):ScrollPrev(1)
	elseif szName == "Btn_NoticeDown" then
		page:Lookup("Scroll_Notice"):ScrollNext(1)
	elseif szName == "Btn_TipsUp" then
		page:Lookup("Scroll_Tips"):ScrollPrev(1)
	elseif szName == "Btn_TipsDown" then
		page:Lookup("Scroll_Tips"):ScrollNext(1)
	elseif szName == "Btn_BigUp" then
		page:Lookup("Scroll_ListBig"):ScrollPrev(1)
	elseif szName == "Btn_BigDown" then
		page:Lookup("Scroll_ListBig"):ScrollNext(1)
	elseif szName == "Btn_IntroductionUp" then
		page:Lookup("Scroll_Introduction"):ScrollPrev(1)
	elseif szName == "Btn_IntroductionDown" then
		page:Lookup("Scroll_Introduction"):ScrollNext(1)
	elseif szName == "Btn_RuleUp" then
		page:Lookup("Scroll_Rule"):ScrollPrev(1)
	elseif szName == "Btn_RuleDown" then
		page:Lookup("Scroll_Rule"):ScrollNext(1)
	elseif szName == "Btn_MUp" then
		page:Lookup("Scroll_MList"):ScrollPrev(1)
	elseif szName == "Btn_MDown" then
		page:Lookup("Scroll_MList"):ScrollNext(1)
	elseif szName == "Btn_MoneyUp" then
		page:Lookup("Scroll_ListMoney"):ScrollPrev(1)
	elseif szName == "Btn_MoneyDown" then
		page:Lookup("Scroll_ListMoney"):ScrollNext(1)
	elseif szName == "Btn_GoodsUp" then
		page:Lookup("Scroll_ListGoods"):ScrollPrev(1)
	elseif szName == "Btn_GoodsDown" then
		page:Lookup("Scroll_ListGoods"):ScrollNext(1)
	elseif szName == "Btn_DepUp" then
		page:Lookup("Scroll_ListDep"):ScrollPrev(1)
	elseif szName == "Btn_DepDown" then
		page:Lookup("Scroll_ListDep"):ScrollNext(1)
	end
end

function GuildPanel.OnCloseGuildPanel(frame, bDisableSound)
	local guild = GetTongClient()
	local player = GetClientPlayer()

	local pageSet = frame:Lookup("PageSet_Total")
	local pageBasic = pageSet:Lookup("Page_Basic")

	local szChange = ""
	local pageNotice = pageBasic:Lookup("PageSet_Info/Page_Notice")
	if pageNotice:Lookup("Edit_Notice"):GetText() ~= guild.szAnnouncement then
		szChange = g_tStrings.STR_GUILD_C_A
	end

	local pageTips = pageBasic:Lookup("PageSet_Info/Page_Tips")
	if pageTips:Lookup("Edit_Tips"):GetText() ~= guild.szOnlineMessage then
		if szMsg ~= "" then
			szChange = szChange..g_tStrings.STR_COMMA
		end
		szChange = szChange..g_tStrings.STR_GUILD_C_T
	end

	local pageSecret = pageSet:Lookup("Page_Secret")

	local pageSaid = pageSecret:Lookup("Wnd_Said")
	if pageSaid:Lookup("Edit_Tell"):GetText() ~= guild.szIntroduction then
		if szMsg ~= "" then
			szChange = szChange..g_tStrings.STR_COMMA
		end
		szChange = szChange..g_tStrings.STR_GUILD_C_I
	end

	local pageSystem = pageSecret:Lookup("Wnd_System")
	if pageSystem:Lookup("Edit_System"):GetText() ~= guild.szRules then
		if szMsg ~= "" then
			szChange = szChange..g_tStrings.STR_COMMA
		end
		szChange = szChange..g_tStrings.STR_GUILD_C_R
	end

	if szChange ~= "" then
		local msg =
		{
			szMessage = FormatString(g_tStrings.STR_GUILD_C, szChange),
			szName = "CloseGuildPanelConfirm",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() CloseGuildPanel() end, },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	else
		CloseGuildPanel(bDisableSound)
	end
end

function GuildPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		GuildPanel.OnCloseGuildPanel(this:GetRoot())
	elseif szName == "Btn_Delete" then
		local dwID = this:GetParent().dwID
		local msg =
		{
			szMessage = FormatString(g_tStrings.STR_GUILD_KICK_SURE, GetTongClient().GetMemberInfo(dwID).szName),
			szName = "DeleteGuildMemberConfirm",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetTongClient().ApplyKickOutMember(dwID) end, },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szName == "Btn_Add" then
		if IsGuildAddMemberOpened() then
			CloseGuildAddMember()
		else
			OpenGuildAddMember()
		end
	elseif szName == "Btn_CloseMember" then
		local wndMembers = this:GetParent()
		local frame = wndMembers:GetParent()
		wndMembers:GetParent():Lookup("PageSet_Total/Page_Basic").bClose = true
		GuildPanel.UpdateAddOnPanelShow(frame)
	elseif szName == "Btn_Team" then
		local guild = GetTongClient()
		local info = guild.GetMemberInfo(this:GetParent().dwID)
		GetClientTeam().InviteJoinTeam(info.szName)
		AddContactPeople(info.szName)
	elseif szName == "Btn_Leave" then --退出帮会
		local msg =
		{
			szMessage = g_tStrings.STR_GUILD_QUIT_SURE,
			szName = "LeaveCampConfirm",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetTongClient().Quit() end, },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
		}
		MessageBox(msg)
	elseif szName == "Btn_Apply" then
		local page = this:GetParent()
		if page:Lookup("Wnd_BankRights"):IsVisible() and page.dwGroup == 1 then
			local msg =
			{
				szMessage = g_tStrings.GUILD_APPLY_BANK_RIGHT_SURE,
				szName = "ApplyBankRightsSure",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() if page:IsValid() then GuildPanel.ApplyManageChange(page) end end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
			}
			MessageBox(msg)			
		else
			GuildPanel.ApplyManageChange(page)
		end
	elseif szName == "Btn_Transfer" then
		local dwID = this:GetParent().dwID
		local szName = GetTongClient().GetMemberInfo(dwID).szName
		local szMsg = FormatLinkString(g_tStrings.STR_GUILD_CHANGE_MASTER_SURE, "font=162", GetFormatText(szName, 166), GetFormatText(g_tStrings.STR_GUILD_CHANGE_MASTER_INPUT, 163))
		local fnAction = function(szInput)
			if szInput == g_tStrings.STR_GUILD_CHANGE_MASTER_INPUT then
				GetTongClient().ChangeMaster(dwID)
			else
				local msg =
				{
					szMessage = g_tStrings.STR_GUILD_CHANGE_MASTER_ERROR,
					szName = "ChangeMasterSureError",
					{szOption = g_tStrings.STR_HOTKEY_SURE},
				}
				MessageBox(msg)
			end
		end
		GetUserInput(szMsg, fnAction, nil, nil, nil, "", 32, nil, true)
	elseif szName == "Btn_Publish" then
		local page = this:GetParent()
		local szMsg = page:Lookup("Edit_Msg"):GetText()
		local szYear = page:Lookup("Edit_Year"):GetText()
		local szMonth = page:Lookup("Edit_Month"):GetText()
		local szDay = page:Lookup("Edit_Day"):GetText()

		if szMsg == "" then
			GuildPanel.WaringMessageBox(g_tStrings.GUILD_WARNING_MSG)
		elseif szYear == "" or szMonth == "" or szDay == "" then
			GuildPanel.WaringMessageBox(g_tStrings.GUILD_WARNING_TIME)
		else
			local nYear, nMonth, nDay = tonumber(szYear), tonumber(szMonth), tonumber(szDay)
			if nYear < 1970 or nYear > 2038 or nMonth < 1 or nMonth > 12 or nDay < 1 or nDay > 31 then
				GuildPanel.WaringMessageBox(g_tStrings.GUILD_WARNING_TIME1)
			else
				GetTongClient().ApplyAddMemorabilia(DateToTime(nYear, nMonth, nDay, 0, 0, 0), szMsg)
			end
		end
	elseif szName == "Btn_Change" then
		local page = this:GetParent()
		local szMsg = page:Lookup("Edit_Msg"):GetText()
		local szYear = page:Lookup("Edit_Year"):GetText()
		local szMonth = page:Lookup("Edit_Month"):GetText()
		local szDay = page:Lookup("Edit_Day"):GetText()
		if szMsg == "" then
			GuildPanel.WaringMessageBox(g_tStrings.GUILD_WARNING_MSG)
		elseif szYear == "" or szMonth == "" or szDay == "" then
			GuildPanel.WaringMessageBox(g_tStrings.GUILD_WARNING_TIME)
		else
			local nYear, nMonth, nDay = tonumber(szYear), tonumber(szMonth), tonumber(szDay)
			if nYear < 1970 or nYear > 2038 or nMonth < 1 or nMonth > 12 or nDay < 1 or nDay > 31 then
				GuildPanel.WaringMessageBox(g_tStrings.GUILD_WARNING_TIME1)
			else
				local nTime = DateToTime(nYear, nMonth, nDay, 0, 0, 0)
				if szMsg ~= page.szText or nTime ~= page.nTime then
					GetTongClient().ApplyModifyMemorabilia(page.dwID, nTime, szMsg)
				end
			end
		end
	elseif szName == "Btn_DeleteMsg" then
		local page = this:GetParent()
		GetTongClient().ApplyDeleteMemorabilia(page.dwID)
	elseif szName == "Btn_Use" then
		local page = this:GetParent():Lookup("Wnd_Left")
		local guild = GetTongClient()
		for i = 1, 16, 1 do
			local edit = page:Lookup("Edit_SG"..i)
			if edit:IsVisible() then
				local szMoney = edit:GetText()
				local nMoney = 0
				if szMoney ~= "" then
					nMoney = tonumber(szMoney)
				end
				if guild.GetGroupWage(edit.nGroupID) ~= nMoney then
					guild.ModifyGroupWage(edit.nGroupID, nMoney)
				end
			end
		end
	elseif szName == "Btn_Give" then
		local page = this:GetParent():Lookup("Wnd_Right")
		local szG = page:Lookup("Edit_MoneyG"):GetText()
		local szS = page:Lookup("Edit_MoneyS"):GetText()
		--local szC = page:Lookup("Edit_MoneyC"):GetText()
		local nMoney = 0
		if szG and szG ~= "" then
			nMoney = nMoney + tonumber(szG) * 10000
		end
		if szS and szS ~= "" then
			nMoney = nMoney + tonumber(szS) * 100
		end
		if nMoney > 0 then
			local fnSave = function()
				GetTongClient().SaveMoney(nMoney)
				if page and page:IsValid() then
					page:Lookup("Edit_MoneyG"):SetText("")
					page:Lookup("Edit_MoneyS"):SetText("")
					page:Lookup("Edit_MoneyC"):SetText("")
				end
			end
			local msg =
			{
				bRichText = true,
				szMessage = FormatLinkString(g_tStrings.STR_GUILD_SAVE_SURE, "font=18", GetMoneyTipText(nMoney, 18)),
				szName = "GuildPaySalaySure",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnSave },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		end
	elseif szName == "Btn_Arena" then
		OpenTongArena()
	elseif szName == "Btn_Salary" then
		OpenGuildSalaryPanel()
    elseif szName == "Btn_Zhujiujie" then
        local tMsg =
        {
            szMessage = g_tStrings.GUILP_PANEL_START_ACTIVITY,
            szName = "StartZhujiujie",
            {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("On_Tong_StartZhuJiuJieRequest") end },
            {szOption = g_tStrings.STR_HOTKEY_CANCEL},
        }
        MessageBox(tMsg)
    elseif szName == "Btn_StartPigRun" then
        local tMsg =
        {
            szMessage = g_tStrings.GUILP_PANEL_START_ACTIVITY,
            szName = "StartZhujiujie",
            {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("On_Tong_StartPigRunRequest") end },
            {szOption = g_tStrings.STR_HOTKEY_CANCEL},
        }
        MessageBox(tMsg)
    else
        GuildDiplomacy.OnLButtonClick()
	end
end

function GuildPanel.WaringMessageBox(szMsg)
	local msg =
	{
		szMessage = szMsg,
		szName = "GuildWaringMessageBox",
		{szOption = g_tStrings.STR_HOTKEY_SURE},
	}
	MessageBox(msg)
end

function GuildPanel.ApplyManageChange(page)
	local guild = GetTongClient()
	local dwGroup = page.dwGroup
	local groupInfo = guild.GetGroupInfo(dwGroup)

	local edit = page:Lookup("Edit_RankName")
	local szGroup = edit:GetText()
	if szGroup ~= "" and szGroup ~= groupInfo.szName then
		guild.ModifyGroupName(dwGroup, szGroup)

		local hList = page:Lookup("", "Handle_MList")
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount , 1 do
			local hGroup = hList:Lookup(i)
			if hGroup.dwGroup == dwGroup then
				hGroup:Lookup("Text_Rank"):SetText(szGroup)
				break
			end
		end
	end

	local wndManage = page:Lookup("Wnd_Manage")
	if wndManage:IsVisible() then
		local c = wndManage:GetFirstChild()
		while c do
			if c:IsVisible() then
				if c.bAdvance then
					if guild.CheckAdvanceOperationGroup(page.dwGroup, c.nGroupID, c.nAccessGroup) ~= c:IsCheckBoxChecked() then
						guild.ModifyAdvanceOperationMask(page.dwGroup, c.nGroupID, c.nAccessGroup, c:IsCheckBoxChecked())
					end
				else
					if guild.CheckBaseOperationGroup(page.dwGroup, c.nAccessGroup) ~= c:IsCheckBoxChecked() then
						guild.ModifyBaseOperationMask(page.dwGroup, c.nAccessGroup, c:IsCheckBoxChecked())
					end
				end
			end
			c = c:GetNext()
		end
	else
		local wndBank = page:Lookup("Wnd_BankRights")
		if wndBank:IsVisible() then
			local c = wndBank:GetFirstChild()
			while c do
				if c:IsVisible() and c.bAccess then
					if c.bAdvance then
						if guild.CheckAdvanceOperationGroup(page.dwGroup, c.nGroupID, c.nAccessGroup) ~= c:IsCheckBoxChecked() then
							guild.ModifyAdvanceOperationMask(page.dwGroup, c.nGroupID, c.nAccessGroup, c:IsCheckBoxChecked())
						end
					else
						if guild.CheckBaseOperationGroup(page.dwGroup, c.nAccessGroup) ~= c:IsCheckBoxChecked() then
							guild.ModifyBaseOperationMask(page.dwGroup, c.nAccessGroup, c:IsCheckBoxChecked())
						end
					end
				end
				c = c:GetNext()
			end
		end
	end

	page:Lookup("Btn_Apply"):Enable(false)
end

function GuildPanel.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_Tip" then
		if this:GetText() == g_tStrings.STR_GUILD_EDIT_REMARK then
			this:SetText("")
		else
			this:SelectAll()
		end
	end
end

function GuildPanel.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_Tip" then
		local szText = this:GetText()
		if szText == "" then
			this:SetText(g_tStrings.STR_GUILD_EDIT_REMARK)
		end
		local wndMembers = this:GetParent()
		if wndMembers.dwID then
			local guild = GetTongClient()
			local info = guild.GetMemberInfo(wndMembers.dwID)
			if szText ~= info.szRemark then
				guild.ChangeMemberRemark(wndMembers.dwID, szText)
				if not GuildPanel.bGuildState then
					local hList = wndMembers:GetRoot():Lookup("PageSet_Total/Page_Basic", "Handle_ListBasic")
					local nCount = hList:GetItemCount() - 1
					for i = 0, nCount, 1 do
						local hI = hList:Lookup(i)
						if hI.dwID == wndMembers.dwID then
							hI:Lookup("Desc"):SetText(szText)
							break
						end
					end
				end
			end
		end
	end
end

function GuildPanel.UpdateSelectMemberInfo(frame)
	local page = frame:Lookup("PageSet_Total/Page_Basic")
	local wndMember = frame:Lookup("Wnd_Members")
	wndMember.dwID = page.dwID
	if not page.dwID then
		return
	end

	local guild = GetTongClient()
	local info = guild.GetMemberInfo(page.dwID)
	local groupInfo = guild.GetGroupInfo(info.nGroupID)

	local player = GetClientPlayer()
	local pInfo = guild.GetMemberInfo(player.dwID)
	local pgroupInfo = guild.GetGroupInfo(pInfo.nGroupID)

	local edit = wndMember:Lookup("Edit_Tip")
	local bEnable = guild.CanAdvanceOperate(pInfo.nGroupID, info.nGroupID, TONG_OPERATION_INDEX.MODIFY_MEMBER_REMARK)
	edit:Enable(bEnable)
	if bEnable and info.szRemark == "" then
		edit:SetText(g_tStrings.STR_GUILD_EDIT_REMARK)
	else
		edit:SetText(info.szRemark)
	end

	local handle = wndMember:Lookup("", "")
	handle:Lookup("Text_MName"):SetText(info.szName)
	handle:Lookup("Text_MLevel"):SetText(info.nLevel)
	handle:Lookup("Text_MSchool"):SetText(GetForceTitle(info.nForceID))
	if info.bIsOnline then
		handle:Lookup("Text_MLastOnLine"):SetText(g_tStrings.STR_GUILD_ONLINE)
	else
		handle:Lookup("Text_MLastOnLine"):SetText(GuildPanel.GetLastOnLineTimeText(info.nLastOfflineTime))
	end

	wndMember:Lookup("Btn_Transfer"):Enable(player.dwID == guild.dwMaster and player.dwID ~= page.dwID)
	wndMember:Lookup("Btn_Doown", "Text_Doown"):SetText(groupInfo.szName)
	wndMember:Lookup("Btn_Doown"):Enable(guild.CheckAdvanceOperationGroup(pInfo.nGroupID, info.nGroupID, 0)) --0是管理人员
	wndMember:Lookup("Btn_Delete"):Enable(guild.CheckAdvanceOperationGroup(pInfo.nGroupID, info.nGroupID, 0)) --0是管理人员

	wndMember:Lookup("Btn_Team"):Enable(player.dwID ~= page.dwID)
end

function GuildPanel.UpdateAccessPage(checkBox)
	local page = checkBox:GetParent()
	if page.Ignore then
		return
	end
	page.Ignore = true
	local szName = checkBox:GetName()
	local a =
	{
		["CheckBox_BasicM"] = 0,
		["CheckBox_BankM"] = 0,
		["CheckBox_Member"] = 0,
--		["CheckBox_Pay"] = 1,
		["CheckBox_MRemark"] = 2,
		["CheckBox_Group"] = 3
	}

	for k, v in pairs(a) do
		local c = page:Lookup(k)
		c.bAccessCheckBox = true
		c.nAccessGroup = v
		c:Check(k == szName)
	end
	page.Ignore = false
	page.szActive = szName

	local player = GetClientPlayer()
	local guild = GetTongClient()
	local info = guild.GetMemberInfo(player.dwID)
	if not info then
		return
	end

	local wndManage = page:Lookup("Wnd_Manage")
	local wndBank = page:Lookup("Wnd_BankRights")
	if szName == "CheckBox_BasicM" then
		wndManage:Show()
		wndBank:Hide()
		local a = 
		{
			{nAccessGroup = 0, szName = g_tStrings.STR_GUILD_BASIC_ACCESS_NAME[0]},
			{nAccessGroup = 1, szName = g_tStrings.STR_GUILD_BASIC_ACCESS_NAME[1]},
			{nAccessGroup = 2, szName = g_tStrings.STR_GUILD_BASIC_ACCESS_NAME[2]},
			{nAccessGroup = 4, szName = g_tStrings.STR_GUILD_BASIC_ACCESS_NAME[4]},
			{nAccessGroup = 3, szName = g_tStrings.STR_GUILD_BASIC_ACCESS_NAME[3]},
			{nAccessGroup = 25, szName = g_tStrings.STR_GUILD_BASIC_ACCESS_NAME[25]},
		}

		local nIndex = 1
		local c = wndManage:GetFirstChild()
		while c do
			if a[nIndex] then
				c:Show()
				c.bAccess = true
				c.bAdvance = false
				c.nAccessGroup = a[nIndex].nAccessGroup
				c:Lookup("", ""):Lookup(0):SetText(a[nIndex].szName)
				c:Check(guild.CheckBaseOperationGroup(page.dwGroup, c.nAccessGroup))
				c:Enable(guild.CanBaseGrant(info.nGroupID, page.dwGroup, c.nAccessGroup))
			else
				c:Hide()
			end
			nIndex = nIndex + 1
			c = c:GetNext()
		end
	elseif szName == "CheckBox_BankM" then
		wndManage:Hide()
		wndBank:Show()
		wndBank.bIgnore = true
		for i = 1, 9, 1 do
			local c = wndBank:Lookup("CheckBox_BankStore"..i)
			c.bAccess = true
			c.bAdvance = false
			c.nAccessGroup = 5 + ((i - 1) * 2)
			c:Check(guild.CheckBaseOperationGroup(page.dwGroup, c.nAccessGroup))
			c:Enable(guild.CanBaseGrant(info.nGroupID, page.dwGroup, c.nAccessGroup))
			c = wndBank:Lookup("CheckBox_BankTake"..i)
			c.bAccess = true
			c.bAdvance = false
			c.nAccessGroup = 6 + ((i - 1) * 2)
			c:Check(guild.CheckBaseOperationGroup(page.dwGroup, c.nAccessGroup))
			c:Enable(guild.CanBaseGrant(info.nGroupID, page.dwGroup, c.nAccessGroup))			
		end
		wndBank.bIgnore = false
		GuildPanel.UpdateBankRights(wndBank)
	else
		wndManage:Show()
		wndBank:Hide()	
		local c = wndManage:GetFirstChild()
		for i = 0, 15, 1 do
			local groupInfo = guild.GetGroupInfo(i)
			if groupInfo.bEnable then
				c.bAccess = true
				c.bAdvance = true
				c.nAccessGroup = checkBox.nAccessGroup
				c.nGroupID = i
				c:Show()
				c:Lookup("", ""):Lookup(0):SetText(groupInfo.szName)
				c:Check(guild.CheckAdvanceOperationGroup(page.dwGroup, c.nGroupID, c.nAccessGroup))
				c:Enable(guild.CanAdvanceGrant(info.nGroupID, page.dwGroup, c.nGroupID, c.nAccessGroup))
				c = c:GetNext()
			end
		end
		while c do
			c:Hide()
			c = c:GetNext()
		end
	end

	wndManage:Lookup("", "Text_Tip"):SetText(FormatString(g_tStrings.STR_GUILD_ACCESS_TIP[szName], guild.GetGroupInfo(page.dwGroup).szName))

	if not page.bIgnorApply then
		if page.bChanged then
			page:Lookup("Btn_Apply"):Enable(true)
		else
			page:Lookup("Btn_Apply"):Enable(false)
		end
	end
end

function GuildPanel.UpdateSelectGroupInfo(page)
	page.bIgnorApply = true

	local player = GetClientPlayer()
	local guild = GetTongClient()
	local info = guild.GetMemberInfo(player.dwID)
	if not info then
		return
	end

	local edit = page:Lookup("Edit_RankName")
	local groupInfo = guild.GetGroupInfo(page.dwGroup)
	edit:SetText(groupInfo.szName)
	edit:Enable(guild.CanAdvanceOperate(info.nGroupID, page.dwGroup, TONG_OPERATION_INDEX.MODIFY_GROUP_NAME))

	GuildPanel.UpdateAccessPage(page:Lookup(page.szActive))

	page.bChanged = false
	page.bIgnorApply = false

	page:Lookup("Btn_Apply"):Enable(false)
end

function GuildPanel.HandleRenameResult(nResult)
	if not nResult then
		return
	end

	local szMsg = g_tStrings.tGuildRenameEventCode[nResult]

	if not szMsg then
		return
	end

	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = szMsg,
		szName = "TongEventCode",
		{
		    szOption = g_tStrings.STR_HOTKEY_SURE,
			fnAction = function()
				if nResult == TONG_EVENT_CODE.RENAME_SUCCESS then
					CloseGuildRename()
					if IsGuildPanelOpened() then
						GetTongClient().ApplyTongInfo()
					end
				end
			end
		},
	}
	MessageBox(tMsg)
end

function GuildPanel.UpdateTongActivityList(hFrame, bExpand)
	if hFrame.bInitTongActivityList then
		return
	end
	hFrame.bInitTongActivityList = true
	local hWnd = hFrame:Lookup("PageSet_Total/Page_Ploy")
	local hList = hWnd:Lookup("", "Handle_Content")
	
	local tTongActivity = Table_GetTongActivityList()
	hList:Clear()
	
	for _, tClass in ipairs(tTongActivity) do
		local hClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_OneClass", "TreeLeaf_TongActivity")
		if bExpand then
			hClass:Expand()
		end
		hClass:Lookup("Text_OneClass"):SetText(tClass.tInfo.szName)
		hClass.dwClassID = tClass.tInfo.dwClassID
		hClass.dwSubClassID = tClass.tInfo.dwSubClassID
		hClass.dwID = tClass.tInfo.dwID
		hClass.bTongActivityClass = true
		
		for _, tSub in ipairs(tClass.tList) do
			local hSubClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_TwoClass", "TreeLeaf_TongActivity")
			if bExpand then
				hSubClass:Expand()
			end
			hSubClass:Lookup("Text_TwoClass"):SetText(tSub.tInfo.szName)
			hSubClass.dwClassID = tClass.tInfo.dwClassID
			hSubClass.dwSubClassID = tSub.tInfo.dwSubClassID
			hSubClass.dwID = tSub.tInfo.dwID
			hSubClass.bTongActivitySubClass = true
			
			for _, tRecord in ipairs(tSub.tList) do
				local hTitle = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_ThreeClass", "TreeLeaf_TongActivity")
				hTitle:Lookup("Text_ThreeClass"):SetText(tRecord.tInfo.szName)
				hTitle.dwClassID = tClass.tInfo.dwClassID
				hTitle.dwSubClassID = tSub.tInfo.dwSubClassID
				hTitle.dwID = tRecord.tInfo.dwID
				hTitle.bTongActivityTitle = true
			end
		end
	end
	hList:FormatAllItemPos()
	
	GuildPanel.SelectTongActivity(hList:Lookup(0))
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Content", "GuildPanel", false)
end

function GuildPanel.SelectTongActivity(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	local bFind = false
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			GuildPanel.UpdateTongActivityTitle(hChild)
			break
		end
	end
	
	hSelect.bSelect = true
	GuildPanel.UpdateTongActivityTitle(hSelect)
	GuildPanel.UpdateTongActivityInfo(hList:GetParent():GetParent(), hSelect.dwClassID, hSelect.dwSubClassID, hSelect.dwID)
end


function GuildPanel.UpdateTongActivityTitle(hItem)
	local hImage = hItem:Lookup(1)
	if hItem.bSelect then
		hImage:Show()
	elseif hItem.bMouse then
		hImage:Show()
	else
		hImage:Hide()
	end
end

function GuildPanel.UpdateTongActivityInfo(hWnd, dwClassID, dwSubClassID, dwID)
	local tRecord = Table_GetTongActivityContent(dwClassID, dwSubClassID, dwID)
	local hInfo = hWnd:Lookup("", "Handle_Info")
	hInfo:Clear()
	local szText = ""
	local nTitleFont = 59
	local nTContentFont = 18
	if tRecord.szTime ~= "" then
		szText = GetFormatText(g_tStrings.TONG_ACTIVITY_TIME, nTitleFont) .. GetFormatText(tRecord.szTime .. "\n", nTContentFont)
	end
	
	if tRecord.szPlace ~= "" then
		szText = szText .. GetFormatText(g_tStrings.TONG_ACTIVITY_PLACE, nTitleFont) .. GetFormatText(tRecord.szPlace .. "\n", nTContentFont)
	end
	
	if tRecord.szJoinLevel ~= "" then
		szText = szText .. GetFormatText(g_tStrings.TONG_ACTIVITY_JOIN_LEVEL, nTitleFont) .. GetFormatText(tRecord.szJoinLevel.. "\n", nTContentFont)
	end
	
	if tRecord.szReward ~= "" then
		szText = szText .. GetFormatText(g_tStrings.TONG_ACTIVITY_REOARD, nTitleFont) .. GetFormatText(tRecord.szReward .. "\n", nTContentFont)
	end
	
	szText = szText .. GetFormatText(g_tStrings.TONG_ACTIVITY_CONTENT .. "\n", nTitleFont) .. tRecord.szContent
	
	hInfo:AppendItemFromString(szText)
	
	hInfo:FormatAllItemPos()
	GuildPanel.UpdateTongActivityBtnState(hWnd, dwClassID, dwSubClassID, dwID)
	
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Info", "GuildPanel", true)
end

function GuildPanel.UpdateTongActivityBtnState(hWnd, dwClassID, dwSubClassID, dwID)
	for szBtnName, tBtnID in pairs(tTongActivityBtn) do
		local bShow = false
		local hBtn = hWnd:Lookup(szBtnName)
		if hBtn then
			for _, tID in ipairs(tBtnID) do
				local nCount = #tID
				if (nCount == 1 and dwClassID == tID[1]) or 
				(nCount == 2 and dwClassID == tID[1] and dwSubClassID == tID[2]) or 
				(nCount == 3 and dwClassID == tID[1] and dwSubClassID == tID[2] and dwId == tID[3]) 
				then
					bShow = true
					break
				end
			end
			if bShow then
				hBtn:Show()
			else
				hBtn:Hide()
			end
		end
	end
end

function OpenGuildPanel(bDisableSound)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsGuildPanelOpened() then
		return
	end

	local player = GetClientPlayer()
	if not player or not player.dwTongID or player.dwTongID == 0 then
		-- OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_NOT_ACTIVE)
        if IsGuildListPanelOpened() then
            CloseGuildListPanel()
        else
            OpenGuildListPanel(nil, true)
        end
		return
	end
    
	HideGuildSysBtnAnimate()
	
	local frame = Wnd.OpenWindow("GuildPanel")
	frame:Show()
	GuildDiplomacy.InitWhenOpen(frame)
	GuildPanel.Update(frame)
    
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsGuildPanelOpened()
	local frame = Station.Lookup("Normal/GuildPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseGuildPanel(bDisableSound)
	if not IsGuildPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/GuildPanel")
	frame:Hide()

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

RegisterEvent("TONG_EVENT_NOTIFY", function(event) GuildPanel.OnEventNotify(event) end)

function GuildPanel_OnLinkTongActivity(dwClassID, dwSubClassID, dwID)
	OpenGuildPanel()
	local hFrame = Station.Lookup("Normal/GuildPanel")
	if not hFrame then
		return
	end
    local hPageTotal = hFrame:Lookup("PageSet_Total")
    hPageTotal:ActivePage("Page_Ploy")
	local hWnd = hPageTotal:Lookup("Page_Ploy")
	local hList = hWnd:Lookup("", "Handle_Content")
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hTitle = hList:Lookup(i)
		if (hTitle.bTongActivityClass and hTitle.dwClassID == dwClassID) 
		or (hTitle.bTongActivitySubClass and hTitle.dwClassID == dwClassID and hTitle.dwSubClassID == dwSubClassID) then
			hTitle:Expand()
			hList:FormatAllItemPos()
			GuildPanel.SelectTongActivity(hTitle)
			FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Content", "GuildPanel", false)
		end
		
		if hTitle.dwClassID == dwClassID and hTitle.dwSubClassID == dwSubClassID and hTitle.dwID == dwID then
			GuildPanel.SelectTongActivity(hTitle)
			break
		end
	end
end

function InvitePlayerJoinTong(szName)
	local szFont = GetMsgFontString("MSG_SYS")
	OutputMessage("MSG_SYS", FormatLinkString(g_tStrings.STR_GUILD_INVITE_1, szFont, MakeNameLink("["..szName.."]", szFont)), true)
	local guild = GetTongClient()
	if guild  then
		guild.InvitePlayerJoinTong(szName)
	end
end

local function OnCommentToKnowGuild()
	local player = GetClientPlayer()
	if player.nLevel >=  10 and player.dwTongID and player.dwTongID == 0 then
		local hObject = GetSysMenuBtnObject("Btn_Guild")
		if hObject then
			FireHelpEvent("OnCommentToKnowGuild", hObject, 1)
		end
	end
end

local function OnPlayerLevelUpdate()
	local player = GetClientPlayer()
	if player.nLevel ==  10 then
		OnCommentToKnowGuild()
	end
end

local function OnTipKnowGuild()
	if arg0 == "success" then
		local hObject = GetSysMenuBtnObject("Btn_Guild")
		if hObject then
			local hAni = hObject:Lookup("", "Animate_Guild")
			hAni:Show()
		end
	end
end


RegisterEvent("LOADING_END", OnCommentToKnowGuild)
RegisterEvent("PLAYER_LEVEL_UPDATE", OnPlayerLevelUpdate)

RegisterEvent("COMMENT_TO_KNOW_GUILD", OnTipKnowGuild)

do
    RegisterScrollEvent("GuildPanel")
    UnRegisterScrollAllControl("GuildPanel")
	
        
    local szFramePath = "Normal/GuildPanel"
    local szWndPath = "PageSet_Total/Page_Ploy"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_DisplayUp", szWndPath.."/Btn_DisplayDown", 
        szWndPath.."/Scroll_Display", 
        {szWndPath, "Handle_Info"})
		
	local szFramePath = "Normal/GuildPanel"
    local szWndPath = "PageSet_Total/Page_Ploy"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_PListUp", szWndPath.."/Btn_PListDown", 
        szWndPath.."/Scroll_PList", 
        {szWndPath, "Handle_Content"})
end


