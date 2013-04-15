ReputationIntroduce = 
{
}

RegisterCustomData("ReputationIntroduce.dwCheckForceID")

local l_hFrame = nil
function ReputationIntroduce.OnFrameCreate()

    
    l_hFrame = this;
end

function ReputationIntroduce.UpdateContent(bHome)
    local hCheck = l_hFrame:Lookup("CheckBox_Exp")
    local dwForceID = ReputationIntroduce.dwForceID
    
    l_hFrame.bIniting = true
    
    if ReputationIntroduce.dwCheckForceID == dwForceID then
        hCheck:Check(true)
    else
        hCheck:Check(false)
    end
    l_hFrame.bIniting = false
    
    local szHandleName = "Handle_Content";
    local hMsg = l_hFrame:Lookup("", szHandleName)
    local hTitle = l_hFrame:Lookup("", "Text_Name")
    
    hMsg:Clear()
    
    local tGain = g_tReputation.tReputationGainDesc[dwForceID] 
    local tRep = g_tReputation.tReputationTable[dwForceID]
    local tItem = g_tReputation.tReputationItem[dwForceID]
    local tRepLevel = g_tReputation.tReputationLevelTable
    local szLine = GetFormatText("\n")
    
    if not tRep or (not tGain and not tItem)then
        CloseReputationIntroduce()
        return 
    end
    
    local szName = tRep.szName
    hTitle:SetText(szName)
    
    if tGain then
        hMsg:AppendItemFromString(g_tReputation.STR_REPUTATION_GAIN_TITLE)
        hMsg:AppendItemFromString(szLine)
    end
    tGain = tGain or {}
    for k, v in ipairs(tGain) do
        local szTitle = tRepLevel[v.dwFromLevel].szLevel.."-"..tRepLevel[v.dwToLevel].szLevel
        local szTitle = GetFormatText(szTitle.."£º", 165)
        hMsg:AppendItemFromString(szTitle)
        hMsg:AppendItemFromString(szLine)
        
        hMsg:AppendItemFromString(v.szDesc)
        hMsg:AppendItemFromString(szLine)
        hMsg:AppendItemFromString(szLine)
    end
    
    if tItem then
        hMsg:AppendItemFromString(g_tReputation.STR_Reputation_REWARD_TITLE)
        hMsg:AppendItemFromString(szLine)
    end
    
    tItem = tItem or {}
    local nMsgW = hMsg:GetSize()
    for nLevel, tData in pairs(tItem) do
        local szTitle = GetFormatText(tRepLevel[nLevel].szLevel.."£º", 165)
        hMsg:AppendItemFromString(szTitle)
        hMsg:AppendItemFromString(szLine)
        local nSize = 0
        for _, tItemInfo in ipairs(tData) do
            local hText = hMsg:AppendItemFromIni("/ui/Config/Default/ReputationIntroduce.ini", "Text_Item")
            local nIndex = hText:GetIndex()
            hText.dwTabIndex = tItemInfo.dwTabIndex;
            hText.nItemID = tItemInfo.nItemID
            local itemInfo = GetItemInfo(tItemInfo.dwTabIndex, tItemInfo.nItemID)
            
            local szName =  GetItemNameByItemInfo(itemInfo)
            local r, g, b = GetItemFontColorByQuality(itemInfo.nQuality)
            hText:SetText("["..szName.."]");
            hText:SetFontColor(r, g, b)
            hText:AutoSize();
            local nTW = hText:GetSize()
            nSize = nSize + nTW
            if nSize > nMsgW then
                hMsg:AppendItemFromString(szLine)
                local hTextLine = hMsg:Lookup(nIndex + 1)
                hTextLine:SetIndex(nIndex)
                nSize = nTW
            end
            
            hText.OnItemMouseEnter = function()
                local x, y = this:GetAbsPos()
                local w, h = this:GetSize()
                OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, this.dwTabIndex, this.nItemID, {x, y, w, h})
            end
            hText.OnItemMouseLeave = function()
                HideTip();
            end
            hText.OnItemLButtonDown = function()
                if IsCtrlKeyDown() then
                    EditBox_AppendLinkItemInfo(GLOBAL.CURRENT_ITEM_VERSION, this.dwTabIndex, this.nItemID)
                end
			end
        end
        hMsg:AppendItemFromString(szLine)
        hMsg:AppendItemFromString(szLine)
    end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "ReputationIntroduce", bHome)
end

function ReputationIntroduce.UpdateReputationOnExpBar()
    if not ReputationIntroduce.dwCheckForceID then
        MainBarPanel_UpdateExpBar()
        return
    end
    
    local nForceID = ReputationIntroduce.dwCheckForceID
    local player = GetClientPlayer()
    local nLevel = player.GetReputeLevel(nForceID)
    if not nLevel then
        return
    end
    local nValue1 = player.GetReputation(nForceID)
    local nValue2 =  GetReputeLimit(nLevel)
    MainBarPanel_UpdateExpBar(nValue1, nValue2, "Rep", ReputationIntroduce.GetReputationTip)
end

function ReputationIntroduce.GetReputationTip()
    if not ReputationIntroduce.dwCheckForceID then
        return
    end
    
    local nForceID = ReputationIntroduce.dwCheckForceID
    local player = GetClientPlayer()
    local nLevel = player.GetReputeLevel(nForceID)
    if not nLevel then
        return
    end
    local nValue1 = player.GetReputation(nForceID)
    local nValue2 =  GetReputeLimit(nLevel)
    
    local szName = g_tReputation.tReputationTable[nForceID].szName
    local szDesc = g_tReputation.tReputationTable[nForceID].szDesc.." </text>"
    local szLevel = g_tReputation.tReputationLevelTable[nLevel].szLevel
    local szTip = GetFormatText(szName.."\n", 65)
    szTip = szTip .. GetFormatText(g_tReputation.STR_REPUTATION_LEVEL..szLevel.."\t"..nValue1.."/"..nValue2.."\n")
    szTip = szTip .. szDesc
    return szTip;
end

function ReputationIntroduce.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Close" then
        CloseReputationIntroduce()
    end
end

function ReputationIntroduce.OnCheckBoxCheck()
    if l_hFrame.bIniting then
        return
    end

    local szName = this:GetName()
    if szName == "CheckBox_Exp" then
        ReputationIntroduce.dwCheckForceID = ReputationIntroduce.dwForceID
        ReputationIntroduce.UpdateReputationOnExpBar()
    end
end

function ReputationIntroduce.OnCheckBoxUncheck()
    if l_hFrame.bIniting then
        return
    end
    
    local szName = this:GetName()
    if szName == "CheckBox_Exp" then
        if ReputationIntroduce.dwCheckForceID == ReputationIntroduce.dwForceID then
            ReputationIntroduce.dwCheckForceID  = nil
        end
        ReputationIntroduce.UpdateReputationOnExpBar()
    end
end

--=========================================================
function IsReputationIntroduceOpened()
    local hFrame = Station.Lookup("Normal/ReputationIntroduce")
    if hFrame and hFrame:IsVisible() then
        return true
    end
    return false
end

function OpenReputationIntroduce(bDisableSound)
    if IsReputationIntroduceOpened() then
        return
    end
   
    local hFrame = Station.Lookup("Normal/ReputationIntroduce")
	l_hFrame = hFrame
    hFrame:Show()
    
    if not bDisableSound then
        PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
    end
end

function CloseReputationIntroduce(bDisableSound)
    if not IsReputationIntroduceOpened() then
        return
    end
    
    local hFrame = Station.Lookup("Normal/ReputationIntroduce")
	hFrame:Hide()
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function ReputationIntroduce_ShowInfo(dwForceID, bHome, bDisableSound)
    if not IsReputationIntroduceOpened() then
        OpenReputationIntroduce(bDisableSound)
    end
    
    ReputationIntroduce.dwForceID = dwForceID
    ReputationIntroduce.UpdateContent(bHome)
end

local function OnSyncRoleDataEnd()
    ReputationIntroduce.UpdateReputationOnExpBar()
end

do
    local Anchor = {s = "TOPLEFT", r = "TOPRIGHT", x = 0, y = 0}
    RegisterFollowPanel("Normal/CharacterPanel", "Normal/ReputationIntroduce", Anchor) 
    
    RegisterScrollEvent("ReputationIntroduce")

    UnRegisterScrollAllControl("ReputationIntroduce")
    
    local szFramePath = "Normal/ReputationIntroduce"
    local szWndPath = ""
    RegisterScrollControl(
        szFramePath, 
        "Btn_Up", "Btn_Down", 
        "Scroll_List", 
        {szWndPath, "Handle_Content"})
end

RegisterEvent("UPDATE_REPUTATION", ReputationIntroduce.UpdateReputationOnExpBar)
RegisterEvent("SYNC_ROLE_DATA_END", OnSyncRoleDataEnd);