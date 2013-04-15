
local INI_FILE = "ui/Config/Default/GuildListPanel.ini"
local GUILD_LIST_AD_LIST_PAGE_COUNT = 10
local GUILD_LIST_TOP_TEN_FONT_MY = 166
local GUILD_LIST_TOP_TEN_FONT_LAST_COST = 162
local MAX_PAY_GOLD = 1000000
local ADD_ADLIST_PAY_GOLD = 100
GuildListPanel = {}

local function IsClientPlayerHaveTong()
	local hPlayer = GetClientPlayer()
	if not hPlayer or not hPlayer.dwTongID or hPlayer.dwTongID == 0 then
		return false
	end
	return true
end
local tCampFrame =
{
	[CAMP.NEUTRAL] = {"ui/Image/UICommon/CommonPanel.UITex", 10},
	[CAMP.GOOD] = {"ui/Image/button/ShopButton.UITex", 43},
	[CAMP.EVIL] = {"ui/Image/button/ShopButton.UITex", 40},
}

function GuildListPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_GET_TOPTEN_TONGLIST")
	this:RegisterEvent("ON_GET_AD_TONGLIST")
	this:RegisterEvent("ON_GET_TOP_TEN_COST")
	this:RegisterEvent("UPDATE_TONG_SIMPLE_INFO")
	this:RegisterEvent("ON_TONG_TOP_TEN_RESPOND")
	--this:RegisterEvent("ON_TONG_ADD_ADLIST_RESPOND")
	this:RegisterEvent("UPDATE_TONG_ROSTER_FINISH")
	this:RegisterEvent("UPDATE_TONG_INFO_FINISH")
    
    local hPage = this:Lookup("PageSet_List/Page_AdList")
	local hBtn = hPage:Lookup("Btn_AddAdList")
    hBtn:Hide()
	
	GuildListPanel.OnEvent("UI_SCALED")
end

function GuildListPanel.OnEvent(szEvent)
	if szEvent == "ON_GET_TOPTEN_TONGLIST" then
		if arg0 then -- 请求成功
			GuildListPanel.UpdateTopTenList(this, arg1, arg2)
		end
	elseif szEvent == "ON_GET_AD_TONGLIST" then
		if arg0 then -- 请求成功
			GuildListPanel.UpdateADListPage(this, GuildListPanel.nListPage, arg1, arg2, arg3)
		end
	elseif szEvent == "ON_GET_TOP_TEN_COST" then
		GuildListPanel.UpdateTopTenCost(this, arg0, arg2, arg1)
	elseif szEvent == "UPDATE_TONG_SIMPLE_INFO" then
		local hCheckRecommend = this:Lookup("PageSet_List/CheckBox_TopTen")
		local hCheckGuild = this:Lookup("PageSet_List/CheckBox_ADList")
		if hCheckRecommend:IsCheckBoxChecked() then
			RemoteCallToServer("On_Tong_GetTopTenTongList")
		elseif hCheckGuild:IsCheckBoxChecked() then
			RemoteCallToServer("On_Tong_GetADTongList", GuildListPanel.nListPage) 
		end
	elseif szEvent == "ON_TONG_TOP_TEN_RESPOND" then
		local nResult = arg0
		if nResult == TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_SUCCESS then
			RemoteCallToServer("On_Tong_GetTopTenCost")
		end
	elseif szEvent == "ON_TONG_ADD_ADLIST_RESPOND" then
		local nResult = arg0
		if nResult == TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_SUCCESS then
			RemoteCallToServer("On_Tong_GetADTongList", GuildListPanel.nListPage)
		end
	elseif szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif szEvent == "UPDATE_TONG_ROSTER_FINISH" or szEvent == "UPDATE_TONG_INFO_FINISH" then
		GuildListPanel.bTongUpdate = true
		GuildListPanel.UpdateAddAdListBtnState(this)
		GuildListPanel.UpdateAddTopTenBtnState(this)
	end
end

function GuildListPanel.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer or hPlayer.nMoveState == MOVE_STATE.ON_DEATH then
		CloseGuildListPanel()
		return
	end
	if this.dwNpcID then
		local dwNpcID = this.dwNpcID
		local hNpc = GetNpc(dwNpcID)
		if not hNpc or not hNpc.CanDialog(hPlayer) then
			CloseGuildListPanel()
		end
	end
end

function GuildListPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Prev" then
		GuildListPanel.nListPage = GuildListPanel.nListPage - 1
		RemoteCallToServer("On_Tong_GetADTongList", GuildListPanel.nListPage)
		this:Enable(false)
	elseif szName == "Btn_Next" then
		GuildListPanel.nListPage = GuildListPanel.nListPage + 1
		RemoteCallToServer("On_Tong_GetADTongList", GuildListPanel.nListPage)
		this:Enable(false)
	elseif szName == "Btn_ADList" or szName == "Btn_TopTen" then
		if not GuildListPanel.szSelectName then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TONG_APPLY_JOIN_SELECT_TONG)
			OutputMessage("MSG_SYS", g_tStrings.TONG_APPLY_JOIN_SELECT_TONG .. g_tStrings.STR_FULL_STOP .. "\n")
		else
			local nWidth, nHeight = Station.GetClientSize()
		    local szTongName = GuildListPanel.szSelectName
			local tMsg =
			{
			    x = nWidth / 2, y = nHeight / 2,
				szMessage = g_tStrings.STR_GUILD_LIST_JOIN_REQUEST,
				szName = "TongApplyJoinRequest",
				fnAutoClose = function() return not IsGuildListPanelOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("On_Tong_ApplyJoinRequest", szTongName) end },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(tMsg)
		end
	elseif szName == "Btn_Close" then
		CloseGuildListPanel()
	elseif szName == "Btn_AddTopTen" then
		local hFrame = this:GetRoot()
		GuildListPanel.AddTopTenRequest(hFrame)
    --[[
	elseif szName == "Btn_AddAdList" then
		local nWidth, nHeight = Station.GetClientSize()
		local szMsg = GetFormatText(g_tStrings.STR_GUILD_LIST_Add_LIST_SURE, 0)
		szMsg = szMsg .. GetGoldText(ADD_ADLIST_PAY_GOLD, 0)
		local tMsg =
		{
		    x = nWidth / 2, y = nHeight / 2,
			szMessage = szMsg,
			bRichText = true,
			szName = "TongAddADListRequest",
			fnAutoClose = function() return not IsGuildListPanelOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("On_Tong_AddADListRequest", szTongName) end },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(tMsg)
     --]]
	end
end

function GuildListPanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_BidGold" then
		if not GuildListPanel.bInit then
			GuildListPanel.bInit = true
			local hPageTopTen = this:GetParent()
			local bCheck = GuildListPanel.CheckTopTenCost(hPageTopTen)
			if bCheck then
				hPageTopTen:Lookup("Edit_BidGold"):SetText(MAX_PAY_GOLD)
			end
			GuildListPanel.bInit = false
		end
	end
end

function GuildListPanel.CheckTopTenCost(hPageTopTen)
	local nGold = 0
	local szGold = hPageTopTen:Lookup("Edit_BidGold"):GetText()
	if szGold ~= "" then
		nGold = tonumber(szGold)
	end
	
	if nGold > MAX_PAY_GOLD then
		return true
	end
	
	return false
end

function GuildListPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_TopTen" then
		GuildListPanel.SelectTopTen(this)
	elseif szName == "Handle_AD" then
		GuildListPanel.SelectAD(this)
	end
end

function GuildListPanel.OnItemRButtonDown()
	local szName = this:GetName()
	if szName == "Text_TMasterName" or szName == "Text_MasterName" then
		local szPlayerName = this:GetText()
		tMenu = 
		{
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szPlayerName); GetPopupMenu():Hide() end},
		}
		PopupMenu(tMenu)
	end
end

function GuildListPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_TopTen" then
		this.bOver = true
		GuildListPanel.UpdateTopTenTitle(this)
	elseif szName == "Handle_AD" then
		this.bOver = true
		GuildListPanel.UpdateADTitle(this)
	end
end

function GuildListPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_TopTen" then
		this.bOver = false
		GuildListPanel.UpdateTopTenTitle(this)
	elseif szName == "Handle_AD" then
		this.bOver = false
		GuildListPanel.UpdateADTitle(this)
	end
end

function GuildListPanel.AddTopTenRequest(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end 
			
	local bHaveTong = IsClientPlayerHaveTong()
	if not bHaveTong then
		return
	end
	
	local hTongClient = GetTongClient()
	if not hTongClient then
		return
	end
	hTopTenPage = hFrame:Lookup("PageSet_List/Page_TopTen")
	local szText = ""
	szText = hTopTenPage:Lookup("Edit_BidGold"):GetText()
	local nCost = 0
	if szText and szText ~= "" then
		nCost = tonumber(szText)
	end
	
	if GuildListPanel.nLastCost and nCost <= GuildListPanel.nLastCost then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tTongAddTopTongReult[TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_LOWERFUNC])
		OutputMessage("MSG_SYS", g_tStrings.tTongAddTopTongReult[TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_LOWERFUNC] .. g_tStrings.STR_FULL_STOP .. "\n")
		return
	end
	
	local fnAllAutoClose = function()
		return not IsGuildListPanelOpened()
	end
	
	local OnAddTopTenRequest = function(szDesc)
		RemoteCallToServer("On_Tong_AddTopTenRequest", nCost, szDesc)
	end
	
	local OnWriteTongDesc = function()
		GetUserInput(g_tStrings.STR_GUILD_LIST_ADD_TPP_TEN_DESC, OnAddTopTenRequest, nil, fnAllAutoClose, nil, nil, 32)
	end
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
	    x = nWidth / 2, y = nHeight / 2,
		szMessage = g_tStrings.STR_GUILD_LIST_ADD_TPP_TEN_SURE,
		szName = "AddTopTenReuqest",
		fnAutoClose = fnAllAutoClose,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() OnWriteTongDesc() end },
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	MessageBox(tMsg)
end

function GuildListPanel.SelectTopTen(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			GuildListPanel.UpdateTopTenTitle(hChild)
		end
	end
	hSelect.bSelect = true
	GuildListPanel.UpdateTopTenTitle(hSelect)
	GuildListPanel.szSelectName = hSelect.szName
end

function GuildListPanel.UpdateTopTenTitle(hTitle)
	local hImage = hTitle:Lookup("Image_TGuildHighlight")
	if hTitle.bSelect then
		hImage:Show()
		hImage:SetAlpha(256)
	elseif hTitle.bOver then
		hImage:Show()
		hImage:SetAlpha(128)
	else
		hImage:Hide()
	end
end

function GuildListPanel.SelectAD(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			GuildListPanel.UpdateADTitle(hChild)
		end
	end
	hSelect.bSelect = true
	GuildListPanel.UpdateADTitle(hSelect)
	GuildListPanel.szSelectName = hSelect.szName
end

function GuildListPanel.UpdateADTitle(hTitle)
	local hImage = hTitle:Lookup("Image_GuildHighlight")
	if hTitle.bSelect then
		hImage:Show()
		hImage:SetAlpha(256)
	elseif hTitle.bOver then
		hImage:Show()
		hImage:SetAlpha(128)
	else
		hImage:Hide()
	end
end

function GuildListPanel.UpdateTopTenCost(hFrame, nLastCost, nLastRanking, nCost)
	GuildListPanel.nLastCost = nLastCost
	local hTopTenPage = hFrame:Lookup("PageSet_List/Page_TopTen")
	local hMyCost = hTopTenPage:Lookup("", "Handle_Bidders/Handle_Successsul")
	local hLastCost = hTopTenPage:Lookup("", "Handle_Bidders/Handle_LastCost")
	hMyCost:Clear()
	hLastCost:Clear()
	local szText = ""
	local hBtnAdd = hTopTenPage:Lookup("Btn_AddTopTen")
	hBtnAdd:Enable(true)
	local bTopTenAdded = false
	if nCost > 0 then
		szText = GetFormatText(g_tStrings.STR_GUILD_LIST_TOP_TEN_SUCCESS, GUILD_LIST_TOP_TEN_FONT_MY) .. GetGoldText(nCost, GUILD_LIST_TOP_TEN_FONT_MY)
		hMyCost:AppendItemFromString(szText)
		bTopTenAdded = true
	end
	
	szText = GetGoldText(nLastCost, GUILD_LIST_TOP_TEN_FONT_LAST_COST)
	hLastCost:AppendItemFromString(szText)
	
	hMyCost:FormatAllItemPos()
	hLastCost:FormatAllItemPos()
	
	GuildListPanel.UpdateAddTopTenBtnState(hFrame, bTopTenAdded)
end

function GuildListPanel.UpdateTopTenList(hFrame, nCount, tTongIDList)
	GuildListPanel.szSelectName = nil
	local hTopTenList = hFrame:Lookup("PageSet_List/Page_TopTen", "Handle_TopTenList")
	hTopTenList:Clear()
	for _, dwTongID in ipairs(tTongIDList) do
	--[[
	for i = 1, 10 do 
		local tTong = 
		{
			["nCamp"] = 1,
			["szTongName"] = "帮会名字啦啦啦",
			["szMasterName"] = "帮主名字",
			["nMemberCount"] = "100",
			["szADDescription"] = "描述什么的最讨厌了",
		}
		--]]
		local tTong = GetTongSimpleInfo(dwTongID)
		if tTong then
			local hTong = hTopTenList:AppendItemFromIni(INI_FILE, "Handle_TopTen")
			local tCampImage = tCampFrame[tTong.nCamp]
			hTong:Lookup("Image_TCamp"):FromUITex(tCampImage[1], tCampImage[2])
			hTong:Lookup("Text_TGuildName"):SetText(tTong.szTongName)
			hTong:Lookup("Text_TMasterName"):SetText(tTong.szMasterName)
			hTong:Lookup("Text_TNumber"):SetText(tTong.nMemberCount)
			hTong:Lookup("Text_TIntroduce"):SetText(tTong.szADDescription)
			hTong.szName = tTong.szTongName
			hTong:Show()
			GuildListPanel.UpdateTopTenTitle(hTong)
		else
			Log("Tong " .. dwTongID .. " not Exist")
		end
	end
	hTopTenList:FormatAllItemPos()
end

function GuildListPanel.UpdateJionInTopTenBtnState(hFrame)
	local hPage = hFrame:Lookup("PageSet_List/Page_TopTen")
	local hBtn = hPage:Lookup("Btn_TopTen")
	local bHaveTong = IsClientPlayerHaveTong()
	local bEnable = not bHaveTong
	hBtn:Enable(bEnable)
end

function GuildListPanel.UpdateAddTopTenBtnState(hFrame, bTopTenAdded)
	local hPage = hFrame:Lookup("PageSet_List/Page_TopTen")
	local hBtnAdd = hPage:Lookup("Btn_AddTopTen")
	hBtnAdd:Enable(true)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local bHaveTong = IsClientPlayerHaveTong()
	if not bHaveTong then
		hBtnAdd:Enable(false)
		return
	end
	
	if bTopTenAdded then
		hBtnAdd:Enable(false)
		return
	end
	
	if not GuildListPanel.bTongUpdate then
		return
	end
	
	local Tong = GetTongClient()
	local nMyFroupID = Tong.GetGroupID(hPlayer.dwID)
	local bCanOperate = Tong.CanBaseOperate(nMyFroupID, TONG_OPERATION_INDEX.DEVELOP_TECHNOLOGY)
	if not bCanOperate then
		hBtnAdd:Enable(false)
	end
end

function GuildListPanel.UpdateADListPage(hFrame, nPage, nTotalCount, nCount, tTongIDList)
	GuildListPanel.szSelectName = nil
	local hPage = hFrame:Lookup("PageSet_List/Page_AdList")
	local hAdList = hPage:Lookup("", "Handle_AdList")
	hAdList:Clear()
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local bHaveTong = IsClientPlayerHaveTong() 
	
	local bAdListAdded = false
	for _, dwTongID in ipairs(tTongIDList) do
		
	--[[
	for i = 1, 10 do 
		local tTong = 
		{
			["nCamp"] = 2,
			["szTongName"] = "帮会名字啦啦啦",
			["szMasterName"] = "帮主名字",
			["nMemberCount"] = "100",
			["szADDescription"] = "描述什么的最讨厌了",
		}
		--]]
		local tTong = GetTongSimpleInfo(dwTongID)
		if tTong then
			local hTong = hAdList:AppendItemFromIni(INI_FILE, "Handle_AD")
			local tCampImage = tCampFrame[tTong.nCamp]
			hTong:Lookup("Image_Camp"):FromUITex(tCampImage[1], tCampImage[2])
			hTong:Lookup("Text_GuildName"):SetText(tTong.szTongName)
			hTong:Lookup("Text_MasterName"):SetText(tTong.szMasterName)
			hTong:Lookup("Text_GuildNumber"):SetText(tTong.nMemberCount)
			hTong.szName = tTong.szTongName
			hTong:Show()
			GuildListPanel.UpdateADTitle(hTong)
			if bHaveTong and hPlayer.dwTongID == dwTongID  then
				bAdListAdded = true
			end
		else
			Log("Tong " .. dwTongID .. " not Exist")
		end
	end
	
	hAdList:FormatAllItemPos()
	
	local hPageText = hPage:Lookup("", "Text_Page")
	local szPage = (nPage - 1) * GUILD_LIST_AD_LIST_PAGE_COUNT + 1  .."-" .. nPage * GUILD_LIST_AD_LIST_PAGE_COUNT .. "(" .. nTotalCount ..  ")"
	hPageText:SetText(szPage)
	GuildListPanel.UpdateADListPageBtnState(hFrame, nTotalCount, nPage)
	
	local hBtn = hPage:Lookup("Btn_ADList")
	local bHaveTong = IsClientPlayerHaveTong()
	local bEnable = not bHaveTong
	hBtn:Enable(bEnable)
	
	local hTextAdded = hPage:Lookup("", "Text_Prompt")
	if bAdListAdded then
		hTextAdded:Show()
	else
		hTextAdded:Hide()
	end
	GuildListPanel.UpdateAddAdListBtnState(hFrame, bAdListAdded)
end

function GuildListPanel.UpdateADListPageBtnState(hFrame, nTotalCount, nPage)
	
	local hBtnPrev = hFrame:Lookup("PageSet_List/Page_AdList/Btn_Prev")
	local hBtnNext = hFrame:Lookup("PageSet_List/Page_AdList/Btn_Next")
	local nPageSize = math.ceil(nTotalCount / GUILD_LIST_AD_LIST_PAGE_COUNT)
	if nPage == 1 then
		hBtnPrev:Enable(false)
	else
		hBtnPrev:Enable(true)
	end
	if nPage >= nPageSize then
		hBtnNext:Enable(false)
	else
		hBtnNext:Enable(true)
	end
end

function GuildListPanel.UpdateAddAdListBtnState(hFrame, bAdListAdded)
	local hPage = hFrame:Lookup("PageSet_List/Page_AdList")
	local hBtn = hPage:Lookup("Btn_AddAdList")
	hBtn:Enable(true)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local bHaveTong = IsClientPlayerHaveTong()
	if not bHaveTong then
		hBtn:Enable(false)
		return
	end
	
	if bAdListAdded then
		hBtn:Enable(false)
		return
	end
	
	if not GuildListPanel.bTongUpdate then
		return
	end
	local Tong = GetTongClient()
	local nMyFroupID = Tong.GetGroupID(hPlayer.dwID)
	local nDefaultGroup = Tong.GetDefaultGroupID()
	local bCanOperater = Tong.CanAdvanceOperate(nMyFroupID, nDefaultGroup, TONG_OPERATION_INDEX.ADD_TO_GROUP)
	if not bCanOperater then
		hBtn:Enable(false)
		return
	end
end

function GuildListPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	GuildListPanel.szSelectName = nil
	if szName == "CheckBox_TopTen" then
		RemoteCallToServer("On_Tong_GetTopTenCost") 
		RemoteCallToServer("On_Tong_GetTopTenTongList") 
		GuildListPanel.UpdateJionInTopTenBtnState(hFrame)
		GuildListPanel.UpdateAddTopTenBtnState(hFrame)
	elseif szName == "CheckBox_ADList" then
		GuildListPanel.nListPage = 1
		RemoteCallToServer("On_Tong_GetADTongList", 1)
		GuildListPanel.UpdateAddAdListBtnState(hFrame)
	elseif szName == "CheckBox_Ranking" then
		OpenAchievementRanking()
		this:Check(false)
	end
end

function OpenGuildListPanel(dwNpcID, bADList, bDisableSound)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
	if not IsGuildListPanelOpened() then
		Wnd.OpenWindow("GuildListPanel")
	end
	
	HideGuildSysBtnAnimate()
	
	local hFrame = Station.Lookup("Normal/GuildListPanel")
	hFrame.dwNpcID = dwNpcID
	local szUserRegion , szUserSever = GetUserServer()
	local hTitle = hFrame:Lookup("", "Text_Title")
	hTitle:SetText(szUserSever)
	local hPageSet = hFrame:Lookup("PageSet_List")
	local bHaveTong = IsClientPlayerHaveTong()
	if bHaveTong then
		local hTongClient = GetTongClient()
		hTongClient.ApplyTongInfo()
		hTongClient.ApplyTongRoster()
	end
	if bADList then
		hPageSet:ActivePage("Page_AdList")
	else
		hPageSet:ActivePage("Page_TopTen")
		RemoteCallToServer("On_Tong_GetTopTenTongList") 
		RemoteCallToServer("On_Tong_GetTopTenCost") 
		GuildListPanel.UpdateJionInTopTenBtnState(hFrame)
		GuildListPanel.UpdateAddTopTenBtnState(hFrame)
	end
	
	
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function CloseGuildListPanel(bDisableSound)
	if not IsGuildListPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("GuildListPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsGuildListPanelOpened()
	local hFrame = Station.Lookup("Normal/GuildListPanel")
	if hFrame then
		return true
	end
	
	return false
end