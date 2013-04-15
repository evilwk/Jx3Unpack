CampPanel = {}
CampPanel.DefaultAnchor = {s = "RIGHT", r = "RIGHT", x = -10, y = 250}
CampPanel.Anchor = {s = "RIGHT", r = "RIGHT", x = -10, y = 250}
CampPanel.GoodMoraleBossIndex = 
{
	[7827] = 4,
	[7828] = 5,
	[7826] = 6,
}
CampPanel.EvilMoraleBossIndex = 
{
	[7823] = 4,
	[7824] = 5,
	[7825] = 6,
}
CampPanel.tCampQuestID = {5549, 5550, 5552, 5553}

RegisterCustomData("CampPanel.Anchor")

function CampPanel.OnFrameCreate()
	this:RegisterEvent("UPDATE_CAMP_INFO")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("CAMP_PANEL_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("QUEST_FAILED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("QUEST_FINISHED")
	
	CampPanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.CAMP)
end

function CampPanel.OnEvent(szEvent)
	if szEvent == "UPDATE_CAMP_INFO" then
		CampPanel.UpdatePanel(this)
	elseif szEvent == "UI_SCALED" then
		CampPanel.UpdateAnchor(this)
	elseif szEvent == "ON_ENTER_CUSTOM_UI_MODE" or szEvent == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif szEvent == "CAMP_PANEL_ANCHOR_CHANGED" then
		CampPanel.UpdateAnchor(this)
	elseif szEvent == "CUSTOM_DATA_LOADED" then
		CampPanel.UpdateAnchor(this)
	elseif szEvent == "QUEST_ACCEPTED" then
		CampPanel.UpdateQuest(arg1)
	elseif szEvent == "QUEST_DATA_UPDATE" then
		local player = GetClientPlayer()
		if not player then
			return
		end
		local dwQuestID = player.GetQuestID(arg0)
		CampPanel.UpdateQuest(dwQuestID)
	elseif szEvent == "QUEST_FAILED" then
		CampPanel.RemoveQuest()
	elseif szEvent == "QUEST_CANCELED" then
		local player = GetClientPlayer()
		if not player then
			return
		end
		local questTrace = player.GetQuestTraceInfo(arg0)
		if not questTrace.fail then
			CampPanel.RemoveQuest()
		end
	elseif szEvent == "QUEST_FINISHED" then
		CampPanel.RemoveQuest()
	end
end

function CampPanel.OnFrameBreathe()
	local szText, szTime = CampActiveTime.GetTime()
	if szText and szTime then
		local textCountdown1, textCountdown2 = nil, nil
		local textCountdownBegin1 = this:Lookup("", "Text_CountdownBegin1")
		local textCountdownBegin2 = this:Lookup("", "Text_CountdownBegin2")
		local textCountdownEnd1 = this:Lookup("", "Text_CountdownEnd1")
		local textCountdownEnd2 = this:Lookup("", "Text_CountdownEnd2")
		if szText == g_tStrings.CAMPACTIVE_BEGIN_LEFT_TIME then
			textCountdown1 = textCountdownBegin1
			textCountdown2 = textCountdownBegin2
			textCountdownBegin1:Show()
			textCountdownBegin2:Show()
			textCountdownEnd1:Hide()
			textCountdownEnd2:Hide()
		elseif szText == g_tStrings.CAMPACTIVE_END_LEFT_TIME then
			textCountdown1 = textCountdownEnd1
			textCountdown2 = textCountdownEnd2
			textCountdownBegin1:Hide()
			textCountdownBegin2:Hide()
			textCountdownEnd1:Show()
			textCountdownEnd2:Show()
		end
		textCountdown1:SetText(szText)
		textCountdown2:SetText(szTime)
		
		local nCurrentTime = GetCurrentTime()
		local tData = TimeToDate(nCurrentTime)
		if tData.weekday ~= 6 and tData.weekday ~= 0 then
			textCountdown1:Hide()
			textCountdown2:Hide()
		end
	end
end

function CampPanel.OnFrameDrag()
end

function CampPanel.OnFrameDragSetPosEnd()
end

function CampPanel.OnFrameDragEnd()
	this:CorrectPos()
	CampPanel.Anchor = GetFrameAnchor(this)
end

function CampPanel.UpdateAnchor(hFrame)
	hFrame:SetPoint(CampPanel.Anchor.s, 0, 0, CampPanel.Anchor.r, CampPanel.Anchor.x, CampPanel.Anchor.y)
	hFrame:CorrectPos()
end

function CampPanel.OnItemMouseEnter()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	local szTip = nil
	
	local nX, nY = Cursor.GetPos()
	--[[
	if szName == "Image_Camp2" then
		local hImageFlag = this:GetParent():Lookup("Image_Scale")
		local nFlagWidth, _ = hImageFlag:GetSize()
		local nFlagX, _ = hImageFlag:GetAbsPos()
		if nX < nFlagX then
			szTip = GetCampAwardTip(CAMP.GOOD)
		elseif nX > nFlagX + nFlagWidth then
			szTip = GetCampAwardTip(CAMP.EVIL)
		end
	--]]
	if szName == "Image_Logo1" then
		if CampPanel.IsCampFightBeginAndInTheMap() then
			szTip = GetCampFightInfoTip(CAMP.GOOD)
		else
			szTip = GetCampInfoTip(CAMP.GOOD)
		end
		
	elseif szName == "Image_Logo2" then
		if CampPanel.IsCampFightBeginAndInTheMap() then
			szTip = GetCampFightInfoTip(CAMP.EVIL)
		else
			szTip = GetCampInfoTip(CAMP.EVIL)
		end
	elseif szName == "Image_Camp2" then
		szTip = "<text>text="..EncodeComponentsString(g_tStrings.STR_CAMP_ADD_LEVEL_FUNCTION_TIP).."font=27</text>"..
				"<text>text="..EncodeComponentsString(g_tStrings.STR_CAMP_ADD_LEVEL_FUNCTION_CONTENT).."font=18</text>"
	else
		local _, _, szIndex1 = string.find(szName, "Handle_HaoQi(%d+)")
		local _, _, szIndex2 = string.find(szName, "Handle_ERen(%d+)")
		if szIndex1 or szIndex2 then
			local npc = GetNpcTemplate(this.dwID)
			szTip = g_tStrings.STR_CAMP_BATTLE[this.nType]..npc.szName.."\n"..g_tStrings.STR_HP..tostring(this.nLifePercent).."%"
			szTip = GetFormatText(szTip, 162)
		end
	end
	
	if szTip then
		OutputTip(szTip, 330, {nX, nY, 10, 10})
	end
end

function CampPanel.OnItemMouseLeave()
	HideTip()
end

function CampPanel.IsCampFightBeginAndInTheMap()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hScene = hPlayer.GetScene()
	if not hScene then
		return
	end
	local dwMapID = GetInCampFightCity()

	return hScene.dwMapID == dwMapID
end

function CampPanel.FormatCampInfoTip(nCamp, nLevel, nScore, nFullScore)
	local szText = g_tStrings.STR_CAMP_TITLE[nCamp] .. g_tStrings.STR_COLON .. "level" .. nLevel .. "\n"
	szText = szText .. g_tStrings.STR_CAMP_SCORE .. nScore .. "/" .. nFullScore
	return GetFormatText(szText, 162)
end

function CampPanel.FormatCampPrizeTip(nCamp, nLevel)
	local szText = g_tStrings.STR_CAMP_PRIZE
end
	
function CampPanel.UpdatePanel(hFrame)
	local hCamp = hFrame:Lookup("", "")
	
	local hCampInfo = GetCampInfo()
	local nGoodCampScore = hCampInfo.nGoodCampScore
	local nEvilCampScore = hCampInfo.nEvilCampScore
	local fPercentage = 0.5
	if nGoodCampScore + nEvilCampScore > 0 then
		fPercentage = nGoodCampScore / (nGoodCampScore + nEvilCampScore)
	end
	local hImageCamp1 = hCamp:Lookup("Image_Camp1")
	hImageCamp1:SetPercentage(fPercentage)
	
	local nWidth, _ = hImageCamp1:GetSize()
	local nPosX, _ = hImageCamp1:GetRelPos()
	local hImageFlag = hCamp:Lookup("Image_Scale")
	local nFlagWidth, _ = hImageFlag:GetSize()
	nPosX = nPosX + nWidth * fPercentage - nFlagWidth / 2
	local _, nPosY = hImageFlag:GetRelPos()
	hImageFlag:SetRelPos(nPosX, nPosY)
	hCamp:FormatAllItemPos()
	
	hCamp:Lookup("Image_Camp2"):SetPercentage(1 - fPercentage)
	
	CampPanel.UpdateCampBossInfo(hFrame)
end

local GetBossHeadImagePath = function(dwID)
	local szPath = "\\ui\\Image\\TargetPanel\\"
	return szPath..tostring(dwID)..".tga"
end

local SortBoss = function(tBoss)
    if tBoss then
        local fnSort = function(BossInfo1, BossInfo2)
        	return BossInfo1.nLifePercent < BossInfo2.nLifePercent
        end
        table.sort(tBoss, fnSort)
    end
end

function CampPanel.UpdateCampBossInfo(frame)
	if not frame then
		return
	end
	
	local tNPCInfo = GetCampNpcInfo()
	local tEvilCampBoss = {}
	local tGoodCampBoss = {}
	local tEvilMoraleBoss = {}
	local tGoodMoraleBoss = {}
	
	for _, NpcInfo in ipairs(tNPCInfo) do
		if NpcInfo.nType == CAMP_NPC_TYPE.EVIL_CAMP_BOSS then
			table.insert(tEvilCampBoss, NpcInfo)
		elseif NpcInfo.nType == CAMP_NPC_TYPE.GOOD_CAMP_BOSS then
			table.insert(tGoodCampBoss, NpcInfo)
		elseif NpcInfo.nType == CAMP_NPC_TYPE.EVIL_CAMP_SCORE_LEVEL_BOSS then
			table.insert(tEvilMoraleBoss, NpcInfo)
		elseif NpcInfo.nType == CAMP_NPC_TYPE.GOOD_CAMP_SCORE_LEVEL_BOSS then
			table.insert(tGoodMoraleBoss, NpcInfo)
		end
	end
	
	SortBoss(tEvilCampBoss)
	SortBoss(tGoodCampBoss)
	SortBoss(tEvilMoraleBoss)
	SortBoss(tGoodMoraleBoss)
	
	local hCamp = frame:Lookup("", "")
	local nGoodIndex, nEvilIndex = 1, 1
	-- 浩气阵营boss
	for _, NpcInfo in ipairs(tGoodCampBoss) do
		local handle = hCamp:Lookup("Handle_HaoQi"..nGoodIndex)
		local imgBoss = handle:Lookup("Image_HaoQiBoss"..nGoodIndex)
		local imgHP = handle:Lookup("Image_HaoQiHP"..nGoodIndex)
		local imgKilled = handle:Lookup("Image_HaoQiKilled"..nGoodIndex)
		handle:Show()
		handle.nType = NpcInfo.nType
		handle.dwID = NpcInfo.dwNpcTemplateID
		handle.nLifePercent = NpcInfo.nLifePercent
		
		local szHeadImagePath = GetBossHeadImagePath(NpcInfo.dwNpcTemplateID)
		imgBoss:FromTextureFile(szHeadImagePath)
		
		local fPercentage = NpcInfo.nLifePercent / 100
		imgHP:SetPercentage(fPercentage)
		
		if NpcInfo.nLifePercent == 0 then
			imgKilled:Show()
		else
			imgKilled:Hide()
		end
		
		nGoodIndex = nGoodIndex + 1
	end
	
	-- 恶人阵营boss
	for _, NpcInfo in ipairs(tEvilCampBoss) do
		local handle = hCamp:Lookup("Handle_ERen"..nEvilIndex)
		local imgBoss = handle:Lookup("Image_ERenBoss"..nEvilIndex)
		local imgHP = handle:Lookup("Image_ERenHP"..nEvilIndex)
		local imgKilled = handle:Lookup("Image_ERenKilled"..nEvilIndex)
		handle:Show()
		handle.nType = NpcInfo.nType
		handle.dwID = NpcInfo.dwNpcTemplateID
		handle.nLifePercent = NpcInfo.nLifePercent
		
		local szHeadImagePath = GetBossHeadImagePath(NpcInfo.dwNpcTemplateID)
		imgBoss:FromTextureFile(szHeadImagePath)
		
		local fPercentage = NpcInfo.nLifePercent / 100
		imgHP:SetPercentage(fPercentage)
		
		if NpcInfo.nLifePercent == 0 then
			imgKilled:Show()
		else
			imgKilled:Hide()
		end
		
		nEvilIndex = nEvilIndex + 1
	end
	
	for i = nGoodIndex, 3 do
		local handle = hCamp:Lookup("Handle_HaoQi"..i)
		handle:Hide()
	end
	
	for i = nEvilIndex, 3 do
		local handle = hCamp:Lookup("Handle_ERen"..i)
		handle:Hide()
	end
	
	for i = 4, 6 do
		local handle = hCamp:Lookup("Handle_HaoQi"..i)
		handle:Hide()
		handle = hCamp:Lookup("Handle_ERen"..i)
		handle:Hide()
	end
	
	-- 浩气士气boss
	for _, NpcInfo in ipairs(tGoodMoraleBoss) do
		local nMoraleIndex = CampPanel.GoodMoraleBossIndex[NpcInfo.dwNpcTemplateID]
		local handle = hCamp:Lookup("Handle_HaoQi"..nMoraleIndex)
		local imgBoss = handle:Lookup("Image_HaoQiBoss"..nMoraleIndex)
		local imgHP = handle:Lookup("Image_HaoQiHP"..nMoraleIndex)
		local imgKilled = handle:Lookup("Image_HaoQiKilled"..nMoraleIndex)
		handle:Show()
		handle.nType = NpcInfo.nType
		handle.dwID = NpcInfo.dwNpcTemplateID
		handle.nLifePercent = NpcInfo.nLifePercent
	
		local szHeadImagePath = GetBossHeadImagePath(NpcInfo.dwNpcTemplateID)
		imgBoss:FromTextureFile(szHeadImagePath)
		
		local fPercentage = NpcInfo.nLifePercent / 100
		imgHP:SetPercentage(fPercentage)
		
		if NpcInfo.nLifePercent == 0 then
			imgKilled:Show()
		else
			imgKilled:Hide()
		end
	end
	
	-- 恶人士气boss
	for _, NpcInfo in ipairs(tEvilMoraleBoss) do
		local nMoraleIndex = CampPanel.EvilMoraleBossIndex[NpcInfo.dwNpcTemplateID]
		local handle = hCamp:Lookup("Handle_ERen"..nMoraleIndex)
		local imgBoss = handle:Lookup("Image_ERenBoss"..nMoraleIndex)
		local imgHP = handle:Lookup("Image_ERenHP"..nMoraleIndex)
		local imgKilled = handle:Lookup("Image_ERenKilled"..nMoraleIndex)
		handle:Show()
		handle.nType = NpcInfo.nType
		handle.dwID = NpcInfo.dwNpcTemplateID
		handle.nLifePercent = NpcInfo.nLifePercent
		
		local szHeadImagePath = GetBossHeadImagePath(NpcInfo.dwNpcTemplateID)
		imgBoss:FromTextureFile(szHeadImagePath)
		
		local fPercentage = NpcInfo.nLifePercent / 100
		imgHP:SetPercentage(fPercentage)
		
		if NpcInfo.nLifePercent == 0 then
			imgKilled:Show()
		else
			imgKilled:Hide()
		end
	end
end

function CampPanel.UpdateQuest(dwQuestID)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local dwCampQuestID = nil
	for k, v in pairs(CampPanel.tCampQuestID) do
		if dwQuestID == v then
			dwCampQuestID = v
			break
		end
	end
	if not dwCampQuestID then
		return
	end
	
	local textQuest = nil
	local szTimeText = CampActiveTime.GetTime()
	local textScore1 = Station.Lookup("Normal/CampPanel"):Lookup("", "Text_MyScore1")
	local textScore2 = Station.Lookup("Normal/CampPanel"):Lookup("", "Text_MyScore2")
	if szTimeText == g_tStrings.CAMPACTIVE_BEGIN_LEFT_TIME then
		textScore1:Show()
		textScore2:Hide()
		textQuest = textScore1
	elseif szTimeText == g_tStrings.CAMPACTIVE_END_LEFT_TIME then
		textScore1:Hide()
		textScore2:Show()
		textQuest = textScore2
	end
	if not textQuest then
		return
	end
	
	local tQuestStringInfo = Table_GetQuestStringInfo(dwCampQuestID)
	local questTrace = player.GetQuestTraceInfo(dwCampQuestID)
	for k, v in pairs(questTrace.quest_state) do
		local szName = tQuestStringInfo["szQuestValueStr" .. (v.i + 1)]
		v.have = math.min(v.have, v.need)
		local szText = szName.."："..v.have.."/"..v.need
		if v.have == v.need then
			szText = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED
		end
		szText = szText.."\n"
		textQuest:SetText(szText)
		break
	end
end

function CampPanel.RemoveQuest()
	local textQuest = nil
	local szTimeText = CampActiveTime.GetTime()
	if szTimeText == g_tStrings.CAMPACTIVE_BEGIN_LEFT_TIME then
		textQuest = Station.Lookup("Normal/CampPanel"):Lookup("", "Text_MyScore1")
	elseif szTimeText == g_tStrings.CAMPACTIVE_END_LEFT_TIME then
		textQuest = Station.Lookup("Normal/CampPanel"):Lookup("", "Text_MyScore2")
	end
	
	if not textQuest then
		return
	end
	
	textQuest:SetText("")
end

function GetCampInfoText(nCamp)
	local hCampInfo = GetCampInfo()
	local nGoodCampScore = hCampInfo.nGoodCampScore
	local nEvilCampScore = hCampInfo.nEvilCampScore
	
	local szText = g_tStrings.STR_CAMP_TITLE[nCamp] .. "\n"
	local nScore = 0
	if nCamp == CAMP.GOOD then
		nScore = nGoodCampScore
	elseif nCamp == CAMP.EVIL then
		nScore = nEvilCampScore
	end
	szText = szText .. g_tStrings.STR_CAMP_SCORE
	szText = szText .. nScore
	return szText
end

function GetCampInfoTip(nCamp)
	local szText = GetCampInfoText(nCamp)
	return GetFormatText(szText, 162)
end

function GetCampFightInfoTip(nCamp)
	local szText = GetCampInfoText(nCamp)
	local tCampInfo = GetCampInfo()
	local nActiveBossCount = 0
	
	if nCamp == CAMP.GOOD then
		nActiveBossCount = tCampInfo.nGoodBossActiveCount
	elseif nCamp == CAMP.EVIL then
		nActiveBossCount = tCampInfo.nEvilBossActiveCount
	else
		return GetFormatText(szText, 162)
	end
	
	if not nActiveBossCount or nActiveBossCount < 0 then
		nActiveBossCount = 0
	end
	
	szText = szText.."\n"..g_tStrings.STR_ACTIVATE_BOSS..nActiveBossCount
	return GetFormatText(szText, 162)
end

function GetCampAwardTip(nCamp)
	local szTitle = g_tStrings.STR_CAMP_TITLE[nCamp] .. g_tStrings.STR_CAMP_AWARD_TITLE .. "\n"
	local szTip = GetFormatText(szTitle, 163)
	
	local GetPercent = function(nNumber)
		local fPer = nNumber * 100 / MAX_CAMP_PRIZE
		return FixFloat(fPer, 0) .. "%"
	end
	
	if nCamp ~= CAMP.NEUTRAL then
		local hCampInfo = GetCampInfo()
		local nLevel = 0
		if nCamp == CAMP.GOOD then
			nLevel = hCampInfo.nCampLevel
		elseif nCamp == CAMP.EVIL then
			nLevel = MAX_CAMP_LEVEL - hCampInfo.nCampLevel
		end
		
		--[[
		local szMoney = g_tStrings.STR_CAMP_AWARD_MONEY .. "\t" .. GetPercent(hCampInfo.GetMoneyPercent(nCamp, nLevel))
		szTip = szTip .. GetFormatText(szMoney, 162)
		
		local szRepute = g_tStrings.STR_CAMP_AWARD_REPUTE .. "\t" .. GetPercent(hCampInfo.GetReputePercent(nCamp, nLevel))
		szTip = szTip .. GetFormatText(szRepute, 162)
		--]]
		
		local szPrestige = g_tStrings.STR_CAMP_AWARD_PRESTIGE .. "\t" .. GetPercent(hCampInfo.GetPrestigePercent(nCamp, nLevel))
		szTip = szTip .. GetFormatText(szPrestige, 162)
		
		--[[
		local szReducePrestige = g_tStrings.STR_CAMP_AWARD_REDUCE_PRESTIGE .. "\t" .. GetPercent(hCampInfo.GetReducePrestigeOnDeath (nCamp, nLevel))
		szTip = szTip .. GetFormatText(szReducePrestige, 162)
		--]]
	end

	-- szTip = szTip .. GetFormatText(g_tStrings.STR_CAMP_FIRST_JOIN_AWARD, 162)

	return szTip
end

function CampPanel_SetAnchorDefault()
	CampPanel.Anchor.s = CampPanel.DefaultAnchor.s
	CampPanel.Anchor.r = CampPanel.DefaultAnchor.r
	CampPanel.Anchor.x = CampPanel.DefaultAnchor.x
	CampPanel.Anchor.y = CampPanel.DefaultAnchor.y
	FireEvent("CAMP_PANEL_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", CampPanel_SetAnchorDefault)

local function OnCampResult()	
	local szMsg = nil
    local szChanel = "MSG_ANNOUNCE_RED"
	if arg0 == CAMP_RESULT_CODE.FAILD then
		szMsg = g_tStrings.STR_CAMP_RESULT_FAILD
	elseif arg0 == CAMP_RESULT_CODE.SUCCEED then
		local hPlayer = GetClientPlayer()
		szMsg = FormatString(g_tStrings.STR_CAMP_RESULT_SUCCEED, g_tStrings.STR_CAMP_TITLE[hPlayer.nCamp])
        szChanel = "MSG_ANNOUNCE_YELLOW"
	elseif arg0 == CAMP_RESULT_CODE.TONG_CONFLICT then
		szMsg = g_tStrings.STR_CAMP_RESULT_TONG
	elseif arg0 == CAMP_RESULT_CODE.IN_PARTY then
		szMsg = g_tStrings.STR_CAMP_RESULT_PARTY
	end
		
	if szMsg then
		OutputMessage("MSG_SYS", szMsg)
        OutputMessage(szChanel, szMsg)
	end
end

local function OnUpdateCampPanel()
	local hPlayer = GetClientPlayer()
	if hPlayer and hPlayer.dwID == arg0 then
		local hCampFrame = Station.Lookup("Normal/CampPanel")
		
		if hPlayer.nCamp == CAMP.NEUTRAL then
			if hCampFrame then
				Wnd.CloseWindow(hCampFrame)
			end
			return
		end
	
		local hScene = hPlayer.GetScene()
		if hScene.nType == MAP_TYPE.BIRTH_MAP or hScene.nType == MAP_TYPE.BATTLE_FIELD then
			if hCampFrame then
				Wnd.CloseWindow(hCampFrame)
			end
		else
			if not hCampFrame then
				hCampFrame = Wnd.OpenWindow("CampPanel")
			end
			CampPanel.UpdatePanel(hCampFrame)
		end
	end	
end

local function OnChangeCampFlag()
	local hClientPlayer = GetClientPlayer()
	if not hClientPlayer then
	    return
	end
	
	local dwPlayerID = arg0
	if hClientPlayer.dwID == dwPlayerID then
		if hClientPlayer.bCampFlag then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SYS_MSG_OPEN_CAMP_FALG, g_tStrings.STR_NAME_YOU))
            OutputMessage("MSG_ANNOUNCE_YELLOW", FormatString(g_tStrings.STR_SYS_MSG_OPEN_CAMP_FALG, g_tStrings.STR_NAME_YOU))
		else
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SYS_MSG_CLOSE_CAMP_FALG, g_tStrings.STR_NAME_YOU))
            OutputMessage("MSG_ANNOUNCE_YELLOW", FormatString(g_tStrings.STR_SYS_MSG_CLOSE_CAMP_FALG, g_tStrings.STR_NAME_YOU))
		end
	else
		local hPlayer = GetPlayer(dwPlayerID)
		if hPlayer.bCampFlag then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SYS_MSG_OPEN_CAMP_FALG, hPlayer.szName))
		else
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SYS_MSG_CLOSE_CAMP_FALG, hPlayer.szName))
		end
	end
end

local nEndTime = 0
local COUNTDOWN_TIME = { 60 * 5, 60 * 4, 60 * 3, 60 * 2, 60, 30 }
local nLastCountdownIndex = nil
local function CloseCampCountdown()
	local nCurTime = GetCurrentTime()
	if nCurTime >= nEndTime then
		RegisterBreatheEvent("WAIT_CLOSE_CAMP", nil)
		nEndTime = 0
		return
	end
	
	local nLeftTime = nEndTime - nCurTime
	for nIndex, nTime in ipairs(COUNTDOWN_TIME) do
		if nLeftTime <= nTime and COUNTDOWN_TIME[nIndex + 1] and nLeftTime > COUNTDOWN_TIME[nIndex + 1] then
			if nLastCountdownIndex ~= nIndex then
				local szTime = GetTimeText(nTime)
				OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SYS_MSG_WAIT_CLOSE_CAMP_FLAG, szTime))
				nLastCountdownIndex = nIndex
			end
			break
		end
	end
end

function GetCloseCampFlagTime()
	return nEndTime
end

function WaitCloseCampFlag(bResult, nLeftSeconds)
	if nLeftSeconds == 0 or not bResult then
		RegisterBreatheEvent("WAIT_CLOSE_CAMP", nil)
		nEndTime = 0
		OutputMessage("MSG_SYS", g_tStrings.STR_SYS_MSG_CLOSE_CAMP_FALG_FAIL)
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SYS_MSG_CLOSE_CAMP_FALG_FAIL)
		return
	end

	nEndTime = GetCurrentTime() + nLeftSeconds
	RegisterBreatheEvent("WAIT_CLOSE_CAMP", CloseCampCountdown)
end

RegisterEvent("CAMP_RESULT", OnCampResult)

RegisterEvent("PLAYER_ENTER_SCENE", OnUpdateCampPanel)
RegisterEvent("CHANGE_CAMP", OnUpdateCampPanel)

RegisterEvent("CHANGE_CAMP_FLAG", OnChangeCampFlag)
