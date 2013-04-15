local INI_PATH =  "ui/Config/Default/Cyclopaedia_Calender.ini"
local STEP_SIZE = 50
local STEP_SIZE3 = 5
local ACTIVE_CLASS_COUNT = 5
local CALENDER_EVENT_ALLDAY = 2
local CALENDER_EVENT_RESET =  1
local CALENDER_EVENT_START = 3
local CALENDER_STATE_NORMAL = 0
local CALENDER_STATE_UNDER_WAY = 1
local CALENDER_STATE_UNOPENED = 2
local CALENDER_STATE_CLOSED = 3
local CALENDER_MAX_NOTICE_NUMBER = 10
local tStateFont = 
{
	[0] = 18, -- normal
	[1] = 198, -- 进行中
	[2] = 163, -- 未开始
	[3] = 161, -- 已结束
}

local tClassFrame = 
{
	[1] = 66, -- 节日
	[2] = 56, -- 秘境
	[3] = 58, -- 休闲
	[4] = 55, -- 对抗
	[5] = 57, -- 任务
}

local function IsLeapYear(nYear)
	if (nYear % 4 == 0 and nYear % 100 ~= 0) or (nYear % 400 == 0) then
		return true
	else
		return false
	end
end

local function GetTodayTime()
	local nTime = GetCurrentTime()
	local t = TimeToDate(nTime)
	
	return t
end

local function GetDaysofMonth(nYear, nMonth)
	local tMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	local nDays = tMonth[nMonth]
	if nMonth == 2 then
		if IsLeapYear(nYear) then
			nDays = nDays + 1
		end
	end
	
	return nDays
end

local function GetPrevMonth(tDate)
	local tTime = clone(tDate)
	if tTime.month == 1 then
		tTime.year = tTime.year - 1
		tTime.month = 12
	else
		tTime.month = tTime.month - 1
	end
	local nDays = GetDaysofMonth(tTime.year, tTime.month)
	if tTime.day > nDays then
		tTime.day = nDays
	end
	
	return tTime
end

local function GetNextMonth(tDate)
	local tTime = clone(tDate)
	if tTime.month == 12 then
		tTime.year = tTime.year + 1
		tTime.month = 1
	else
		tTime.month = tTime.month + 1
	end
	local nDays = GetDaysofMonth(tTime.year, tTime.month)
	if tTime.day > nDays then
		tTime.day = nDays
	end
	
	return tTime
end

function GetPrevDay(tDate)
	local tTime = clone(tDate)
	if tTime.day == 1 then
		tTime = GetPrevMonth(tTime)
		local nNumber = GetDaysofMonth(tTime.year, tTime.month)
		tTime.day = nNumber
	else
		tTime.day = tTime.day - 1
	end
	
	local nTime = DateToTime(tTime.year, tTime.month, tTime.day, tTime.hour, tTime.minute, tTime.second)
	tTime = TimeToDate(nTime)
	return tTime
end

function GetNextDay(tDate)
	local tTime = clone(tDate)
	local nNumber = GetDaysofMonth(tTime.year, tTime.month)
	if tTime.day == nNumber then
		tTime = GetNextMonth(tTime)
		tTime.day = 1
	else
		tTime.day = tTime.day + 1
	end
	
	local nTime = DateToTime(tTime.year, tTime.month, tTime.day, tTime.hour, tTime.minute, tTime.second)
	tTime = TimeToDate(nTime)
	return tTime
end

local function IsDateEqual(tLeft, tRight)
	if tLeft.year == tRight.year and tLeft.month == tRight.month and tLeft.day == tRight.day then
		return true
	end
	
	return false
end

local function IsToday(tTime)
	local tToday = GetTodayTime()
	local bToday = IsDateEqual(tTime, tToday)
	
	return bToday
end

local function IsFuture(tTime)
	local tToday = GetTodayTime()
	if (tTime.year > tToday.year)
	or (tTime.year == tToday.year and tTime.month > tToday.month)
	or (tTime.year == tToday.year and tTime.month == tToday.month and tTime.day > tToday.day) then
		return true
	end
	
	return false
end

local function SortByTimeAscend(tLeft, tRight)
	if tLeft.nTime == tRight.nTime then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nTime < tRight.nTime
end

local function SortByStateAscend(tLeft, tRight)
	if tLeft.nState == tRight.nState then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nState < tRight.nState
end

local function SortByClassAscend(tLeft, tRight)
	if tLeft.nClass == tRight.nClass then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nClass < tRight.nClass
end

local function SortByLevelAscend(tLeft, tRight)
	if tLeft.nSortLevel == tRight.nSortLevel then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nSortLevel < tRight.nSortLevel
end

local function SortByAwardAscend(tLeft, tRight)
	if tLeft.nSortAward == tRight.nSortAward then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nSortAward < tRight.nSortAward
end

local function SortByTimeDescend(tLeft, tRight)
	if tLeft.nTime == tRight.nTime then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nTime > tRight.nTime
end

local function SortByStateDescend(tLeft, tRight)
	if tLeft.nState == tRight.nState then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nState > tRight.nState
end

local function SortByClassDescend(tLeft, tRight)
	if tLeft.nClass == tRight.nClass then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nClass > tRight.nClass
end

local function SortByLevelDescend(tLeft, tRight)
	if tLeft.nSortLevel == tRight.nSortLevel then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nSortLevel > tRight.nSortLevel
end

local function SortByAwardDescend(tLeft, tRight)
	if tLeft.nSortAward == tRight.nSortAward then
		return tLeft.nShowPriority > tRight.nShowPriority
	end
	
	return tLeft.nSortAward > tRight.nSortAward
end

local function SortByPriority(tLeft, tRight)
	return tLeft.nShowPriority < tRight.nShowPriority
end

local function GetLunarMonthText(nMonth, bLeapMonth)
	local szText = ""
	if bLeapMonth then
		szText = g_tStrings.CYCLOPAEDIA_CLENDER_LEAP
	end
	szText = g_tStrings.tChineseNumber[nMonth]
	if nMonth == 1 and not bLeapMonth then
		szText = g_tStrings.CYCLOPAEDIA_MONTH_ONE
	end
	szText = szText .. g_tStrings.CYCLOPAEDIA_MONTH
	
	return szText
end

local function GetLunarDayText(nDay)
	local szText = ""
	local nBitTen = 0
	local nBitOne = 0
	if nDay == 10 then
		nBitTen = 0
		nBitOne = 10
	else
		nBitTen = math.floor(nDay / 10)
		nBitOne = nDay % 10
	end
	
	local szText = g_tStrings.tLunarDatePrefix[nBitTen] .. g_tStrings.tChineseNumber[nBitOne]
	return szText
end

local function GetLunarTextForDaily(tTime)
	local hCalendar = GetActivityMgrClient()
	local tLunar = hCalendar.SolarDateToLunar(tTime.year, tTime.month, tTime.day)
	local szText = GetLunarMonthText(tLunar.nMonth) .. GetLunarDayText(tLunar.nDay)
	
	return szText
end

local function GetLunarTextForMonthly(tTime)
	local szText = ""
	local hCalendar = GetActivityMgrClient()
	local tLunar = hCalendar.SolarDateToLunar(tTime.year, tTime.month, tTime.day)
	szText = GetLunarMonthText(tLunar.nMonth)
	return szText
end

local function GetLunarTextForMonthDate(tTime)
	local szText = ""
	local hCalendar = GetActivityMgrClient()
	local tLunar = hCalendar.SolarDateToLunar(tTime.year, tTime.month, tTime.day)
	if tLunar.nDay == 1 then
		szText = GetLunarMonthText(tLunar.nMonth, tLunar.bLeapMonth)
	else
		szText = GetLunarDayText(tLunar.nDay)
	end
	return szText
end

local tSortCompMap = 
{
	[1] = 
	{
		["Handle_Time"] = SortByTimeDescend,
		["Handle_Name"] = SortByStateDescend,
		["Handle_Sort"] = SortByClassDescend,
		["Handle_Degree"] = SortByLevelDescend,
		["Handle_Award"] = SortByAwardDescend,
	},
	
	[2] = 
	{
		["Handle_Time"] = SortByTimeAscend,
		["Handle_Name"] = SortByStateAscend,
		["Handle_Sort"] = SortByClassAscend,
		["Handle_Degree"] = SortByLevelAscend,
		["Handle_Award"] = SortByAwardAscend,
	}
}

Cyclopaedia_Calender = {}
Cyclopaedia_Calender.bFilterLevel = false
Cyclopaedia_Calender.tFilterClass = {}
Cyclopaedia_Calender.tNotice = {}
Cyclopaedia_Calender.bNotPopCalender = false

for i = 1, ACTIVE_CLASS_COUNT do
	Cyclopaedia_Calender.tFilterClass[i] = true
end

RegisterCustomData("Cyclopaedia_Calender.bFilterLevel")
RegisterCustomData("Cyclopaedia_Calender.tFilterClass")
RegisterCustomData("Cyclopaedia_Calender.bNotPopCalender")

function Cyclopaedia_Calender.UpdateSortDaily(hItem)
	local hHandleTitle = hItem:GetParent()
	local nCount = hHandleTitle:GetItemCount()
	for i = 0, nCount - 1 do 
		local hChild = hHandleTitle:Lookup(i)
		if hChild.bSort then
			if hChild ~= hItem then
				hChild.bSort = false
				hChild:Lookup(1):Hide()
				hChild:Lookup(2):Hide()
				hChild.bDescend = false
			end
		end
	end
		
	local szName = hItem:GetName()
	local hWnd = hHandleTitle:GetParent():GetParent()
	local SortComp
	if not hItem.bSort or hItem.bDescend then
		hItem.bDescend = false
		hItem:Lookup(1):Hide()
		hItem:Lookup(2):Show()
		SortComp = tSortCompMap[2][szName]
	else
		hItem.bDescend = true
		hItem:Lookup(1):Show()
		hItem:Lookup(2):Hide()
		SortComp = tSortCompMap[1][szName]
	end
	hItem.bSort = true
	Cyclopaedia_Calender.DailySortComp = SortComp
	Cyclopaedia_Calender.UpdateDaily(hWnd)
end

function Cyclopaedia_Calender.SetTime(tTime)
	local nTime = DateToTime(tTime.year, tTime.month, tTime.day, tTime.hour, tTime.minute, tTime.second)
	Cyclopaedia_Calender.tTime = TimeToDate(nTime)
	Cyclopaedia_Calender.tDaily = Table_GetCalenderOfDay(tTime.year, tTime.month, tTime.day, 1)
	
	Cyclopaedia_Calender.bToday = IsToday(tTime)
	Cyclopaedia_Calender.bFuture = IsFuture(tTime)
	Cyclopaedia_Calender.FormatActivityTime()
	Cyclopaedia_Calender.UpdateDailyActiveState()
end

function Cyclopaedia_Calender.FormatActivityTime()
	local tDaily = Cyclopaedia_Calender.GetDailyCander()
	local nTime = GetCurrentTime()
	local tTime = Cyclopaedia_Calender.tTime
	local nEarly = DateToTime(tTime.year, tTime.month, tTime.day, 7, 0, 0)
	local tNextDay = GetNextDay(tTime)
	local nLate = DateToTime(tNextDay.year, tNextDay.month, tNextDay.day, 6, 59, 59) -- 次日早上6:59
	for _, tLine in ipairs(tDaily) do
		szTime = ""
		if tLine.nEvent == CALENDER_EVENT_ALLDAY or tLine.nEvent == CALENDER_EVENT_RESET then
			szTime = "7:00~" .. g_tStrings.CYCLOPAEDIA_CLENDER_TOMORROW .. "6:59"
			tLine.nTime = nEarly
		else
			local tStartTime = TimeToDate(tLine.nStartTime)
			 --- 早上7:00
			local bEqual = IsDateEqual(tTime, tStartTime)
			if bEqual then
				tLine.nTime = tLine.nStartTime
				szTime = tStartTime.hour .. ":" .. string.format("%02d", tStartTime.minute)
			else
				if tLine.nEndTime > nEarly then
					szTime = "7:00"
					tLine.nTime = nEarly
				else
					szTime = "0:00"
					tLine.nTime = DateToTime(tTime.year, tTime.month, tTime.day, 0, 0, 0)
				end
			end
			szTime = szTime .. "~"
			local tEndTime = TimeToDate(tLine.nEndTime)
			bEqual = IsDateEqual(tTime, tEndTime)
			if not bEqual then
				szTime = szTime .. g_tStrings.CYCLOPAEDIA_CLENDER_TOMORROW
			end
			
			if nLate > tLine.nEndTime then
				szTime = szTime .. tEndTime.hour .. ":" .. string.format("%02d", tEndTime.minute)
			else
				szTime = szTime .. "6:59"
			end
		end
		tLine.szTime = szTime
	end
end

function Cyclopaedia_Calender.UpdateDailyActiveState()
	local bToday = Cyclopaedia_Calender.bToday
	local tDaily = Cyclopaedia_Calender.GetDailyCander()
	local nTime = GetCurrentTime()
	for _, tLine in ipairs(tDaily) do
		if not bToday then
			tLine.nState = CALENDER_STATE_NORMAL
		elseif tLine.nEvent == CALENDER_EVENT_ALLDAY or tLine.nEvent == CALENDER_EVENT_RESET then
			tLine.nState = CALENDER_STATE_UNDER_WAY
		else
			if nTime < tLine.nStartTime then
				tLine.nState = CALENDER_STATE_UNOPENED
			elseif nTime < tLine.nEndTime then
				tLine.nState = CALENDER_STATE_UNDER_WAY
			else
				tLine.nState = CALENDER_STATE_CLOSED
			end
		end
		tLine.szState = g_tStrings.tActiveState[tLine.nState]
	end
end

function Cyclopaedia_Calender.IsStateChange()
	--[[
	local tDaily = Cyclopaedia_Calender.GetDailyCander()
	local hCalendar = GetActivityMgrClient()
	local nTime = GetCurrentTime()
	for _, tLine in ipairs(tDaily) do
		if tLine.nEvent == CALENDER_EVENT_START then 
			local nState = -1
			local bStartPassed = hCalendar.IsTimePassed(tLine.nStartDay, nTime)
			local bEndPassed = hCalendar.IsTimePassed(tLine.nEndDay, nTime)
			if not bStartPassed then
				nState = CALENDER_STATE_UNOPENED
			elseif not bEndPassed then
				nState = CALENDER_STATE_UNDER_WAY
			else
				nState = CALENDER_STATE_CLOSED
			end
			if nState ~= tLine.nState then
				return true
			end
		end
	end
	
	return false
	--]]
end

function Cyclopaedia_Calender.GetTime(tTime)
	return Cyclopaedia_Calender.tTime
end

function Cyclopaedia_Calender.GetDailyCander()
	return Cyclopaedia_Calender.tDaily
end

function Cyclopaedia_Calender.IsMonthFilterAll()
	for i = 1, ACTIVE_CLASS_COUNT do
		if not Cyclopaedia_Calender.tFilterClass[i] then
			return false
		end
	end	
	
	return true
end

function Cyclopaedia_Calender.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	Cyclopaedia_Calender.OnEvent("UI_SCALED")
	
	local hWnd = this:Lookup("Wnd_Calender")
	hWnd:Lookup("CheckBox_PopCalender"):Check(Cyclopaedia_Calender.bNotPopCalender)
	Cyclopaedia_Calender.Update(hWnd)
end

function Cyclopaedia_Calender.Update(hWnd)
	local tToday = GetTodayTime()
	Cyclopaedia_Calender.SetTime(tToday)
	hWnd:Lookup("CheckBox_Change"):Check(false)
	hWnd:Lookup("Wnd_DailyCalender/CheckBox_Filter"):Check(Cyclopaedia_Calender.bFilterLevel)
	Cyclopaedia_Calender.bUpdateFilter = true
	for i = 1, ACTIVE_CLASS_COUNT do 
		hWnd:Lookup("Wnd_MonthlyCalender/CheckBox_Filter" .. i):Check(Cyclopaedia_Calender.tFilterClass[i])
	end
	Cyclopaedia_Calender.DailySortComp = nil
	Cyclopaedia_Calender.bUpdateFilter = false
	local bAll = Cyclopaedia_Calender.IsMonthFilterAll()
	local hFilterAll = hWnd:Lookup("Wnd_MonthlyCalender", "Handle_FilterAll")
	hFilterAll.bCheck = bAll
	Cyclopaedia_Calender.UpdateClassFilterState(hFilterAll)
	Cyclopaedia_Calender.UpdateWnd(hWnd, false)
	hWnd:Lookup("Wnd_MonthlyCalender/Wnd_Expand"):Hide()
	local hWndMini = hWnd:Lookup("Wnd_MiniMap")
	Cyclopaedia_Calender.CloseMiniMonth(hWndMini)
	
end

function Cyclopaedia_Calender.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 50, 50)
	elseif szEvent == "PLAYER_LEVEL_UPDATE" then
		if Cyclopaedia_Calender.bFilterLevel then
			local hWnd = this:Lookup("Wnd_Calender")
			if not hWnd:Lookup("CheckBox_Change"):IsCheckBoxChecked() then
				local hWndDaily = hWnd:Lookup("Wnd_DailyCalender")
				Cyclopaedia_Calender.UpdateDaily(hWndDaily)
			end
		end
	end
end

function Cyclopaedia_Calender.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Change" then
		Cyclopaedia_Calender.UpdateWnd(this:GetParent(), true)
	elseif szName == "CheckBox_MiniMap" then
		hWndMini = this:GetParent():Lookup("Wnd_MiniMap")
		Station.SetFocusWindow(hWndMini)
		local tTime = Cyclopaedia_Calender.GetTime()
		Cyclopaedia_Calender.UpdateMiniMonth(hWndMini, tTime)
	elseif szName == "CheckBox_Filter" then
		local hWndDaily = this:GetParent()
		Cyclopaedia_Calender.bFilterLevel = true
		Cyclopaedia_Calender.UpdateDaily(hWndDaily)
	elseif szName == "CheckBox_Filter1"
	or szName == "CheckBox_Filter2"
	or szName == "CheckBox_Filter3"
	or szName == "CheckBox_Filter4"
	or szName == "CheckBox_Filter5" then
		if not Cyclopaedia_Calender.bUpdateFilter then
			local nIndex = string.match(szName, "CheckBox_Filter(%d)")
			nIndex = tonumber(nIndex)
			Cyclopaedia_Calender.tFilterClass[nIndex] = true
			local bAll = Cyclopaedia_Calender.IsMonthFilterAll()
			local hWnd = this:GetParent()
			local hFilterAll = hWnd:Lookup("", "Handle_FilterAll")
			hFilterAll.bCheck = bAll
			Cyclopaedia_Calender.UpdateClassFilterState(hFilterAll)
			Cyclopaedia_Calender.UpdateMonth(hWnd)
		end
	elseif szName == "CheckBox_PopCalender" then
		Cyclopaedia_Calender.bNotPopCalender = true
	end
end

function Cyclopaedia_Calender.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Change" then
		Cyclopaedia_Calender.UpdateWnd(this:GetParent(), false)
		Cyclopaedia_Calender.DailySortComp = SortByStateAscend
	elseif szName == "CheckBox_MiniMap" then
		hWndMini = this:GetParent():Lookup("Wnd_MiniMap")
		Cyclopaedia_Calender.CloseMiniMonth(hWndMini)	
	elseif szName == "CheckBox_Filter" then
		local hWndDaily = this:GetParent()
		Cyclopaedia_Calender.bFilterLevel = false
		Cyclopaedia_Calender.UpdateDaily(hWndDaily)
	elseif szName == "CheckBox_Filter1" 
	or szName == "CheckBox_Filter2"
	or szName == "CheckBox_Filter3"
	or szName == "CheckBox_Filter4"
	or szName == "CheckBox_Filter5" then
		if not Cyclopaedia_Calender.bUpdateFilter then
			local nIndex = string.match(szName, "CheckBox_Filter(%d)")
			nIndex = tonumber(nIndex)
			Cyclopaedia_Calender.tFilterClass[nIndex] = false
			local hWnd = this:GetParent()
			local hFilterAll = hWnd:Lookup("", "Handle_FilterAll")
			hFilterAll.bCheck = false
			Cyclopaedia_Calender.UpdateClassFilterState(hFilterAll)
			Cyclopaedia_Calender.UpdateMonth(hWnd)
		end
	elseif szName == "CheckBox_PopCalender" then
		Cyclopaedia_Calender.bNotPopCalender = false
	end
end

function Cyclopaedia_Calender.OnItemMouseEnter()
	local szName = this:GetName()
    local szType = this:GetType()
	if szName == "Handle_Date" and this.nDay then
		if not this.bSelect then	
			this:Lookup("Image_DateOver"):SetAlpha(128)
			this:Lookup("Image_DateOver"):Show()
		end
	elseif szName == "Handle_EventList_1" then
		if not this.bSelect then
			this:Lookup("Image_Sel_9"):SetAlpha(128)
			this:Lookup("Image_Sel_9"):Show()
		end
	elseif szName == "Handle_Time" or szName == "Handle_Name" 
	or szName == "Handle_Sort" or szName == "Handle_Degree"
	or szName == "Handle_Award" then
		this:Lookup(0):SetFontScheme(3)
	elseif szName == "Handle_FilterAll" then
		this.bOver = true
		Cyclopaedia_Calender.UpdateClassFilterState(this)
	elseif szName == "Text_More" then
		if this.szLink and this.szLink ~= "" then
			this:SetFontScheme(59)
		end
	elseif szName == "Text_Se_1" or szName == "Text_Se_2" or szName == "Text_Se_3" then
		if not this.bSelect then
			local nIndex = string.match(szName, "Text_Se_(%d)")
			local hHandle = this:GetParent()
			local hImage = hHandle:Lookup("Image_Se_" .. nIndex)
			hImage:SetAlpha(128)
			hImage:Show()
		end
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(GetFormatText(this.szName), 400, {x, y, w, h})	
	elseif szName == "Handle_ExpandActive" then
		if not this.bSelect then
			local hImage = this:Lookup("Image_Se")
			hImage:SetAlpha(128)
			hImage:Show()
		end
		local hText = this:Lookup("Text_Se")
		local x, y = hText:GetAbsPos()
		local w, h = hText:GetSize()
		OutputTip(GetFormatText(this.szName), 400, {x, y, w, h})	
	elseif szName == "Handle_Top" then
		local hDate = this:GetParent()
		if hDate.nDay then
			this:Lookup("Image_DateTop_O"):Show()
		end
    elseif szType == "Text" and this:IsLink() then
		local nFont = this:GetFontScheme()
		this.nFont = nFont
		this:SetFontScheme(164)
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	end
end

function Cyclopaedia_Calender.OnItemMouseLeave()
	local szName = this:GetName()
    local szType = this:GetType()
	if szName == "Handle_Date" and this.nDay then
		if not this.bSelect then
			this:Lookup("Image_DateOver"):Hide()
		end
	elseif szName == "Handle_EventList_1" then
		if not this.bSelect then
			this:Lookup("Image_Sel_9"):SetAlpha(255)
			this:Lookup("Image_Sel_9"):Hide()
		end
	elseif szName == "Handle_Time" or szName == "Handle_Name" 
	or szName == "Handle_Sort" or szName == "Handle_Degree"
	or szName == "Handle_Award" then
		this:Lookup(0):SetFontScheme(18)
	elseif szName == "Handle_FilterAll" then
		this.bOver = false
		Cyclopaedia_Calender.UpdateClassFilterState(this)
	elseif szName == "Text_More" then
		if this.szLink then
			this:SetFontScheme(27)
		end
	elseif szName == "Text_Se_1" or szName == "Text_Se_2" or szName == "Text_Se_3" then
		if not this.bSelect then
			local nIndex = string.match(szName, "Text_Se_(%d)")
			local hHandle = this:GetParent()
			local hImage = hHandle:Lookup("Image_Se_" .. nIndex)
			hImage:Hide()
		end
		HideTip()
	elseif szName == "Handle_ExpandActive" then
		if not this.bSelect then
			local hImage = this:Lookup("Image_Se")
			hImage:Hide()
		end
		HideTip()
	elseif szName == "Handle_Top" then
		this:Lookup("Image_DateTop_O"):Hide()
    elseif szType == "Text" and this:IsLink() then
		if this.nFont then
			this:SetFontScheme(this.nFont)
			local hHandle = this:GetParent()
			hHandle:FormatAllItemPos()
		end
	end
end

function Cyclopaedia_Calender.OnItemLButtonDBClick()
	local szName = this:GetName()
	if szName == "Text_Se_1" 
	or szName == "Text_Se_2" 
	or szName == "Text_Se_3" 
	or szName == "Handle_ExpandActive" then
		if this.szLink and this.szLink ~= "" then
			local argSave = arg0
			arg0 = this.szLink
			FireEvent("EVENT_LINK_NOTIFY")
			arg0 = argSave
		end
	elseif szName == "Handle_Date" then
		if this.nDay then
			Cyclopaedia_Calender.SelectMiniDate(this)
			local hWndMini = this:GetParent():GetParent():GetParent()
			Cyclopaedia_Calender.OnMiniDateSure(hWndMini)
		end
	end
end

function Cyclopaedia_Calender.OnSetFocus()
	local szName = this:GetName()
	local bWndMiniClose = true
	local bWndExpandClose = true
	
	local hWndCalender = this:GetRoot():Lookup("Wnd_Calender")
	
	if not hWndCalender then
		return
	end
	
	if szName == "Wnd_Expand" then
		bWndExpandClose = false
	elseif szName == "Wnd_MiniMap" or szName == "CheckBox_MiniMap"then
		bWndMiniClose = false
	else
		hParent = this:GetParent()
		szName = hParent:GetName()
		if szName == "Wnd_MiniMap" then
			bWndMiniClose = false
		end
	end
	
	if bWndExpandClose then
		hWndCalender:Lookup("Wnd_MonthlyCalender/Wnd_Expand"):Hide()
	end
	
	if bWndMiniClose then
		hWndMini = hWndCalender:Lookup("Wnd_MiniMap")
		Cyclopaedia_Calender.CloseMiniMonth(hWndMini)
		
	end
end

function Cyclopaedia_Calender.UpdateWnd(hWnd, bMonth)
	local hWndDaily = hWnd:Lookup("Wnd_DailyCalender")
	local hWndMonth = hWnd:Lookup("Wnd_MonthlyCalender")
	if bMonth then
		hWnd:Lookup("Btn_Daily"):Enable(true)
		hWnd:Lookup("Btn_Monthly"):Enable(false)
		hWndDaily:Hide()
		hWndMonth:Show()
		Cyclopaedia_Calender.UpdateMonth(hWndMonth)
	else
		hWnd:Lookup("Btn_Daily"):Enable(false)
		hWnd:Lookup("Btn_Monthly"):Enable(true)
		hWndDaily:Show()
		hWndMonth:Hide()
		Cyclopaedia_Calender.UpdateDaily(hWndDaily)
	end
	
end

function Cyclopaedia_Calender.OnLButtonClick()
	local szName = this:GetName()
	local tToday = GetTodayTime()
	if szName == "Btn_Close" then
		CloseCalenderPanel()
	elseif szName == "Btn_PagePrev_1" then
		local hWndMini = this:GetParent()
		local tTime = GetPrevMonth(hWndMini.tDate)
		Cyclopaedia_Calender.UpdateMiniMonth(hWndMini, tTime)
	elseif szName == "Btn_PageNext_1" then
		local hWndMini = this:GetParent()
		local tTime = GetNextMonth(hWndMini.tDate)
		Cyclopaedia_Calender.UpdateMiniMonth(hWndMini, tTime)
	elseif szName == "Btn_Year" then
		local hWndMini = this:GetParent()
		local hImage = hWndMini:Lookup("", "Image_Year")
		local nWidth, nHeight = hImage:GetSize()
		local nPosX, nPosY = hImage:GetAbsPos()
		local SelectYear = function(UserData)
			hWndMini:Lookup("", "Text_Year"):SetText(UserData)
			local tTime = hWndMini.tDate
			tTime.year = UserData
			if tTime.year == tToday.year - 1 then
				if tTime.month < tToday.month then
					tTime.month = tToday.month
				end
			elseif tTime.year == tToday.year + 1 then
				if tTime.month > tToday.month then
					tTime.month = tToday.month
				end
			end
			Cyclopaedia_Calender.UpdateMiniMonth(hWndMini, tTime)
			GetPopupMenu():Hide()
		end
		tMenu = 
		{
			nMiniWidth = nWidth,
			x = nPosX,
			y = nPosY + nHeight,
			{szOption = tToday.year - 1, bMCheck = true, fnAction = SelectYear, UserData = tToday.year - 1, fnAutoClose = function() return true end},
			{szOption = tToday.year, bMCheck = true, fnAction = SelectYear , UserData = tToday.year, fnAutoClose = function() return true end},
			{szOption = tToday.year + 1, bMCheck = true, fnAction = SelectYear, UserData = tToday.year + 1, fnAutoClose = function() return true end},
		}
		PopupMenu(tMenu)
		
	elseif szName == "Btn_Month" then
		local hWndMini = this:GetParent()
		local hImage = hWndMini:Lookup("", "Image_Month")
		local nWidth, nHeight = hImage:GetSize()
		local nPosX, nPosY = hImage:GetAbsPos()
		local function SelectMonth(UserData)
			hWndMini:Lookup("", "Text_Month"):SetText(UserData)
			local tTime = hWndMini.tDate
			tTime.month = UserData
			Cyclopaedia_Calender.UpdateMiniMonth(hWndMini, tTime)
			GetPopupMenu():Hide()
		end
		tMenu = 
		{
			nMiniWidth = nWidth,
			x = nPosX,
			y = nPosY + nHeight,
		}
		
		local nStartMonth = 1
		local nEndMonth = 12
		if hWndMini.tDate.year == tToday.year - 1 then
			nStartMonth = tToday.month
		elseif hWndMini.tDate.year == tToday.year + 1 then
			nEndMonth = tToday.month
		end
		
		for i = nStartMonth, nEndMonth do
			local tMonthMenu = 
			{
				szOption = i,
				bMCheck = true,
				fnAction = SelectMonth,
				UserData = i,
				fnAutoClose = function() return true end,
			}
			table.insert(tMenu, tMonthMenu)
		end
		PopupMenu(tMenu)
	elseif szName == "Btn_PagePrev" then
		local hWnd = this:GetParent()
		local bCheck = hWnd:Lookup("CheckBox_Change"):IsCheckBoxChecked()
		local tTime = Cyclopaedia_Calender.GetTime()
		if bCheck then
			tTime = GetPrevMonth(tTime)
		else
			tTime = GetPrevDay(tTime)
		end
		Cyclopaedia_Calender.SetTime(tTime)
		Cyclopaedia_Calender.UpdateWnd(hWnd, bCheck)
	elseif szName == "Btn_PageNext" then
		local hWnd = this:GetParent()
		local bCheck = hWnd:Lookup("CheckBox_Change"):IsCheckBoxChecked()
		local tTime = Cyclopaedia_Calender.GetTime()
		if bCheck then
			tTime = GetNextMonth(tTime)
		else
			tTime = GetNextDay(tTime)
		end
		Cyclopaedia_Calender.SetTime(tTime)
		Cyclopaedia_Calender.UpdateWnd(hWnd, bCheck)
	elseif szName == "Btn_Today" then
		local hWnd = this:GetParent()
		local tToday = GetTodayTime()
		Cyclopaedia_Calender.SetTime(tToday)
		hWnd:Lookup("CheckBox_Change"):Check(false)
		Cyclopaedia_Calender.UpdateWnd(hWnd, false)
	elseif szName == "Btn_ThisMonth" then
		local hWnd = this:GetParent()
		local tToday = GetTodayTime()
		Cyclopaedia_Calender.SetTime(tToday)
		hWnd:Lookup("CheckBox_Change"):Check(true)
		Cyclopaedia_Calender.UpdateWnd(hWnd, true)
	elseif szName == "Btn_Sure" then
		local hWndMini = this:GetParent()
		Cyclopaedia_Calender.OnMiniDateSure(hWndMini)
	elseif szName == "Btn_Daily" then
		local hWnd = this:GetParent()
		hWnd:Lookup("CheckBox_Change"):Check(false)
	elseif szName == "Btn_Monthly" then
		local hWnd = this:GetParent()
		hWnd:Lookup("CheckBox_Change"):Check(true)
    elseif szName == "Btn_ActivePopularize" then
        OpenActivePopularize()
	end
end

function Cyclopaedia_Calender.OnMiniDateSure(hWndMini)
	local hWnd = hWndMini:GetParent()
	local tTime = hWndMini.tDate
	local bMonth = false
	if hWndMini.nSelectDay then
		tTime.day = hWndMini.nSelectDay
		bMonth = false
	else
		bMonth = true
	end
	Cyclopaedia_Calender.SetTime(tTime)
	hWnd:Lookup("CheckBox_Change"):Check(bMonth)
	hWnd:Lookup("CheckBox_MiniMap"):Check(false)
	Cyclopaedia_Calender.UpdateWnd(hWnd, bMonth)
	Cyclopaedia_Calender.CloseMiniMonth(hWndMini)
end

function Cyclopaedia_Calender.OnFrameBreathe()
	local hText = this:Lookup("", "Text_Calender")
	local tToday = GetTodayTime()
	hText:SetText(tToday.day)
end
--[[
function Cyclopaedia_Calender.OnFrameBreathe()
	local hWnd = this:Lookup("Wnd_Calender")
	local bCheck = hWnd:Lookup("CheckBox_Change"):IsCheckBoxChecked()
	if bCheck then
		return 
	end
	local tTime = Cyclopaedia_Calender.GetTime()
	local bChange = false
	if Cyclopaedia_Calender.bFuture then
		local bToday = IsToday(tTime)
		if not bToday then
			return
		end
		Cyclopaedia_Calender.bToday = true
		Cyclopaedia_Calender.bFuture = false
		bChange = true
	elseif Cyclopaedia_Calender.bToday then
		local bToday = IsToday(tTime)
		if not bToday then
			bChange = true
			Cyclopaedia_Calender.bToday = false
		else
			bChange = Cyclopaedia_Calender.IsStateChange()
		end
	end
	if not bChange then
		return 
	end
	local hWndDaily = hWnd:Lookup("Wnd_DailyCalender")
	Cyclopaedia_Calender.UpdateDailyActiveState()
	Cyclopaedia_Calender.UpdateDaily(hWndDaily)
end
--]]
function Cyclopaedia_Calender.OnLButtonDown()
	local szName = this:GetName()
	local hWnd = this:GetParent()
    if szName == "Btn_BUp1_1" then
		hWnd:Lookup("Scroll_List1_1"):ScrollPrev()
	elseif szName == "Btn_BDown1_1" then
		hWnd:Lookup("Scroll_List1_1"):ScrollNext()
	elseif szName == "Btn_BUp3_1" then
		hWnd:Lookup("Scroll_List3_1"):ScrollPrev()
	elseif szName == "Btn_BDown3_1" then
		hWnd:Lookup("Scroll_List3_1"):ScrollNext()
	elseif szName == "Btn_BUp5" then
		hWnd:Lookup("Scroll_List5"):ScrollPrev()
	elseif szName == "Btn_BDown5" then
		hWnd:Lookup("Scroll_List5"):ScrollNext()
	elseif szName == "Btn_BUp2_2" then
		hWnd:Lookup("Scroll_List2_2"):ScrollPrev()
	elseif szName == "Btn_BDown2_2" then
		hWnd:Lookup("Scroll_List2_2"):ScrollNext()
	end
end

function Cyclopaedia_Calender.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_Date" then
		if this.nDay then
			Cyclopaedia_Calender.SelectMiniDate(this)
		end
	elseif szName == "Handle_EventList_1" then
		Cyclopaedia_Calender.SelectActive(this)
	elseif szName == "Handle_Time" or szName == "Handle_Name" 
	or szName == "Handle_Sort" or szName == "Handle_Degree"
	or szName == "Handle_Award" then
		Cyclopaedia_Calender.UpdateSortDaily(this)
	elseif szName == "Handle_Bottom" then
		local hDate = this:GetParent()
		if hDate.nDay then
			Cyclopaedia_Calender.SelectMonthDate(hDate)
		end
	elseif szName == "Text_Se_1" or szName == "Text_Se_2" or szName == "Text_Se_3" then
		local nIndex = string.match(szName, "Text_Se_(%d)")
		local hHandle = this:GetParent()
		local hMonth = hHandle:GetParent():GetParent()
		local nCount = hMonth:GetItemCount()
		for i = 0, nCount - 1 do
			local hChild = hMonth:Lookup(i)
			local hBottom = hChild:Lookup("Handle_Bottom")
			for i = 1, 3 do
				hBottom:Lookup("Image_Se_" .. i):Hide()
				hBottom:Lookup("Text_Se_" .. i).bSelect = false
			end
		end
		hHandle:Lookup("Image_Se_" .. nIndex):SetAlpha(255)
		hHandle:Lookup("Image_Se_" .. nIndex):Show()
		this.bSelect = true
	elseif szName == "Handle_Top" then
		local hDate = this:GetParent()
		if hDate.nDay then
			local tTime = Cyclopaedia_Calender.GetTime()
			tTime.day = hDate.nDay
			Cyclopaedia_Calender.SetTime(tTime)
			local hWnd = hDate:GetParent():GetParent():GetParent():GetParent()
			hWnd:Lookup("CheckBox_Change"):Check(false)
			Cyclopaedia_Calender.UpdateWnd(hWnd, false)
		end
	elseif szName == "Handle_Expand_Down" then
		local hDate = this:GetParent()
		Cyclopaedia_Calender.ExpandMonthDate(hDate, hDate.nDay)
	elseif szName == "Handle_FilterAll" then
		local hWnd = this:GetParent():GetParent()
		Cyclopaedia_Calender.bUpdateFilter = true
		if this.bCheck then
			this.bCheck = false
			for i = 1, ACTIVE_CLASS_COUNT do
				hWnd:Lookup("CheckBox_Filter" .. i):Check(false)
				Cyclopaedia_Calender.tFilterClass[i] = false
			end
		else
			for i = 1, ACTIVE_CLASS_COUNT do
				hWnd:Lookup("CheckBox_Filter" .. i):Check(true)
				Cyclopaedia_Calender.tFilterClass[i] = true
			end
			this.bCheck = true
		end
		Cyclopaedia_Calender.bUpdateFilter = false
		Cyclopaedia_Calender.UpdateClassFilterState(this)
		Cyclopaedia_Calender.UpdateMonth(hWnd)
	elseif szName == "Handle_Expand_Up" then
		local hWndExpand = this:GetParent():GetParent()
		hWndExpand:Hide()
	elseif szName == "Handle_ExpandActive" then
		local hList = this:GetParent()
		local nCount = hList:GetItemCount()
		for i = 0, nCount - 1 do
			local hChild = hList:Lookup(i)
			if hChild.bSelect then
				hChild:Lookup("Image_Se"):Hide()
				hChild.bSelect = false
				break
			end
		end
		this.bSelect = true
		this:Lookup("Image_Se"):SetAlpha(255)
		this:Lookup("Image_Se"):Show()
	elseif szName == "Text_More" then
		if this.szLink and this.szLink ~= "" then
			local argSave = arg0
			arg0 = this.szLink
			FireEvent("EVENT_LINK_NOTIFY")
			arg0 = argSave
		end
	end
end

function Cyclopaedia_Calender.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_EventList_1" 
	or szName == "Text_Se_1" 
	or szName == "Text_Se_2" 
	or szName == "Text_Se_3" 
	or szName == "Handle_ExpandActive" then
		if IsCtrlKeyDown() and this.dwID then
			local tActive = Table_GetCalenderActivity(this.dwID)
			local szName = FormatString(g_tStrings.CYCLOPAEDIA_LINK_FORMAT, tActive.szName)
			EditBox_AppendEventLink(szName, "CalenderTip/" .. this.dwID)
		end
	end
end

function Cyclopaedia_Calender.UpdateClassFilterState(hFilterAll)
	hFilterAll:Lookup("Image_Nomal"):Hide()
	hFilterAll:Lookup("Image_NormalOver"):Hide()
	hFilterAll:Lookup("Image_CheckOver"):Hide()
	hFilterAll:Lookup("Image_CheckNormal"):Hide()
	if hFilterAll.bCheck then
		if hFilterAll.bOver then
			hFilterAll:Lookup("Image_CheckOver"):Show()
		else
			hFilterAll:Lookup("Image_CheckNormal"):Show()
		end
	else
		if hFilterAll.bOver then
			hFilterAll:Lookup("Image_NormalOver"):Show()
		else
			hFilterAll:Lookup("Image_Nomal"):Show()
		end
	end
end

function Cyclopaedia_Calender.ExpandMonthDate(hDate, nDay)
	local tTime = Cyclopaedia_Calender.GetTime()
	local tDate = clone(tTime)
	tDate.day = nDay
	local tActive = Table_GetCalenderOfDay(tTime.year, tTime.month, nDay, 2)
	tActive = Cyclopaedia_Calender.FilterMonthDate(tActive)
	table.sort(tActive, SortByPriority)
	
	local hHandleMonth = hDate:GetParent()
	local hWndMonth = hHandleMonth:GetParent():GetParent()
	
	local hWndExpand = hWndMonth:Lookup("Wnd_Expand")
	Station.SetFocusWindow(hWndExpand)
	local hHandle = hWndExpand:Lookup("", "")
	
	local hTop = hHandle:Lookup("Handle_Top_Expand")
	local szLunar = GetLunarTextForMonthDate(tDate)
	hTop:Lookup("Text_Date_Expand"):SetText(FormatString(g_tStrings.STR_ITEM_TEMP_ECHANT_LEFT_TIME, szLunar) .. " " .. nDay)
	local bToday = IsToday(tDate)
	if bToday then
		hTop:Lookup("Text_Date_Expand"):SetFontScheme(163)
		hTop:Lookup("Text_Today_Expand"):Show()
	else
		hTop:Lookup("Text_Date_Expand"):SetFontScheme(18)
		hTop:Lookup("Text_Today_Expand"):Hide()
	end
	
	local hBottom = hHandle:Lookup("Handle_Bottom_Expand")
	hBottom:Clear()
	for _, tLine in ipairs(tActive) do
		local hActive = hBottom:AppendItemFromIni(INI_PATH, "Handle_ExpandActive")
		hActive:Lookup("Text_Se"):SetText(tLine.szName)
		hActive.szName = tLine.szName
		hActive:Lookup("Image_Type"):SetFrame(tClassFrame[tLine.nClass])
		hActive.dwID = tLine.dwID
		hActive.szLink = tLine.szDetailPath
		if tLine.bHighlight then
			local hImage = hActive:Lookup("Image_Festival")
			hImage:Show()
			hImage:FromUITex(tLine.szHighlightPath, tLine.nFrame)
		end
	end
	hBottom:FormatAllItemPos()
	
	local nWidth = hBottom:GetSize()
	
	local _, nHeight = hBottom:GetAllItemSize()
	hBottom:SetSize(nWidth, nHeight)
	local fX, fY = hBottom:GetRelPos()
	local hExpandUp = hHandle:Lookup("Handle_Expand_Up")
	hExpandUp:SetRelPos(fX, fY + nHeight)
	local _, fExpandUpHeight = hExpandUp:GetSize()
	local hImageBg = hHandle:Lookup("Handle_Top_Expand/Image_DateBottom_Expand")
	nWidth = hImageBg:GetSize()
	hImageBg:SetSize(nWidth, fExpandUpHeight + nHeight)
	
	fX, fY = hExpandUp:GetRelPos()
	local fTotalHeight = fY + fExpandUpHeight
	nWidth = hHandle:GetSize()
	hHandle:SetSize(nWidth, fTotalHeight)
	hHandle:FormatAllItemPos()
	hWndExpand:SetSize(nWidth, fTotalHeight)
	
	fX, fY = hDate:GetAbsPos()
	local fStartX, fStartY = hHandleMonth:GetAbsPos()
	_, nHeight = hHandleMonth:GetSize()
	local fStandard = (fStartY + nHeight + fStartY) / 2
	local fDateX, fDateY = hDate:GetAbsPos()
	local _, fDateHeight = hDate:GetSize()
	if  fY > fStandard then
		hWndExpand:SetAbsPos(fDateX, fDateY + fDateHeight - fTotalHeight)
	else
		hWndExpand:SetAbsPos(fDateX, fDateY)
	end
	hWndExpand:Show()
end

function Cyclopaedia_Calender.SelectMonthDate(hDate)
	local hList = hDate:GetParent()
	
	nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild:Lookup("Handle_Bottom/Image_DateWhole_P"):Hide()
			hChild.bSelect = false
		end
	end
	
	hDate.bSelect = true
	hDate:Lookup("Handle_Bottom/Image_DateWhole_P"):Show()
	local tTime = Cyclopaedia_Calender.GetTime()
	tTime.day = hDate.nDay
	Cyclopaedia_Calender.SetTime(tTime)
end

function Cyclopaedia_Calender.DailyFilterByLevel(nLevel, tDaily)
	local tResult = {}
	for _, tLine in ipairs(tDaily) do
		local bFit = false
		for _, tLevelSect in ipairs(tLine.tLevel) do
			if tLevelSect[1] >= tLevelSect[2] then
                if nLevel >= tLevelSect[1] then
                    bFit = true
                    break
                end
            else
                if nLevel >= tLevelSect[1] and nLevel <= tLevelSect[2] then
                    bFit = true
                    break
                end
            end
		end
		if bFit then
			table.insert(tResult, tLine)
		end
	end
	return tResult
end

function Cyclopaedia_Calender.UpdateDaily(hWndDaily)
	local tDailyCanender = Cyclopaedia_Calender.GetDailyCander()
	if not tDailyCanender then
		return
	end
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	if Cyclopaedia_Calender.bFilterLevel then
		tDailyCanender = Cyclopaedia_Calender.DailyFilterByLevel(hPlayer.nLevel, tDailyCanender)
	end
	
	local tTime = Cyclopaedia_Calender.GetTime()
	hWndDaily:Lookup("", "Text_Date_1"):SetText(g_tStrings.tWeek[tTime.weekday])
	local szTime = FormatString(g_tStrings.STR_TIME_3, tTime.year, tTime.month, tTime.day)
	hWndDaily:Lookup("", "Text_Date_2"):SetText(szTime)
	local szLunar = GetLunarTextForDaily(tTime)
	hWndDaily:Lookup("", "Text_Date_3"):SetText(g_tStrings.CYCLOPAEDIA_LUNAR .. szLunar)
	local hList = hWndDaily:Lookup("", "Handle_EventList")
	
	if not Cyclopaedia_Calender.DailySortComp then
		Cyclopaedia_Calender.DailySortComp = SortByTimeAscend
		local hTitleTime = hWndDaily:Lookup("", "Handle_Title/Handle_Time")
		hTitleTime.bSort = true
		hTitleTime.bDescend = false
	end
	
	hList:Clear()
	table.sort(tDailyCanender, Cyclopaedia_Calender.DailySortComp)
	Cyclopaedia_Calender.tCurrentDaily = tDailyCanender
	for dwIndex, tLine in ipairs(tDailyCanender) do
		local hLine = hList:AppendItemFromIni(INI_PATH, "Handle_EventList_1")
		hLine.dwIndex = dwIndex
		hLine.dwID = tLine.dwID
		hLine:Lookup("Text_EventTime"):SetText(tLine.szTime)
		hLine:Lookup("Text_EventName"):SetText(tLine.szName)
		hLine:Lookup("Text_EventName"):SetFontScheme(tStateFont[tLine.nState])
		-- level 显示的时候去掉最后的分号
		local nLength = string.len(tLine.szLevel)
		local szLevel = string.sub(tLine.szLevel, 1, nLength - 1)
		hLine:Lookup("Text_EventLv"):SetText(szLevel)
		hLine:Lookup("Text_Award2"):SetText(tLine.szAward)
	end
	
	hList:FormatAllItemPos()	

    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_EventList", "Cyclopaedia_Calender", true)
	if hList:Lookup(0) then
		Cyclopaedia_Calender.SelectActive(hList:Lookup(0))
	end
	
	local hWnd = hWndDaily:GetParent()
	local tToday = GetTodayTime()
	if (tTime.year < tToday.year - 1) 
	or (tTime.year == tToday.year - 1 and tTime.month < tToday.month) 
	or (tTime.year == tToday.year - 1 and tTime.month == tToday.month and tTime.day == 1)  then
		hWnd:Lookup("Btn_PagePrev"):Enable(false)
	else
		hWnd:Lookup("Btn_PagePrev"):Enable(true)
	end
	
	local nNumber = GetDaysofMonth(tToday.year, tToday.month)
	
	if (tTime.year > tToday.year + 1) 
	or (tTime.year == tToday.year + 1 and tTime.month > tToday.month) 
	or (tTime.year == tToday.year + 1 and tTime.month == tToday.month and tTime.day == nNumber) then
		hWnd:Lookup("Btn_PageNext"):Enable(false)
	else
		hWnd:Lookup("Btn_PageNext"):Enable(true)
	end
end

function Cyclopaedia_Calender.SelectActive(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hLine = hList:Lookup(i)
		if hLine.bSelect then
			hLine:Lookup("Image_Sel_9"):Hide()
			hLine.bSelect = false
			break
		end
	end
	hSelect.bSelect = true
	hSelect:Lookup("Image_Sel_9"):SetAlpha(255)
	hSelect:Lookup("Image_Sel_9"):Show()
	local hWnd = hList:GetParent():GetParent()
	local tDaily = Cyclopaedia_Calender.tCurrentDaily
	Cyclopaedia_Calender.UpdateDailyDetail(hWnd, tDaily[hSelect.dwIndex])
end

function Cyclopaedia_Calender.UpdateDailyDetail(hWnd, tDetail)
	local hContentMsg = hWnd:Lookup("", "Handle_Announce/Handle_Info")
	ActivePopularize.AppendActiveDetail(hContentMsg, tDetail)
    
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Info", "Cyclopaedia_Calender", true)
end

function Cyclopaedia_Calender.SelectMiniDate(hItem)

	local hList = hItem:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do 
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild:Lookup("Image_DateOver"):Hide()
			hChild.bSelect = false
		end
	end
	
	hItem.bSelect = true
	hItem:Lookup("Image_DateOver"):Show()
	hItem:Lookup("Image_DateOver"):SetAlpha(256)
	
	local hWndMini = hItem:GetParent():GetParent():GetParent()
	hWndMini.nSelectDay = hItem.nDay
end

function Cyclopaedia_Calender.UpdateMiniMonth(hWndMini, tTime)
	local nTime = DateToTime(tTime.year, tTime.month, 1, 4, 5, 6)--取得该月第一天是星期几
	local tBegin = TimeToDate(nTime)
	hWndMini:Show()
	nWeek = tBegin.weekday % 7
	local nDays = GetDaysofMonth(tTime.year, tTime.month)
	if hWndMini.nSelectDay and hWndMini.nSelectDay > nDays then
		hWndMini.nSelectDay = nDays
	end
	local nNumber = nDays + nWeek
	local hTotalHandle = hWndMini:Lookup("", "")
	hWndMini.tDate = clone(tTime)
	hTotalHandle:Lookup("Text_Year"):SetText(tTime.year)
	hTotalHandle:Lookup("Text_Month"):SetText(tTime.month)
	local hHandle = hTotalHandle:Lookup("Handle_MiniMapSolo")
	local i = 0
	local nDate = 1;
	hHandle:Clear()
	while true do
		local hDate = hHandle:AppendItemFromIni(INI_PATH, "Handle_Date")
		hDate:Lookup("Image_Today"):Hide()
		hDate:Lookup("Image_DateOver"):Hide()
		hDate:Lookup("Image_DateNormal"):Show()
		if i >= nWeek and i < nNumber then
			hDate:Lookup("Text_DateNum"):SetText(nDate)
			hDate.nDay = nDate
			local tDate = clone(tTime)
			tDate.day = nDate
			local bToday = IsToday(tDate)
			if bToday then
				hDate:Lookup("Text_DateNum"):SetFontScheme(163)
				hDate:Lookup("Image_Today"):Show()
				hDate:Lookup("Image_DateNormal"):Hide()
			end
			if hWndMini.nSelectDay == nDate then
				hDate:Lookup("Image_DateOver"):Show()
				hDate:Lookup("Image_DateOver"):SetAlpha(256)
				hDate.bSelect = true
			end
			nDate = nDate + 1
		end
		
		i = i + 1
		if i >= nNumber and i % 7 == 0 then
			break
		end
	end
	
	hHandle:FormatAllItemPos()
	local _, fAllHeight = hHandle:GetAllItemSize()
	local fWidth = hHandle:GetSize()
	local _, fY = hHandle:GetRelPos()
	hHandle:SetSize(fWidth, fAllHeight)
	local fTotalWidth = hTotalHandle:GetSize()
	hTotalHandle:SetSize(fTotalWidth, fY + fAllHeight)
	hWndMini:SetSize(fTotalWidth, fY + fAllHeight)
	local hBgImage = hTotalHandle:Lookup("Image_Bg") 
	fWidth = hBgImage:GetSize()
	hBgImage:SetSize(fWidth, fY + fAllHeight + 10)
	
	local tToday = GetTodayTime()
	if (tTime.year < tToday.year - 1) or (tTime.year == tToday.year - 1 and tTime.month <= tToday.month) then
		hWndMini:Lookup("Btn_PagePrev_1"):Enable(false)
	else
		hWndMini:Lookup("Btn_PagePrev_1"):Enable(true)
	end
	
	if (tTime.year > tToday.year + 1) or (tTime.year == tToday.year + 1 and tTime.month >= tToday.month) then
		hWndMini:Lookup("Btn_PageNext_1"):Enable(false)
	else
		hWndMini:Lookup("Btn_PageNext_1"):Enable(true)
	end
end

function Cyclopaedia_Calender.CloseMiniMonth(hWndMini)
	hWndMini.nSelectDay = nil
	hWndMini:Hide()
	hWndMini:GetParent():Lookup("CheckBox_MiniMap"):Check(false)
end

function Cyclopaedia_Calender.UpdateMonth(hWndMonth)
	local tTime = Cyclopaedia_Calender.GetTime()
	local nTime = DateToTime(tTime.year, tTime.month, 1, 4, 5, 6)--取得该月第一天是星期几
	local tBegin = TimeToDate(nTime)
	nWeek = tBegin.weekday % 7
	local nDays = GetDaysofMonth(tTime.year, tTime.month)
	local nNumber = nDays + nWeek
	local hTotalHandle = hWndMonth:Lookup("", "")
	local szTime = FormatString(g_tStrings.STR_TIME_5, tTime.year, tTime.month)
	hTotalHandle:Lookup("Text_Date1"):SetText(szTime)
	local hHandle = hTotalHandle:Lookup("Handle_Month")
	local i = 0
	local nDate = 1;
	hHandle:Clear()
	Cyclopaedia_Calender.tDateActiveID = {0, 0, 0}
	while true do
		local hDate = hHandle:AppendItemFromIni(INI_PATH, "Handle_MonthSolo")
		
		if i >= nWeek and i < nNumber then
			hDate.nDay = nDate
			local tDate = clone(tTime)
			tDate.day = nDate
			
			local szLunar = GetLunarTextForMonthDate(tDate)
			hDate:Lookup("Handle_Top/Text_Date"):SetText(FormatString(g_tStrings.STR_ITEM_TEMP_ECHANT_LEFT_TIME, szLunar) .. " " .. nDate)
			hDate:Lookup("Handle_Top/Text_Date"):Show()
			local bToday = IsToday(tDate)
			if bToday then
				hDate:Lookup("Handle_Top/Text_Today"):Show()
				hDate:Lookup("Handle_Bottom/Image_TodayBottom_N"):Show()
				hDate:Lookup("Handle_Top/Text_Date"):SetFontScheme(163)
				hDate.bToday = true
			end
			if tTime.day == nDate then
				hDate:Lookup("Handle_Bottom/Image_DateWhole_P"):Show()
				hDate.bSelect = true
			end
			Cyclopaedia_Calender.UpdateMonthDate(hDate, tDate)
			nDate = nDate + 1
		else
			hDate:Lookup("Handle_Bottom/Image_DateBottom_N"):Hide()
			hDate:Lookup("Handle_Bottom/Image_DateWhole_Disable"):Show()
		end
		
		i = i + 1
		if i >= nNumber and i % 7 == 0 then
			break
		end
	end
	hHandle:FormatAllItemPos()
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Month", "Cyclopaedia_Calender", true)
	local hWnd = hWndMonth:GetParent()
	local tToday = GetTodayTime()
	if (tTime.year < tToday.year - 1) 
	or (tTime.year == tToday.year - 1 and tTime.month <= tToday.month) then
		hWnd:Lookup("Btn_PagePrev"):Enable(false)
	else
		hWnd:Lookup("Btn_PagePrev"):Enable(true)
	end
	
	if (tTime.year > tToday.year + 1) 
	or (tTime.year == tToday.year + 1 and tTime.month >= tToday.month) then
		hWnd:Lookup("Btn_PageNext"):Enable(false)
	else
		hWnd:Lookup("Btn_PageNext"):Enable(true)
	end
	
end

function Cyclopaedia_Calender.FilterMonthDate(tActive)
	local tResult = {}
	for _, tLine in ipairs(tActive) do
		if Cyclopaedia_Calender.tFilterClass[tLine.nClass] then
			table.insert(tResult, tLine)
		end
	end
	return tResult
end

function Cyclopaedia_Calender.UpdateMonthDate(hDate, tTime)
	local tActive = Table_GetCalenderOfDay(tTime.year, tTime.month, tTime.day, 2)
	tActive = Cyclopaedia_Calender.FilterMonthDate(tActive)
	table.sort(tActive, SortByPriority)
	
	local nCount = #tActive
	local nDisplayCount = 3
	if nCount > 3 then
		nDisplayCount = 2
	end
	local tDisplay = {}
	for nIndex = 1, 3 do
		dwID = Cyclopaedia_Calender.tDateActiveID[nIndex]
		if dwID > 0 then
			local bFind = false
			for _, tLine in ipairs(tActive) do
				if dwID == tLine.dwID then
					bFind = true
					Cyclopaedia_Calender.UpdateMonthActive(hDate, tTime, tLine, nIndex)
					tDisplay[dwID] = true
					break
				end			
			end	
			if not bFind then
				Cyclopaedia_Calender.tDateActiveID[nIndex] = 0
			end
		end
	end
	local nActiveIndex = 1
	for nIndex = 1, nDisplayCount do
		dwID = Cyclopaedia_Calender.tDateActiveID[nIndex]
		if dwID == 0 then
			while true do
				if nActiveIndex > nCount then
					break
				end
				if not tDisplay[tActive[nActiveIndex].dwID] then
					break
				end
				nActiveIndex = nActiveIndex + 1
			end
			if nActiveIndex > nCount then
				break
			end
			Cyclopaedia_Calender.UpdateMonthActive(hDate, tTime, tActive[nActiveIndex], nIndex)
			nActiveIndex = nActiveIndex + 1
		end
	end
	if nCount > 3 then
		hDate:Lookup("Handle_Expand_Down"):Show()
		hDate:Lookup("Handle_Expand_Down/Image_ExpandDown"):Show()
	end
end

function Cyclopaedia_Calender.UpdateMonthActive(hDate, tTime, tDateActive, nIndex)
	local hBottom = hDate:Lookup("Handle_Bottom")
	local hType = hBottom:Lookup("Image_Type_" .. nIndex)
	local hText = hBottom:Lookup("Text_Se_" .. nIndex)
	hType:Show()
	assert(tDateActive.nClass >= 1 and tDateActive.nClass <= #tClassFrame)
	hType:SetFrame(tClassFrame[tDateActive.nClass])
	hText:Show()
	hText:SetText(tDateActive.szName)
	hText.szLink = tDateActive.szDetailPath
	hText.dwID = tDateActive.dwID
	hText.szName = tDateActive.szName
	if tDateActive.bHighlight then
		local hImage = hBottom:Lookup("Image_Festival" .. nIndex)
		hImage:Show()
		hImage:FromUITex(tDateActive.szHighlightPath, tDateActive.nFrame)
		if tDateActive.nEvent == CALENDER_EVENT_START then -- 有跨度的活动才需要记录位置
			hType:Hide()
			local tStartTime = TimeToDate(tDateActive.nStartTime)
			local tEndTime = TimeToDate(tDateActive.nEndTime)
			local bStart = IsDateEqual(tStartTime, tTime)
			local bEnd = IsDateEqual(tEndTime, tTime)
			if bStart then
				hText:SetText(tDateActive.szName .. " " .. g_tStrings.CYCLOPAEDIA_CLENDER_ACTIVITY_START)
			elseif bEnd then
				hText:SetText(tDateActive.szName .. " " .. g_tStrings.CYCLOPAEDIA_CLENDER_ACTIVITY_END)
			else
				hText:SetText("")
			end
			Cyclopaedia_Calender.tDateActiveID[nIndex] = tDateActive.dwID
		end
	end
end
----------

function OpenCalenderPanel(bDisableSound)
	if not IsCalenderPanelOpened() then
		Wnd.OpenWindow("Cyclopaedia_Calender")
	end
    
    CloseActivePopularize()
	local hFrame = Station.Lookup("Normal/Cyclopaedia_Calender")
	hFrame:BringToTop()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsCalenderPanelOpened()
	local hFrame = Station.Lookup("Normal/Cyclopaedia_Calender")
	if hFrame then
		return true
	end
	
	return false
end

function CloseCalenderPanel(bDisableSound)
	if not IsCalenderPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("Cyclopaedia_Calender")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

do  
    RegisterScrollEvent("Cyclopaedia_Calender")
    
    UnRegisterScrollAllControl("Cyclopaedia_Calender")
        
    local szFramePath = "Normal/Cyclopaedia_Calender"
    local szWndPath = "Wnd_Calender/Wnd_DailyCalender"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BUp1_1", szWndPath.."/Btn_BDown1_1", 
        szWndPath.."/Scroll_List1_1", 
        {szWndPath, "Handle_EventList"})

    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BUP2_2", szWndPath.."/Btn_BDown2_2", 
        szWndPath.."/Scroll_List2_2", 
        {szWndPath, "Handle_Announce/Handle_Info"})
        
    szWndPath = "Wnd_Calender/Wnd_MonthlyCalender"
     RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BUp5", szWndPath.."/Btn_BDown5", 
        szWndPath.."/Scroll_List5", 
        {szWndPath, "Handle_Month"})
end