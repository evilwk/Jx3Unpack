CampActiveTime = {nCount = 1, }

local tStepTime = {
	[1] = {nCycleTime = 39600}, 		--休息时间			（11小时,2:00~13:00）
	[2] = {nCycleTime = 7200}, 			--第一场战斗时间	（2小时,13:00~15:00）
	[3] = {nCycleTime = 14400}, 		--休息时间			（4小时,15:00~19:00）
	[4] = {nCycleTime = 7200}, 			--第二场战斗时间	（2小时,19:00~21:00）
	[5] = {nCycleTime = 18000}, 		--休息时间			（5小时,21:00~02:00）
}
CampActiveTime.tNextCampBattleDay = { -- 离下次攻防战间隔的天数，现在是星期3，4，6，7有攻防战
	[0] = 0,
	[1] = 5,
	[2] = 4,
	[3] = 3,
	[4] = 2,
	[5] = 1,
	[6] = 0,
}

function CampActiveTime.OnFrameCreate()
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("UPDATE_CAMP_INFO")
	this:RegisterEvent("CHANGE_CAMP")
	
end


function CampActiveTime.OnEvent(szEvent)
	if szEvent == "PLAYER_ENTER_SCENE" then
		--CampActiveTime.UpdatePanel()
	elseif szEvent == "UI_SCALED" then
		CampActiveTime.UpdateAnchor()
	elseif szEvent == "CHANGE_CAMP" then
		--CampActiveTime.UpdatePanel()
	end
	
end


function CampActiveTime.UpdateAnchor()
	local nX, nY = Station.GetClientSize()
	CampActiveTime.hFrame:SetRelPos(nX - 275, 285)
end


function GetTimeInfo()
	local nCurrentTime = GetCurrentTime()
	local tData = TimeToDate(nCurrentTime)
	local nStartTime = DateToTime(tData.year, tData.month, tData.day, 2, 0, 0)
	local nWeekday = tData.weekday
	
	if nCurrentTime < nStartTime then
		nWeekday = nWeekday - 1
		if nWeekday < 0 then 
			nWeekday = 6
		end
		
		nStartTime = nStartTime - 24 * 3600
	end
	
	if CampActiveTime.tNextCampBattleDay[nWeekday] > 0 then
		return nWeekday, 1, nStartTime + tStepTime[1].nCycleTime + CampActiveTime.tNextCampBattleDay[nWeekday] * 24 * 3600
	end
	
	local nUsedTime = nCurrentTime - nStartTime
	local nStep = 0 --当前时间处于第几个阶段
	local nEndTime = nStartTime --当前阶段截止时间

	for nIndex = 1, #tStepTime do 
		if tStepTime[nIndex].nCycleTime > nUsedTime then
			nStep = nIndex
			nEndTime = nEndTime + tStepTime[nIndex].nCycleTime
			break
		end
		
		nUsedTime = nUsedTime - tStepTime[nIndex].nCycleTime
		nEndTime = nEndTime + tStepTime[nIndex].nCycleTime
	end
	
	if nStep == 5 then
		nEndTime = nEndTime + tStepTime[1].nCycleTime
	end
	return nWeekday, nStep, nEndTime
end


local function ReFreshActiveTime()
	CampActiveTime.weekday, CampActiveTime.nStep, CampActiveTime.nEndTime = GetTimeInfo()
end

function CampActiveTime.OnFrameBreathe()
	local nCurrentTime = GetCurrentTime()
	CampActiveTime.nNextStepTime = CampActiveTime.nEndTime - nCurrentTime
	
	if CampActiveTime.nCount > 4800 then
		ReFreshActiveTime()
		CampActiveTime.nCount = 1
	end
	if CampActiveTime.nNextStepTime < 30 then
		ReFreshActiveTime()
		CampActiveTime.nCount = 1
	end
	CampActiveTime.nCount = CampActiveTime.nCount + 1
	
	--CampActiveTime.UpdatePanel()
end


function CampActiveTime.UpdatePanel()
	local player = GetClientPlayer()
	if not player then
		return
	end
	if player.nLevel < 70 then
		CampActiveTime.hFrame:Hide()
		return
	end
	if player.nCamp == 0 then
		CampActiveTime.hFrame:Hide()
		return
	end
	if CampActiveTime.weekday == 7 then
		CampActiveTime.hFrame:Hide()
	else
		CampActiveTime.hFrame:Show()
	end
	local tTime = TimeToDate(CampActiveTime.nNextStepTime)
	local szText = ""
	local nHour = tTime.hour - 8

	if tTime.day > 1 then 
		nHour = nHour + 24 * (tTime.day - 1)
	end

	if CampActiveTime.nStep % 2 == 0 then
		szText = g_tStrings.CAMPACTIVE_END_LEFT_TIME 
	else
		szText = g_tStrings.CAMPACTIVE_BEGIN_LEFT_TIME
	end
	CampActiveTime.hFrame:Lookup("","Text_CampActiveTime"):SetText(szText .. nHour .. ":" .. tTime.minute .. ":" .. tTime.second)
end

function CampActiveTime.CreateWindow()
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/CampActiveTime")
	if not frame then
		frame = Wnd.OpenWindow("UI/Config/Default/CampActiveTime.ini", "CampActiveTime")
	end
	CampActiveTime.hFrame = frame
end

function CampActiveTime.GetTime()
	if CampActiveTime.nNextStepTime < 0 then
		CampActiveTime.nNextStepTime = 0
	end
	
	local tTime = TimeToDate(CampActiveTime.nNextStepTime)
	local nHour = tTime.hour - 8

	if tTime.day > 1 then 
		nHour = nHour + 24 * (tTime.day - 1)
	end

	local szTime = nHour .. ":" .. tTime.minute .. ":" .. tTime.second
	if CampActiveTime.nStep % 2 == 0 then
		return g_tStrings.CAMPACTIVE_END_LEFT_TIME, szTime, CampActiveTime.weekday
	else
		return g_tStrings.CAMPACTIVE_BEGIN_LEFT_TIME, szTime, CampActiveTime.weekday
	end 	
end


CampActiveTime.CreateWindow()
ReFreshActiveTime()
