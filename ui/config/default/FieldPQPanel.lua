local INI_PATH =  "ui/Config/Default/FieldPQPanel.ini"
local FIELD_PQ_STATE_NOT_START = 1
local FIELD_PQ_STATE_UNDER_WAY = 2
local FIELD_PQ_STATE_FAIL = 3
local FIELD_PQ_STATE_FINISH = 4
local FIELD_TIME_MINUTE = 60
local FIELD_TIME_SECOND = 1000

local tFontScheme = 
{
	[1] = 0,
	[2] = 27,
	[3] = 27,
	[4] = 27,
}

FieldPQPanel = {}

FieldPQPanel.bMinimize = false
RegisterCustomData("FieldPQPanel.bMinimize")

function FieldPQPanel.OnFrameCreate()
	local hCheckMinimize = this:Lookup("CheckBox_Minimize")
	hCheckMinimize:Check(FieldPQPanel.bMinimize)
	FieldPQPanel.Minimize(this)
end

function FieldPQPanel.OnLButtonDown()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_Introduce" then
		local argSave = arg0
		local dwPQTemplateID = hFrame.dwPQTemplateID
		local nStep = hFrame.nStep
		if not dwPQTemplateID then
			dwPQTemplateID = 0
			nStep = 0
		elseif not nStep then
			nStep = 0
		end
		arg0 = "FieldPQ/" ..dwPQTemplateID .. "/" .. nStep
		FireEvent("EVENT_LINK_NOTIFY")
		arg0 = argSave
	end
end

function FieldPQPanel.OnFrameBreathe()
	if this.nStartTime then
		local bUpdate = false
		local nPasTime = (GetTickCount() - this.nStartTime) / FIELD_TIME_SECOND
		if this.nTime then
			this.nLeftTime = this.nTime - nPasTime
			
			bUpdate = FieldPQPanel.IsRefreshTime(this.nLeftTime, this.nShowTime)
		elseif this.nNextTime then
			this.nLeftNextTime = this.nNextTime - nPasTime
			bUpdate = FieldPQPanel.IsRefreshTime(this.nLeftNextTime, this.nNextShowTime)
		end
		if bUpdate then
			FieldPQPanel.UpdateFrame(this)
		end
	end
	--[[
	if this.nState and this.nState == FIELD_PQ_STATE_FINISH then
		FieldPQPanel.UpdatePQGPS(this)
	end
	--]]
end

function FieldPQPanel.OnCheckBoxCheck()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		FieldPQPanel.bMinimize = true
		FieldPQPanel.Minimize(hFrame)
	end
end

function FieldPQPanel.OnCheckBoxUncheck()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		FieldPQPanel.bMinimize = false
		FieldPQPanel.Minimize(hFrame)
	end
end

function FieldPQPanel.Minimize(hFrame)
	local hBtnIntroduce = hFrame:Lookup("Btn_Introduce")
	local hImageBg = hFrame:Lookup("", "Image_BG")
	local hState = hFrame:Lookup("", "Handle_State")
	local hStep = hFrame:Lookup("", "Handle_PQStep")
	local hInfo = hFrame:Lookup("", "Handle_PQInfo")
	if FieldPQPanel.bMinimize then
		hImageBg:Hide()
		hState:Hide()
		hStep:Hide()
		hInfo:Hide()
		hBtnIntroduce:Hide()
	else
		hImageBg:Show()
		hState:Show()
		hStep:Show()
		hInfo:Show()
		hBtnIntroduce:Show()
	end
end

function FieldPQPanel.IsRefreshTime(nTime, nShowTime)
	local nNowTime = math.ceil(nTime / FIELD_TIME_MINUTE)
	if nNowTime == nShowTime then
		return false
	end
	
	return true 
end

function FieldPQPanel.UpdateFrame(hFrame)
	FieldPQPanel.UpdateInfo(hFrame)
end

function FieldPQPanel.UpdateState(hFrame)
	local hTotal = hFrame:Lookup("", "")
	local hState = hTotal:Lookup("Handle_State/Text_State")
	hState:SetFontScheme(tFontScheme[hFrame.nState])
	hState:SetText(g_tStrings.tFieldPQState[hFrame.nState])
	local hTime = hTotal:Lookup("Handle_State/Text_Time")
	hTime:Hide()
	if hFrame.nState == FIELD_PQ_STATE_UNDER_WAY then
		hTime:Show()
		local szTime, nFontScheme, nShowTime = FieldPQPanel.FormatTime(hFrame.nLeftTime)
		hFrame.nShowTime = nShowTime
		hTime:SetFontScheme(nFontScheme)                                         
		hTime:SetText(szTime)
	end
end

function FieldPQPanel.UpdateInfo(hFrame)
	local hTotal = hFrame:Lookup("", "")
	local tTrace = hFrame.tPQTrace
	local tPQTraceString = Table_GetFieldPQString(hFrame.dwPQTemplateID, hFrame.nStep)
	local hStep = hTotal:Lookup("Handle_PQStep/Text_PMsg")
	local hInfo = hTotal:Lookup("Handle_PQInfo")
	FieldPQPanel.UpdateState(hFrame)
	if hFrame.nState == FIELD_PQ_STATE_NOT_START then
		hStep:SetText("_/_")
	else
		hStep:SetText(hFrame.nStep .. "/" .. hFrame.nTotalStep)
	end
	
	hInfo:Clear()
	if hFrame.nState == FIELD_PQ_STATE_UNDER_WAY or hFrame.nState == FIELD_PQ_STATE_FAIL then
		FieldPQPanel.AppendPQTrace(hInfo, g_tStrings.FIELD_PQ_TRACE, hFrame.tPQTrace, tPQTraceString)
	elseif hFrame.nState == FIELD_PQ_STATE_FINISH then
		FieldPQPanel.AppendPQStatic(hInfo, "", hFrame.tPQStatistic, hFrame.nScore)
	end
	--[[
	FieldPQPanel.UpdatePQGPS(hFrame)
	--]]
	
	hInfo:FormatAllItemPos()
	local fInfoWidth = hInfo:GetSize()
	local _, fInfoHeight = hInfo:GetAllItemSize() 
	hInfo:SetSize(fInfoWidth, fInfoHeight)
	local _, fInfoY = hInfo:GetRelPos()
	
	local fTotalWidth = hTotal:GetSize()
	local fTotalHeight = fInfoY + fInfoHeight + 10
	hTotal:SetSize(fTotalWidth, fTotalHeight)
	local hImgBg = hTotal:Lookup("Image_BG")
	hImgBg:SetSize(fTotalWidth, fTotalHeight)
end

function FieldPQPanel.AppendPQTrace(hHandle, szTitle, tTrace, tPQTraceString)
	local szTitle = GetFormatText(szTitle .. "\n", 0)
	hHandle:AppendItemFromString(szTitle)
	local nNeed
	for nIndex, nHave in ipairs(tTrace.KillNpc) do
		local szName = Table_GetNpcTemplateName(tPQTraceString["nKillNpcTemplateID" .. nIndex])
		nNeed = tPQTraceString["nAmount" .. nIndex]
		nHave = math.min(nHave, nNeed)
		local szText = GetFormatText(szName .. " " .. nHave .. "/" .. nNeed .. "\n", 27)
		hHandle:AppendItemFromString(szText)
	end
	
	for nIndex, nHave in ipairs(tTrace.PQValue) do
		local szName = tPQTraceString["szPQValueStr" .. nIndex]
		nNeed = tPQTraceString["nPQvalue" .. nIndex]
		nHave = math.min(nHave, nNeed)
		local szText = GetFormatText(szName .. " " .. nHave .. "/" .. nNeed .. "\n", 27)
		hHandle:AppendItemFromString(szText)
	end
	
	hHandle:FormatAllItemPos()
end

function FieldPQPanel.UpdatePQGPS(hFrame)
	local hGPS = hFrame:Lookup("", "Handle_Compass")
	hGPS:Hide()
	if hFrame.nState ~= FIELD_PQ_STATE_FINISH then
		return
	end
	local hPoint = hGPS:Lookup("Image_PointGreen")
	QuestTraceList.UpdataQuestGPSTarget(hPoint, hFrame.fPQX, hFrame.fPQY)
	local hSelf = hGPS:Lookup("Image_Player")
	QuestTraceList.UpdateQuestGPSSelf(hSelf)
	hGPS:FormatAllItemPos()
	hGPS:Show()
end

function FieldPQPanel.AppendPQStatic(hHandle, szTitle, tPQStatistic, nScore)
	local hFrame = hHandle:GetRoot()
	local szTitle = GetFormatText(szTitle .. "\n", 0)
	local szTime, nFont, nNextShowTime = FieldPQPanel.FormatTime(hFrame.nLeftNextTime)
	hFrame.nNextShowTime = nNextShowTime
	local szNextTime = GetFormatText(g_tStrings.FIELD_PQ_NEXT_TIME) .. GetFormatText(szTime .. "\n\n", nFont)
	-- szNextTime = szNextTime .. GetFormatText(g_tStrings.FIELD_PQ_GUID .. "\n\n")
	hHandle:AppendItemFromString(szNextTime)
	local hTittle = hHandle:AppendItemFromIni(INI_PATH, "Handle_ScoreMsg", "Handle_ScoreTitle")
	hTittle:Lookup("Text_Rank"):SetText(g_tStrings.FIELD_PQ_RANK)
	hTittle:Lookup("Text_Name"):SetText(g_tStrings.STR_GUILD_NAME)
	hTittle:Lookup("Text_School"):SetText(g_tStrings.STR_GUILD_SCHOOL)
	hTittle:Lookup("Text_Score"):SetText(g_tStrings.FIELD_PQ_SCORE)
	hTittle:Show()
	
	for nIndex, tPlayer in ipairs(tPQStatistic) do
		local hTemp = hHandle:AppendItemFromIni(INI_PATH, "Handle_ScoreMsg", "Handle_Statistic" .. nIndex)
		hTemp:Lookup("Text_Rank"):SetText(nIndex)
		hTemp:Lookup("Text_Name"):SetText(tPlayer[1])
		hTemp:Lookup("Text_School"):SetText(g_tStrings.tForceTitle[tPlayer[2]])
		hTemp:Lookup("Text_Score"):SetText(tPlayer[3])
		hTemp:Show()
	end
	
	local hPlayer = GetClientPlayer()
	if hPlayer then
		local hSelf = hHandle:AppendItemFromIni(INI_PATH, "Handle_ScoreMsg", "Handle_StatisticSelf")
		hSelf:Lookup("Text_Rank"):SetText(g_tStrings.MENTOR_SELF)
		hSelf:Lookup("Text_Name"):SetText(hPlayer.szName)
		hSelf:Lookup("Text_School"):SetText(g_tStrings.tForceTitle[hPlayer.dwForceID])
		hSelf:Lookup("Text_Score"):SetText(nScore)
		hSelf:Show()
	end
	hHandle:FormatAllItemPos()
end

function FieldPQPanel.FormatTime(nTime)
	local szTime = ""
	
	local nShowTime = math.ceil(nTime / FIELD_TIME_MINUTE)
	if nShowTime <= 1 then                                         
		szTime = "<1"                                         
		nFonsScheme = 196
	else                                         
		szTime = nShowTime                                         
		nFonsScheme = 198                                     
	end                                         
	szTime = szTime .. g_tStrings.STR_BUFF_H_TIME_M     
	
	return szTime, nFonsScheme, nShowTime
end 
   
   
-- nState 未开始1，需要参数 dwPQTemplateID, nStepID, nState 其他可为nil
-- nState 进行中2  需要参数 dwPQTemplateID, nStepID, nState, nTime, tPQTrace,其他可为nil
-- nstate 失败 3  需要参数 dwPQTemplateID, nStepID, nState, tPQTrace, 其他可为nil
-- nState 完成 4 需要参数 dwPQTemplateID, nStepID, nState, tPQStatistic, nScore, nNextTime 其他可为nil
function OpenFieldPQPanel(dwPQTemplateID, nStepID, nState, nTime, tPQTrace, tPQStatistic, nScore, nNextTime, bDisableSound)
	if not IsFieldPQPanelOpened() then
		Wnd.OpenWindow("FieldPQPanel")
	end
	local hFrame = Station.Lookup("Normal/FieldPQPanel")
	hFrame.dwPQTemplateID = dwPQTemplateID
	hFrame.nStep = nStepID
	hFrame.nState = nState
	hFrame.nTime = nTime
	hFrame.nLeftTime = nTime
	hFrame.tPQTrace = tPQTrace
	hFrame.tPQStatistic = tPQStatistic
	hFrame.nScore = nScore
	hFrame.nNextTime = nNextTime
	hFrame.nLeftNextTime = nNextTime
	hFrame.nStartTime = GetTickCount()
	local tFieldPQ = Table_GetFieldPQ(dwPQTemplateID)
	hFrame.nTotalStep = tFieldPQ.nTotalStep
	hFrame.fPQX = tFieldPQ.fX
	hFrame.fPQY = tFieldPQ.fY
	FieldPQPanel.UpdateFrame(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsFieldPQPanelOpened()
	local hFrame = Station.Lookup("Normal/FieldPQPanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

function CloseFieldPQPanel(dwPQTemplateID, bDisableSound)
	Wnd.CloseWindow("FieldPQPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end


