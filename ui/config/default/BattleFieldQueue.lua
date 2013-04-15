
BattleFieldQueue = {}

local BATTLE_BG_TAG_DIR = "ui/image/BattleField"
local INI_FILE_PATH = "UI/Config/Default/PartyRecruitPanel.ini"
local lc_tReward = 
{

}

local lc_BattleNotOpen = {}

local lc_hPageBattle
function BattleFieldQueue.OnFrameCreate()
    lc_hPageBattle = this:Lookup("PageSet_Total/Page_Battlefield")
    BattleFieldQueue.UpdateBattleList()
end

function BattleFieldQueue.OnEvent(szEvent)
	if szEvent == "PARTY_ADD_MEMBER" or szEvent == "PARTY_DELETE_MEMBER" or 
	   szEvent == "TEAM_AUTHORITY_CHANGED" or  szEvent == "PARTY_DISBAND" then
		BattleFieldQueue.UpdateButtonState()
    elseif szEvent == "ON_BATTLEFIELD_REWARD_DATA" then
        local nEnterTime = arg0
        local tReward = arg1 or {}
        local dwMapID = arg2
        
        if not lc_tReward[dwMapID] then
            lc_tReward[dwMapID] = {["nWinWeiWang"]="", ["nWinTitlePoint"]="", ["nFailWeiWang"]="", ["nFailTitlePoint"]=""} 
        end
        local tWin = tReward["win"] or {}
        local tFail = tReward["fail"] or {}
        lc_tReward[dwMapID]["nWinWeiWang"] = tWin.nWeiWang or ""
        lc_tReward[dwMapID]["nWinTitlePoint"] = tWin.nTitlePoint or ""
        lc_tReward[dwMapID]["nFailWeiWang"] = tFail.nWeiWang or ""
        lc_tReward[dwMapID]["nFailTitlePoint"] = tFail.nTitlePoint or ""

        BattleFieldQueue.UpdateReward()
    elseif szEvent == "BATTLE_FIELD_STATE_UPDATE" then
        BattleFieldQueue.UpdateButtonState()
        BattleFieldQueue.UpdateBattleTip()
        BattleFieldQueue.UpdateBackStateTime()
        
    elseif szEvent == "BATTLE_FIELD_UPDATE_TIME" then
        local dwMapID = BattleFieldQueue.nSelID
        if dwMapID and (IsInBattleFieldQueue(dwMapID) or IsCanEnterBattleField(dwMapID)) then
            BattleFieldQueue.UpdateBattleTip()
        end
    elseif szEvent == "GET_TODAY_ZHANCHANG_RESPOND" then
        local tResult = arg0 or {}
        
        for dwMapID, state in pairs(tResult) do
            lc_BattleNotOpen[dwMapID] = not state
        end
        BattleFieldQueue.UpdateBattleList()
	end
end

function BattleFieldQueue.UpdateBattleTip(hList)
    if not hList then
        local hWndBattle = lc_hPageBattle:Lookup("Wnd_Battlefield")
        hList = hWndBattle:Lookup("", "")
    end
    
    local dwMapID = BattleFieldQueue.nSelID
    if dwMapID and (IsInBattleFieldQueue(dwMapID) or IsCanEnterBattleField(dwMapID)) then
        local szTip1, szTip2, szTip3 = GetBattleFieldQueueDesc(dwMapID, 203, 204, 1)
        local tTip = {szTip1, szTip2, szTip3}
        for i = 1, 3, 1 do
            local hTip = hList:Lookup("Handle_BattleTip"..i)
            local szDesc = tTip[i] or  GetFormatText("")
            hTip:Clear()
            hTip:AppendItemFromString(szDesc);
            hTip:FormatAllItemPos()
        end
    else
        for i = 1, 3, 1 do
            local hTip = hList:Lookup("Handle_BattleTip"..i)
            hTip:Clear()
            hTip:FormatAllItemPos()
        end 
    end
end

function BattleFieldQueue.UpdateItemBg(hItem)
    if not hItem then
        return
    end
    local hImage = hItem:Lookup("Image_NameBg")
    if hItem.bSel or hItem.bOver then
        hImage:SetFrame(29)
    else 
        hImage:SetFrame(28)
    end
end

function BattleFieldQueue.GetSelectItem()
    local hWndBattle = lc_hPageBattle:Lookup("Wnd_Battlefield")
    local hList = hWndBattle:Lookup("", "")
        
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1, 1 do
		local hItem = hList:Lookup(i)
		if hItem.dwMapID then
            return hItem
		end
	end
end

function BattleFieldQueue.SelectItem(hItemSel)
    if not hItemSel then
		return
	end
	
	local hList = hItemSel:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1, 1 do
		local hItem = hList:Lookup(i)
		if hItem.bSel then
			hItem.bSel = false
			BattleFieldQueue.UpdateItemBg(hItem)
		end
	end
    hItemSel.bSel = true;
    BattleFieldQueue.nSelID = hItemSel.dwMapID
    BattleFieldQueue.UpdateItemBg(hItemSel)
    BattleFieldQueue.UpdateContent(hItemSel)
    BattleFieldQueue.UpdateButtonState()
    
    RemoteCallToServer("On_Zhanchang_Count", hItemSel.dwMapID)
    lc_hPageBattle:Lookup("", "Image_PicturesLeft"):FromTextureFile(BATTLE_BG_TAG_DIR.."/"..hItemSel.dwMapID.."L.tga")
    lc_hPageBattle:Lookup("", "Image_PicturesRight"):FromTextureFile(BATTLE_BG_TAG_DIR.."/"..hItemSel.dwMapID.."R.tga")
end

function BattleFieldQueue.GetBattleFieldMapID()
    local tResult = {}
	local nRow = g_tTable.BattleField:GetRowCount()
    for i = 2, nRow, 1 do
        local tLine = g_tTable.BattleField:GetRow(i)
        table.insert(tResult, {dwMapID = tLine.dwMapID, szMapName = tLine.szName})
    end
    
	return tResult
end

function BattleFieldQueue.UpdateBattleList()
    local tResult = BattleFieldQueue.GetBattleFieldMapID()
    local hList = lc_hPageBattle:Lookup("", "Handle_BattlefieldBT")
    hList:Clear()
    
    
    if BattleFieldQueue.nSelID and lc_BattleNotOpen[BattleFieldQueue.nSelID] then
        BattleFieldQueue.nSelID = nil
    end
    
    for k, v in ipairs(tResult) do
        local dwMapID = v.dwMapID
        local szMapName = v.szMapName
        local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "HI_Battlefield01")
        hItem.dwMapID = dwMapID
        hItem.szMapName = szMapName
        
        local imgBg = hItem:Lookup("Image_NameBg")
        local textName = hItem:Lookup("Text_Battlefield01Name")
        textName:SetText(szMapName)
        imgBg:SetFrame(28)
        if lc_BattleNotOpen[dwMapID] then
            imgBg:SetFrame(30)
        end
        
        if not lc_BattleNotOpen[dwMapID] and (not BattleFieldQueue.nSelID  or dwMapID == BattleFieldQueue.nSelID) then
            BattleFieldQueue.SelectItem(hItem)
        end
    end
    if not BattleFieldQueue.nSelID and hList:GetItemCount() > 0 then
        local hItem = hList:Lookup(0)
        BattleFieldQueue.SelectItem(hItem)
    end
    hList:FormatAllItemPos();
end

function BattleFieldQueue.UpdateContent(hItem)
    local dwMapID = hItem.dwMapID
    local szMapName = hItem.szMapName
    
    local hWndBattle = lc_hPageBattle:Lookup("Wnd_Battlefield")
    local hList = hWndBattle:Lookup("", "")
    --hList:Lookup("Text_BattlefieldTitle"):SetText(szMapName)
    
    BattleFieldQueue.UpdateBattleTip(hList)
    BattleFieldQueue.UpdateReward()
       
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_TwoPlayerBattlefield", "PartyRecruitPanel")
end

function BattleFieldQueue.UpdateReward()
    local function FormatReward(value)
        if value ~= nil and value ~= "" then
            value = "+"..value
        end
        return value
    end
    
    local hWndBattle = lc_hPageBattle:Lookup("Wnd_Battlefield")
    local hList = hWndBattle:Lookup("", "")
    
    local dwMapID = BattleFieldQueue.nSelID
    local tReward = lc_tReward[dwMapID] or {["nWinWeiWang"]="", ["nWinTitlePoint"]="", ["nFailWeiWang"]="", ["nFailTitlePoint"]=""} 
        
    local hRewardV = hList:Lookup("Handle_RewardVictory")
    local hTextWW = hRewardV:Lookup("Text_VRewardAuthority")
    local hTextZJ = hRewardV:Lookup("Text_VRewardClass")
    
    hTextWW:SetText(GetString("STR_BF_PRESTAGE").."\n"..FormatReward(tReward.nWinWeiWang))
    hTextZJ:SetText(GetString("STR_TITLE").."\n"..FormatReward(tReward.nWinTitlePoint))
    
    local hRewardF = hList:Lookup("Handle_RewardFailure")
    hTextWW = hRewardF:Lookup("Text_FRewardAuthority")
    hTextZJ = hRewardF:Lookup("Text_FRewardClass")
    hTextWW:SetText(GetString("STR_BF_PRESTAGE").."\n"..FormatReward(tReward.nFailWeiWang))
    hTextZJ:SetText(GetString("STR_TITLE").."\n"..FormatReward(tReward.nFailTitlePoint))
end

function BattleFieldQueue.UpdateBackStateTime()
    local text = lc_hPageBattle:Lookup("", "Text_BattleTime")
    if not IsInBattleFieldBacklist() then
        text:SetText("")
        return
    end
    
    local nTime = GetBattleFieldBackCoolTime()
    local szTime = FormatBattleFieldTime(nTime)
    local szText = g_tStrings.STR_FT_ESCAPE_TIME..szTime
	text:SetText(szText)
end

function BattleFieldQueue.UpdateButtonState()
    local dwMapID = BattleFieldQueue.nSelID
    local hPage = lc_hPageBattle
	hPage:Lookup("Btn_ManyQueue"):Enable(false)
		
	local player = GetClientPlayer()
	if player.IsInParty() then
		if player.IsPartyLeader() then
			hPage:Lookup("Btn_ManyQueue"):Enable(true)
		end
	end
	
    hPage:Lookup("Btn_SingleQueue"):Enable(true)
    if IsInBattleFieldBacklist() or lc_BattleNotOpen[dwMapID] then
        hPage:Lookup("Btn_SingleQueue"):Enable(false)
        hPage:Lookup("Btn_ManyQueue"):Enable(false)
    end
        
    if IsInBattleFieldQueue(dwMapID) then
        hPage:Lookup("Btn_LeaveQueue"):Show()
    else
        hPage:Lookup("Btn_LeaveQueue"):Hide()
    end
end

function BattleFieldQueue.EnterBattleFieldQueue(dwMapID, bTeam)
    local player = GetClientPlayer()
    local nGroupID = 0;
    if player.nCamp == CAMP.NEUTRAL then
        OutputMessage("MSG_SYS", g_tStrings.STR_BATTLEFIELD_NETURAL_NOT_ENTER)
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BATTLEFIELD_NETURAL_NOT_ENTER)
        return
    end
    if not dwMapID then
        return
    end
    
    if player.nCamp == CAMP.GOOD then
        nGroupID = 0;
    else
        nGroupID = 1;
    end
    
	JoinBattleFieldQueue(dwMapID, nGroupID, bTeam)
end

function BattleFieldQueue.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_SingleQueue" then
        if IsCanEnterBattleField() then
            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_JION_QUEUE_TIP1)
            return
        end
        BattleFieldQueue.EnterBattleFieldQueue(BattleFieldQueue.nSelID)
    elseif szName == "Btn_ManyQueue" then
        if IsCanEnterBattleField() then
            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_JION_QUEUE_TIP1)
            return
        end
        BattleFieldQueue.EnterBattleFieldQueue(BattleFieldQueue.nSelID, true)
    elseif szName == "Btn_LeaveQueue" then
        DoLeaveBattleFieldQueue(BattleFieldQueue.nSelID)
    end
end

function BattleFieldQueue.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "HI_Battlefield01" then
        if not lc_BattleNotOpen[this.dwMapID] then
            BattleFieldQueue.SelectItem(this);
        end
	end
end

function BattleFieldQueue.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "HI_Battlefield01" then
        if lc_BattleNotOpen[this.dwMapID] then
            local x, y = this:GetAbsPos()
            local w, h = this:GetSize()
            
            local szTip = GetFormatText(FormatString(g_tStrings.STR_BATTLE_CLOSE_STATE_TIP, this.szMapName))
            OutputTip(szTip, 400, {x, y, w - 30, h})
        else
            this.bOver = true
            BattleFieldQueue.UpdateItemBg(this)
        end
	end
end

function BattleFieldQueue.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "HI_Battlefield01" then
        if not lc_BattleNotOpen[this.dwMapID] then
            this.bOver = false
            BattleFieldQueue.UpdateItemBg(this)
        end
        HideTip()
	end
end

function BattleFieldQueue.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "HI_Battlefield01" then
        if lc_BattleNotOpen[this.dwMapID] then
            local x, y = this:GetAbsPos()
            local w, h = this:GetSize()
            
            local szTip = GetFormatText(FormatString(g_tStrings.STR_BATTLE_CLOSE_STATE_TIP, this.szMapName))
            OutputTip(szTip, 400, {x, y, w - 30, h})
        else
            this.bOver = true
            BattleFieldQueue.UpdateItemBg(this)
        end
	end
end

function BattleFieldQueue.IsBattleQueueVisible()
    if not IsPartyRecruitPanelOpened() then
        return false;
    end
    
    local frame = Station.Lookup("Normal/PartyRecruitPanel")
    if not frame then 
        return false
    end
    
    local hPage = frame:Lookup("PageSet_Total/Page_Battlefield")
    if hPage and hPage:IsVisible() then
        return true
    end
    
    return false
end

function BattleFieldQueue.InitWhenOpen(frame)
    lc_hPageBattle = frame:Lookup("PageSet_Total/Page_Battlefield")
    BattleFieldQueue.UpdateBattleList()
    BattleFieldQueue.UpdateButtonState()
    BattleFieldQueue.UpdateBackStateTime()
        
    RemoteCallToServer("On_Zhanchang_GetTodayZhanchang")
end

local function OnJoinBattleFieldQueue()
	if arg1 == BATTLE_FIELD_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_SYS", g_tStrings.STR_BATTLEFIELD_JOIN_QUEUE[arg1]);
	else
        local szName = arg3
        local player = GetClientPlayer();
        local szTip = g_tStrings.STR_BATTLEFIELD_JOIN_QUEUE[arg1]
        
        if szName and szName ~= player.szName then
            szTip = FormatString(szTip, g_tStrings.STR_BATTLE_JION_QUEUE_TIP1.."["..szName.."]")
        else
            szTip = FormatString(szTip, g_tStrings.STR_BATTLE_JION_QUEUE_TIP)
        end
        
		OutputMessage("MSG_ANNOUNCE_RED", szTip);
        OutputMessage("MSG_SYS", szTip); 
	end
	if arg1 == BATTLE_FIELD_RESULT_CODE.SUCCESS then
		PlayTipSound("018")
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.FAILED then
		PlayTipSound("019")
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.IN_BLACK_LIST then
		PlayTipSound("020")
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.LEVEL_ERROR then
		PlayTipSound("021")
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.FORCE_ERROR then
		PlayTipSound("022")
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.TEAM_MEMBER_ERROR then
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.TEAM_SIZE_ERROR then
		PlayTipSound("023")
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.TOO_MANY_JOIN then
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.CAMP_ERROR then
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.TIME_ERROR then
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.IN_DUNGEON_QUEUE then
	elseif arg1 == BATTLE_FIELD_RESULT_CODE.MAX_PARTY_SIZE_ERROR then
	end
end

local function OnLeaveBattleFieldQueue(dwMapID)
    OutputMessage("MSG_SYS", g_tStrings.STR_BATTLEFIELD_LEAVE_QUEUE); 
    OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BATTLEFIELD_LEAVE_QUEUE);
    local param0 = BATTLE_FIELD_NOTIFY_TYPE.LEAVE_BATTLE_FIELD
    local param1, param2 = nil 
    local param3 = dwMapID
    FireUIEvent("BATTLE_FIELD_NOTIFY", param0, param1, param2, param3)
end

RegisterEvent("JOIN_BATTLE_FIELD_QUEUE", OnJoinBattleFieldQueue)
RegisterEvent("LEAVE_BATTLE_FIELD_QUEUE", function() OnLeaveBattleFieldQueue(arg0) end)