local DUNGEON_TYPE = 
{
	NORMAL = 1,
	RAID = 3,
	HARD = 2,
	BATTLE_FIELD = 4,
}

local REMOTE_CALLER =
{
	SAVE_COPY = nil,
	MAP_INFO  = nil,
}

DungeonInfoPanel = 
{
}
local l_hFrame
local INI_FILE = "UI/Config/Default/DungeonInfoPanel.ini"
local l_nBattleSelected
local l_nDungeonSelected
local l_tBattleMapInfo = {}
local l_tDungeonMapInfo = {}
local l_tDungeonExpand = {}
local l_tDungeonLayers = {}
local l_tDungeonCopyID = {}

function InitDungeonLayers()
    if l_tDungeonLayers and #l_tDungeonLayers > 0 then
        return
    end
    
    l_tDungeonLayers = {}
    local nCount = g_tTable.DungeonInfo:GetRowCount()
	local tVersionMap = {}
    local tTmpOtherMap = {}
	for i = 2, nCount do
		local tLine = g_tTable.DungeonInfo:GetRow(i)
        local dwMapID = tLine.dwMapID
        local szVersionName, szOtherName, szLayer3Name = tLine.szVersionName, tLine.szOtherName, tLine.szLayer3Name
        local tVerList = tVersionMap[szVersionName]
        if not tVersionMap[szVersionName] then
            table.insert(l_tDungeonLayers, {})
            local nIndex = #l_tDungeonLayers
            tVerList = l_tDungeonLayers[nIndex]
            tVerList.szVersionName = szVersionName
            tVerList.tOtherNameList = {}
            tVersionMap[szVersionName] = tVerList
            
            l_tDungeonExpand[szVersionName] = true
        end
        
        local tOther = tTmpOtherMap[szOtherName]
        if not tTmpOtherMap[szOtherName] then
            table.insert(tVerList.tOtherNameList, {})
            local nIndex = #tVerList.tOtherNameList
            tOther = tVerList.tOtherNameList[nIndex] 
            tOther.szOtherName = szOtherName
            tOther.tLayers = {}
            tTmpOtherMap[szOtherName] = tOther
        end
        table.insert(tOther.tLayers, {szName = szLayer3Name, dwMapID = dwMapID})
	end
end

function DungeonInfoPanel.OnFrameCreate()
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	
	l_hFrame = this
	DungeonInfoPanel.Init(this)
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseDungeonInfoPanel(true) end)

	DungeonInfoPanel.OnEvent("TEAM_AUTHORITY_CHANGED")
end

function DungeonInfoPanel.Init(frame)	
	local pageN = frame:Lookup("PageSet_Main/Page_Normal")
	local pageF = frame:Lookup("PageSet_Main/Page_BattleField")
	
    local player = GetClientPlayer()
    local bHaveAuthority = false
    if not player.IsInParty() or player.IsPartyLeader() then
        bHaveAuthority = true
    end
    
    pageN:Lookup("Btn_Refresh").bHaveAuthority = bHaveAuthority
    pageN:Lookup("Btn_RefreshAll"):Enable(bHaveAuthority)
    
    DungeonInfoPanel.UpdateResetState()
    InitDungeonLayers();
    
    REMOTE_CALLER.MAP_INFO = DUNGEON_TYPE.NORMAL
    RemoteCallToServer("OnApplyPlayerSavedCopysRequest")
	RemoteCallToServer("OnApplyEnterMapInfoRequest")
end

function DungeonInfoPanel.OnEvent(event)
	if event == "LOADING_END" then
		local frame = this:GetRoot()
		if frame:Lookup("PageSet_Main/Page_Normal"):IsVisible() then
			REMOTE_CALLER.MAP_INFO = DUNGEON_TYPE.NORMAL
		else
			REMOTE_CALLER.MAP_INFO = DUNGEON_TYPE.BATTLE_FIELD
		end
		RemoteCallToServer("OnApplyEnterMapInfoRequest")
	elseif event == "TEAM_AUTHORITY_CHANGED" then
		local frame  = this:GetRoot()
		local player = GetClientPlayer()
		
		local bHaveAuthority = false
		if not player.IsInParty() or player.IsPartyLeader() then
			bHaveAuthority = true
		end
		
		local page = frame:Lookup("PageSet_Main/Page_Normal")
		local btnRefresh = page:Lookup("Btn_Refresh")
		
		btnRefresh.bHaveAuthority = bHaveAuthority
		btnRefresh:Enable(btnRefresh.bHaveAuthority and btnRefresh.bCanReset)
		
		page:Lookup("Btn_RefreshAll"):Enable(bHaveAuthority)
	end
end

function DungeonInfoPanel.UpdateBgStatus(hItem)
	if not hItem then          
		Trace("KLUA [ERROR] ui/Config/Default/DungionInfoPanel.lua DungeonInfoPanel.UpdateBgStatus(hItem) hItem is nil!\n")
		return
	end
	
	local szName = hItem:GetName()
	local img = nil
    if szName == "TreeLeaf_Layer1" then
		img = hItem:Lookup("Image_Layer1")
    elseif szName == "TreeLeaf_Layer2" then
        img = hItem:Lookup("Image_Layer2")
	elseif szName == "TreeLeaf_Layer3" then
		img = hItem:Lookup("Image_Layer3")
	elseif szName == "Handle_BFItem" then
		img = hItem:Lookup("Image_BFLight")
	end
	
	if not img then
		return
	end
	
	if hItem.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hItem.bOver then
		img:Show()
		img:SetAlpha(128)				
	else
		img:Hide()
	end
end

function DungeonInfoPanel.Selected(hItem)
	if hItem then 
		local hList = hItem:GetParent()
		local nCount = hList:GetItemCount()
		for i = 0, nCount - 1, 1 do
			local hI = hList:Lookup(i)
			if hI and hI.bSel then
				hI.bSel = false
				DungeonInfoPanel.UpdateBgStatus(hI)
			end
		end
		
		hItem.bSel = true
        if hItem:GetName() == "TreeLeaf_Layer3" then
            l_nDungeonSelected = hItem.dwMapID
        else
            l_nBattleSelected = hItem.dwMapID
        end
		DungeonInfoPanel.UpdateBgStatus(hItem)
		DungeonInfoPanel.UpdateDescList(hItem.dwMapID)
        DungeonInfoPanel.UpdateResetState(hItem)
	end
end
--
function DungeonInfoPanel.UpdateDungeonList(frame)
    local hBook = frame:Lookup("PageSet_Main/Page_Normal", "Handle_Book")
    hBook:Clear()
    
    for _, tVersion in pairs(l_tDungeonLayers) do
        local szVersionName = tVersion.szVersionName
        local hTree1 = hBook:AppendItemFromIni(INI_FILE, "TreeLeaf_Layer1")
        hTree1.szName = szVersionName
        hTree1:Lookup("Text_Layer1"):SetText(szVersionName)
        if l_tDungeonExpand[szVersionName] then
            hTree1:Expand()
        end
        for _, tOther in ipairs(tVersion.tOtherNameList) do
            local szOtherName = tOther.szOtherName
            local hTree2 = hBook:AppendItemFromIni(INI_FILE, "TreeLeaf_Layer2")
            hTree2.szName = szOtherName
            hTree2:Lookup("Text_Layer2"):SetText(szOtherName)
            if l_tDungeonExpand[szOtherName] then
                hTree2:Expand()
            end
            
            for _, tLayer in ipairs(tOther.tLayers) do
                local szName = tLayer.szName
                local hTree3 = hBook:AppendItemFromIni(INI_FILE, "TreeLeaf_Layer3")
                hTree3:Lookup("Text_Layer3"):SetText(szName)
                hTree3.dwMapID = tLayer.dwMapID
                local tInfo = l_tDungeonMapInfo[hTree3.dwMapID]
                
                if tInfo and tInfo.nType == DUNGEON_TYPE.NORMAL then
                	if tInfo.nLimitedTimes == 0 then
                        hTree3:Lookup("Text_Number"):SetText(g_DungeonStrings.STR_DUNGEON_NO_LIMITED)
                    else
                        hTree3:Lookup("Text_Number"):SetText(tInfo.nEnterTimes.."/"..tInfo.nLimitedTimes)
                    end
                elseif tInfo then
                    local szTime = DungeonInfoPanel.GetResetTime(tInfo.nRefreshTime)
                    hTree3:Lookup("Text_Time"):SetText(szTime)
                    if l_tDungeonCopyID[tLayer.dwMapID] then
                        hTree3:Lookup("Text_Number"):SetText("0/1")
                    else
                        hTree3:Lookup("Text_Number"):SetText("1/1")
                    end
                end
                
                if hTree3.dwMapID == l_nDungeonSelected then
                    DungeonInfoPanel.Selected(hTree3)
                    bSel = true
                end
            end
        end
    end
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Book", "DungeonInfoPanel", true)
end

function DungeonInfoPanel.UpdateBattleFieldList(frame)
    local page = frame:Lookup("PageSet_Main/Page_BattleField")
    hList = page:Lookup("", "Handle_BFList")
    hList:Clear()
    
    for dwMapID, v in pairs(l_tBattleMapInfo) do
        local hItem    = hList:AppendItemFromIni(INI_FILE, "Handle_BFItem")
        hItem.dwMapID  = dwMapID
        hItem.nMapType = nMapType
        
        hItem:Lookup("Text_BFNameList"):SetText(v.szMapName)
        if v.nLimitedTimes == 0 then
            hItem:Lookup("Text_BFCountList"):SetText(g_DungeonStrings.STR_DUNGEON_NO_LIMITED)
        else
            hItem:Lookup("Text_BFCountList"):SetText(v.nEnterTimes.."/"..v.nLimitedTimes)
        end
        
        if hItem.dwMapID == l_nBattleSelected then
            DungeonInfoPanel.Selected(hItem)
        end
    end
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_BFList", "DungeonInfoPanel", true)
end

function DungeonInfoPanel.UpdateResetState(hItem)
    local hBtnReset =  l_hFrame:Lookup("PageSet_Main/Page_Normal/Btn_Refresh")
    if not hItem then
        hBtnReset:Enable(false)
        return
    end

    local tInfo = l_tDungeonMapInfo[hItem.dwMapID]
    if tInfo and tInfo.nType == DUNGEON_TYPE.NORMAL then
        hBtnReset.bCanReset = true
    else
        hBtnReset.bCanReset = false
    end
    hBtnReset:Enable(hBtnReset.bHaveAuthority and hBtnReset.bCanReset)
end

function DungeonInfoPanel.UpdateDescList(dwMapID)
	if l_tBattleMapInfo[dwMapID] then
		OpenIntroduce(dwMapID, true, true)
	else
	    OpenIntroduce(dwMapID, true, false)
	end
end

function DungeonInfoPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local frame  = this:GetRoot()
	if szName == "CheckBox_Normal" then
        if l_nDungeonSelected then
            DungeonInfoPanel.UpdateDescList(l_nDungeonSelected)
        else
            CloseIntroduce()
        end
    elseif szName == "CheckBox_BattleField" then
        if l_nBattleSelected then
            DungeonInfoPanel.UpdateDescList(l_nBattleSelected)
        else
            CloseIntroduce()
        end
    end
end

function DungeonInfoPanel.OnCheckBoxUncheck()
	local szName = this:GetName()	
end


function DungeonInfoPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseDungeonInfoPanel()
	elseif szName == "Btn_Refresh" then
		local dwMapID = l_nDungeonSelected
		if dwMapID then
			RemoteCallToServer("OnResetMapRequest", dwMapID)
		end
		
		if not GetClientPlayer().IsAchievementAcquired(982) then
			RemoteCallToServer("OnClientAddAchievement", "Dungeon_First_Refresh")
		end
		
	elseif szName == "Btn_RefreshAll" then
        DungeonInfoPanel.RefreshAll()
	end
end

function DungeonInfoPanel.RefreshAll()
        RemoteCallToServer("OnResetMapRequest", 0)
		if not GetClientPlayer().IsAchievementAcquired(982) then
			RemoteCallToServer("OnClientAddAchievement", "Dungeon_First_Refresh")
		end

end

function DungeonInfoPanel.OnLButtonDown()
	DungeonInfoPanel.OnLButtonHold()
end

function DungeonInfoPanel.OnItemLButtonClick()
	local szName = this:GetName()
	
	if szName == "TreeLeaf_Layer3" or szName == "Handle_BFItem" then
		DungeonInfoPanel.Selected(this)

    elseif szName == "TreeLeaf_Layer1" or szName == "TreeLeaf_Layer2" then
		l_tDungeonExpand[this.szName] = not l_tDungeonExpand[this.szName]
        this:ExpandOrCollapse()
        FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Book", "DungeonInfoPanel", false)
	end
end

function DungeonInfoPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "TreeLeaf_Layer1" or szName == "TreeLeaf_Layer2" or szName == "TreeLeaf_Layer3" or szName == "Handle_BFItem" then
		this.bOver = true
		DungeonInfoPanel.UpdateBgStatus(this)
	end
end

function DungeonInfoPanel.OnItemMouseLeave()
	local szName = this:GetName()
	
	if szName == "TreeLeaf_Layer1" or szName == "TreeLeaf_Layer2" or szName == "TreeLeaf_Layer3" or szName == "Handle_BFItem" then
		this.bOver = false
		DungeonInfoPanel.UpdateBgStatus(this)
	end
end

function DungeonInfoPanel.GetDungeonDesc(dwMapID)
	local tDesc = Table_GetDungeonInfo(dwMapID)
	if not tDesc then
		return ""
	end
	local _, _, nMaxPlayerCount = GetMapParams(dwMapID)
    if not nMaxPlayerCount then
        nMaxPlayerCount= "--"
    end
	local szDesc = ""
    
    if l_tDungeonMapInfo[dwMapID] and l_tDungeonMapInfo[dwMapID].nType ~= DUNGEON_TYPE.NORMAL then
        local szID = g_DungeonStrings.STR_DUNGEON_NO_RECORD
        if l_tDungeonCopyID[dwMapID] then
            szID = l_tDungeonCopyID[dwMapID]
        end
        
        szDesc = szDesc .. GetFormatText(g_DungeonStrings.STR_DUNGEON_COPY_ID, 163)..GetFormatText(szID.."\n\n", 162)
    end
    
	szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_ENTER_LEVEL, 163)..GetFormatText(tDesc.nMinLevel.."\n\n", 162)
	if tDesc.nFitMinLevel ~= tDesc.nFitMaxLevel then
		szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_FIT_LEVEL, 163)..GetFormatText(tDesc.nFitMinLevel.." ~ "..tDesc.nFitMaxLevel.."\n\n", 162)
	else
		szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_FIT_LEVEL, 163)..GetFormatText(tDesc.nFitMinLevel.."\n\n", 162)
	end
	
	szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_ENTER_NUMBER, 163)..GetFormatText(nMaxPlayerCount.."\n\n", 162)
	szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_ENTER_INFO, 163)..GetFormatText(tDesc.szEnterWay.."\n\n", 162)
	
	szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_BOSS_INFO, 163)..GetFormatText(tDesc.szBossInfo.."\n\n", 162)
	szDesc = szDesc .. GetFormatText(g_tStrings.DUNGEON_INTRODUCTION, 163) .. tDesc.szIntroduction
	return szDesc
end

function DungeonInfoPanel.GetResetTime(nTime)
	local szTime = ""
	local nH, nM, nS = GetTimeToHourMinuteSecond(nTime)
	
	local nDay = math.floor(nH / 24)
	if nDay > 0 then
		szTime = nDay..g_tStrings.STR_BUFF_H_TIME_D 
	elseif nH > 0 then
		szTime = nH..g_tStrings.STR_BUFF_H_TIME_H
	elseif nM > 0 then
		szTime = nM..g_tStrings.STR_BUFF_H_TIME_M
	elseif nS >= 0 then
		szTime = nS..g_tStrings.STR_BUFF_H_TIME_S
	end
	
	return szTime
end

function UpdateDungeonInfo(szCallBackFunc, tData, tData1)
	local frame = Station.Lookup("Normal/DungeonInfoPanel")
	if szCallBackFunc == "OnApplyPlayerSavedCopysRespond" then
		if not tData then
			l_tDungeonCopyID = {}
			tData = {}
		end
		
		for dwMapID, v in pairs(tData) do
			l_tDungeonCopyID[dwMapID] = v[1]
		end
        
	elseif szCallBackFunc == "OnApplyEnterMapInfoRespond" then
		l_tBattleMapInfo = {}
        l_tDungeonMapInfo = {}
		local tEnterMapInfo = tData or {}
		local tLeftRefTime = tData1 or {}
		for dwMapID, v in pairs(tEnterMapInfo) do
			local szMapName = Table_GetMapName(dwMapID)
			local _, nMapType, nMaxPlayerCount, nLimitedTimes = GetMapParams(dwMapID)
 
			local nType, tInfo = nil, nil
			if nMapType and nMapType == MAP_TYPE.BATTLE_FIELD then
				nType = DUNGEON_TYPE.BATTLE_FIELD
				local nCanEnterTimes = nLimitedTimes - v
				l_tBattleMapInfo[dwMapID] = {
					szMapName = szMapName, 
					nEnterTimes = nCanEnterTimes, 
					nLimitedTimes = nLimitedTimes,}
				
			elseif nMapType and nMapType == MAP_TYPE.DUNGEON then
				local nRefreshCycle = GetMapRefreshInfo(dwMapID)
				local nCanEnterTimes = nLimitedTimes - v
				if nRefreshCycle == 0 and nMaxPlayerCount <= 5 then
					l_tDungeonMapInfo[dwMapID] =
					{
						nType = DUNGEON_TYPE.NORMAL,
						nEnterTimes = nCanEnterTimes, nLimitedTimes = nLimitedTimes,
					}
				
				elseif nRefreshCycle ~= 0 and nMaxPlayerCount <= 5 then
					local nRefreshTime = tLeftRefTime[dwMapID] or 0
					l_tDungeonMapInfo[dwMapID] = 
					{
						nType = DUNGEON_TYPE.HARD,
						nRefreshCycle = nRefreshCycle, nRefreshTime = nRefreshTime
					}
	
				elseif nRefreshCycle ~= 0 and nMaxPlayerCount > 5 then
					local nRefreshTime = tLeftRefTime[dwMapID] or 0
					nType = DUNGEON_TYPE.RAID
					l_tDungeonMapInfo[dwMapID] = 
					{
						nType = DUNGEON_TYPE.RAID,
						nRefreshCycle = nRefreshCycle, nRefreshTime = nRefreshTime
					}
				end
			end
		end

        DungeonInfoPanel.UpdateDungeonList(frame)
        DungeonInfoPanel.UpdateBattleFieldList(frame)

	elseif szCallBackFunc == "OnResetMapRespond" then
		local bFail = false
		local tResetFailMapID = tData or {}

        for k, dwMapID in pairs(tResetFailMapID) do
            local szName = Table_GetMapName(dwMapID)
            local _, nMapType, nMaxPlayerCount, nLimitedTimes = GetMapParams(dwMapID)
            if nMapType and nMapType == MAP_TYPE.DUNGEON then
                local nRefreshCycle = GetMapRefreshInfo(dwMapID)
                if nRefreshCycle == 0 then
                    local szMsg = FormatString(g_DungeonStrings.STR_DUNGEON_RESET_FAIL, szName)
                    OutputMessage("MSG_SYS", szMsg)
                    OutputMessage("MSG_ANNOUNCE_RED", szMsg)
                    bFail = true
                end
            end
        end

		if not bFail then
			OutputMessage("MSG_SYS", g_DungeonStrings.STR_DUNGEON_RESET_SUCCESS)
            OutputMessage("MSG_ANNOUNCE_YELLOW", g_DungeonStrings.STR_DUNGEON_RESET_SUCCESS)
		end		
	end
end

function IsDungeonInfoPanelOpened()
	local frame = Station.Lookup("Normal/DungeonInfoPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenDungeonInfoPanel(bDisableSound)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
	if IsDungeonInfoPanelOpened() then
		return
	end
	
	l_hFrame = Wnd.OpenWindow("DungeonInfoPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
	FireDataAnalysisEvent("FIRST_OPEN_DUNGEON_PANEL")
end

function CloseDungeonInfoPanel(bDisableSound)
	if not IsDungeonInfoPanelOpened() then
		return
	end
	
	CloseIntroduce(true)
	
	Wnd.CloseWindow("DungeonInfoPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

do  
    RegisterScrollEvent("DungeonInfoPanel")
    
    UnRegisterScrollAllControl("DungeonInfoPanel")
        
    local szFramePath = "Normal/DungeonInfoPanel"
    local szWndPath = "PageSet_Main/Page_Normal"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_NListUp", szWndPath.."/Btn_NListDown", 
        szWndPath.."/Scroll_NList", 
        {szWndPath, "Handle_Book"})

    szWndPath = "PageSet_Main/Page_BattleField"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BFListUp", szWndPath.."/Btn_BFListDown", 
        szWndPath.."/Scroll_BFList", 
        {szWndPath, "Handle_BFList"})
end