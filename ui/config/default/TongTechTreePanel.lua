local TREE_LINE_MAX_SIZE = 10
local FARM_LINE_MAX_SIZE =  5
local TONG_TECH_TREE_NODE_CLICK_SUCCESS = 10
local TONG_TECH_TREE_NODE_CLICK_NOT_ENOUGH_CONDITION = 1
local TONG_TECH_TREE_NODE_CLICK_NOT_ENOUGH_COST = 2
local TONG_TECH_TREE_NODE_CLICK_NOT_ENOUGH_POINT = 3
local TONG_TECH_TREE_NODE_CLICK_NOT_OPERATE = 5

local szIniFile = "UI/Config/Default/TongTechTreePanel.ini"

local tTrunkNode = 
{
	[1] = 0, -- 招贤纳士
	[2] = 1, -- 封官拜将
	[3] = 2, -- 藏珍坊
	[4] = 4, -- 阵营铁卫（这个以前在逻辑中叫龙神马壮）
	[5] = 3, -- 圣手坊
	[6] = 5, -- 积少成多
	[7] = 7, -- 白手起家
	[8] = 6, -- 周而复始
	[9] = 9, -- 隐宝阁
	[10] = 10, -- 神工阁
	[11] = 8, -- 年年有余
	[12] = 11, -- 多彩多色
	[13] = 13, -- 吃遍天下
	[14] = 12, -- 美轮美奂
	[15] = 15, -- 玉华玄宫
	[16] = 16, -- 天机宝殿
	[17] = 14, -- 物美价廉
	[18] = 17, -- 仙人指路
	[19] = 18, -- 事半功倍
	[20] = 19, -- 富贵勿相忘
	[21] = 25, -- 兴家立业
	[22] = 28, -- 灵丹妙药
}

local tFarmNode = 
{
	[1] = 20, -- 小猪快跑
	[2] = 21, -- 步步生莲
	[3] = 22, -- 锦天绣地
	[4] = 27, -- 鸢飞鱼跃
	[5] = 24, -- 春华秋实
	[6] = 23, -- 奇珍异宝
	[7] = 29, -- 洗髓伐脉
	[8] = 26, -- 五谷丰登
	[9] = 30, -- 欣欣向荣
}

TongTechTreePanel = {}

function TongTechTreePanel.OnFrameCreate()
	this:RegisterEvent("UPDATE_TONG_INFO_FINISH")
	this:RegisterEvent("UPDATE_TONG_ROSTER_FINISH")
	this:RegisterEvent("SET_TONG_TECH_TREE_RESPOND")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("UPDATE_SELECT_TARGET")
	this:RegisterEvent("ON_TONG_BUILD_LEVEL_RESPOND")
	
	TongTechTreePanel.OnEvent("UI_SCALED")
	TongTechTreePanel.Update(this)
end

function TongTechTreePanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif szEvent == "UPDATE_TONG_INFO_FINISH" then
		TongTechTreePanel.Update(this)
	elseif szEvent == "UPDATE_TONG_ROSTER_FINISH" then
		TongTechTreePanel.Update(this)
	elseif szEvent == "SET_TONG_TECH_TREE_RESPOND" then
		local nNodeID, nLevel, bResult, nError = arg0, arg1, arg2, arg3
		local tNodeInfo = Table_GetTongTechTreeNodeInfo(nNodeID, nLevel)
		if bResult then
			local Node = TongTechTreeNode[nNodeID]
			local nCost = GetTongTechTreeNodeCost(Node, nLevel)
			local nDevelopmentPoint = GetTongTechTreeNodeDevelopmentPoint(Node, nLevel)
			local szMsg = FormatString(g_tStrings.TONG_TECH_TREE_SUCCESS_COST_POINT .. "\n", tNodeInfo.szName, nLevel, nDevelopmentPoint, nCost)
			OutputMessage("MSG_SYS", szMsg)
		else
			local szMsg = g_tStrings.tTongTechTreeError[nError]
			OutputMessage("MSG_ANNOUNCE_RED", szMsg)
		end
		local TongClient = GetTongClient()
		TongClient.ApplyTongInfo()
		TongClient.ApplyTongRoster()
		TongTechTreePanel.Update(this)
	elseif szEvent == "UPDATE_SELECT_TARGET" then
		if this.dwNpcID then
			local hPlayer = GetClientPlayer()
			local dwTargetType, dwTargetID = hPlayer.GetTarget()
			if dwTargetType ~= TARGET.NPC or dwTargetID ~= this.dwNpcID then
				CloseTongTechTreePanel()
			end
		end
	elseif szEvent == "ON_TONG_BUILD_LEVEL_RESPOND" then
        this.tState = arg0
		TongTechTreePanel.UpdateTongBuildLevel(this)
	end
end

function TongTechTreePanel.OnFrameBreathe()
	if not this.dwNpcID then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer or hPlayer.nMoveState == MOVE_STATE.ON_DEATH then
		CloseTongTechTreePanel()
		return
	end
	
	if this.dwNpcID then
		local hNpc = GetNpc(this.dwNpcID)
		if not hNpc or not hNpc.CanDialog(hPlayer) then
			CloseTongTechTreePanel()
		end
	end
end

function TongTechTreePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseTongTechTreePanel()
	elseif this.nNodeID then
		TongTechTreePanel.ClickNode(this)
	end
end

function TongTechTreePanel.ClickNode(hNode)
	local hFrame = hNode:GetRoot()
	if hFrame.bCanClick and not hNode.bMax then
		if hNode.bCanClick then
			local nNodeID = hNode.nNodeID
			local TongClient = GetTongClient()
			local nLevel = TongClient.GetTechNodeLevel(nNodeID)
			local Node = TongTechTreeNode[nNodeID]
			local nCost = GetTongTechTreeNodeCost(Node, nLevel + 1)
			local nDevelopmentPoint = GetTongTechTreeNodeDevelopmentPoint(Node, nLevel + 1)
			local tNodeInfo = Table_GetTongTechTreeNodeInfo(nNodeID, nLevel + 1)
			local szDesc = FormatString(g_tStrings.TONG_TECH_TREE_NODE_CLICK_SURE, tNodeInfo.szName, nLevel + 1, nDevelopmentPoint, nCost)
            local fnClickNode = function()
                RemoteCallToServer("OnSetTongTechTreeRequest", nNodeID, nLevel + 1)
                RemoteCallToServer("On_Tong_GetBuildLevelRequest")
            end
			local tMsg = 
			{
				szMessage = szDesc, 
				szName = "ClickTongTechTreeSure", 
				fnAutoClose = function() return not IsTongTechTreePanelOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnClickNode},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL }
			}
			MessageBox(tMsg)
		else
			local szMsg = g_tStrings.tTongTechTreeError[hNode.nError]
			OutputMessage("MSG_ANNOUNCE_RED", szMsg)
		end
	end
end

function TongTechTreePanel.OnItemMouseEnter()
	local szName = this:GetName()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	if szName == "Image_GongCasing" or szName == "Image_DanCasing" then
        local szTip = GetFormatText(g_tStrings.TONG_TECH_TREE_TIP_POINT .. this.nTimes .. "/" .. this.nBuildTimes .. "\n") 
        if szName == "Image_GongCasing" then
            szTip = szTip .. GetFormatText(FormatString(g_tStrings.TONG_TECH_TREE_TIP_GONGFANG, this.szName))
        else
            szTip = szTip .. GetFormatText(FormatString(g_tStrings.TONG_TECH_TREE_TIP_DANFANG, this.szName))
        end
		OutputTip(szTip, 300, {x, y, w, h})
	end
end

function TongTechTreePanel.OnItemMouseLeave()
	HideTip()
end

function TongTechTreePanel.OnMouseEnter()
	if this.nNodeID then
		local szTip = ""
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
	 	local nNodeID = this.nNodeID
	 	local TongClient = GetTongClient()
	 	local nLevel = TongClient.GetTechNodeLevel(nNodeID)
	 	local nMaxLevel = TongTechTreePanel.GetTreeNodeMaxLevel(nNodeID)
	 	local nShowLevel = nLevel
	 	if nShowLevel == 0 then
	 		nShowLevel = 1
	 	end
	 	local tNodeInfo = Table_GetTongTechTreeNodeInfo(nNodeID, nShowLevel)
	 	szTip = GetFormatText(tNodeInfo.szName, 31)
	 	szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, nShowLevel.."/"..nMaxLevel), 61)
		
		if nLevel ~= 0 then
			szTip = szTip .. GetFormatText(g_tStrings.CURRENT_LEVEL, 106)
			szTip = szTip .. GetFormatText(tNodeInfo.szDesc .. "\n", 100)
			if nLevel == nMaxLevel then
				szTip = szTip .. GetFormatText(g_tStrings.TONG_TECH_TREE_NODE_TOP_LEVEL, 106)
			else
				szTip = szTip .. GetFormatText(g_tStrings.STR_NEXT_LEVEL, 106)
			end
		end
		
		if nLevel ~= nMaxLevel then
			nLevel = nLevel + 1
			local Node = TongTechTreeNode[nNodeID]
			local nCost = GetTongTechTreeNodeCost(Node, nLevel)
			local nDevelopmentPoint = GetTongTechTreeNodeDevelopmentPoint(Node, nLevel)
			local nFont = 106
			if nCost > 0 then
				szTip = szTip .. GetFormatText(g_tStrings.TONG_TECH_TREE_NEED_COST , 106)
				if nCost > TongClient.nFund then
					nFont = 102
				end
				szTip = szTip .. GetFormatText(nCost, nFont)
			end
			
			if nDevelopmentPoint > 0 then
				if nCost > 0 then
					szTip = szTip .. GetFormatText("\t\t\t")
				end
				szTip = szTip .. GetFormatText(g_tStrings.TONG_TECH_TREE_NEED_POINT , 106)
				nFont = 106
				if nDevelopmentPoint > TongClient.nDevelopmentPoint then
					nFont = 102
				end
				szTip = szTip .. GetFormatText(nDevelopmentPoint, nFont)
			end
			szTip = szTip .. GetFormatText("\n")
			
			local szNeed = ""
			local nCount = 0
			nFont = 106
			
			for nNeedNodeID, nNeedLevel in pairs(Node.Dependence) do
				if TongClient.GetTechNodeLevel(nNeedNodeID) < nNeedLevel then
					nFont = 102
				end
				local tNeedNodeInfo = Table_GetTongTechTreeNodeInfo(nNeedNodeID, nNeedLevel)
				if tNeedNodeInfo then
					if nCount == 0 then
						szNeed = szNeed .. g_tStrings.TONG_TECH_TREE_NEED_GET_THROUGH
					else
						szNeed = szNeed .. g_tStrings.STR_COMMA
					end
					szNeed = szNeed .. FormatString(g_tStrings.STR_LEARN_SKILL_LEVEL, tNeedNodeInfo.szName, nNeedLevel)
					nCount = nCount + 1
				end
			end
			if szNeed ~= "" then
				szTip = szTip .. GetFormatText(szNeed .. "\n", nFont)
			end
			
			local tNextNodeInfo = Table_GetTongTechTreeNodeInfo(nNodeID, nLevel)
			szTip = szTip .. GetFormatText(tNextNodeInfo.szDesc .. "\n", 100)
			
			for nNextLevel = nLevel + 1, nMaxLevel do
				local tInfo = Table_GetTongTechTreeNodeInfo(nNodeID, nNextLevel)
				szTip = szTip .. GetFormatText(tInfo.szDesc .. "\n", 61)
			end
		end
		OutputTip(szTip, 300, {x, y, w, h})
	end
	
end

function TongTechTreePanel.OnMouseLeave()
	HideTip()
end

function TongTechTreePanel.Update(hFrame)
	local TongClient = GetTongClient()
	local hPlayer = GetClientPlayer()
	local hInfo = TongClient.GetMemberInfo(hPlayer.dwID)
	local bCanClick = false
	if hFrame.dwNpcID then
		bCanClick = true
	end
	hFrame.bCanClick = bCanClick
	local hPoint = hFrame:Lookup("", "Text_GuildDev")
	hPoint:SetText(TongClient.nDevelopmentPoint)
	local hMoney = hFrame:Lookup("", "Handle_GuildMoney")
	hMoney:Clear()
	hMoney:AppendItemFromString(GetFormatText(TongClient.nFund .. "  ", 18))
	local hImage = hMoney:AppendItemFromIni(szIniFile, "Image_MoneyIcon")
	hImage:Show()
	hMoney:FormatAllItemPos()
	local hWndTrunk = hFrame:Lookup("PageSet_TongTechTree/Page_TreeTrunk")
	TongTechTreePanel.UpdateTrunk(hWndTrunk)
	
	local hWndFarm = hFrame:Lookup("PageSet_TongTechTree/Page_FarmTree")
	TongTechTreePanel.UpdateFarm(hWndFarm)
	TongTechTreePanel.UpdateTongBuildLevel(hFrame)
end

function TongTechTreePanel.UpdateTongBuildLevel(hFrame)
	local hHandle = hFrame:Lookup("", "Handle_Build")
    
	hHandle:Show()
	local hTextGongUnStart = hHandle:Lookup("Text_GongUnStart")
	local hTextGong = hHandle:Lookup("Text_Gong")
	local hTextGongFinish = hHandle:Lookup("Text_GongFinish")
	local hImageGong = hHandle:Lookup("Image_Gongbar")
	local hImageGongBg = hHandle:Lookup("Image_GongCasing")
	local tState = hFrame.tState
	if tState and tState.szGongFangName then
		hTextGongUnStart:Hide()
        hTextGong:Show()
		hTextGong:SetText(tState.szGongFangName .. ":")
		if tState.bGongFangBuilding then
			hTextGongFinish:Hide()
			hImageGongBg:Show()
			hImageGong:Show()
            hImageGongBg.szName = tState.szGongFangName
			hImageGongBg.nTimes = tState.nGongFangTotalTimes
			hImageGongBg.nBuildTimes = tState.nGongBuildTimes
			local fPercentage = tState.nGongFangTotalTimes / tState.nGongBuildTimes
			hImageGong:SetPercentage(fPercentage)
		else
			hTextGongFinish:Show()
			hImageGongBg:Hide()
			hImageGong:Hide()
		end
	else
		hTextGongUnStart:Show()
		hTextGong:Hide()
		hTextGongFinish:Hide()
		hImageGongBg:Hide()
		hImageGong:Hide()
	end
	
	local hTextDanUnStart = hHandle:Lookup("Text_DanUnStart")
	local hTextDan = hHandle:Lookup("Text_Dan")
	local hTextDanFinish = hHandle:Lookup("Text_DanFinish")
	local hImageDan = hHandle:Lookup("Image_Danbar")
	local hImageDanBg = hHandle:Lookup("Image_DanCasing")
	
	if tState and tState.szDanFangName then
		hTextDanUnStart:Hide()
        hTextDan:Show()
		hTextDan:SetText(tState.szDanFangName .. ":")
		if tState.bDanFangBuilding then
			hTextDanFinish:Hide()
			hImageDanBg:Show()
			hImageDan:Show()
            hImageDanBg.szName = tState.szDanFangName
			hImageDanBg.nTimes = tState.nDanFangTotalTimes
			hImageDanBg.nBuildTimes = tState.nDanBuildTimes
			local fPercentage = tState.nDanFangTotalTimes / tState.nDanBuildTimes
			hImageDan:SetPercentage(fPercentage)
		else
			hTextDanFinish:Show()
			hImageDanBg:Hide()
			hImageDan:Hide()
		end
	else
		hTextDanUnStart:Show()
		hTextDan:Hide()
		hTextDanFinish:Hide()
		hImageDanBg:Hide()
		hImageDan:Hide()
	end
end

function TongTechTreePanel.UpdateFarm(hWndFarm)
	local hFrame = hWndFarm:GetRoot()
	local TongClient = GetTongClient()
	local hFarmHandle = hWndFarm:Lookup("", "")
	for nIndex, nNodeID in pairs(tFarmNode) do
		local hFarmNode = hWndFarm:Lookup("Btn_FarmNode" .. nIndex)
		local bCanClick, nError = false, 0
		local nLevel = TongClient.GetTechNodeLevel(nNodeID)
		local nMaxLevel = TongTechTreePanel.GetTreeNodeMaxLevel(nNodeID)
		
		local hText = hFarmHandle:Lookup("Text_FarmNode" .. nIndex)
		if nLevel == nMaxLevel then
			hFarmNode.bMax = true
			hText:SetFontScheme(16)
			bCanClick = true
		else
			hFarmNode.bMax = false
			hText:SetFontScheme(192)
		end
		
		if not hFarmNode.bMax then
			bCanClick, nError = TongTechTreePanel.IsCanClickTreeNode(TongClient, nNodeID,  nLevel + 1)
		end
		
		local bShowLine = false
		hFarmNode.bCanClick = bCanClick
		hFarmNode.nNodeID = nNodeID
		hFarmNode.nError = nError
		if nLevel >= 1 or bCanClick then
			if hFrame.dwNpcID then
				hFarmNode:Enable(true)
			else
				hFarmNode:Enable(false)
				hText:SetFontScheme(169)
			end
			hText:Show()
			hText:SetText(nLevel)
			bShowLine = true
		else
			hFarmNode:Enable(false)
			hText:Hide()
		end
		for i = 1, FARM_LINE_MAX_SIZE do
			local szLineName = "Image_FN".. nIndex .."Line" .. i
			local hLine = hFarmHandle:Lookup(szLineName)
			if not hLine then
				break
			end
			hLine:Show(bShowLine)
		end
	end
end

function TongTechTreePanel.UpdateTrunk(hWndTrunk)
	local hFrame = hWndTrunk:GetRoot()
	local TongClient = GetTongClient()
	local hTrunkHandle = hWndTrunk:Lookup("", "Handle_NodeTotal")
	for nIndex, nNodeID in pairs(tTrunkNode) do
		local hTrunkNode = hWndTrunk:Lookup("Btn_TrunkNode" .. nIndex)
		local bCanClick, nError = false, 0
		local nLevel = TongClient.GetTechNodeLevel(nNodeID)
		local nMaxLevel = TongTechTreePanel.GetTreeNodeMaxLevel(nNodeID)
		
		local hText = hTrunkHandle:Lookup("Text_TrunkNode" .. nIndex)
		if nLevel == nMaxLevel then
			hTrunkNode.bMax = true
			hText:SetFontScheme(16)
			bCanClick = true
		else
			hTrunkNode.bMax = false
			hText:SetFontScheme(192)
		end
		
		if not hTrunkNode.bMax then
			bCanClick, nError = TongTechTreePanel.IsCanClickTreeNode(TongClient, nNodeID,  nLevel + 1)
		end
		
		local bShowLine = false
		hTrunkNode.bCanClick = bCanClick
		hTrunkNode.nNodeID = nNodeID
		hTrunkNode.nError = nError
		if nLevel >= 1 or bCanClick then
			if hFrame.dwNpcID then
				hTrunkNode:Enable(true)
			else
				hTrunkNode:Enable(false)
				hText:SetFontScheme(169)
			end
			hText:Show()
			hText:SetText(nLevel)
			bShowLine = true
		else
			hTrunkNode:Enable(false)
			hText:Hide()
		end
		for i = 1, TREE_LINE_MAX_SIZE do
			local szLineName = "Image_TN".. nIndex .."Line" .. i
			local hLine = hTrunkHandle:Lookup(szLineName)
			if not hLine then
				break
			end
			hLine:Show(bShowLine)
		end
	end
end

function TongTechTreePanel.GetTreeNodeMaxLevel(nNodeID)
	local Node = TongTechTreeNode[nNodeID]
	local nMaxLevel = Node.Max
	
	return nMaxLevel
end

function TongTechTreePanel.IsCanClickTreeNode(TongClient, nNodeID, nLevel)
	local bCanClick = true
	local nError = TONG_TECH_TREE_NODE_CLICK_SUCCESS
	local Node = TongTechTreeNode[nNodeID]
	local nCost = 0
	local nDevelopmentPoint = 0
	
	nCost = GetTongTechTreeNodeCost(Node, nLevel)
	nDevelopmentPoint = GetTongTechTreeNodeDevelopmentPoint(Node, nLevel)
	
	if TongClient.nFund < nCost then
		nError = TONG_TECH_TREE_NODE_CLICK_NOT_ENOUGH_COST
		bCanClick = false
	end
	if TongClient.nDevelopmentPoint < nDevelopmentPoint then
		nError = TONG_TECH_TREE_NODE_CLICK_NOT_ENOUGH_POINT
		bCanClick = false
	end
	
	for NodeIndex, Limit in pairs(TongTechTreeNode[nNodeID].Dependence) do
		if TongClient.GetTechNodeLevel(NodeIndex) < Limit then
			bCanClick = false
			nError = TONG_TECH_TREE_NODE_CLICK_NOT_ENOUGH_CONDITION
		end
	end
	return bCanClick, nError
end

function OpenTongTechTreePanel(dwNpcID, bDisableSound)
	local hPlayer = GetClientPlayer()
	if not hPlayer or not hPlayer.dwTongID or hPlayer.dwTongID == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_NOT_ACTIVE)
		return
	end
	
	if not IsTongTechTreePanelOpened() then
		Wnd.OpenWindow("TongTechTreePanel")
	end
	local TongClient = GetTongClient()
	TongClient.ApplyTongInfo()
	TongClient.ApplyTongRoster()
	local hFrame = Station.Lookup("Normal/TongTechTreePanel")
	hFrame.dwNpcID = dwNpcID
	RemoteCallToServer("On_Tong_GetBuildLevelRequest")
	TongTechTreePanel.Update(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsTongTechTreePanelOpened()
	local hFrame = Station.Lookup("Normal/TongTechTreePanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

function CloseTongTechTreePanel(bDisableSound)
	if not IsTongTechTreePanelOpened() then
		return
	end
	
	Wnd.CloseWindow("TongTechTreePanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end