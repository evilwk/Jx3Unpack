
BattleFieldPanel = 
{
	tEnterState = {},
	bBattleFieldEnd = false,
}

RegisterCustomData("BattleFieldPanel.tEnterState")

local INI_FILE_PATH = "UI/Config/Default/BattleFieldPanel.ini"
local BATTLE_FIELD_SIDE = 
{
	[0] = {"CheckBox_All", 12, },
	[1] = {"CheckBox_Force1", 15},
	[2] = {"CheckBox_Force2", 13},
	[3] = {"CheckBox_Force3", 14},
	[4] = {"CheckBox_Force4", 12},
}

function BattleFieldPanel.OnFrameCreate()
	this:RegisterEvent("BATTLE_FIELD_SYNC_STATISTICS")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("UI_SCALED")
	
	BattleFieldPanel.UpdateAnchor(this)
end

function BattleFieldPanel.OnEvent(szEvent)
	if szEvent == "BATTLE_FIELD_SYNC_STATISTICS" then
		BattleFieldPanel.OnSyncStatistics(this)
	elseif szEvent == "UI_SCALED" then
		BattleFieldPanel.UpdateAnchor(this)
	elseif szEvent == "SYS_MSG" then
		if arg0 == "UI_OME_BANISH_PLAYER" then
			if arg1 == BANISH_CODE.MAP_REFRESH or arg1 == BANISH_CODE.NOT_IN_MAP_OWNER_PARTY then
				this.nBanishTime = arg2 * 1000 + GetTickCount()
			elseif arg1 == BANISH_CODE.CANCEL_BANISH then
				this.nBanishTime = nil
			end
		end
	end
end

function BattleFieldPanel.OnFrameBreathe()
	local hBanishText = this:Lookup("", "Text_Banish")
	local nCurTime = GetTickCount()
	if this.nBanishTime and this.nBanishTime > nCurTime  then
		local nTime = math.floor((this.nBanishTime - nCurTime) / 1000)
		hBanishText:SetText(FormatString(g_tStrings.STR_BATTLEFIELD_BANISH, nTime .. g_tStrings.STR_BUFF_H_TIME_S))
		hBanishText:Show()
	else
		this.nBanishTime = nil
		hBanishText:SetText("")
		hBanishText:Hide()
	end
end

local function MsgBox_ForceLeaveBattle()
	local msg =
	{
		szMessage = g_tStrings.STR_SURE_LEAVE_BATTLE,
		szName = "ForceLeaveBattle",
		{ szOption = g_tStrings.STR_HOTKEY_SURE, 
		  fnAction = function() 
			LeaveBattleField() 
		  end
		},
		{ szOption = g_tStrings.STR_HOTKEY_CANCEL},		
	}
	MessageBox(msg)
end

function BattleFieldPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseBattleFieldPanel()
	elseif szName == "Btn_Leave" then
		if BattleFieldPanel.bBattleFieldEnd then
			CloseBattleFieldPanel()
			LeaveBattleField()
		else
			CloseBattleFieldPanel() 
			MsgBox_ForceLeaveBattle()
		end
	end
end

function BattleFieldPanel.OnItemLButtonClick()
end

function BattleFieldPanel.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Handle_Player" then
		local tData = this.tData or {}
		local hFrame = this:GetRoot()
		local player = GetClientPlayer()
		if tData.nBattleFieldSide == hFrame.nClientPlayerSide and 
		   tData.dwPlayerID ~= player.dwID then
			local menu = 
			{
				{szOption = g_tStrings.STR_REPORT_GUAJI, 
					fnAction = function() 
						BattleField_ReprotRobot(tData.dwPlayerID) 
					end
				},
			}
			PopupMenu(menu)
		end
	end
end

function BattleFieldPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()

	local _, _, szIndex = string.find(szName, "CheckBox_(%d+)")
	if szIndex then
		BattleFieldPanel.UpdateStatisticsPage(hFrame, hFrame.nCurrentSide, tonumber(szIndex), false)
		return
	end
	
	local hHelpPage = hFrame:Lookup("Wnd_HelpPage")
	local hStatisticsPage = hFrame:Lookup("Wnd_StatisticsPage")
	
	local hFrame = this:GetRoot()
	if szName == "CheckBox_Help" then
		BattleFieldPanel.UpdateHelpPage(hFrame)
		hHelpPage:Show()
		hStatisticsPage:Hide()
		hFrame.szCurrentPage = "Wnd_HelpPage"
	else
		hFrame:Lookup("CheckBox_Help"):Check(false)
		hHelpPage:Hide()
		hStatisticsPage:Show()
		hFrame.szCurrentPage = "Wnd_StatisticsPage"
	end
	
	for nSide, tData in pairs(BATTLE_FIELD_SIDE) do
		if tData[1] == szName then
			BattleFieldPanel.UpdateStatisticsPage(hFrame, nSide, hFrame.nSortIndex, hFrame.bAscending)
		else
			hFrame:Lookup(tData[1]):Check(false)
		end
	end
end

function BattleFieldPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	local _, _, szIndex = string.find(szName, "CheckBox_(%d+)")
	if szIndex then
		local hFrame = this:GetRoot()
		BattleFieldPanel.UpdateStatisticsPage(hFrame, hFrame.nCurrentSide, tonumber(szIndex), true)
	end
end

function BattleFieldPanel.UpdateAnchor(hFrame)
	hFrame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	hFrame:CorrectPos()
end

function BattleFieldPanel.OnSyncStatistics(hFrame)
	local tSideTable = {}
	hFrame.tStatistics = {}
	
	local tStatistics = GetBattleFieldStatistics()
	if not tStatistics then
		return
	end
	
	local hPlayer = GetClientPlayer()
	for dwPlayerID, tData in pairs(tStatistics) do
		if tData.Name and tData.BattleFieldSide >= 0 then	-- maybe offline
			local tDataLine = 
			{ 
				tData.ForceID, 
				tData.Name, 
				tData[PQ_STATISTICS_INDEX.KILL_COUNT],
				tData[PQ_STATISTICS_INDEX.DEATH_COUNT],
				tData[PQ_STATISTICS_INDEX.DECAPITATE_COUNT],
				tData[PQ_STATISTICS_INDEX.SOLO_COUNT],
				tData[PQ_STATISTICS_INDEX.HARM_OUTPUT],
				tData[PQ_STATISTICS_INDEX.TREAT_OUTPUT],
				tData[PQ_STATISTICS_INDEX.INJURY],
				tData[PQ_STATISTICS_INDEX.SPECIAL_OP_1],
				tData[PQ_STATISTICS_INDEX.SPECIAL_OP_2],
				tData[PQ_STATISTICS_INDEX.SPECIAL_OP_3],
				tData[PQ_STATISTICS_INDEX.SPECIAL_OP_4],
				tData[PQ_STATISTICS_INDEX.AWARD_1],
				tData[PQ_STATISTICS_INDEX.AWARD_2],
				tData[PQ_STATISTICS_INDEX.AWARD_3],
			}
			tDataLine.dwPlayerID = dwPlayerID
			tDataLine.nBattleFieldSide = tData.BattleFieldSide + 1 	-- begin with 0 to begin with 1
			table.insert(hFrame.tStatistics, tDataLine)
						
			if tDataLine.nBattleFieldSide then
				if tSideTable[tDataLine.nBattleFieldSide] then
					tSideTable[tDataLine.nBattleFieldSide] = tSideTable[tDataLine.nBattleFieldSide] + 1
				else
					tSideTable[tDataLine.nBattleFieldSide] = 1
				end
				
				if tSideTable[0] then
					tSideTable[0] = tSideTable[0] + 1
				else
					tSideTable[0] = 1
				end
			end
			
			if hPlayer.dwID == dwPlayerID then
				hFrame.nClientPlayerSide = tDataLine.nBattleFieldSide
				hFrame.nRewardMoney = tData[PQ_STATISTICS_INDEX.AWARD_MONEY]
				hFrame.nRewardExp = tData[PQ_STATISTICS_INDEX.AWARD_EXP]
			end
		end
	end

	local szPlayerCount = nil
	for i = 1, MAX_BATTLE_FIELD_SIDE_COUNT do
		if hFrame.tGroupInfo[i] and tSideTable[i] then
			if not szPlayerCount then
				szPlayerCount = g_tStrings.STR_BATTLEFIELD_PLAYER_COUNT .. "  "
			else
				szPlayerCount = szPlayerCount .. "  /  "
			end
			szPlayerCount = szPlayerCount .. hFrame.tGroupInfo[i] .. " " .. tSideTable[i]
		end
	end
	if szPlayerCount then
		hFrame:Lookup("Wnd_StatisticsPage", "Text_PlayerNumber"):SetText(szPlayerCount)
	end
		
	local _, _, nBeginTime, nEndTime  = GetBattleFieldPQInfo()
	local nCurrentTime = GetCurrentTime()
	if nBeginTime and nBeginTime > 0 then
		local nTime = 0
		if nEndTime ~= 0 and nCurrentTime > nEndTime then
			nTime = nEndTime - nBeginTime
		else
			nTime = nCurrentTime - nBeginTime
		end
		local szTime = GetTimeText(nTime)
		hFrame:Lookup("Wnd_StatisticsPage", "Text_Time"):SetText(g_tStrings.STR_BATTLEFIELD_TIME_USED .. " " .. szTime)
	end
	
	if nEndTime and nEndTime > 0 then
		local nTime = nEndTime - nCurrentTime
		if nTime < 0 then
			nTime = 0
		end
		local szTime = GetTimeText(nTime)
		hFrame:Lookup("Wnd_StatisticsPage", "Text_WarningTime"):SetText(g_tStrings.STR_BATTLEFIELD_TIME_LEFT .. " " .. szTime)
	end
	
	if hFrame.szCurrentPage == "Wnd_StatisticsPage" then
		BattleFieldPanel.UpdateStatisticsPage(hFrame, hFrame.nCurrentSide, hFrame.nSortIndex, hFrame.bAscending)
	end
end

function BattleFieldPanel.SetPQOption(hListItem, nIndex, nData, nIcon, nFontID)
	local hText = hListItem:Lookup("Text_S" .. nIndex)
	local hImage = hListItem:Lookup("Image_S" .. nIndex)
	if nIcon and nData > 0 then
		hText:SetFontScheme(nFontID)
		hText:SetText(g_tStrings.STR_MUL .. nData)
		hText:Show()
		if nIcon > 0 then
			hImage:SetFrame(nIcon)
			hImage:Show()
		else
			hImage:Hide()
		end
	else
		hText:Hide()
		hImage:Hide()
	end		
end

function BattleFieldPanel.FormatRewardText(nData, nIcon, nFontID)
	local szText = ""
	if nData and nData > 0 then
		if nIcon and nIcon >= 0 then
			szText = szText .. GetFormatImage("ui/Image/UICommon/CommonPanel2.UITex", nIcon)
		end
		szText = szText .. GetFormatText(" " .. nData .. "  ", nFontID)
	end
	return szText
end

function BattleFieldPanel.UpdateStatisticsPage(hFrame, nSide, nSortIndex, bAscending)
	local hList = hFrame:Lookup("Wnd_StatisticsPage", "Handle_List")
	hList:Clear()
	
	hFrame.nCurrentSide = nSide
	
	if not hFrame.tStatistics then
		ApplyBattleFieldStatistics()
		return
	end
	
	if hFrame.nSortIndex then
		local hImageOrder = hFrame:Lookup("Wnd_StatisticsPage/CheckBox_" .. hFrame.nSortIndex):Lookup("", "Image_Order" .. hFrame.nSortIndex)
		if hImageOrder then
			hImageOrder:Hide()
		end
		hFrame.nSortIndex = nil
	end
	
	if nSortIndex then
		local nFrame = 127
		if bAscending then
			nFrame = 131
		end
		local hImageOrder = hFrame:Lookup("Wnd_StatisticsPage/CheckBox_" .. nSortIndex):Lookup("", "Image_Order" .. nSortIndex)
		if hImageOrder then
			hImageOrder:SetFrame(nFrame)
			hImageOrder:Show()
		end
		
		hFrame.nSortIndex = nSortIndex
		hFrame.bAscending = bAscending
		
		local funcSort = function(tLeft, tRight)
			if bAscending then
				return tLeft[nSortIndex] < tRight[nSortIndex]
			else
				return tLeft[nSortIndex] > tRight[nSortIndex]
			end
		end
		table.sort(hFrame.tStatistics, funcSort)
	end

	local hPlayer = GetClientPlayer()
	local dwClientPlayerID = hPlayer.dwID
	local nRewardIcon1, nRewardIcon2, nRewardIcon3 = Table_GetBattleFieldRewardIconInfo(hPlayer.GetScene().dwMapID)

	local TEXT_HANDLE_LIST = { "Text_Name", "Text_Kill1", "Text_Dead", "Text_Kill2", "Text_Solo", "Text_Damage", "Text_Health", "Text_Injured"}
	for nIndex, tData in ipairs(hFrame.tStatistics) do
		if hFrame.nCurrentSide == 0 or tData.nBattleFieldSide == hFrame.nCurrentSide then
			local hListItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_Player")
			
			local nFontID = 162
			if dwClientPlayerID == tData.dwPlayerID then
				nFontID = 163
			end

			-- base info
			local szPath, nFrame = GetForceImage(tData[1])
			hListItem:Lookup("Image_School"):FromUITex(szPath, nFrame)
			
			for nIndex, szHandle in ipairs(TEXT_HANDLE_LIST) do
				local hText = hListItem:Lookup(szHandle)
				hText:SetFontScheme(nFontID)
				hText:SetText(tData[nIndex + 1])
			end
		
			-- pq option
			BattleFieldPanel.SetPQOption(hListItem, 1, tData[10], hFrame.nPQOptionIcon1, nFontID)
			BattleFieldPanel.SetPQOption(hListItem, 2, tData[11], hFrame.nPQOptionIcon2, nFontID)
			BattleFieldPanel.SetPQOption(hListItem, 3, tData[12], hFrame.nPQOptionIcon3, nFontID)
			BattleFieldPanel.SetPQOption(hListItem, 4, tData[13], hFrame.nPQOptionIcon4, nFontID)
	
			-- reward
			local hHandleReward = hListItem:Lookup("Handle_Reward")
			hHandleReward:Clear()
			if BattleFieldPanel.bBattleFieldEnd then
				local szReward = ""
				szReward = szReward .. BattleFieldPanel.FormatRewardText(tData[14], nRewardIcon1, nFontID)
				szReward = szReward .. BattleFieldPanel.FormatRewardText(tData[15], nRewardIcon2, nFontID)
				szReward = szReward .. BattleFieldPanel.FormatRewardText(tData[16], nRewardIcon3, nFontID)
				
				hHandleReward:AppendItemFromString(szReward)
				hHandleReward:FormatAllItemPos()
				hHandleReward:Show()
			else
				hHandleReward:Hide()
			end
						
			-- backgroud image
			if tData.nBattleFieldSide then
				hListItem:Lookup("Image_Bg"):SetFrame(BATTLE_FIELD_SIDE[tData.nBattleFieldSide][2])
			end
			hListItem.tData = tData
		end
	end
	BattleFieldPanel.UpdateScrollInfo(hList)
	
	-- money reward	
	local hMoneyReward = hFrame:Lookup("Wnd_StatisticsPage", "Handle_MoneyReward")
	if BattleFieldPanel.bBattleFieldEnd and hFrame.nRewardMoney and hFrame.nRewardMoney > 0 then
		local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(hFrame.nRewardMoney)
		local hTextGold = hMoneyReward:Lookup("Text_Gold")
		local hImageGold = hMoneyReward:Lookup("Image_Gold")
		if nGold and nGold > 0 then
			hTextGold:SetText(nGold)
			hTextGold:Show()
			hImageGold:Show()
		else
			hTextGold:Hide()
			hImageGold:Hide()					
		end
		
		local hTextSilver = hMoneyReward:Lookup("Text_Silver")
		local hImageSilver = hMoneyReward:Lookup("Image_Silver")
		if nSilver and nSilver > 0 then
			hTextSilver:SetText(nSilver)
			hTextSilver:Show()
			hImageSilver:Show()
		else
			hTextSilver:Hide()
			hImageSilver:Hide()					
		end
		
		local hTextCopper = hMoneyReward:Lookup("Text_Copper")
		local hImageCopper = hMoneyReward:Lookup("Image_Copper")
		if nCopper and nCopper > 0 then
			hTextCopper:SetText(nCopper)
			hTextCopper:Show()
			hImageCopper:Show()
		else
			hTextCopper:Hide()
			hImageCopper:Hide()					
		end

		hMoneyReward:Show()
	end
	
	-- exp reward
	local hTextExp = hFrame:Lookup("Wnd_StatisticsPage", "Text_Exp")
	if BattleFieldPanel.bBattleFieldEnd and hFrame.nRewardExp and hFrame.nRewardExp > 0 then
		hTextExp:SetText(g_tStrings.STR_BATTLEFIELD_REWARD_EXP .. hFrame.nRewardExp)
		hTextExp:Show()
	end
end

function BattleFieldPanel.UpdateHelpPage(hFrame)
	local hHandleHelpPage = hFrame:Lookup("Wnd_HelpPage", "")
	local szHelpImage, szHelpText = Table_GetBattleFieldHelpInfo(GetClientPlayer().GetScene().dwMapID)

	local hHandleHelpText = hHandleHelpPage:Lookup("Handle_HelpText")
	hHandleHelpText:Clear()
	if szHelpText then
		hHandleHelpText:AppendItemFromString(szHelpText)
		hHandleHelpText:FormatAllItemPos()
	end
	
	local hIamgeHelp = hHandleHelpPage:Lookup("Image_Help")
	if szHelpImage and #szHelpImage > 0 then
		hIamgeHelp:FromTextureFile(szHelpImage)
		hIamgeHelp:Show()
	else
		hIamgeHelp:Hide()
	end
end

function BattleFieldPanel.UpdateFrame(hFrame)
	local hPlayer = GetClientPlayer()

	local hScene = hPlayer.GetScene()
	local dwMapID = hScene.dwMapID
	hFrame:Lookup("", "Text_Title"):SetText(GetBattleFieldQueueName(dwMapID, hScene.nCopyIndex))

	hFrame.tGroupInfo = Table_GetBattleFieldGroupInfo(dwMapID)
	for i = 0, MAX_BATTLE_FIELD_SIDE_COUNT do
		local hCheckBoxSide = hFrame:Lookup(BATTLE_FIELD_SIDE[i][1])
		if hFrame.tGroupInfo[i] and #hFrame.tGroupInfo[i] > 0 then
			hCheckBoxSide:Lookup("", ""):Lookup(0):SetText(hFrame.tGroupInfo[i])
			hCheckBoxSide:Show()
		elseif i == 0 then
			hCheckBoxSide:Show()
		else
			hCheckBoxSide:Hide()
		end
	end

	local tPQOptionInfo = Table_GetBattleFieldPQOptionInfo(dwMapID)
	local UpdatePQOption = function(nIndex)
		local hCheckBox = hFrame:Lookup("Wnd_StatisticsPage/CheckBox_" .. (nIndex + 9)) -- checkbox index
		local szNameParam = "szPQOptionName" .. nIndex
		local szIconParam = "nPQOptionIcon" .. nIndex
		if tPQOptionInfo[szNameParam] and #tPQOptionInfo[szNameParam] > 0 then
			hCheckBox:Lookup("", ""):Lookup(0):SetText(tPQOptionInfo[szNameParam])
			hCheckBox:Show()
			hFrame[szIconParam] = tPQOptionInfo[szIconParam]
		else
			hCheckBox:Hide()
			hFrame[szIconParam] = nil
		end
	end
	UpdatePQOption(1)
	UpdatePQOption(2)
	UpdatePQOption(3)
	UpdatePQOption(4)
	
	hFrame:Lookup("Wnd_StatisticsPage", "Text_Exp"):Hide()
	hFrame:Lookup("Wnd_StatisticsPage", "Handle_MoneyReward"):Hide()
	
	-- leave battlefiled button
	local hQuitButton = hFrame:Lookup("Wnd_StatisticsPage/Btn_Leave")
	local hBtnText = hQuitButton:Lookup("", ""):Lookup("Text_Leave")
	if BattleFieldPanel.bBattleFieldEnd then
		hBtnText:SetText(g_tStrings.STR_LEAVE_BATTLEFIELD)
	else
		hBtnText:SetText(g_tStrings.STR_FORCE_LEAVE_BATTLEFIELD)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Scrollbar

function BattleFieldPanel.UpdateScrollInfo(hList)
	hList:FormatAllItemPos()
	
	local _, nItemHeight = hList:GetAllItemSize()
	local _, nHeight = hList:GetSize()
	
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Wnd_StatisticsPage/Scroll_SP")
	local nCountStep = math.ceil((nItemHeight - nHeight) / 10)
	hScroll:SetStepCount(nCountStep)
	hScroll:SetScrollPos(hList.nScrollPos)
	if nCountStep > 0 then
		hFrame:Lookup("Wnd_StatisticsPage/Btn_SPUp"):Show()
		hFrame:Lookup("Wnd_StatisticsPage/Btn_SPDown"):Show()
		hScroll:Show()
	else
		hFrame:Lookup("Wnd_StatisticsPage/Btn_SPUp"):Hide()
		hFrame:Lookup("Wnd_StatisticsPage/Btn_SPDown"):Hide()
		hScroll:Hide()
	end
end

function BattleFieldPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_SPUp" then
		this:GetRoot():Lookup("Wnd_StatisticsPage/Scroll_SP"):ScrollPrev(1)
	elseif szName == "Btn_SPDown" then
		this:GetRoot():Lookup("Wnd_StatisticsPage/Scroll_SP"):ScrollNext(1)
	end
end

function BattleFieldPanel.OnLButtonDown()
	BattleFieldPanel.OnLButtonHold()
end

function BattleFieldPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Scroll_SP" then
		if nCurrentValue == 0 then
			hFrame:Lookup("Wnd_StatisticsPage/Btn_SPUp"):Enable(0)
		else
			hFrame:Lookup("Wnd_StatisticsPage/Btn_SPUp"):Enable(1)
		end
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Wnd_StatisticsPage/Btn_SPDown"):Enable(0)
		else
			hFrame:Lookup("Wnd_StatisticsPage/Btn_SPDown"):Enable(1)
		end		
	    hFrame:Lookup("Wnd_StatisticsPage", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	end
end

function BattleFieldPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local hScroll = this:GetRoot():Lookup("Wnd_StatisticsPage/Scroll_SP")
	if hScroll:IsVisible() then
		hScroll:ScrollNext(nDistance)
	end
	return true	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function OpenBattleFieldPanel(bDiableSound, bHelpPage)
	local hFrame = Station.Lookup("Topmost1/BattleFieldPanel")
	if not hFrame then
		hFrame = Wnd.OpenWindow("BattleFieldPanel")
	end
	
	hFrame.tStatistics = nil
	BattleFieldPanel.UpdateFrame(hFrame, bHelpPage)
	if bHelpPage then
		hFrame:Lookup("CheckBox_Help"):Check(true)
	else
		hFrame:Lookup(BATTLE_FIELD_SIDE[0][1]):Check(true)
	end

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseBattleFieldPanel(bDisableSound)
	local hFrame = Station.Lookup("Topmost1/BattleFieldPanel")
	if not hFrame then
		return
	end
	
	Wnd.CloseWindow(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function SwitchBattleFieldPanel(bDisableSound)
	if IsBattleFieldPanelOpen() then
		CloseBattleFieldPanel(bDisableSound)
	else
		OpenBattleFieldPanel(bDiableSound)
	end
end

function IsBattleFieldPanelOpen()
	local hFrame = Station.Lookup("Topmost1/BattleFieldPanel")
	if hFrame and hFrame:IsVisible() then
		return true
	else
		return false
	end
end

local function OnPlayerEnterScene()
	local hPlayer = GetClientPlayer()
	if hPlayer and hPlayer.dwID == arg0 then
		if IsInBattleField() then
			ClosePartyRecruitPanel()
			BattleFieldPanel.bBattleFieldEnd = false
			
			local hPlayer = GetClientPlayer()
			local hScene = hPlayer.GetScene()
			local dwMapID = hScene.dwMapID
			if not BattleFieldPanel.tEnterState[dwMapID] then
				OpenBattleFieldPanel(true, true)
				BattleFieldPanel.tEnterState[dwMapID] = true
			end
		else
			CloseBattleFieldPanel()
		end
	end
end

local function OnBattleFieldEnd()
	OutputMessage("MSG_SYS", g_tStrings.STR_BATTLEFIELD_END)
	BattleFieldPanel.bBattleFieldEnd = true
	OpenBattleFieldPanel()
end

function BattleField_SetCloseMapInfo(dwMapID, nTime)
    BattleFieldPanel.dwCloseMapID = dwMapID
    if nTime then
        BattleFieldPanel.nEndCloseFrame = GetTickCount() + (nTime * 1000);
    else
        BattleFieldPanel.nEndCloseFrame = nil
    end
end

function BattleField_GetCloseMapInfo()
    return BattleFieldPanel.dwCloseMapID, BattleFieldPanel.nEndCloseFrame
end

function BattleField_IsCanReportPlayer(szRoleName)
	if not IsInBattleField() then
		return
	end
	
	local player = GetClientPlayer()
	local hTeam = GetClientTeam()
	for nGroupID = 0, hTeam.nGroupNum - 1 do
		local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
		for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
			local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
			if tMemberInfo and dwMemberID ~= player.dwID and 
			   tMemberInfo.szName == szRoleName then
				return dwMemberID
			end
		end
	end
	return
end

RegisterEvent("PLAYER_ENTER_SCENE", OnPlayerEnterScene)
RegisterEvent("BATTLE_FIELD_END", OnBattleFieldEnd)