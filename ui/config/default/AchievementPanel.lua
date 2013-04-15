AchievementPanel = 
{
	szFilter = "all",
	aRanking = {},
	--aGlobalRanking = {},
}

RegisterCustomData("AchievementPanel.szFilter")
--RegisterCustomData("AchievementPanel.aGlobalRanking")

function AchievementPanel.OnFrameCreate()
	AchievementPanel.Init(this)
	
	AchievementPanel.UpdateAchievementPoint(this)
	AchievementPanel.UpdateCmpShow(this)
	AchievementPanel.UpdateAchievementFilterShow(this)
	
	this:RegisterEvent("NEW_ACHIEVEMENT")
	this:RegisterEvent("SYNC_ACHIEVEMENT_DATA")
	this:RegisterEvent("UPDATE_ACHIEVEMENT_POINT")
	this:RegisterEvent("UPDATE_ACHIEVEMENT_COUNT")
	this:RegisterEvent("ACHIEVEMENT_FILTER_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ON_SYNC_RANKING_INFO")
	--this:RegisterEvent("ON_GET_GLOBALE_RANKING")
	
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseAchievementPanel(true) end)
end

function AchievementPanel.GetAchievementCount(dwCounterID)
	if not AchievementPanel.aDepend then
		local t = {}
		local nCount = g_tTable.AchievementInfo:GetRowCount()
		for i = 2, nCount, 1 do
			local aInfo = g_tTable.AchievementInfo:GetRow(i)
			if aInfo and aInfo.nShiftID ~= 0 and aInfo.nShiftType == 1 then
				t[aInfo.nShiftID] = aInfo.dwID
			end
		end
		AchievementPanel.aDepend = t		
	end
	
	local player = GetClientPlayer()
	local nCount = player.GetAchievementCount(dwCounterID)
	if not nCount or nCount == 0 then
		local dwDepend = AchievementPanel.aDepend[dwCounterID]
		while dwDepend do
			nCount = player.GetAchievementCount(dwDepend)
			if nCount and nCount ~= 0 then
				break
			end
			dwDepend = AchievementPanel.aDepend[dwDepend]
		end
	end
	return nCount or 0
end

function AchievementPanel.OnFrameBreathe()
	if AchievementPanel.dwPlayerID then
		if not GetPlayer(AchievementPanel.dwPlayerID) then
			CloseAchievementPanel()
		end
	end
end

function AchievementPanel.UpdateCmpShow(frame)
	local page = frame:Lookup("PageSet_Achievement"):GetActivePage()
	local wndCmp = frame:Lookup("Wnd_Cmp")
	
	local szName = page:GetName()
	if szName == "Page_Normal" then
		if not AchievementPanel.dwPlayerID then
			wndCmp:Hide()
		else
			wndCmp:Show()
			AchievementPanel.UpdateCmpData(page, wndCmp)
		end
		AchievementPanel.UpdateSize(frame)
	elseif szName == "Page_FD" then
		if not page.bSel or not page.bCheckAchievement then
			wndCmp:Hide()
		else
			wndCmp:Show()
			AchievementPanel.UpdateRankingData(page, wndCmp)
		end
		AchievementPanel.UpdateSize(frame)	
	else
		wndCmp:Hide()
		AchievementPanel.UpdateSize(frame)
	end	
end

function AchievementPanel.UpdateCmpData(page, wndCmp)
	local player = GetPlayer(AchievementPanel.dwPlayerID)
	if not player then
		CloseAchievementPanel()
		return
	end
	
	local handle = wndCmp:Lookup("", "")
	
	local szAdd = ""
	if page:GetName() == "Page_FD" then
		szAdd = "FD"
	end
	local hA = page:Lookup("", "Handle_Achievement"..szAdd)
	
	local hList = handle:Lookup("Handle_CmpList")
	hList:Clear()
	hList:Show()
	
	local nF, nC = 0, 0
	local szIniFile = "UI/Config/Default/AchievementCmp.ini"
	local nCount = hA:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hMe = hA:Lookup(i)
		local hOther = hList:AppendItemFromIni(szIniFile, "Achievement")
		hOther.dwGeneral = hMe.dwGeneral
		hOther.dwSub = hMe.dwSub
		hOther.dwDetail = hMe.dwDetail
		hOther.dwAchievement = hMe.dwAchievement
		hOther.bCmpAchievement = true
		hOther.bFinish = player.IsAchievementAcquired(hMe.dwAchievement)
		local box = hOther:Lookup("Icon")
		box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		box:SetObjectIcon(hMe:Lookup("Icon"):GetObjectIcon())
		hOther:Lookup("Hortation"):SetText(hMe:Lookup("Hortation"):GetText())
		hOther:Lookup("ShortDesc"):SetText(hMe:Lookup("ShortDesc"):GetText())
		hOther:Lookup("Finish"):Show(hOther.bFinish)
		nC = nC + 1
		if hOther.bFinish then
			nF = nF + 1
		end
	end
	
	AchievementPanel.UpdateScrollInfo(hList)
	
	handle:Lookup("Handle_RankingList"):Hide()
	handle:Lookup("Handle_FDL"):Hide()
	wndCmp:Lookup("Btn_CloseCmp"):Hide()
	
	local hCmp = handle:Lookup("Handle_Cmp")
	hCmp:Show()
	
	hCmp:Lookup("Text_Name"):SetText(player.szName)
	hCmp:Lookup("Text_Finish"):SetText(nF.."/"..nC)
	hCmp:Lookup("Text_ARVCamp"):SetText(player.GetAchievementRecord())	
end

function AchievementPanel.UpdateRankingData(page, wndCmp)
	local handle = wndCmp:Lookup("", "")
	
	local szAdd = ""
	if page:GetName() == "Page_FD" then
		szAdd = "FD"
	end
	local hA = page:Lookup("", "Handle_Achievement"..szAdd)
	
	local hList = handle:Lookup("Handle_RankingList")
	hList:Clear()
	hList:Show()
	
	local _, szUserSever = GetUserServer()
	
	local aRanking = AchievementPanel.aRanking[page.dwRankingAchievement] or {}
	local aInfo = aRanking.aInfo or {}
	
	AchievementPanel.AppendRankingData(hList, szUserSever, aInfo)
	
	if g_MergedRanking and g_MergedServerInfo and g_MergedServerInfo[szUserSever] then
		local tServers = g_MergedServerInfo[szUserSever]
		for i, szOrgServer in ipairs(tServers) do
			local tOrg = g_MergedRanking[szOrgServer] or {}
			local aInfo = tOrg[page.dwRankingAchievement] or {}
			if #aInfo > 0 then
				AchievementPanel.AppendRankingData(hList, FormatString(g_tStrings.ORG_SERVER, szOrgServer), aInfo)
			end
		end
	end
	
	AchievementPanel.UpdateScrollInfo(hList)
	
	handle:Lookup("Handle_CmpList"):Hide()
	handle:Lookup("Handle_Cmp"):Hide()
	
	wndCmp:Lookup("Btn_CloseCmp"):Show()
	handle:Lookup("Handle_FDL"):Show()
end

function AchievementPanel.AppendRankingData(hList, szServer, aInfo, bSplit)
	local szIniFile = "UI/Config/Default/AchievementCmp.ini"
	
	if hList:GetItemCount() > 0 then
		hList:AppendItemFromIni(szIniFile, "Split") --分割线
	end
	
	for i, v in ipairs(aInfo) do
		local hI = hList:AppendItemFromIni(szIniFile, "Group")
		hI.szName = v[1][1]
		hI.aInfo = v[1]
		hI.bRankingPlayer = true
		hI.bRankingGroup = true
		hI.szServer = szServer
		
		local img = hI:Lookup("Image_SelGroup")
		local textLevel = hI:Lookup("Text_Level")
		local textName = hI:Lookup("Text_Name")
		img:SetName("Sel")
		textLevel:SetName("Level")
		textName:SetName("Name")
		textLevel:SetText(i)
		
		local szName = hI.szName
		if #(v[2]) > 0 then
			szName = szName..g_tStrings.ACHIVEMENT_BY_TEAM
		end
		textName:SetText(szName)
		
		for j, vA in ipairs(v[2]) do
			local hI = hList:AppendItemFromIni(szIniFile, "Title")
			hI.szName = vA[1]
			hI.aInfo = vA
			hI.bRankingPlayer = true
			hI.bRankingTitle = true
			hI.szServer = szServer
			
			local img = hI:Lookup("Image_Sel")
			local textLevel = hI:Lookup("Text_TitleLevel")
			local textName = hI:Lookup("Text_TitleName")
			img:SetName("Sel")
			textLevel:SetName("Level")
			textName:SetName("Name")
			textLevel:SetText(i)
			textName:SetText(hI.szName)			
		end
	end
end

function AchievementPanel.UpdateSize(frame)
	local wndCmp = frame:Lookup("Wnd_Cmp")
	local pageSet = frame:Lookup("PageSet_Achievement")
	local _, h = frame:GetSize()
	local w, _ = pageSet:GetSize()
	local w1, _ = wndCmp:GetSize()
	if wndCmp:IsVisible() then
		frame:SetSize(w + w1, h)
	else
		frame:SetSize(w, h)
	end
	CorrectAutoPosFrameAfterClientResize()
end

function AchievementPanel.OnEvent(event)
	if event == "NEW_ACHIEVEMENT" then
		AchievementPanel.Update(this)
		if AchievementPanel.szFilter ~= "all" then
			AchievementPanel.UpdateFilter(this)
		end
	elseif event == "SYNC_ACHIEVEMENT_DATA" then
		if arg0 == GetClientPlayer().dwID then
			AchievementPanel.Update(this)
		end
	elseif event == "UPDATE_ACHIEVEMENT_POINT" then
		AchievementPanel.UpdateAchievementPoint(this)
	elseif event == "UPDATE_ACHIEVEMENT_COUNT" then
		AchievementPanel.UpdateAchievementPoint(this)
		AchievementPanel.Update(this)
	elseif event == "ACHIEVEMENT_FILTER_CHANGED" then
		AchievementPanel.UpdateFilter(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		AchievementPanel.UpdateFilter(this)		
		local page = this:Lookup("PageSet_Achievement"):GetActivePage()
		local szName = page:GetName()
		if szName == "Page_Normal" or szName == "Page_FD" then
			AchievementPanel.UpdateSelect(page)
		end	
	elseif event == "ON_SYNC_RANKING_INFO" then
		AchievementPanel.OnSyncRankingInfo(this, arg0, arg1, arg2)
	elseif event == "ON_GET_GLOBALE_RANKING" then
		if arg2 == true then
			AchievementPanel.OnSyncGlobalRankingInfo(this, arg0, arg1)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GET_GLOBALE_RANKING_FAILED)
		end
	end
end

function AchievementPanel.OnSyncGlobalRankingInfo(frame, szKey, msg)
	AchievementPanel.aGlobalRanking[szKey] = {nQueryTime = GetCurrentTime(), aRanking = msg}
	AchievementPanel.UpdateSelectRanking(frame:Lookup("PageSet_Achievement/Page_RANK"))
end

function AchievementPanel.OnSyncRankingInfo(frame, dwAchieveMent, RankingInfo, bStatic)
	local a = AchievementPanel.aRanking[dwAchieveMent]
	local bCHange = false
	if not a or #(a.aInfo) ~= #RankingInfo then
		bCHange = true
	else
		for i, v in ipairs(a) do
			local vO = RankingInfo[i]
			if not vO or v[1] ~= vO[1] and #(v[2]) ~= #(vO[2]) then
				bCHange = true
				break
			end
			
			for j, vA in rpairs(v[2]) do
				if vO[2][j] ~= vA then
					bCHange = true
					break
				end
			end
			if bCHange then
				break
			end
		end
	end
	AchievementPanel.aRanking[dwAchieveMent] = 
	{
		aInfo = RankingInfo, 
		bNoNeedUpdate = bStatic, 
		nTime = GetTickCount(),
	}
	
	local page = frame:Lookup("PageSet_Achievement"):GetActivePage()
	if bCHange and page:GetName() == "Page_FD" and page.dwRankingAchievement == dwAchieveMent then
		AchievementPanel.UpdateCmpShow(frame)
	end
end

function AchievementPanel.UpdateFilter(frame)
	AchievementPanel.UpdateAchievementFilterShow(frame)
	local page = frame:Lookup("PageSet_Achievement/Page_Normal")
	AchievementPanel.UpdateSelect(page)
	local page = frame:Lookup("PageSet_Achievement/Page_FD")
	AchievementPanel.UpdateSelect(page)
end

function AchievementPanel.UpdateAchievementFilterShow(frame)
	local text = frame:Lookup("Btn_Filter", "Text_Filter")
	if AchievementPanel.szFilter == "finish" then
		text:SetText(g_tStrings.STR_ACHIEVEMENT_FLITER_FINISH)
	elseif AchievementPanel.szFilter == "unfinish" then
		text:SetText(g_tStrings.STR_ACHIEVEMENT_FLITER_UNFINISH)
	else
		text:SetText(g_tStrings.STR_ACHIEVEMENT_FLITER_ALL)
	end
end

function AchievementPanel.Init(frame)
	local page = frame:Lookup("PageSet_Achievement/Page_Normal")
	AchievementPanel.InitPage(page)
	page = frame:Lookup("PageSet_Achievement/Page_FD")
	AchievementPanel.InitPage(page)
    --[[
	page = frame:Lookup("PageSet_Achievement/Page_RANK")
	AchievementPanel.InitRankingPage(page)
    --]]
end

function AchievementPanel.InitRankingPage(page)
	local dwGeneral = 3
	
	local handle = page:Lookup("", "")
	local hList = handle:Lookup("Handle_ListRANK")
	local hAchievement = handle:Lookup("Handle_RANKList")
	hList:Clear()
	hAchievement:Clear()
	
	local aGeneral = g_tTable.AchievementGeneral:Search(dwGeneral)
	if not aGeneral then
		AchievementPanel.UpdateScrollInfo(hList)
		return
	end	
	page:GetParent():Lookup("CheckBox_RANK", "Text_RANK"):SetText(aGeneral.szName)
	
	local szIniFile = "UI/Config/Default/AchievementAdd.ini"
	local szSubs = aGeneral.szSubs
	for s in string.gmatch(szSubs, "%d+") do
		local dwSub = tonumber(s)
		local aSub = g_tTable.AchievementSub:Search(dwSub)
		if aSub then
			local hGroup = hList:AppendItemFromIni(szIniFile, "Group")
			hGroup.dwGeneral = dwGeneral
			hGroup.dwSub = dwSub
			hGroup.bGroup = true
			hGroup.bGlobalRanking = true
			local img = hGroup:Lookup("Image_SelGroup")
			local text = hGroup:Lookup("Text_Group")
			img:SetName("Sel")
			text:SetName("Name")
			text:SetText(aSub.szName)
			
			local szDetails = aSub.szDetails
			for s in string.gmatch(szDetails, "%d+") do
				local dwDetail = tonumber(s)
				local aDetail = g_tTable.Ranking:Search(dwDetail)
				if aDetail then
					local hTitle = hList:AppendItemFromIni(szIniFile, "Title")
					hTitle.dwGeneral = dwGeneral
					hTitle.dwSub = dwSub
					hTitle.dwDetail = dwDetail
					hTitle.bTitle = true
					hTitle.bGlobalRanking = true
					local img = hTitle:Lookup("Image_Sel")
					local text = hTitle:Lookup("Text_Title")
					img:SetName("Sel")
					text:SetName("Name")
					text:SetText(aDetail.szName)
				end
			end
		end
	end
	
	AchievementPanel.UpdateScrollInfo(hList)
	AchievementPanel.UpdateScrollInfo(hAchievement)	
end

function AchievementPanel.InitPage(page)
	local szAdd, dwGeneral = "", 1
	if page:GetName() == "Page_FD" then
		szAdd, dwGeneral = "FD", 2
	end

	local handle = page:Lookup("", "")
	local hList = handle:Lookup("Handle_List"..szAdd)
	local hAchievement = handle:Lookup("Handle_Achievement"..szAdd)
	hList:Clear()
	hAchievement:Clear()
	
	local aGeneral = g_tTable.AchievementGeneral:Search(dwGeneral)
	if not aGeneral then
		AchievementPanel.UpdateScrollInfo(hList)
		return
	end
	page.dwGeneral = dwGeneral
	
	if dwGeneral == 1 then
		page:GetParent():Lookup("CheckBox_Normal", "Text_Normal"):SetText(aGeneral.szName)
	else
		page:GetParent():Lookup("CheckBox_FD", "Text_FD"):SetText(aGeneral.szName)
	end
	
	local szIniFile = "UI/Config/Default/AchievementAdd.ini"
	local szSubs = aGeneral.szSubs
	for s in string.gmatch(szSubs, "%d+") do
		local dwSub = tonumber(s)
		local aSub = g_tTable.AchievementSub:Search(dwSub)
		if aSub then
			local hGroup = hList:AppendItemFromIni(szIniFile, "Group")
			hGroup.dwGeneral = dwGeneral
			hGroup.dwSub = dwSub
			hGroup.bGroup = true
			local img = hGroup:Lookup("Image_SelGroup")
			local text = hGroup:Lookup("Text_Group")
			img:SetName("Sel")
			text:SetName("Name")
			
			local nCount, nFinish = AchievementPanel.GetAchivementFinishCount(aSub.szAchievements)
			
			local szDetails = aSub.szDetails
			for s in string.gmatch(szDetails, "%d+") do
				local dwDetail = tonumber(s)
				local aDetail = g_tTable.AchievementDetail:Search(dwDetail)
				if aDetail then
					local hTitle = hList:AppendItemFromIni(szIniFile, "Title")
					hTitle.dwGeneral = dwGeneral
					hTitle.dwSub = dwSub
					hTitle.dwDetail = dwDetail
					hTitle.bTitle = true
					local img = hTitle:Lookup("Image_Sel")
					local text = hTitle:Lookup("Text_Title")
					img:SetName("Sel")
					text:SetName("Name")
					local nC, nF = AchievementPanel.GetAchivementFinishCount(aDetail.szAchievements)
					nCount, nFinish = nCount + nC, nFinish + nF
					text:SetText(aDetail.szName.."("..nF.."/"..nC..")")
				end
			end
			
			text:SetText(aSub.szName.."("..nFinish.."/"..nCount..")")
		end
	end
	
	AchievementPanel.UpdateScrollInfo(hList)
	AchievementPanel.UpdateScrollInfo(hAchievement)
end

function AchievementPanel.Update(frame)
	local page = frame:Lookup("PageSet_Achievement/Page_Normal")
	AchievementPanel.UpdatePage(page)
	page = frame:Lookup("PageSet_Achievement/Page_FD")
	AchievementPanel.UpdatePage(page)
end
	
function AchievementPanel.UpdatePage(page)
	local szAdd = ""
	if page:GetName() == "Page_FD" then
		szAdd = "FD"
	end	

	local player = GetClientPlayer()
	
	local hList = page:Lookup("", "Handle_List"..szAdd)
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bGroup then
			local aSub = g_tTable.AchievementSub:Search(hI.dwSub)
			if aSub then
				local nCountGroup, nFinishGroup = AchievementPanel.GetAchivementFinishCount(aSub.szAchievements)
				local szDetails = aSub.szDetails
				for s in string.gmatch(szDetails, "%d+") do
					local dwDetail = tonumber(s)
					local aDetail = g_tTable.AchievementDetail:Search(dwDetail)
					if aDetail then
						local nC, nF = AchievementPanel.GetAchivementFinishCount(aDetail.szAchievements)
						nCountGroup, nFinishGroup = nCountGroup + nC, nFinishGroup + nF
					end
				end
				hI:Lookup("Name"):SetText(aSub.szName.."("..nFinishGroup.."/"..nCountGroup..")")
			end
		else
			local aDetail = g_tTable.AchievementDetail:Search(hI.dwDetail)
			if aDetail then
				local nC, nF = AchievementPanel.GetAchivementFinishCount(aDetail.szAchievements)
				hI:Lookup("Name"):SetText(aDetail.szName.."("..nF.."/"..nC..")")
			end
		end
	end
	
	local hAchievement = page:Lookup("", "Handle_Achievement"..szAdd)
	local nCount = hAchievement:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hAchievement:Lookup(i)
		hI.bFinish = player.IsAchievementAcquired(hI.dwAchievement)
		hI:Lookup("Finish"):Show(hI.bFinish)
		local hDetail = hI:Lookup("Detail")
		local nC = hDetail:GetItemCount() - 1
		for j = 0, nC, 1 do
			local hD = hDetail:Lookup(j)
			if hD.bSubAchievement then --子成就
				hD.bFinish = player.IsAchievementAcquired(hD.dwSubAchievement)
				hD:Lookup("FinishFlag"):Show(hD.bFinish)
			elseif hD.bCounter then --计数器
				hD.bFinish = player.IsAchievementAcquired(hD.dwCounter)
				hD:Lookup("FinishFlag"):Show(hD.bFinish)
				local nCMax = GetAchievementInfo(hD.dwCounter) or 0
				local nC = AchievementPanel.GetAchievementCount(hD.dwCounter)
				hD:Lookup("SubName"):SetText(hD.szDesc..":"..nC.."/"..nCMax)
			end
		end
	end
end

function AchievementPanel.GetAchivementFinishCount(szAchievements)
	local player = GetClientPlayer()
	local nCount, nFinish = 0, 0
	for s in string.gmatch(szAchievements, "%d+") do
		local dwAchievement = tonumber(s)
		if player.IsAchievementAcquired(dwAchievement) then
			nFinish = nFinish + 1
		end
		nCount = nCount + 1
	end
	return nCount, nFinish
end

function AchievementPanel.ShowAchievementByID(frame, dwAchievement)
	local aAchievement = g_tTable.Achievement:Search(dwAchievement)
	if not aAchievement then
		return
	end
	local pageSet = frame:Lookup("PageSet_Achievement")
	local page, child = nil, pageSet:GetFirstChild()
	while child do
		if child.dwGeneral == aAchievement.dwGeneral then
			page = child
			break
		end
		child = child:GetNext()
	end
	
	if not page then
		return
	end
	
	local szAdd = ""
	if page:GetName() == "Page_FD" then
		szAdd = "FD"
	end	
	
	pageSet:ActivePage(page:GetName())
	
	local hList = page:Lookup("", "Handle_List"..szAdd)
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if (aAchievement.dwDetail == 0 and hI.dwSub == aAchievement.dwSub) or
			(aAchievement.dwDetail ~= 0 and hI.dwDetail == aAchievement.dwDetail) then
			AchievementPanel.Sel(hI)
			--make visible
			if not hI.bGroup then
				for j = i, 0, -1 do
					local hB = hList:Lookup(j)
					if hB.bGroup then
						if not hB:IsExpand() then
							hB:Expand()
							AchievementPanel.UpdateScrollInfo(hList)
							break
						end
					end
				end
			end
			
			local x, y = hI:GetAbsPos()
			local w, h = hI:GetSize()
			local xL, yL = hList:GetAbsPos()
			local wL, hL = hList:GetSize()
			local scroll = page:Lookup("Scroll_List"..szAdd)
			if y < yL then
				scroll:ScrollPrev(math.ceil((yL - y) / 10))
			elseif y + h > yL + hL then
				scroll:ScrollNext(math.ceil((y + h - yL - hL) / 10))
			end
			break
		end
	end
	
	local hAchievement = page:Lookup("", "Handle_Achievement"..szAdd)
	local nCount = hAchievement:GetItemCount() -1
	for i = 0, nCount, 1 do
		local hI = hAchievement:Lookup(i)
		if hI.dwAchievement == aAchievement.dwID then
			AchievementPanel.ShowAchievementDetail(hI, true)
			AchievementPanel.SelAchievement(hI)
			
			local x, y = hI:GetAbsPos()
			local w, h = hI:GetSize()
			local xL, yL = hAchievement:GetAbsPos()
			local wL, hL = hAchievement:GetSize()
			local scroll = page:Lookup("Scroll_Achievement"..szAdd)
			if y < yL then
				scroll:ScrollPrev(math.ceil((yL - y) / 10))
			elseif y + h > yL + hL then
				scroll:ScrollNext(math.ceil((y + h - yL - hL) / 10))
			end
			break
		end
	end
end

function AchievementPanel.UpdateAchievementPoint(frame)
	local handle = frame:Lookup("", "")
	
	local player = GetClientPlayer()
	
	handle:Lookup("Text_APV"):SetText(player.GetAchievementPoint())
	handle:Lookup("Text_ARV"):SetText(player.GetAchievementRecord())
end

function AchievementPanel.OnItemLButtonDown()
	if IsCtrlKeyDown() and (this.bAchievement or this:GetParent().bAchievement) then
		if this.bAchievement then
			EditBox_AppendLinkAchievement(this.dwAchievement)
		else
			EditBox_AppendLinkAchievement(this:GetParent().dwAchievement)
		end
		return
	end
	if this.bGroup then
		if this:IsExpand() then
			this:Collapse()
		else
			this:Expand()
		end
		AchievementPanel.UpdateScrollInfo(this:GetParent())
        --[[
		if not this.bGlobalRanking then
			AchievementPanel.Sel(this)
		end
        --]]
        AchievementPanel.Sel(this)
	elseif this.bTitle then
		AchievementPanel.Sel(this)
	elseif this.bExpand then
		local hI = this:GetParent()
		AchievementPanel.ShowOrHideAchievementDetail(hI)
	elseif this.bRanking then
		this.bDown = true
		AchievementPanel.UpdateRankingBtnShow(this)
	elseif this.bRankingPlayer then
		AchievementPanel.SelRankingPlayer(this)
		if this.bRankingGroup then
			if this:IsExpand() then
				this:Collapse()
			else
				this:Expand()
			end
			AchievementPanel.UpdateScrollInfo(this:GetParent())
		end
    --[[
	elseif  this.bGlobalGuildRanking then
		AchievementPanel.SelGlobalRanking(this)
	elseif this.bGlobalPlayerRanking then
		AchievementPanel.SelGlobalRanking(this)
    --]]
	elseif this:GetName() == "iteminfolink" then
		OnItemLinkDown(this)
	end
end

function AchievementPanel.UpdateGlobalRankingSelShow(hI)
	local img = hI:Lookup("Image_Sel")
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

function AchievementPanel.SelGlobalRanking(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			AchievementPanel.UpdateGlobalRankingSelShow(hB)
			break
		end
	end
	
	hI.bSel = true
	AchievementPanel.UpdateGlobalRankingSelShow(hI)
end

function AchievementPanel.OnItemRButtonDown()
	if this.bRankingPlayer or this.bGlobalPlayerRanking then
		local szName = this.szName
		local player = GetClientPlayer()
		local menu = 
		{
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szName) AddContactPeople(szName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szName) AddContactPeople(szName) end},
		    {szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = player.dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szName) AddContactPeople(szName) end},
		}
		PopupMenu(menu)
	end
end

function AchievementPanel.SelRankingPlayer(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			AchievementPanel.UpdateRankingPlayerShow(hB)
			break
		end
	end
	
	hI.bSel = true
	AchievementPanel.UpdateRankingPlayerShow(hI)
end

function AchievementPanel.UpdateRankingPlayerShow(hI)
	local img = hI:Lookup("Sel")
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

function AchievementPanel.OnItemLButtonUp()
	if this.bRanking then
		this.bDown = false
		AchievementPanel.UpdateRankingBtnShow(this)
	end
end

function AchievementPanel.OnItemLButtonClick()
	if this.bSubAchievement then
		AchievementPanel.ShowAchievementByID(this:GetRoot(), this.dwSubAchievement)
	elseif this.bRanking then
		local hI = this:GetParent()
		if hI.bSelectRanking then
			AchievementPanel.UnSelectRankingAchievement(hI:GetParent():GetParent():GetParent())
		else
			AchievementPanel.SelectRankingAchievement(hI)
		end
	end
end

function AchievementPanel.RequestRanking(dwAchievement)
	local t = AchievementPanel.aRanking[dwAchievement]
	if not t or not (t.bNoNeedUpdate and GetTickCount() - t.nTime > 2000) then --频率控制，两秒一次
		RemoteCallToServer("OnQueryRankingInfo", dwAchievement)
	end
end

function AchievementPanel.SelectRankingAchievement(hI)
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB.bSelectRanking = false
		hB:Lookup("SelectFD"):Hide()
	end
	hI.bSelectRanking = true
	hI:Lookup("SelectFD"):Show()
	
	local page = hP:GetParent():GetParent()
	page.bCheckAchievement = true
	page.dwRankingAchievement = hI.dwAchievement
	
	AchievementPanel.RequestRanking(page.dwRankingAchievement)
	AchievementPanel.UpdateCmpShow(page:GetRoot())
end

function AchievementPanel.UnSelectRankingAchievement(page)
	local hP = page:Lookup("", "Handle_AchievementFD")
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB.bSelectRanking = false
		hB:Lookup("SelectFD"):Hide()
	end

	page.bCheckAchievement = nil
	page.dwRankingAchievement = nil
	AchievementPanel.UpdateCmpShow(page:GetRoot())
end

function AchievementPanel.OnItemLButtonDBClick()
	if this.bGroup then
		AchievementPanel.OnItemLButtonDown()
	elseif this.bTitle then
		AchievementPanel.OnItemLButtonDown()
	elseif this.bExpand then
		local hI = this:GetParent()
		AchievementPanel.ShowOrHideAchievementDetail(hI)
	elseif this.bRanking then
		AchievementPanel.OnItemLButtonClick()
	elseif this.bRankingPlayer then
		AchievementPanel.OnItemLButtonDown()
	end
end

function AchievementPanel.ShowOrHideAchievementDetail(hI)
	AchievementPanel.ShowAchievementDetail(hI, not hI.bShowDetail)
end

function AchievementPanel.UnShowAllDetail(frame)
	local pageSet = frame:Lookup("PageSet_Achievement")
	local hList = pageSet:Lookup("Page_Normal", "Handle_Achievement")
	local nCount = hList:GetItemCount() -1
	for i = 0, nCount, 1 do
		AchievementPanel.ShowAchievementDetail(hList:Lookup(i), false)
	end
	local hList = pageSet:Lookup("Page_FD", "Handle_AchievementFD")
	local nCount = hList:GetItemCount() -1
	for i = 0, nCount, 1 do
		AchievementPanel.ShowAchievementDetail(hList:Lookup(i), false)
	end	
end

function AchievementPanel.UpdateAllShowDetail(frame)
	local pageSet = frame:Lookup("PageSet_Achievement")
	local hList = pageSet:Lookup("Page_Normal", "Handle_Achievement")
	local nCount = hList:GetItemCount() -1
	for i = 0, nCount, 1 do
		AchievementPanel.UpdateDetailShowInfo(hList:Lookup(i))
	end
	AchievementPanel.UpdateScrollInfo(hList)
	local hList = pageSet:Lookup("Page_FD", "Handle_AchievementFD")
	local nCount = hList:GetItemCount() -1
	for i = 0, nCount, 1 do
		AchievementPanel.UpdateDetailShowInfo(hList:Lookup(i))
		AchievementPanel.ShowAchievementDetail(hList:Lookup(i), false)
	end	
end

function AchievementPanel.UpdateDetailShowInfo(hI)
	local hDetail = hI:Lookup("Detail")
	local imgState = hI:Lookup("State")
	local imgBreak = hI:Lookup("Break")
	if hI.bShowDetail then
		hDetail:Show()
		hDetail:SetSize(300, 10000)
		hDetail:FormatAllItemPos()
		hDetail:SetSizeByAllItemSize()
	else
		hDetail:Hide()
		hDetail:SetSize(0, 0)
	end
	hI:FormatAllItemPos()
	local w, h = hI:GetAllItemSize()
	hI:SetSize(w, h + 12)
	
	if AchievementPanel.dwPlayerID then
		imgState:Hide()
	else
		imgState:Show()
	end
	
	if hI.bShowDetail then
		if hI.bOver then
			imgState:SetFrame(33)
		else
			imgState:SetFrame(32)
		end
	else
		if hI.bOver then
			imgState:SetFrame(31)
		else
			imgState:SetFrame(30)
		end
	end
end

function AchievementPanel.ShowAchievementDetail(hI, bShowDetail)
	hI.bShowDetail = bShowDetail
	if AchievementPanel.dwPlayerID then
		hI.bShowDetail = false
	end
	AchievementPanel.UpdateDetailShowInfo(hI)
	AchievementPanel.UpdateScrollInfo(hI:GetParent())
end

function AchievementPanel.OnItemMouseEnter()
	if this.bGroup then
		this.bOver = true
		AchievementPanel.UpdateSelShow(this)
	elseif this.bTitle then
		this.bOver = true
		AchievementPanel.UpdateSelShow(this)
        --[[
		if this.bGlobalRanking then
			local aRankingInfo = g_tTable.Ranking:Search(this.dwDetail)
			if aRankingInfo and aRankingInfo.szDesc ~= "" then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputTip(aRankingInfo.szDesc, 400, {x, y, w, h})			
			end
		end
        --]]
	elseif this.bSubAchievement then
		local text = this:Lookup("SubName")
		this.nFont = text:GetFontScheme()
		text:SetFontScheme(18)	--子成就鼠标一上去颜色
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local aAchievement = g_tTable.Achievement:Search(this.dwSubAchievement)
		local szTip = GetFormatText(aAchievement.szName.."\n", 27)..GetFormatText(aAchievement.szShortDesc, 18)
		OutputTip(szTip, 400, {x, y, w, h})
	elseif this.bCounter then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local nCMax = GetAchievementInfo(this.dwCounter) or 0
		local nC = AchievementPanel.GetAchievementCount(this.dwCounter)
		local szTip = GetFormatText(this.szDesc..":"..nC.."/"..nCMax, 18) --todo:完成状况
		OutputTip(szTip, 400, {x, y, w, h})
	elseif this.bRanking then
		this.bOver = true
		AchievementPanel.UpdateRankingBtnShow(this)
	elseif this.bRankingPlayer then
		this.bOver = true
		AchievementPanel.UpdateRankingPlayerShow(this)
		if this.szServer and this.szName then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local time = TimeToDate(this.aInfo[3])
			local szTime = FormatString(g_tStrings.STR_TIME_2, time.year, time.month, time.day, time.hour, time.minute, time.second)
			--记录队伍中玩家的{名字，帮会名字，FD时间，门派，阵营}
			local szTip = GetFormatText(this.szName.."\n", 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_SCHOOL, g_tStrings.tForceTitle[this.aInfo[4]] or g_tStrings.STR_CHARACTER_NO_FORCE), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_CAMP, g_tStrings.STR_GUILD_CAMP_NAME[this.aInfo[5]]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD, this.aInfo[2]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_TIME, szTime), 18)..
				GetFormatText(this.szServer.."\n", 106)
			OutputTip(szTip, 400, {x, y, w, h})
		end
	elseif this.bGlobalPlayerRanking then
		this.bOver = true
		AchievementPanel.UpdateGlobalRankingSelShow(this)
		local aRankingInfo = g_tTable.Ranking:Search(this.dwDetail)
		if aRankingInfo then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = GetFormatText(this.aInfo[1].."\n", 27)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_LEVEL, this.aInfo[4]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_SCHOOL, g_tStrings.tForceTitle[this.aInfo[5]] or g_tStrings.STR_CHARACTER_NO_FORCE), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_CAMP, g_tStrings.STR_GUILD_CAMP_NAME[this.aInfo[6]]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD, this.aInfo[2]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_VALUE, aRankingInfo.szValueName, this.aInfo[7]), 18)
			OutputTip(szTip, 400, {x, y, w, h})
		end
	elseif this.bGlobalGuildRanking then
		this.bOver = true
		AchievementPanel.UpdateGlobalRankingSelShow(this)
		local aRankingInfo = g_tTable.Ranking:Search(this.dwDetail)
		if aRankingInfo then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = GetFormatText(this.aInfo[1].."\n", 27)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD_MASTER, this.aInfo[2]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD_CAMP, g_tStrings.STR_GUILD_CAMP_NAME[this.aInfo[3]]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD_MEMBER, this.aInfo[4]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_VALUE, aRankingInfo.szValueName, this.aInfo[5]), 18)
			OutputTip(szTip, 400, {x, y, w, h})
		end
	end
end

function AchievementPanel.OnActivePage()
	local page = this:GetActivePage()
	local szName = page:GetName()
	if szName == "Page_Normal" then
		AchievementPanel.UpdateCmpShow(this:GetRoot())
	elseif szName == "Page_FD" then
		AchievementPanel.UpdateCmpShow(this:GetRoot())
    end
    --[[
	elseif szName == "Page_RANK" then
		AchievementPanel.UpdateCmpShow(this:GetRoot())
	end
    --]]
end

function AchievementPanel.OnItemMouseLeave()
	if this.bGroup then
		this.bOver = false
		AchievementPanel.UpdateSelShow(this)
		HideTip()
	elseif this.bTitle then
		this.bOver = false
		AchievementPanel.UpdateSelShow(this)
		HideTip()
	elseif this.bSubAchievement then
		if this.nFont then
			this:Lookup("SubName"):SetFontScheme(this.nFont)
		end
		HideTip()
	elseif this.bCounter then
		HideTip()
	elseif this.bRanking then
		this.bOver = false
		AchievementPanel.UpdateRankingBtnShow(this)
	elseif this.bRankingPlayer then
		this.bOver = false
		AchievementPanel.UpdateRankingPlayerShow(this)
		HideTip()
	elseif this.bGlobalPlayerRanking then
		this.bOver = false
		AchievementPanel.UpdateGlobalRankingSelShow(this)
		HideTip()
	elseif this.bGlobalGuildRanking then
		this.bOver = false
		AchievementPanel.UpdateGlobalRankingSelShow(this)			
		HideTip()
	end
end

function AchievementPanel.UpdateRankingBtnShow(img)
	if img.bDown then
		img:SetFrame(59)
	elseif img.bOver then
		img:SetFrame(58)
	else
		img:SetFrame(57)
	end
end

function AchievementPanel.UpdateSelShow(hI)
	local img = hI:Lookup("Sel")
	local text = hI:Lookup("Name")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
		text:SetFontScheme(162)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
		text:SetFontScheme(162)
	else
		img:Hide()
		text:SetFontScheme(160)
	end
end

function AchievementPanel.Sel(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			AchievementPanel.UpdateSelShow(hB)
			break
		end
	end
	
	hI.bSel = true
	AchievementPanel.UpdateSelShow(hI)
	
	local page = hP:GetParent():GetParent()
	page.bSel = true
	page.dwGeneral = hI.dwGeneral
	page.dwSub = hI.dwSub
	page.dwDetail = hI.dwDetail
	
    --[[
	if hI.bGlobalRanking then
		AchievementPanel.UpdateSelectRanking(page)
	else
		AchievementPanel.UpdateSelect(page)
	end
    --]]
    AchievementPanel.UpdateSelect(page)
end

function AchievementPanel.UnSel(page)
	local bRank = false
	local szAdd = ""
	if page:GetName() == "Page_FD" then
		szAdd = "FD"
    end
    --[[
	elseif page:GetName() == "Page_RANK" then
		szAdd = "RANK"
		bRank = true
	end
    --]]
	local hList = page:Lookup("", "Handle_List"..szAdd)
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bSel then
			hI.bSel = false
			AchievementPanel.UpdateSelShow(hI)
			break
		end
	end
	page.bSel = false
    --[[
	if bRank then
		AchievementPanel.UpdateSelectRanking(page)
	else
		AchievementPanel.UpdateSelect(page)
	end
    --]]
    AchievementPanel.UpdateSelect(page)
end

function AchievementPanel.SelAchievement(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			hB:Lookup("Select"):Show(hB.bSel)
		end
	end
	
	hI.bSel = true
	hI:Lookup("Select"):Show(hI.bSel)
end

function AchievementPanel.UnSelAchievement(hI)
	if not hI.bSel then
		return
	end
	
	hI.bSel = false
	hI:Lookup("Select"):Show(hI.bSel)		
end

function AchievementPanel.GetGlobalRankingValue(szKey)
	local nTime = GetCurrentTime()
	local a = AchievementPanel.aGlobalRanking[szKey]
	if not a or not a.nQueryTime then
		RemoteCallToServer("OnQueryGlobalRanking", szKey)
		AchievementPanel.aGlobalRanking[szKey] = {nQueryTime = nTime}
		return {}
	elseif not a.aRanking and nTime > a.nQueryTime + 2 then --2sCd
		RemoteCallToServer("OnQueryGlobalRanking", szKey)
		AchievementPanel.aGlobalRanking[szKey] = {nQueryTime = nTime}
		return {}		
	end
	
	local nlastQTime = a.nQueryTime or 0
	local aTime = TimeToDate(nTime)
	local nTimeRefresh = DateToTime(aTime.year, aTime.month, aTime.day, 7, 0, 0)
	if nlastQTime < nTimeRefresh then
		RemoteCallToServer("OnQueryGlobalRanking", szKey)
		a.nQueryTime = nTime
	end
	return a.aRanking
end

function AchievementPanel.UpdateSelectRanking(page)
	local handle = page:Lookup("", "")
	local hA = handle:Lookup("Handle_RANKList")
	local hD = handle:Lookup("Handle_DescRANK")
	local hG = handle:Lookup("Handle_GuildTitle")
	local hP = handle:Lookup("Handle_PlayerTitle")

	hA:Show(page.bSel)
	hG:Show(page.bSel)
	hP:Show(page.bSel)
	hD:Show(not page.bSel)
	
	hA:Clear()
	if not page.bSel then
		AchievementPanel.UpdateScrollInfo(hA)
		AchievementPanel.UpdateCmpShow(page:GetRoot())
		return
	end
	
	local aRankingInfo = g_tTable.Ranking:Search(page.dwDetail)

	if not aRankingInfo then
		hG:Hide()
		hP:Hide()
		AchievementPanel.UpdateScrollInfo(hA)
		AchievementPanel.UpdateCmpShow(page:GetRoot())
		return
	end
	
	local aRanking = AchievementPanel.GetGlobalRankingValue(aRankingInfo.szKey)
	if aRankingInfo.nType == 1 then --帮会
		hG:Show()
		hP:Hide()
		hG:Lookup("Text_GuildValue"):SetText(aRankingInfo.szValueName)
		
		local szIniFile = "UI/Config/Default/AchivementRankingGuild.ini"
		for k, v in ipairs(aRanking) do
			local hI = hA:AppendItemFromIni(szIniFile, "Handle_Guild")
			hI.bGlobalGuildRanking = true
			hI.aInfo = v
			hI.dwDetail = page.dwDetail
			hI:Lookup("Text_Name"):SetText(v[1])
			local img = hI:Lookup("Image_Order"..k)
			local text = hI:Lookup("Text_Order")
			if img then
				img:Show()
				text:Hide()
			else
				text:Show()
				text:SetText(k)
			end
			hI:Lookup("Text_Value"):SetText(v[5])
			hI:Lookup("Image_Neutral"):Show(v[3] == CAMP.NEUTRAL)
			hI:Lookup("Image_Good"):Show(v[3] == CAMP.GOOD)
			hI:Lookup("Image_Evil"):Show(v[3] == CAMP.EVIL)
		end
	else
		hG:Hide()
		hP:Show()
		hP:Lookup("Text_PlayerValue"):SetText(aRankingInfo.szValueName)

		local szIniFile = "UI/Config/Default/AchivementRankingPlayer.ini"
		for k, v in ipairs(aRanking) do
			local hI = hA:AppendItemFromIni(szIniFile, "Handle_Player")
			hI.bGlobalPlayerRanking = true
			hI.aInfo = v
			hI.szName = v[1]
			hI.dwDetail = page.dwDetail
			
			hI:Lookup("Text_Name"):SetText(v[1])
			hI:Lookup("Text_Level"):SetText(v[4])
			local img = hI:Lookup("Image_Order"..k)
			local text = hI:Lookup("Text_Order")
			if img then
				img:Show()
				text:Hide()
			else
				text:Show()
				text:SetText(k)
			end
			hI:Lookup("Text_Value"):SetText(v[7])
			hI:Lookup("Image_School"):FromUITex(GetForceImage(v[5]))
		end
	end
	
	AchievementPanel.UpdateScrollInfo(hA)
	AchievementPanel.UpdateCmpShow(page:GetRoot())		
end

function AchievementPanel.UpdateSelect(page)
	local bFD = false
	local szAdd = ""
	if page:GetName() == "Page_FD" then
		szAdd = "FD"
		bFD = true
	end
	local hA = page:Lookup("", "Handle_Achievement"..szAdd)
	local hD = page:Lookup("", "Handle_Desc"..szAdd)
	
	hA:Show(page.bSel)
	hD:Show(not page.bSel)
	
	hA:Clear()
	if bFD then
		AchievementPanel.UnSelectRankingAchievement(page)
	end
	if not page.bSel then
		AchievementPanel.UpdateScrollInfo(hA)
		AchievementPanel.UpdateCmpShow(page:GetRoot())
		return
	end
	
	local player = GetClientPlayer()
	
	local szAchievements = ""
	if page.dwDetail then
		local aDetail =  g_tTable.AchievementDetail:Search(page.dwDetail)
		szAchievements = aDetail.szAchievements
	else
		local aSub = g_tTable.AchievementSub:Search(page.dwSub)
		szAchievements = aSub.szAchievements
	end
	local szIniFile = "UI/Config/Default/AchievementAdd.ini"
	for s in string.gmatch(szAchievements, "%d+") do
		local dwAchievement = tonumber(s)
		local aAchievement = g_tTable.Achievement:Search(dwAchievement)
		if aAchievement then
			local bFinish = player.IsAchievementAcquired(dwAchievement)
			if not ((AchievementPanel.szFilter == "finish" and not bFinish) or (AchievementPanel.szFilter == "unfinish" and bFinish)) then
				local hAchievement = hA:AppendItemFromIni(szIniFile, "Achievement")
				hAchievement.dwGeneral = page.dwGeneral
				hAchievement.dwSub = page.dwSub
				hAchievement.dwDetail = page.dwDetail
				hAchievement.dwAchievement = dwAchievement
				hAchievement.bAchievement = true
				hAchievement.bFD = bFD
				hAchievement.bFinish = bFinish
				hAchievement:Lookup("Name"):SetText(aAchievement.szName)
				local box = hAchievement:Lookup("Icon")
				box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
				box:SetObjectIcon(aAchievement.nIconID)
				hAchievement:Lookup("ShortDesc"):SetText(aAchievement.szShortDesc)
				local _, nP = GetAchievementInfo(dwAchievement)
				hAchievement:Lookup("Hortation"):SetText(nP or 0)
				hAchievement:Lookup("Finish"):Show(hAchievement.bFinish)
				
				local img = hAchievement:Lookup("Ranking")
				img:Show(hAchievement.bFD)
				img.bRanking = true
				
				local img = hAchievement:Lookup("Break")
				img.bExpand = true
				
				AchievementPanel.UpdateAchievementDetail(hAchievement)
			end
		end
	end
	
	AchievementPanel.UpdateScrollInfo(hA)
	AchievementPanel.UpdateCmpShow(page:GetRoot())	
end

function AchievementPanel.UpdateAchievementDetail(hAchievement)
	local player = GetClientPlayer()
	local aAchievement = g_tTable.Achievement:Search(hAchievement.dwAchievement)
	
	local hDetail = hAchievement:Lookup("Detail")
	hDetail:Clear()
	if not aAchievement then
		return
	end
	
	local szIniFile = "UI/Config/Default/AchievementAdd.ini"
	if aAchievement.szDesc ~= "" then
		hDetail:AppendItemFromString(GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..aAchievement.szDesc.."\n", 160))
	end
	local bSub, bCounter = false, false
	local szSubAchievements = aAchievement.szSubAchievements
	for s in string.gmatch(szSubAchievements, "%d+") do
		local dwSubAchievement = tonumber(s)
		local aSubAchievement = g_tTable.Achievement:Search(dwSubAchievement)
		if aSubAchievement then
			local hSub = hDetail:AppendItemFromIni(szIniFile, "SubAchivement")
			hSub.bSubAchievement = true
			hSub.bFinish = player.IsAchievementAcquired(dwSubAchievement)
			hSub.dwSubAchievement = dwSubAchievement
			hSub:Lookup("SubName"):SetText(aSubAchievement.szName)
			hSub:Lookup("FinishFlag"):Show(hSub.bFinish)
			bSub = true
		end
	end

	local szCounters = aAchievement.szCounters
	for s in string.gmatch(szCounters, "%d+") do
		local dwCounter = tonumber(s)
		local aCounter = g_tTable.AchievementCounter:Search(dwCounter)
		if aCounter then
			if bSub then
				hDetail:AppendItemFromString("<text>text=\"\\\n\"</text>")
				bSub = false
			end
			bCounter = true
			local hSub = hDetail:AppendItemFromIni(szIniFile, "SubAchivement")
			hSub.bCounter = true
			hSub.dwCounter = dwCounter
			hSub.szDesc = aCounter.szDesc
			hSub.bFinish = player.IsAchievementAcquired(dwCounter)
			local nCMax = GetAchievementInfo(dwCounter) or 0
			local nC = AchievementPanel.GetAchievementCount(dwCounter)
			hSub:Lookup("SubName"):SetText(aCounter.szDesc..":"..nC.."/"..nCMax)
			hSub:Lookup("FinishFlag"):Show(hSub.bFinish)
		end
	end
	
	if bSub or bCounter then
		hDetail:AppendItemFromString("<text>text=\"\\\n\"</text>")
	end
	
	local _, nPoint, nExp, nPrefix, nPostfix = GetAchievementInfo(hAchievement.dwAchievement)
	nPoint, nExp, nPrefix, nPostfix = nPoint or 0, nExp or 0, nPrefix or 0, nPostfix or 0
	if nPoint > 0 then
		hDetail:AppendItemFromString(GetFormatText(FormatString(g_tStrings.STR_ACHIEVEMENT_HR_POINT.."\n", nPoint), 160))
	end
	if nExp > 0 then
		hDetail:AppendItemFromString(GetFormatText(FormatString(g_tStrings.STR_ACHIEVEMENT_HR_EXP.."\n", nExp), 160))
	end
	
	if nPrefix > 0 and nPrefix < 256 then
		local aPrefix = g_tTable.Designation_Prefix:Search(nPrefix)
		if aPrefix then
			if GetDesignationPrefixInfo(nPrefix).nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
				hDetail:AppendItemFromString(GetFormatText(FormatString(g_tStrings.STR_ACHIEVEMENT_HR_TITLE_WORLD.."\n", aPrefix.szName), 160))
			else
				hDetail:AppendItemFromString(GetFormatText(FormatString(g_tStrings.STR_ACHIEVEMENT_HR_TITLE_PREFIX.."\n", aPrefix.szName), 160))
			end
		end
	end

	if nPostfix > 0 and nPostfix < 256 then
		local aPostfix = g_tTable.Designation_Postfix:Search(nPostfix)
		if aPostfix then
			hDetail:AppendItemFromString(GetFormatText(FormatString(g_tStrings.STR_ACHIEVEMENT_HR_TITLE_POSTFIX.."\n", aPostfix.szName), 160))
		end
	end
	
	if aAchievement.dwItemType > 0 and aAchievement.dwItemID > 0 then
		local itemInfo = GetItemInfo(aAchievement.dwItemType, aAchievement.dwItemID)
		if itemInfo then
			local szItem = MakeItemInfoLink("["..GetItemNameByItemInfo(itemInfo).."]", "font=160 "..GetItemFontColorByQuality(itemInfo.nQuality, true), 0, aAchievement.dwItemType, aAchievement.dwItemID)	
			hDetail:AppendItemFromString(FormatLinkString(g_tStrings.STR_ACHIEVEMENT_HR_TITLE_ITEM, "font=160", szItem))
		end
	end
	
	hAchievement.bShowDetail = false
	AchievementPanel.UpdateDetailShowInfo(hAchievement)
end

function AchievementPanel.UpdateScrollInfo(hList)
	local scroll, btnUp, btnDown
	
	local szName = hList:GetName()
	
	local page = hList:GetParent():GetParent()
	if szName == "Handle_List" then
		scroll = page:Lookup("Scroll_List")
		btnUp = page:Lookup("Btn_Up")
		btnDown = page:Lookup("Btn_Down")
	elseif szName == "Handle_Achievement" then
		scroll = page:Lookup("Scroll_Achievement")
		btnUp = page:Lookup("Btn_AUp")
		btnDown = page:Lookup("Btn_ADown")
	elseif szName == "Handle_ListFD" then
		scroll = page:Lookup("Scroll_ListFD")
		btnUp = page:Lookup("Btn_UpFD")
		btnDown = page:Lookup("Btn_DownFD")
	elseif szName == "Handle_AchievementFD" then
		scroll = page:Lookup("Scroll_AchievementFD")
		btnUp = page:Lookup("Btn_AUpFD")
		btnDown = page:Lookup("Btn_ADownFD")
	elseif szName == "Handle_CmpList" then
		if not hList:IsVisible() then
			return
		end
		scroll = page:Lookup("Scroll_Info")
		btnUp = page:Lookup("Btn_Up_Info")
		btnDown = page:Lookup("Btn_Down_Info")
	elseif szName == "Handle_RankingList" then
		if not hList:IsVisible() then
			return
		end
		scroll = page:Lookup("Scroll_Info")
		btnUp = page:Lookup("Btn_Up_Info")
		btnDown = page:Lookup("Btn_Down_Info")
	elseif szName == "Handle_ListRANK" then
		scroll = page:Lookup("Scroll_ListR")
		btnUp = page:Lookup("Btn_UpR")
		btnDown = page:Lookup("Btn_DownR")		
	elseif szName == "Handle_RANKList" then
		scroll = page:Lookup("Scroll_AchievementR")
		btnUp = page:Lookup("Btn_AUpR")
		btnDown = page:Lookup("Btn_ADownR")		
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

function AchievementPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	
	local szName = this:GetName()
	local page = this:GetParent()
	local hList, btnUp, btnDown
	if szName == "Scroll_List" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_List"), page:Lookup("Btn_Up"), page:Lookup("Btn_Down")
	elseif szName == "Scroll_Achievement" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_Achievement"), page:Lookup("Btn_AUp"), page:Lookup("Btn_ADown")
		if page:GetParent():GetActivePage() == page and not this.bNoPost then
			local scroll = page:GetRoot():Lookup("Wnd_Cmp/Scroll_Info")
			scroll.bNoPost = true
			scroll:SetScrollPos(nCurrentValue)
			scroll.bNoPost = false
		end
	elseif szName == "Scroll_ListFD" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_ListFD"), page:Lookup("Btn_UpFD"), page:Lookup("Btn_DownFD")
	elseif szName == "Scroll_AchievementFD" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_AchievementFD"), page:Lookup("Btn_AUpFD"), page:Lookup("Btn_ADownFD")
	elseif szName == "Scroll_Info" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_CmpList"), page:Lookup("Btn_Up_Info"), page:Lookup("Btn_Down_Info")
		if hList:IsVisible() then
			if not this.bNoPost then
				local activePage = page:GetRoot():Lookup("PageSet_Achievement"):GetActivePage()
				if activePage:GetName() == "Page_Normal" then
					scroll = activePage:Lookup("Scroll_Achievement")
					scroll.bNoPost = true
					scroll:SetScrollPos(nCurrentValue)
					scroll.bNoPost = false
				end
			end
		else
			hList = page:Lookup("", "Handle_RankingList")
		end
	elseif szName == "Scroll_ListR" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_ListRANK"), page:Lookup("Btn_UpR"), page:Lookup("Btn_DownR")
	elseif szName == "Scroll_AchievementR" then
		hList, btnUp, btnDown = page:Lookup("", "Handle_RANKList"), page:Lookup("Btn_AUpR"), page:Lookup("Btn_ADownR")
	end
	
	btnUp:Enable(nCurrentValue ~= 0)
	btnDown:Enable(nCurrentValue ~= this:GetStepCount())
    hList:SetItemStartRelPos(0, - nCurrentValue * 10)
    if hList2 then
    	hList2:SetItemStartRelPos(0, - nCurrentValue * 10)
    end
end

function AchievementPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_List" then
		this:GetParent():GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_Achievement" then
		this:GetParent():GetParent():Lookup("Scroll_Achievement"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_ListFD" then
		this:GetParent():GetParent():Lookup("Scroll_ListFD"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_AchievementFD" then
		this:GetParent():GetParent():Lookup("Scroll_AchievementFD"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_CmpList" then
		this:GetParent():GetParent():Lookup("Scroll_Info"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_RankingList" then
		this:GetParent():GetParent():Lookup("Scroll_Info"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_ListRANK" then
		this:GetParent():GetParent():Lookup("Scroll_ListR"):ScrollNext(nDistance)
		return 1
	elseif szName == "Handle_RANKList" then
		this:GetParent():GetParent():Lookup("Scroll_AchievementR"):ScrollNext(nDistance)
		return 1
	end
end

function AchievementPanel.OnMouseWheel()
	if this:GetName() == "AchievementPanel" then
		return 1
	end
end

function AchievementPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Filter" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end
		
		local fnA = function(u, b)
			AchievementPanel.szFilter = u
			FireEvent("ACHIEVEMENT_FILTER_CHANGED")
		end
		
		local btn = this
		local text = this:Lookup("", "Text_Filter")
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

			fnAutoClose = function() return not IsAchievementPanelOpened() end,
			{szOption = g_tStrings.STR_ACHIEVEMENT_FLITER_FINISH, UserData = "finish", fnAction = fnA },
			{szOption = g_tStrings.STR_ACHIEVEMENT_FLITER_UNFINISH, UserData = "unfinish", fnAction = fnA },
			{szOption = g_tStrings.STR_ACHIEVEMENT_FLITER_ALL, UserData = "all", fnAction = fnA }
		}
		PopupMenu(menu)	
		return true	
	else
		AchievementPanel.OnLButtonHold()
	end
end

function AchievementPanel.OnLButtonHold()
	local szName = this:GetName()
	local page = this:GetParent()
	if szName == "Btn_Up" then
		page:Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		page:Lookup("Scroll_List"):ScrollNext(1)
	elseif szName == "Btn_AUp" then
		page:Lookup("Scroll_Achievement"):ScrollPrev(1)
	elseif szName == "Btn_ADown" then
		page:Lookup("Scroll_Achievement"):ScrollNext(1)
	elseif szName == "Btn_UpFD" then
		page:Lookup("Scroll_ListFD"):ScrollPrev(1)
	elseif szName == "Btn_DownFD" then
		page:Lookup("Scroll_ListFD"):ScrollNext(1)
	elseif szName == "Btn_AUpFD" then
		page:Lookup("Scroll_AchievementFD"):ScrollPrev(1)
	elseif szName == "Btn_ADownFD" then
		page:Lookup("Scroll_AchievementFD"):ScrollNext(1)
	elseif szName == "Btn_Up_Info" then
		page:Lookup("Scroll_Info"):ScrollPrev(1)
	elseif szName == "Btn_Down_Info" then
		page:Lookup("Scroll_Info"):ScrollNext(1)
	elseif szName == "Btn_UpR" then
		page:Lookup("Scroll_ListR"):ScrollPrev(1)
	elseif szName == "Btn_DownR" then
		page:Lookup("Scroll_ListR"):ScrollNext(1)
	elseif szName == "Btn_AUpR" then
		page:Lookup("Scroll_AchievementR"):ScrollPrev(1)
	elseif szName == "Btn_ADownR" then
		page:Lookup("Scroll_AchievementR"):ScrollNext(1)
	end
end

function AchievementPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseAchievementPanel()
	elseif szName == "Btn_Back" then
		local page = this:GetParent()
		AchievementPanel.UnSel(page)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_BackFD" then
		local page = this:GetParent()
		AchievementPanel.UnSel(page)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_BackR" then
		local page = this:GetParent()
		AchievementPanel.UnSel(page)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_CloseCmp" then
		AchievementPanel.UnSelectRankingAchievement(this:GetRoot():Lookup("PageSet_Achievement/Page_FD"))
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

function IsAchievementPanelOpened()
	local frame = Station.Lookup("Normal/AchievementPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenAchievementPanel(bDisableSound, dwAchievement)   
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	AchievementPanel.dwPlayerID = nil

	if IsAchievementPanelOpened() then
		local frame = Station.Lookup("Normal/AchievementPanel")
		if dwAchievement then
			AchievementPanel.ShowAchievementByID(frame, dwAchievement)
		end
		AchievementPanel.UpdateAllShowDetail(frame)
		AchievementPanel.UpdateCmpShow(frame)
		return
	end
	
	local frame = Wnd.OpenWindow("AchievementPanel")
	frame:Show()
	
	if dwAchievement then
		AchievementPanel.ShowAchievementByID(frame, dwAchievement)
	end
	
	AchievementPanel.UpdateAllShowDetail(frame)
	AchievementPanel.UpdateCmpShow(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CompareAchievement(dwPlayerID)	
    if CheckPlayerIsRemote() then
        return
    end
    
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	local player = GetPlayer(dwPlayerID)
	if not player then
		return
	end
	
	AchievementPanel.dwPlayerID = dwPlayerID
	
	local bOpen = IsAchievementPanelOpened()
	local frame = Wnd.OpenWindow("AchievementPanel")
	frame:Show()
	AchievementPanel.UnShowAllDetail(frame)
	AchievementPanel.UpdateCmpShow(frame)
	if not bOpen then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseAchievementPanel(bDisableSound)
	if not IsAchievementPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/AchievementPanel")
	frame:Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end
