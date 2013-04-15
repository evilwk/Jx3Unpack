TongArena = 
{
    Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = 200}
}

local STR_LUNKONG = g_tStrings.STR_MATCHES_NONE --轮空
local STR_UNSURE =  g_tStrings.STR_MATCHES_UNSURE --待定

local OBJECT = TongArena
local PAGE_RESULT_COUNT = 20
local PAGE_GOOD_START_INDEX = 1
local PAGE_EVIL_START_INDEX = 1
local MAX_MATCHE_COUNT = 4
local INI_FILE = "/ui/Config/Default/TongArena.ini"
local MATCH_TYPE = {ZHULU=1, ZHENGBA=2}
local MATCH_TYPE_STRING = 
{
    [MATCH_TYPE.ZHULU] = g_tStrings.STR_MATCHES_WAR1,
    [MATCH_TYPE.ZHENGBA] = g_tStrings.STR_MATCHES_WAR2,
}

local WIDGET = {}
local l_tAngle =
{
    [CAMP.GOOD]={tHistory={}, nStart=1, nSelID=nil}, 
    [CAMP.EVIL]={tHistory={}, nStart=1, nSelID=nil}, 
    CheckCamp = CAMP.GOOD,
}
local l_tGame = 
{
    [CAMP.GOOD]={nType=MATCH_TYPE.ZHULU, nNumber=1}, 
    [CAMP.EVIL]={nType=MATCH_TYPE.ZHULU, nNumber=1}, 
    CheckCamp = CAMP.GOOD,
}
local CHAMPION_INFO = {}
local GAME_CHECK_CAMP = CAMP.GOOD
local VOTE_CHECK_CAMP = CAMP.GOOD
local FINAL_CHECK_PAGE=1

function TongArena.InitObject(hFrame)
    WIDGET.hFrame = hFrame
    WIDGET.hPageAngle = hFrame:Lookup("PageSet_Total/Page_Angle")
    WIDGET.hPageVote = hFrame:Lookup("PageSet_Total/Page_Vote")
    WIDGET.hPageGame = hFrame:Lookup("PageSet_Total/Page_Game")
    WIDGET.hPageFinal = hFrame:Lookup("PageSet_Total/Page_Final")
    WIDGET.hPageRank = WIDGET.hPageFinal:Lookup("PageSet_Final/Page_Ranking")
    WIDGET.hPageWar = WIDGET.hPageFinal:Lookup("PageSet_Final/Page_War")
    WIDGET.hPageContest = WIDGET.hPageFinal:Lookup("PageSet_Final/Page_Contest")
    WIDGET.hBtnVote = WIDGET.hPageVote:Lookup("Btn_Vote")
    WIDGET.hBtnMonthly = WIDGET.hPageVote:Lookup("Btn_Monthly")
end

function TongArena.OnFrameCreate()
    this:RegisterEvent("TONG_AREAN_ANGLE_DATA")
    this:RegisterEvent("TONG_AREAN_GAME_DATA")
    this:RegisterEvent("TONG_AREAN_VOTE_DATA")
    this:RegisterEvent("TONG_AREAN_VOTE_PLAYER_RESPOND")
    this:RegisterEvent("TONG_AREAN_FINAL_WAR_DATA")
    this:RegisterEvent("TONG_AREAN_FINAL_RANK_DATA")
    this:RegisterEvent("TONG_AREAN_CHAMPION")
    this:RegisterEvent("TONG_AREAN_CAMP_MVP")
    this:RegisterEvent("TONG_AREAN_VOTE_CHAMPOIN")
    this:RegisterEvent("TONG_AREAN_REWARD_STATE")
    this:RegisterEvent("TONG_AREAN_TIME")
    
    this:RegisterEvent("UI_SCALED")
    OBJECT.InitObject(this);
    OBJECT.InitState()
    TongArena.UpdateAnchor(this)
end

function TongArena.OnEvent(szEvent)
    if szEvent == "TONG_AREAN_ANGLE_DATA" then
        OBJECT.UnLockRequestOpertion()
        local nCamp = arg0
        local tData = arg1
        if tData then
            for i, _ in ipairs(tData) do
                tData[i].nIndex = i
            end
            table.sort(tData, 
                function(a, b) 
                    if a.nScore == b.nScore then
                        return a.nIndex < b.nIndex
                    end
                    return a.nScore > b.nScore 
                end
            )
        end
        local nTotal = 0;
        for k, v in pairs(tData) do
            if v.nScore then
                nTotal = nTotal + v.nScore
            end
        end
        
        l_tAngle[nCamp].nStart = 1
        l_tAngle[nCamp].tHistory = tData
        l_tAngle[nCamp].nTotalVotes = nTotal
        
        OBJECT.UpdateAngleList(tData, l_tAngle[nCamp].nStart)
        WIDGET.hPageAngle:Lookup("", "Text_TotalA"):SetText(nTotal);
    elseif szEvent == "TONG_AREAN_GAME_DATA" then
        OBJECT.UnLockRequestOpertion()
        OBJECT.OnAcceptGameData(arg0, arg1, arg2, arg3)

    elseif szEvent == "TONG_AREAN_VOTE_DATA" then
        OBJECT.UnLockRequestOpertion()
        OBJECT.OnAcceptVoteData(arg0, arg1)
    elseif szEvent == "TONG_AREAN_VOTE_PLAYER_RESPOND" then
        local dwTargetID, nScore, nResult = arg0, arg1, arg2
        if nResult then
            OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_VOTE_SUCCESS)
            TongArena.OnUpdateVoteResult(dwTargetID, nScore)
        else
            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_VOTE_FAILED)
        end
        
    elseif szEvent == "TONG_AREAN_FINAL_WAR_DATA" then
        OBJECT.UnLockRequestOpertion()
        
        local nNumber, tData = arg0, arg1
        local hText = WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Lookup("", "Text_MatchesF_0")
        if hText.Value == nNumber then
            TongArena.UpdateFinalWar(tData)
        end
    elseif szEvent == "TONG_AREAN_FINAL_RANK_DATA" then
        OBJECT.UnLockRequestOpertion()
        local tData = arg0
        if tData then
            table.sort(tData, 
                function(a, b) 
                    if a.nScore ~= b.nScore then
                        return a.nScore > b.nScore 
                    end
                    return a.nTime < b.nTime
                end
            )
        end
        OBJECT.UpdateFinalRank(tData)
    elseif szEvent == "TONG_AREAN_CHAMPION" then
        local szPlayerName, bCurrentChampion = arg0, arg1
        CHAMPION_INFO.szPlayerName, CHAMPION_INFO.bCurrentChampion = szPlayerName, bCurrentChampion
        local szText = ""
        if not szPlayerName or szPlayerName=="" then
            szText=""
        else
            szText = FormatString(g_tStrings.STR_CURRNET_CHAMPION, szPlayerName)
        --elseif bCurrentChampion then
        --else
        --    szText = FormatString(g_tStrings.STR_LAST_CHAMPION, szPlayerName)
        end
        OBJECT.UpdateIntroduce(szText)
        
        RemoteCallToServer("On_Tong_RewardStateRequest")
    elseif szEvent == "TONG_AREAN_CAMP_MVP" then
        OBJECT.UnLockRequestOpertion()
        OBJECT.UpdateFinalContest(arg0)
        
    elseif szEvent == "TONG_AREAN_VOTE_CHAMPOIN" then
        local nResult = arg0
        if nResult == 0 then
            OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tArenaVoteResult[nResult])
            RemoteCallToServer("On_Tong_RewardStateRequest")
            RemoteCallToServer("OnTongArenaVoteRankRequest", VOTE_CHECK_CAMP) -- 获取投票排名
            OBJECT.LockRequestOpertion()
        else
            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tArenaVoteResult[nResult])
        end
        
    elseif szEvent == "TONG_AREAN_REWARD_STATE" then
        local nState, szVotePlayer, nReward = arg0, arg1, arg2
        TongArena.UpdateRewardState(nState, szVotePlayer, nReward);
    
    elseif szEvent == "TONG_AREAN_TIME" then
        OBJECT.UnLockRequestOpertion()
        local nWeek, nDay = arg0, arg1
        TongArena.InitTime(nWeek, nDay)
        
    elseif szEvent == "UI_SCALED" then
        TongArena.UpdateAnchor(this)
    end
end

function TongArena.UpdateRewardState(nState, szVotePlayer, nReward)
    local hList = WIDGET.hPageVote:Lookup("", "Handle_Reward");
    local hReward1 = hList:Lookup("Text_Reward1")
    local hWinner = hList:Lookup("Text_WinnerName")
    local hReward2 = hList:Lookup("Text_Reward2")
    local hChampion = hList:Lookup("Text_Champion")
    local hReward3 = hList:Lookup("Text_Reward3")
    local hRePoint = hList:Lookup("Text_RePoint")
    local hSend = hList:Lookup("Text_Send")
    local szChampion = CHAMPION_INFO.szPlayerName
    local bCurrentChampion = CHAMPION_INFO.bCurrentChampion
    
    hReward1:Hide()
    hWinner:Hide()
    hReward2:Hide()
    hChampion:Hide()
    hReward3:Hide()
    hRePoint:Hide()
    hSend:Hide()
    if nState ~= 2 and szVotePlayer and szVotePlayer ~= "" then
        hReward1:Show()
        hWinner:Show()
        hWinner:SetText(szVotePlayer)
    end
        
    if nState == 0 then
        --
    elseif nState == 1 then
        hReward2:Show()
        hChampion:Show()
        hChampion:SetText(szChampion)
        
        hReward3:Show()
        hRePoint:Show()
        hSend:Show()
        nReward = nReward or ""
        hRePoint:SetText(tostring(nReward)..g_tStrings.STR_ARENA_CONTRIBUTE)
    end
end

function TongArena.InitTime(nWeek, nDay)
    local hText1 = WIDGET.hPageGame:Lookup("Btn_Matches1"):Lookup("", "Text_Matches1")
    local hText2 = WIDGET.hPageGame:Lookup("Btn_Matches"):Lookup("", "Text_Matches")
    if nWeek == 1 then
        hText1:SetText(g_tStrings.STR_MATCHES_WAR1)
        hText1.Value = 1
    else
        hText1:SetText(g_tStrings.STR_MATCHES_WAR2)
        hText1.Value = 2
    end
    
    local nIndex = 1
    if nWeek <= 2 then
        nIndex = math.min(nDay, 4)
    else
        nIndex = 4
    end
    local szFirst = FormatString(g_tStrings.STR_MATCHES_INDEX, g_tStrings.STR_NUMBER[nIndex])
    hText2:SetText(szFirst)
    hText2.Value = nIndex
    
    l_tGame[CAMP.GOOD].nType = hText1.Value
    l_tGame[CAMP.GOOD].nNumber = hText2.Value
    
    l_tGame[CAMP.EVIL].nType = hText1.Value
    l_tGame[CAMP.EVIL].nNumber = hText2.Value
 
    if nWeek >= 4 then
        nIndex = math.min(nDay, 4)
    else
        nIndex = 1
    end
    szFirst = FormatString(g_tStrings.STR_MATCHES_INDEX, g_tStrings.STR_NUMBER[nIndex])
    hText3 = WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Lookup("", "Text_MatchesF_0")
    hText3:SetText(szFirst)
    hText3.Value = nIndex
    
    if nWeek == 3 then
        WIDGET.hBtnVote.bEnable = true
        WIDGET.hBtnMonthly.bEnable = true
    else
        WIDGET.hBtnVote.bEnable = false
        WIDGET.hBtnMonthly.bEnable = false
    end
    
    if nWeek <= 2 then
        TongArena.GameCheckCamp(l_tGame.CheckCamp)
    elseif nWeek == 3 then
        local pageSet = WIDGET.hPageVote:GetParent()
        pageSet:ActivePage(WIDGET.hPageVote:GetName())
    elseif nWeek == 4 then
        local pageSet = WIDGET.hPageFinal:GetParent()
        pageSet:ActivePage(WIDGET.hPageFinal:GetName())
    end
end

function TongArena.InitState()
    WIDGET.hFrame.bIniting = true
    
    OBJECT.UpdateIntroduce();
    RemoteCallToServer("OnTongArenaChampionRequest") --请求擂主

    local nCurrentTime = GetCurrentTime()
    local tData = TimeToDate(nCurrentTime)
    local nWeekday = tData.weekday
    
    local Tong = GetTongClient()
    local nCamp = Tong.nCamp
    if nCamp ~= CAMP.GOOD and nCamp ~= CAMP.EVIL then
        nCamp = CAMP.GOOD
    end
    
    --=======Angle=========================
    l_tAngle.CheckCamp = nCamp
    l_tAngle[CAMP.GOOD].nStart = 1
    l_tAngle[CAMP.EVIL].nStart = 1
    
    WIDGET.hPageAngle:Lookup("", "Text_TotalA"):SetText(0);
    if nCamp == CAMP.GOOD then
        WIDGET.hPageAngle:Lookup("CheckBox_GoodA"):Check(true)
        WIDGET.hPageAngle:Lookup("CheckBox_EvilA"):Check(false)
    else
        WIDGET.hPageAngle:Lookup("CheckBox_GoodA"):Check(false)
        WIDGET.hPageAngle:Lookup("CheckBox_EvilA"):Check(true)
    end   
     
    OBJECT.UpdateAngleList()
    
    --=======Game===========================
    l_tGame[CAMP.GOOD].nType = MATCH_TYPE.ZHULU
    l_tGame[CAMP.GOOD].nNumber = 1
    l_tGame[CAMP.EVIL].nType = MATCH_TYPE.ZHULU
    l_tGame[CAMP.EVIL].nNumber = 1
    l_tGame.CheckCamp = nCamp

    if nCamp == CAMP.GOOD then
        WIDGET.hPageGame:Lookup("CheckBox_Good"):Check(true)
        WIDGET.hPageGame:Lookup("CheckBox_Evil"):Check(false)
    else
        WIDGET.hPageGame:Lookup("CheckBox_Good"):Check(false)
        WIDGET.hPageGame:Lookup("CheckBox_Evil"):Check(true)
    end
    OBJECT.UpdateGame(nCamp)
    
    local hText = WIDGET.hPageGame:Lookup("Btn_Matches1"):Lookup("", "Text_Matches1")
    hText:SetText(g_tStrings.STR_MATCHES_WAR1)
    hText.Value = 1
    hText = WIDGET.hPageGame:Lookup("Btn_Matches"):Lookup("", "Text_Matches")
    local szFirst = FormatString(g_tStrings.STR_MATCHES_INDEX, g_tStrings.STR_NUMBER[1])
    hText:SetText(szFirst)
    hText.Value = 1
    
    --=======Vote================================
    if nCamp == CAMP.GOOD then
        WIDGET.hPageVote:Lookup("CheckBox_GoodV"):Check(true)
        WIDGET.hPageVote:Lookup("CheckBox_EvilV"):Check(false)
    else
        WIDGET.hPageVote:Lookup("CheckBox_GoodV"):Check(false)
        WIDGET.hPageVote:Lookup("CheckBox_EvilV"):Check(true)
    end
    VOTE_CHECK_CAMP = nCamp
    
    OBJECT.UpdateVoteList()
    OBJECT.SetVoteInfo()
    
    TongArena.UpdateRewardState(0);
    
    --=======Final======================================
    FINAL_CHECK_PAGE = 1
    hText = WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Lookup("", "Text_MatchesF_0")
    hText:SetText(szFirst)
    hText.Value = 1
    
    OBJECT.UpdateFinalRank()
    OBJECT.UpdateFinalWar()
    OBJECT.UpdateFinalContest()
    
    RemoteCallToServer("On_Tong_ArenaTime")
    OBJECT.LockRequestOpertion()
    
    WIDGET.hFrame.bIniting = false
end

function TongArena.UpdateAngleList(tData, nStart)
    tData = tData or {}
    nStart = nStart or 1
    local szHandleName = "Handle_ListAngle"
    local hList = WIDGET.hPageAngle:Lookup("", szHandleName)
    local nEnd = math.min(#tData, nStart + PAGE_RESULT_COUNT - 1)
    hList:Clear()
    hList.hSelItem = nil
    for k=nStart, nEnd, 1 do
        tPlayer = tData[k]
        local hItem = hList:AppendItemFromIni(INI_FILE, "Handle_ItemList")
        hItem:SetName("Handle_ItemList")
        hItem.dwID = tPlayer.dwID
        hItem:Lookup("Text_ListTaxis"):SetText(k)
        hItem:Lookup("Text_ListName"):SetText(tPlayer.name)
        hItem:Lookup("Text_ListGangs"):SetText(tPlayer.tong)
        hItem:Lookup("Text_ListSchool"):SetText(g_tStrings.tForceTitle[tPlayer.school])
        hItem:Lookup("Text_ListHold"):SetText(tPlayer.nScore)
        --[[
        if hItem.dwID and hItem.dwID == hList.dwID then
            Output("select")
            OBJECT.SelectResult(hItem, "Image_Light")
        end
        ]]
    end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "TongArena", true)
    
    OBJECT.UpdatePageInfo(WIDGET.hPageAngle, "Btn_Back", "Btn_Next", "Text_Page", nStart, #tData)
end

function TongArena.OnAcceptVoteData(nCamp, tData)
    if VOTE_CHECK_CAMP ~= nCamp then
        return
    end
    
    if tData then
        for i, _ in ipairs(tData) do
            tData[i].nIndex = i
        end
        table.sort(tData, 
            function(a, b) 
                if a.nScore == b.nScore then
                    return a.nIndex < b.nIndex
                end
                return a.nScore > b.nScore 
            end
        )
    end
        
    OBJECT.UpdateVoteList(tData)
end

function TongArena.OnUpdateVoteResult(dwTargetID, nScore)
    local szHandleName = "Handle_ListVote"
    local hList = WIDGET.hPageVote:Lookup("", szHandleName)
    local nCurrentVoteNum = 0
    local nCount = hList:GetItemCount() - 1
    for i=0, nCount, 1 do
        local hItem = hList:Lookup(i)
        if hItem.dwID == dwTargetID then
            hItem.nScore = hItem.nScore + nScore
            hItem:Lookup("Text_ListHoldV"):SetText(hItem.nScore)
        end
        nCurrentVoteNum = nCurrentVoteNum + hItem.nScore
    end
    
    hList:FormatAllItemPos()
    OBJECT.SetVoteInfo(nCurrentVoteNum);
end

function TongArena.UpdateVoteList(tData)
    tData = tData or {}
    local szHandleName = "Handle_ListVote"
    local hList = WIDGET.hPageVote:Lookup("", szHandleName)
    WIDGET.hBtnVote:Enable(false)
    WIDGET.hBtnMonthly:Enable(false)
    
    hList:Clear()
    hList.bVote = true
    hList.hSelItem = nil
    local nCurrentVoteNum = 0
    for k, tPlayer in ipairs(tData) do
        local hItem = hList:AppendItemFromIni(INI_FILE, "Handle_ItemListV")
        local hImageLight = hItem:Lookup("Image_LightV")
        hImageLight:SetName("Image_Light")
        
        hItem:SetName("Handle_ItemList")
        hItem.dwID =  tPlayer.dwID
        hItem.nScore = tPlayer.nScore or 0
        hItem:Lookup("Text_ListTaxisV"):SetText(k)
        hItem:Lookup("Text_ListNameV"):SetText(tPlayer.name)
        hItem:Lookup("Text_ListGangsV"):SetText(tPlayer.tong)
        hItem:Lookup("Text_ListSchoolV"):SetText(g_tStrings.tForceTitle[tPlayer.school])
        hItem:Lookup("Text_ListHoldV"):SetText(tPlayer.nScore)
        hItem:Lookup("Text_ListON"):SetText(tPlayer.nReward)
        
        nCurrentVoteNum = nCurrentVoteNum + tPlayer.nScore
    end
    hList:FormatAllItemPos()
    OBJECT.SetVoteInfo(nCurrentVoteNum);
end

function TongArena.OnAcceptGameData(nCamp, nGameType, nNumber, tData)
    if nCamp == l_tGame.CheckCamp and 
       nGameType == l_tGame[nCamp].nType and 
       nNumber == l_tGame[nCamp].nNumber then
        OBJECT.UpdateGame(nCamp, tData)
    end
end

function TongArena.UpdateGame(nCamp, tData)
    tData = tData or {}
    local tPlayer = tData.tPlayer or {}
    local tInfo = tData.tInfo or {}
    local tPlayerMap = {}
    local nFrame = 32
    for k, v in pairs(tPlayer) do
        tPlayerMap[v.dwID] = v;
    end
    tPlayerMap[0] = nil
    
    if nCamp == CAMP.EVIL then
        nFrame = 36
    end
    
    local GetPlayerID = function(nLayer, nIndex)
        local dwID = 0
        if tInfo[nLayer] and tInfo[nLayer][nIndex] and tInfo[nLayer][nIndex] ~= 0 then
            dwID = tInfo[nLayer][nIndex]
        end
        return dwID   
    end
    
    local nBase = 8
    local hList = WIDGET.hPageGame:Lookup("", "Handle_Eliminated")
    local hLine  = hList:Lookup("Handle_Line")
    for k=1, 4, 1 do 
        for i=1, nBase, 1 do
           local tChar = tPlayerMap[GetPlayerID(k, i)]
           local hImage = hList:Lookup("Image_BgG"..k.."_"..i)
           local hText1 = hList:Lookup("Text_GN"..k.."_"..i)
           local hText2 = hList:Lookup("Text_GT"..k.."_"..i)
           if tChar then
                hImage:SetFrame(nFrame) 
                hText1:SetText(tChar.name)
                hText2:SetText(tChar.tong)
           else
                local bLunKong = false;
                hImage:SetFrame(49) 
                if k == 1 and #tPlayer ~= 0 then
                    bLunKong = true
                end
                
                if k ~= 1 and #tPlayer ~= 0 then
                    local dwID1 = GetPlayerID(k - 1, i*2 - 1)
                    local dwID2 = GetPlayerID(k - 1, i*2)
                    if not tPlayerMap[dwID1] and not tPlayerMap[dwID2] then
                        bLunKong = true
                    end
                end
                            
                if bLunKong then
                    hText1:SetText(STR_LUNKONG)
                    hText2:SetText(STR_LUNKONG)
                else
                    hText1:SetText(STR_UNSURE)
                    hText2:SetText(STR_UNSURE)
                end
           end
        end
        nBase = nBase / 2
    end
    
    nBase = 4
    for k=2, 4, 1 do 
        for i=1, nBase, 1 do
           local nLayer = k - 1
           local nID1, nID2 = i*2 - 1, i*2
           
           local hImageLV = hLine:Lookup("Image_Line_V"..nLayer.."_"..nID1)
           local hImageLH = hLine:Lookup("Image_Line_H"..nLayer.."_"..nID1)
           local hImageRV = hLine:Lookup("Image_Line_V"..nLayer.."_"..nID2)
           local hImageRH = hLine:Lookup("Image_Line_H"..nLayer.."_"..nID2)
           local hImageVect = hLine:Lookup("Image_Line"..nLayer.."_"..nID1.."V"..nID2)
           hImageLV:SetFrame(6)
           hImageLH:SetFrame(4)
           hImageRV:SetFrame(6)
           hImageRH:SetFrame(4)
           hImageVect:SetFrame(6)
           
           local nPlayerID = GetPlayerID(k, i)
           if nPlayerID ~= 0 then
                hImageVect:SetFrame(5)
                if nPlayerID == tInfo[k-1][nID1] then
                    hImageLV:SetFrame(5)
                    hImageLH:SetFrame(3)
                elseif nPlayerID == tInfo[k-1][nID2] then
                    hImageRV:SetFrame(5)
                    hImageRH:SetFrame(3)
                end
           end
        end
        nBase = nBase / 2
    end
end

function TongArena.UpdateFinalRank(tData)
    tData = tData or {}
    local szHandleName = "Handle_FinalRList"
    local hList = WIDGET.hPageRank:Lookup("", szHandleName)
    hList:Clear()
    hList.hSelItem = nil
    for k, tPlayer in ipairs(tData) do
        local hItem = hList:AppendItemFromIni(INI_FILE, "Handle_FinalItemList")
        local szTime = GetTimeText(tPlayer.nTime)
        if szTime == "" then
            szTime = "0"
        end
        
        hItem.dwID =  tPlayer.dwID
        
        hItem:Lookup("Text_ListTaxisF"):SetText(k)
        hItem:Lookup("Text_ListNameF"):SetText(tPlayer.name)
        hItem:Lookup("Text_ListGangsF"):SetText(tPlayer.tong or "")
        hItem:Lookup("Text_ListTimeF"):SetText(szTime)
        hItem:Lookup("Text_ListHoldF"):SetText(tPlayer.nScore * 3)
        hItem:Lookup("Text_CampF"):SetText(g_tStrings.STR_CAMP_TITLE[tPlayer.nCamp])
        
        --[[
        if hItem.dwID and hItem.dwID == hList.dwID then
            TongArena.SelectResult(hItem, "Image_Light")
        end
        ]]
    end
    hList:FormatAllItemPos()
end

function TongArena.UpdateFinalWar(tData)
    tData = tData or {}
    local hGoodList = WIDGET.hPageWar:Lookup("", "Handle_Good_Sum")
    local hEvilList = WIDGET.hPageWar:Lookup("", "Handle_Evil_Sum")
    
    local tGood = tData[1] or {}
    local tEvil = tData[2] or {}
    local tVect = tData[3] or {}
    
    for i=1, 4, 1 do
        local tName = {g_tStrings.STR_MATCHES_UNSURE, g_tStrings.STR_MATCHES_UNSURE}
        local tTong = {g_tStrings.STR_MATCHES_UNSURE, g_tStrings.STR_MATCHES_UNSURE}
        local nID = i - 1
        local tPlayerGood = tGood[i] or {}
        local tPlayerEvil = tEvil[i] or {}
        
        local hImageG = hGoodList:Lookup("Image_Good"..nID)
        local hTextG1 = hGoodList:Lookup("Text_Good"..nID.."_1")
        local hTextG2 = hGoodList:Lookup("Text_Good"..nID.."_2")
        local hImageGV = hGoodList:Lookup("Image_GV"..nID)
        
        local hImageE = hEvilList:Lookup("Image_Evil"..nID)
        local hTextE1 = hEvilList:Lookup("Text_Evil"..nID.."_1")
        local hTextE2 = hEvilList:Lookup("Text_Evil"..nID.."_2")
        local hImageEV = hEvilList:Lookup("Image_EV"..nID)
        local bGoodExist, bEvilExist = false, false
        
        if tPlayerGood.name then
            tName[1] = tPlayerGood.name
            tTong[1] = tPlayerGood.tong or ""
            bGoodExist = true
        end
        
        if tPlayerEvil.name then
            tName[2] = tPlayerEvil.name
            tTong[2] = tPlayerEvil.tong or ""
            bEvilExist = true
        end
        
        if bGoodExist and not bEvilExist then
            tName[2] = g_tStrings.STR_MATCHES_NONE
            tTong[2] = g_tStrings.STR_MATCHES_NONE
        end
        
        if not bGoodExist and bEvilExist then
            tName[1] = g_tStrings.STR_MATCHES_NONE
            tTong[1] = g_tStrings.STR_MATCHES_NONE
        end
        
        hImageGV:Hide()
        hImageEV:Hide()
        if tVect[i] and tVect[i] == tPlayerGood.dwID then
            hImageGV:Show()
        elseif tVect[i] and tVect[i] == tPlayerEvil.dwID then
            hImageEV:Show()
        end
        hTextG1:SetText(tName[1])
        hTextG2:SetText(tTong[1])
        hTextE1:SetText(tName[2])
        hTextE2:SetText(tTong[2])
    end
end

function TongArena.UpdateFinalContest(tData)
    tData = tData or {}
    local tGood = tData[1] or {}
    local tEvil = tData[2] or {}
    local nWinner = tData.nWinner
    local hGood = WIDGET.hPageContest:Lookup("", "Handle_Good_Contest")
    local hEvil = WIDGET.hPageContest:Lookup("", "Handle_Evil_Contest")
    local hTextG1 = hGood:Lookup("Text_GoodC1")
    local hTextG2 = hGood:Lookup("Text_GoodC2")
    local hTextE1 = hEvil:Lookup("Text_EvilC1")
    local hTextE2 = hEvil:Lookup("Text_EvilC2")
    local hImageG = hGood:Lookup("Image_CRV")
    local hImageE = hEvil:Lookup("Image_CEV")
    
    local tName = {g_tStrings.STR_MATCHES_UNSURE, g_tStrings.STR_MATCHES_UNSURE}
    local tTong = {g_tStrings.STR_MATCHES_UNSURE, g_tStrings.STR_MATCHES_UNSURE}
    local bGoodExist, bEvilExist = false, false
    if tGood.name then
        tName[1] = tGood.name  
        tTong[1] = tGood.tong or ""
        bGoodExist = true
    end
    
    if tEvil.name then
        tName[2] = tEvil.name
        tTong[2] = tEvil.tong or ""
        bEvilExist = true
    end
    
    if bGoodExist and not bEvilExist then
        tName[2] = g_tStrings.STR_MATCHES_NONE
        tTong[2] = g_tStrings.STR_MATCHES_NONE
    end
    
    if not bGoodExist and bEvilExist then
        tName[1] = g_tStrings.STR_MATCHES_NONE
        tTong[1] = g_tStrings.STR_MATCHES_NONE
    end
    
    hImageG:Hide()
    hImageE:Hide()
    if nWinner and nWinner == tGood.dwID then
        hImageG:Show()
    elseif nWinner and nWinner == tEvil.dwID then
        hImageE:Show()
    end
    
    hTextG1:SetText(tName[1])
    hTextG2:SetText(tTong[1])
    hTextE1:SetText(tName[2])
    hTextE2:SetText(tTong[2])
end

function TongArena.UpdatePageInfo(hWnd, szBack, szNext, szText, nStart, nTotal)
    local hBtnBack = hWnd:Lookup(szBack)
    local hBtnNext = hWnd:Lookup(szNext)
    local hText = hWnd:Lookup("", szText)
    local nEnd = nStart + PAGE_RESULT_COUNT - 1
    nEnd = math.min(nEnd, nTotal)
	hBtnBack:Enable(nStart ~= 1)
	hBtnNext:Enable(nEnd < nTotal)
	if nTotal == 0 then
		hText:SetText("(0-0(0))")
	else
		hText:SetText(nStart.."-"..nEnd.." ("..nTotal..")")
	end
end

function TongArena.UpdateIntroduce(szMvplayer)
    szMvplayer = szMvplayer or ""
    local hPage = WIDGET.hPageAngle
    local hList = hPage:Lookup("PageSet_Info/Page_Notice", "Handle_NTextA");
    local tContent = {{text=g_tStrings.STR_MATCHE_ANNOUNCE1}}
    table.insert(tContent, 1, {text=szMvplayer, nFont=163})
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hList = hPage:Lookup("PageSet_Info/Page_Rules", "Handle_RTextA");
    tContent = {{text=g_tStrings.STR_MATCHE_RULE1}}
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hPage = WIDGET.hPageGame
    hList = hPage:Lookup("PageSet_InfoG/Page_NoticeG", "Handle_NTextG");
    tContent = {{text=g_tStrings.STR_MATCHE_ANNOUNCE2}}
    table.insert(tContent, 1, {text=szMvplayer, nFont=163})
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hList = hPage:Lookup("PageSet_InfoG/Page_RulesG", "Handle_RTextG");
    tContent = {{text=g_tStrings.STR_MATCHE_RULE2}}
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hPage = WIDGET.hPageVote
    hList = hPage:Lookup("PageSet_InfoV/Page_NoticeV", "Handle_NTextV");
    tContent = {{text=g_tStrings.STR_MATCHE_ANNOUNCE3}}
    table.insert(tContent, 1, {text=szMvplayer, nFont=163})
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hList = hPage:Lookup("PageSet_InfoV/Page_RulesV", "Handle_RTextV");
    tContent = {{text=g_tStrings.STR_MATCHE_RULE3}}
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hPage = WIDGET.hPageFinal
    hList = hPage:Lookup("PageSet_InfoF/Page_NoticeF", "Handle_NTextF");
    tContent = {{text=g_tStrings.STR_MATCHE_ANNOUNCE4}}
    table.insert(tContent, 1, {text=szMvplayer, nFont=163})
    OBJECT.UpdateAnnounce(hList, tContent)
    
    hList = hPage:Lookup("PageSet_InfoF/Page_RulesF", "Handle_RTextF");
    tContent = {{text=g_tStrings.STR_MATCHE_RULE4}}
    OBJECT.UpdateAnnounce(hList, tContent)
end

function TongArena.UpdateAnnounce(hList, tContent)
    hList:Clear()
    local szHandleName = hList:GetName()
    local szLine = GetFormatText("\n")
    for k, v in ipairs(tContent) do
        if not v.text or v.text ~= "" then
            local szText = GetFormatText(v.text, v.nFont)
            hList:AppendItemFromString(szText)
            hList:AppendItemFromString(szLine)
        end
    end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "TongArena")
end

function TongArena.SelectResult(hSelItem, szImage)
    local dwID = nil
    local hList = hSelItem:GetParent()
    if hList.hSelItem then
        hList.hSelItem.bSel = false
        OBJECT.UpdateBgStatus(hList.hSelItem, szImage)
    end
    
    hSelItem.bSel = true
    hList.hSelItem = hSelItem
    OBJECT.UpdateBgStatus(hSelItem, szImage)
    
    if hList.bVote then
        WIDGET.hBtnVote:Enable(WIDGET.hBtnVote.bEnable)
        WIDGET.hBtnMonthly:Enable(WIDGET.hBtnMonthly.bEnable)
        WIDGET.hPageVote:Lookup("Edit_VoteNum"):SetText("1")
    end
end

function TongArena.UpdateBgStatus(hItem, szImage)
    if not hItem then
		return
	end
	local img = hItem:Lookup(szImage)
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

function TongArena.SetVoteInfo(nCurrentVoteNum)
    local hVoteNum = WIDGET.hPageVote:Lookup("", "Text_Total")
    hVoteNum:SetText(nCurrentVoteNum or 0)
end

function TongArena.OnGameMenuAction()
    local hPage = WIDGET.hPageGame
    local hTextType = hPage:Lookup("Btn_Matches1"):Lookup("", "Text_Matches1") 
    local hTextNumber = hPage:Lookup("Btn_Matches"):Lookup("", "Text_Matches") 
    local nCamp = l_tGame.CheckCamp
    local nType, nNumber = hTextType.Value, hTextNumber.Value
    l_tGame[nCamp].nType = nType
    l_tGame[nCamp].nNumber = nNumber
    
    RemoteCallToServer("OnTongArenaGameRequest", nCamp, nType, nNumber) -- 获取比赛场次、结果
    OBJECT.LockRequestOpertion()
end

function TongArena.OnFinalWarMenuAction()
    local hText = WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Lookup("", "Text_MatchesF_0")
    local nNumber = hText.Value    
    RemoteCallToServer("OnTongArenaFinalWarRequest", nNumber) -- 获取循环赛场次
    OBJECT.LockRequestOpertion()
end

function TongArena.OnFinalRankMenuAction()
    RemoteCallToServer("OnTongArenaFinalRankRequest") -- 获取循环赛排名
    OBJECT.LockRequestOpertion()
end

function TongArena.PopupMenu(hBtn, text, tData)
	if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end
    
	local szName = text:GetName()
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
			if text:IsValid() then
                text:SetText(UserData.name)
                text.Value = UserData.value
                if UserData.fnAction then
                    UserData.fnAction()
                end
			end
		end,
		fnAutoClose = function() return not IsTongArenaOpened() end,
	}
	for k, v in ipairs(tData) do
        table.insert(menu, {szOption = v.name, UserData= v, r = v.r, g = v.g, b = v.b})
	end
	PopupMenu(menu)
end

function TongArena.AngleCheckCamp(nCamp)
    l_tAngle.CheckCamp = nCamp
    local szUnCheck = "CheckBox_GoodA"
    if nCamp == CAMP.GOOD then
        szUnCheck = "CheckBox_EvilA"
    end
    WIDGET.hPageAngle:Lookup(szUnCheck):Check(false);
    
    RemoteCallToServer("OnTongArenaAngleRequest", nCamp) -- 逐鹿贴
    OBJECT.LockRequestOpertion()
end

function TongArena.GameCheckCamp(nCamp)
    local hPage = WIDGET.hPageGame
    local hTextType = hPage:Lookup("Btn_Matches1"):Lookup("", "Text_Matches1") 
    local hTextNumber = hPage:Lookup("Btn_Matches"):Lookup("", "Text_Matches") 
    local nType, nNumber = l_tGame[nCamp].nType, l_tGame[nCamp].nNumber
    hTextType.Value = nType
    hTextType:SetText(MATCH_TYPE_STRING[nType])
    
    hTextNumber.Value = nNumber
    szNumber = FormatString(g_tStrings.STR_MATCHES_INDEX, g_tStrings.STR_NUMBER[nNumber])
    hTextNumber:SetText(szNumber)
    
    local szUnCheck = "CheckBox_Good"
    if nCamp == CAMP.GOOD then
        szUnCheck = "CheckBox_Evil"
    end
    l_tGame.CheckCamp = nCamp
    WIDGET.hPageGame:Lookup(szUnCheck):Check(false);
    RemoteCallToServer("OnTongArenaGameRequest", nCamp, nType, nNumber) -- 获取争霸赛、逐鹿赛场次
    OBJECT.LockRequestOpertion()
end

function TongArena.VoteCheckCamp(nCamp, szUnCheck)
    local szUnCheck = "CheckBox_GoodV"
    if nCamp == CAMP.GOOD then
        szUnCheck = "CheckBox_EvilV"
    end
    WIDGET.hPageVote:Lookup(szUnCheck):Check(false);
    VOTE_CHECK_CAMP = nCamp
    RemoteCallToServer("OnTongArenaVoteRankRequest", nCamp) -- 获取投票排名
    OBJECT.LockRequestOpertion()
end

function TongArena.FinalCheckWar()
    FINAL_CHECK_PAGE = 1
    local hText = WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Lookup("", "Text_MatchesF_0")
    local nValue = tonumber(hText.Value)
    if nValue and nValue >= 1 and nValue <=4 then
        RemoteCallToServer("OnTongArenaFinalWarRequest", nValue) -- 获取循环赛场次
        OBJECT.LockRequestOpertion()
    end
end

function TongArena.FinalCheckRank()
    FINAL_CHECK_PAGE = 2
    RemoteCallToServer("OnTongArenaFinalRankRequest") -- 获取循环赛排名
    OBJECT.LockRequestOpertion()
end

function TongArena.FinalCheckContest()
    FINAL_CHECK_PAGE = 3
    RemoteCallToServer("OnTongArenaCampMVPRequest") -- 获取总决赛场次
    OBJECT.LockRequestOpertion()
end

function TongArena.LockRequestOpertion()
    if not IsTongArenaOpened() or not WIDGET.hFrame then
        return
    end
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Angle"):Enable(false)
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Game"):Enable(false)
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Vote"):Enable(false)
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Final"):Enable(false)
    WIDGET.hPageAngle:Lookup("CheckBox_GoodA"):Enable(false)
    WIDGET.hPageAngle:Lookup("CheckBox_EvilA"):Enable(false)
    WIDGET.hPageGame:Lookup("CheckBox_Good"):Enable(false)
    WIDGET.hPageGame:Lookup("CheckBox_Evil"):Enable(false)
    WIDGET.hPageVote:Lookup("CheckBox_GoodV"):Enable(false)
    WIDGET.hPageVote:Lookup("CheckBox_EvilV"):Enable(false)
    WIDGET.hPageFinal:Lookup("PageSet_Final/CheckBox_CWar"):Enable(false)
    WIDGET.hPageFinal:Lookup("PageSet_Final/CheckBox_Ranking"):Enable(false)
    WIDGET.hPageFinal:Lookup("PageSet_Final/CheckBox_Contest"):Enable(false)
    WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Enable(false)
    WIDGET.hPageGame:Lookup("Btn_Matches1"):Enable(false)
    WIDGET.hPageGame:Lookup("Btn_Matches"):Enable(false)
end

function TongArena.UnLockRequestOpertion()
    if not IsTongArenaOpened() or not WIDGET.hFrame then
        return
    end
    
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Angle"):Enable(true)
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Game"):Enable(true)
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Vote"):Enable(true)
    WIDGET.hFrame:Lookup("PageSet_Total/CheckBox_Final"):Enable(true)
    WIDGET.hPageAngle:Lookup("CheckBox_GoodA"):Enable(true)
    WIDGET.hPageAngle:Lookup("CheckBox_EvilA"):Enable(true)
    WIDGET.hPageGame:Lookup("CheckBox_Good"):Enable(true)
    WIDGET.hPageGame:Lookup("CheckBox_Evil"):Enable(true)
    WIDGET.hPageVote:Lookup("CheckBox_GoodV"):Enable(true)
    WIDGET.hPageVote:Lookup("CheckBox_EvilV"):Enable(true)
    WIDGET.hPageFinal:Lookup("PageSet_Final/CheckBox_CWar"):Enable(true)
    WIDGET.hPageFinal:Lookup("PageSet_Final/CheckBox_Ranking"):Enable(true)
    WIDGET.hPageFinal:Lookup("PageSet_Final/CheckBox_Contest"):Enable(true)
    WIDGET.hPageWar:Lookup("Btn_MatchesF_0"):Enable(true)
    WIDGET.hPageGame:Lookup("Btn_Matches1"):Enable(true)
    WIDGET.hPageGame:Lookup("Btn_Matches"):Enable(true)
end

--====================window 消息==========

function TongArena.OnCheckBoxCheck()
    if WIDGET.hFrame.bIniting then
        return
    end
    local tCheck =
    {
        ["CheckBox_GoodA"]={fnAction=OBJECT.AngleCheckCamp, Param1=CAMP.GOOD,},
        ["CheckBox_EvilA"]={fnAction=OBJECT.AngleCheckCamp, Param1=CAMP.EVIL,},
        
        ["CheckBox_Good"]={fnAction=OBJECT.GameCheckCamp, Param1=CAMP.GOOD,},
        ["CheckBox_Evil"]={fnAction=OBJECT.GameCheckCamp, Param1=CAMP.EVIL,},
        
        ["CheckBox_GoodV"]={fnAction=OBJECT.VoteCheckCamp, Param1=CAMP.GOOD,},
        ["CheckBox_EvilV"]={fnAction=OBJECT.VoteCheckCamp, Param1=CAMP.EVIL,},
        
        ["CheckBox_CWar"]={fnAction=OBJECT.FinalCheckWar},
        ["CheckBox_Ranking"]={fnAction=OBJECT.FinalCheckRank},
        ["CheckBox_Contest"]={fnAction=OBJECT.FinalCheckContest},
    }
    
    local szName = this:GetName()
    if szName == "CheckBox_Angle" then
        OBJECT.AngleCheckCamp(l_tAngle.CheckCamp)
    elseif szName == "CheckBox_Game" then
        OBJECT.GameCheckCamp(l_tGame.CheckCamp)
        
    elseif szName == "CheckBox_Vote" then
        OBJECT.VoteCheckCamp(VOTE_CHECK_CAMP)
        
    elseif szName == "CheckBox_Final" then
        if FINAL_CHECK_PAGE == 1 then
            OBJECT.FinalCheckWar()
        elseif FINAL_CHECK_PAGE == 2 then
            OBJECT.FinalCheckRank()
        elseif FINAL_CHECK_PAGE == 3 then
            OBJECT.FinalCheckContest()
        end
    end
    
    for k, v in pairs(tCheck) do
        if szName == k and v.fnAction then
            v.fnAction(v.Param1)
        end
    end
    this:Enable(true)
    PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

function TongArena.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Close" then
        CloseTongArena()
    elseif szName == "Btn_Back" then
        local nCamp = l_tAngle.CheckCamp
        local tData = l_tAngle[nCamp].tHistory
        l_tAngle[nCamp].nStart = math.max(1, l_tAngle[nCamp].nStart - PAGE_RESULT_COUNT)
        OBJECT.UpdateAngleList(tData, l_tAngle[nCamp].nStart)
        
    elseif szName == "Btn_Next" then
        local nCamp = l_tAngle.CheckCamp
        local tData = l_tAngle[nCamp].tHistory
        l_tAngle[nCamp].nStart = math.min(l_tAngle[nCamp].nStart + PAGE_RESULT_COUNT, #tData)
        OBJECT.UpdateAngleList(tData, l_tAngle[nCamp].nStart)
        
    elseif szName == "Btn_Vote" then
        local hList = WIDGET.hPageVote:Lookup("", "Handle_ListVote")
        local nNumber = WIDGET.hPageVote:Lookup("Edit_VoteNum"):GetText()
        if nNumber == "" or nNumber == nil then
            nNumber = 0
        else
            nNumber = tonumber(nNumber)
        end
        
        if hList.hSelItem and hList.hSelItem.dwID then
            RemoteCallToServer("OnTongArenaVotePlayer", VOTE_CHECK_CAMP, hList.hSelItem.dwID, nNumber)
        end
    elseif szName == "Btn_Monthly" then
        local hList = WIDGET.hPageVote:Lookup("", "Handle_ListVote")
        if hList.hSelItem and hList.hSelItem.dwID then
            RemoteCallToServer("On_Tong_ArenaVoteChampion", hList.hSelItem.dwID, VOTE_CHECK_CAMP)
        end
    end
    PlaySound(SOUND.UI_SOUND,g_sound.Button)
end

function TongArena.OnItemLButtonClick()
	local szName = this:GetName()
    if szName == "Handle_ItemList" then
        TongArena.SelectResult(this, "Image_Light")
    elseif szName == "Handle_FinalItemList" then
        OBJECT.SelectResult(this, "Image_LightF")
    end
end

function TongArena.OnItemMouseEnter()
	local szName = this:GetName()
    if szName == "Handle_ItemList" then
        this.bOver = true
        OBJECT.UpdateBgStatus(this, "Image_Light")
    elseif szName == "Handle_FinalItemList" then
        this.bOver = true
        OBJECT.UpdateBgStatus(this, "Image_LightF")
    end
end

function TongArena.OnItemMouseLeave()
	local szName = this:GetName()
    if szName == "Handle_ItemList" then
        this.bOver = false
        OBJECT.UpdateBgStatus(this, "Image_Light")  
    elseif szName == "Handle_FinalItemList" then
        this.bOver = false
        OBJECT.UpdateBgStatus(this, "Image_LightF")    
    end
end

function TongArena.OnLButtonDown()
    local szName = this:GetName()
    if szName == "Btn_Matches1" then
        if not this:IsEnabled() then
            return
        end
        
		local tData = 
        {
            {name=g_tStrings.STR_MATCHES_WAR1, value=1, fnAction=OBJECT.OnGameMenuAction}, 
            {name=g_tStrings.STR_MATCHES_WAR2, value=2, fnAction=OBJECT.OnGameMenuAction}, 
        }
		local text = this:Lookup("", "Text_Matches1")
		OBJECT.PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_Matches" then
        if not this:IsEnabled() then
            return
        end
        
        local tData = {}
		for i=1, MAX_MATCHE_COUNT, 1 do
            local szName = FormatString(g_tStrings.STR_MATCHES_INDEX, g_tStrings.STR_NUMBER[i])
			table.insert(tData, {name=szName, value=i, fnAction=OBJECT.OnGameMenuAction})
		end
		local text = this:Lookup("", "Text_Matches")
		OBJECT.PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_MatchesF_0" then
        if not this:IsEnabled() then
            return
        end
        local tData = {}
		for i=1, MAX_MATCHE_COUNT, 1 do
            local szName = FormatString(g_tStrings.STR_MATCHES_INDEX, g_tStrings.STR_NUMBER[i])
			table.insert(tData, {name=szName, value=i, fnAction=OBJECT.OnFinalWarMenuAction})
		end
		local text = this:Lookup("", "Text_MatchesF_0")
		OBJECT.PopupMenu(this, text, tData)
        return true
    end
end

function TongArena.UpdateAnchor(frame)
	frame:SetPoint(TongArena.Anchor.s, 0, 0, TongArena.Anchor.r, TongArena.Anchor.x, TongArena.Anchor.y)
	frame:CorrectPos()
end

--========================================================
function IsTongArenaOpened(bDisableSound)
    local frame = Station.Lookup("Normal/TongArena")
    if frame and frame:IsVisible() then
        return true
    end
end

function OpenTongArena(bDisableSound)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
    if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local frame = Wnd.OpenWindow("TongArena")
    OBJECT.InitObject(frame);
	OBJECT.UnLockRequestOpertion()
    
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end 
end

function CloseTongArena(bDisableSound)
    if IsTongArenaOpened() then
		Wnd.CloseWindow("TongArena")
	end
    
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

do
    RegisterScrollEvent("TongArena")
    UnRegisterScrollAllControl("TongArena")
    
    local szFramePath = "Normal/TongArena"
    local szPath = "PageSet_Total/Page_Angle"
    RegisterScrollControl(szFramePath, szPath.."/Btn_ListUp", szPath.."/Btn_ListDown", szPath.."/Scroll_ListAngle", {szPath, "Handle_ListAngle"})
        
    szPath = "PageSet_Total/Page_Angle/PageSet_Info/Page_Notice"
    RegisterScrollControl(szFramePath, szPath.."/Btn_NoticeUp", szPath.."/Btn_NoticeDown", szPath.."/Scroll_Notice", {szPath, "Handle_NTextA"})
        
    szPath = "PageSet_Total/Page_Angle/PageSet_Info/Page_Rules"
    RegisterScrollControl(szFramePath, szPath.."/Btn_RulesUp", szPath.."/Btn_RulesDown", szPath.."/Scroll_Rules", {szPath, "Handle_RTextA"})

    szPath = "PageSet_Total/Page_Game/PageSet_InfoG/Page_NoticeG"
    RegisterScrollControl(szFramePath, szPath.."/Btn_NoticeUpG", szPath.."/Btn_NoticeDownG", szPath.."/Scroll_NoticeG", {szPath, "Handle_NTextG"})
        
    szPath = "PageSet_Total/Page_Game/PageSet_InfoG/Page_RulesG"
    RegisterScrollControl(szFramePath, szPath.."/Btn_RulesUpG", szPath.."/Btn_RulesDownG", szPath.."/Scroll_RulesG", {szPath, "Handle_RTextG"})
    
    szPath = "PageSet_Total/Page_Vote/PageSet_InfoV/Page_NoticeV"
    RegisterScrollControl(szFramePath, szPath.."/Btn_NoticeUpV", szPath.."/Btn_NoticeDownV", szPath.."/Scroll_NoticeV", {szPath, "Handle_NTextV"})
        
    szPath = "PageSet_Total/Page_Vote/PageSet_InfoV/Page_RulesV"
    RegisterScrollControl(szFramePath, szPath.."/Btn_RulesUpV", szPath.."/Btn_RulesDownV", szPath.."/Scroll_RulesV", {szPath, "Handle_RTextV"})
    
    szPath = "PageSet_Total/Page_Final/PageSet_InfoF/Page_NoticeF"
    RegisterScrollControl(szFramePath, szPath.."/Btn_NoticeUpF", szPath.."/Btn_NoticeDownF", szPath.."/Scroll_NoticeF", {szPath, "Handle_NTextF"})
        
    szPath = "PageSet_Total/Page_Final/PageSet_InfoF/Page_RulesF"
    RegisterScrollControl(szFramePath, szPath.."/Btn_RulesUpF", szPath.."/Btn_RulesDownF", szPath.."/Scroll_RulesF", {szPath, "Handle_RTextF"})
end
