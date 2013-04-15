ProgressSaveData = {}
ProgressSaveData.Anchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 0, y = -250}
ProgressSaveData.bOutLog = false
ProgressSaveData.bOpen = false
g_bProgressSaveData_Loaded = false

local lc_nTotalData = 0

local lc_hFrame
local lc_hImageP
local lc_hTextTip
local lc_hTextTitle

function ProgressSaveData.Init(szText, nTotalData)
	lc_hTextTip:SetText(szText)
	lc_hImageP:SetPercentage(0)
end

function ProgressSaveData.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	lc_hFrame = this
	lc_hTextTip = lc_hFrame:Lookup("", "Text_Tip")
	lc_hImageP = lc_hFrame:Lookup("", "Image_Progress")
	lc_hTextTitle = lc_hFrame:Lookup("", "Text_Title")
	
	ProgressSaveData.UpdateAnchor(this)
end

function ProgressSaveData.OnEvent(event)
    if event == "UI_SCALED" then
		ProgressSaveData.UpdateAnchor(this)
	end
end

function ProgressSaveData.UpdateAnchor(frame)
	frame:SetPoint(ProgressSaveData.Anchor.s, 0, 0, ProgressSaveData.Anchor.r, ProgressSaveData.Anchor.x, ProgressSaveData.Anchor.y)
	frame:CorrectPos()
end

function IsProgressSaveDataOpend()
	local frame = Station.Lookup("Topmost2/ProgressSaveData")
	if frame and frame:IsVisible() then
		return true;
	end
	return false
end

function OpenProgressSaveData()
	if IsProgressSaveDataOpend() then
		return
	end
	
	local frame = Wnd.OpenWindow("ProgressSaveData")
end

function CloseProgressSaveData()
	if not IsProgressSaveDataOpend() then
		return
	end
	
	Wnd.CloseWindow("ProgressSaveData")
end

function ProgressSaveData_Title(szText)
	if ProgressSaveData.bOutLog then
		Trace(szText)
	end
	
	if ProgressSaveData.bOpen  then 
		OpenProgressSaveData()
		lc_hTextTitle:SetText(szText)
		Station.Paint()
	end
end

function ProgressSaveData_Begin(szText, nTotalData)
	if nTotalData == 0 then
		return
	end
	
	if ProgressSaveData.bOutLog then
		Trace(szText)
	end
	
	if ProgressSaveData.bOpen then 
		OpenProgressSaveData()
		ProgressSaveData.Init(szText, nTotalData)
		lc_nTotalData = nTotalData
	end
end

function ProgressSaveData_LoadOne(szText, nIndex)
	if ProgressSaveData.bOpen then
		lc_hTextTip:SetText(szText)
		lc_hImageP:SetPercentage(nIndex / lc_nTotalData)
		
		local nMillSecond = GetTickCount()
		if not ProgressSaveData.nLastMillSecond or nMillSecond - 40 > ProgressSaveData.nLastMillSecond then
			
			Station.Paint()
			ProgressSaveData.nLastMillSecond = GetTickCount()
		end
	end
	
	ProgressSaveData.nBeginTime = GetTickCount()
end

function ProgressSaveData_FinishOne(szText, nIndex)
	if ProgressSaveData.bOutLog then
		local nCost = GetTickCount()- ProgressSaveData.nBeginTime
		Trace(szText.."  ("..nIndex.."/"..lc_nTotalData..") time:".. nCost.."ms")
	end
end

function ProgressSaveData_End(szText)
	if ProgressSaveData.bOutLog then
		Trace(szText)
	end
	
	if ProgressSaveData.bOpen then
		CloseProgressSaveData()
		Station.Paint()
	end
	ProgressSaveData.nLastMillSecond = nil
end

function ProgressSaveData_TurnOn(bOpen)
	ProgressSaveData.bOpen = bOpen
end

function GetLuaFrameInfo()
	local tLayer = 
	{
		"Lowest",
		"Lowest1",
		"Lowest2",
		"Normal",
		"Normal1",
		"Normal2",
		"Topmost",
		"Topmost1",
		"Topmost2",
	}
	
	local nTotal = 0;
	local nAddonCount = 0
	local fnCount = function(frame)
		local hBorther = frame
		while hBorther do
			if hBorther:IsAddOn() then
				nAddonCount = nAddonCount + 1
				--Trace("addon", hBorther:GetName(), hBorther:GetType(), nAddonCount)
			end
			nTotal = nTotal + 1
			hBorther = hBorther:GetNext()
		end
	end
	
	for _, v in pairs(tLayer) do
		local hRoot = Station.Lookup(v)
		local frame = hRoot:GetFirstChild()
		if frame then
			fnCount(frame)
		end
	end
	
	local szTip = string.format("addonWindow(%d) TotalWindow(%d)", nAddonCount, nTotal)
	szTip = szTip .. "\nlua mem:"..collectgarbage("count")
	return szTip
end

g_bProgressSaveData_Loaded = true