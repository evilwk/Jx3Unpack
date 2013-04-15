local INI_PATH =  "ui/Config/Default/Cyclopaedia_FAQ.ini"
local STEP_SIZE = 10

Cyclopaedia_FAQ = {}

function Cyclopaedia_FAQ.Update(hWnd)
	local tFAQ = Table_GetFAQList()
	Cyclopaedia_FAQ.UpdateList(hWnd, tFAQ)
	local hList = hWnd:Lookup("", "Handle_FAQList")
	Cyclopaedia_FAQ.Select(hList:Lookup(0))
end

----------------------
function Cyclopaedia_FAQ.OnItemLButtonDown(hItem)
	local szName = hItem:GetName()
	if szName == "TreeLeaf_Page" then
		Cyclopaedia_FAQ.Select(hItem)
	end
end

function Cyclopaedia_FAQ.OnLButtonDown(hButton)
	local szName = hButton:GetName()
	local hWnd = hButton:GetParent()
    if szName == "Btn_FAQInfoUp" then
		--hWnd:Lookup("Scroll_FAQInfo"):ScrollPrev()
	elseif szName == "Btn_FAQInfoDown" then
		--hWnd:Lookup("Scroll_FAQInfo"):ScrollNext()
	elseif szName == "Btn_FAQLeftUp" then
		hWnd:Lookup("Scroll_FAQLeft"):ScrollPrev()
	elseif szName == "Btn_FAQLeftDown" then
		hWnd:Lookup("Scroll_FAQLeft"):ScrollNext()
	end
end

function Cyclopaedia_FAQ.OnScrollBarPosChanged(hScroll)
	local szName = hScroll:GetName()
	local nCurrentValue = hScroll:GetScrollPos()
	if szName == "Scroll_FAQInfo" then
        --[[
		local hWndInfo = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWndInfo:Lookup("Btn_FAQInfoUp"):Enable(false)
		else
			hWndInfo:Lookup("Btn_FAQInfoUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWndInfo:Lookup("Btn_FAQInfoDown"):Enable(false)
		else
			hWndInfo:Lookup("Btn_FAQInfoDown"):Enable(true)
		end
		hWndInfo:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
        --]]
	elseif szName == "Scroll_FAQLeft" then
		local hWnd = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_FAQLeftUp"):Enable(false)
		else
			hWnd:Lookup("Btn_FAQLeftUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWnd:Lookup("Btn_FAQLeftDown"):Enable(false)
		else
			hWnd:Lookup("Btn_FAQLeftDown"):Enable(true)
		end
		hWnd:Lookup("", "Handle_FAQList"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end

function Cyclopaedia_FAQ.OnItemMouseEnter(hItem)
	if hItem.bFAQClass then
		hItem.bMouse = true
		Cyclopaedia_FAQ.UpdateTitle(hItem)
	end
end

function Cyclopaedia_FAQ.OnItemMouseLeave(hItem)
	if hItem.bFAQClass then
		hItem.bMouse = false
		Cyclopaedia_FAQ.UpdateTitle(hItem)
	end
end

function Cyclopaedia_FAQ.OnItemMouseWheel(hItem)
	local nDistance = Station.GetMessageWheelDelta()
	local szName = hItem:GetName()
	
	if szName == "Handle_FAQList" then
		local hWnd = hItem:GetParent():GetParent()
		hWnd:Lookup("Scroll_FAQLeft"):ScrollNext(nDistance)
	elseif szName == "Handle_FAQInfo" then
        --[[
		local hWndInfo = hItem:GetParent()
		hWndInfo:Lookup("Scroll_FAQInfo"):ScrollNext(nDistance)
        --]]
	end
end
-------------------------
function Cyclopaedia_FAQ.UpdateList(hWnd, tFAQ)
	local hList = hWnd:Lookup("", "Handle_FAQList")
	hList:Clear()
	
	for dwClassID, tSub in pairs(tFAQ) do
		local hClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Page")
		local szClassName = Table_GetFAQClassName(dwClassID)
		hClass:Lookup("Text_Page"):SetText(szClassName)
		hClass.dwClassID = dwClassID
		hClass.bFAQClass = true
		hClass.tInfo = tSub
	end

	local _, _, szVersionLineName = GetVersion()
	if szVersionLineName == "zhkr" then
		local hClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Page")
		hClass:Lookup("Text_Page"):SetText(g_tStrings.KOREA_LOGO_LEVEL)
		hClass.bKoreaLogo = true
		hClass.bFAQClass = true
	end
	hList:FormatAllItemPos()
	
	Cyclopaedia_FAQ.UpdateListScroll(hList, true)
end


function Cyclopaedia_FAQ.UpdateListScroll(hList, bHome)
	local hWnd = hList:GetParent():GetParent()
	local hScroll = hWnd:Lookup("Scroll_FAQLeft")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_FAQLeftUp"):Show()
		hWnd:Lookup("Btn_FAQLeftDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_FAQLeftUp"):Hide()
		hWnd:Lookup("Btn_FAQLeftDown"):Hide()
	end	
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function Cyclopaedia_FAQ.Select(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	local bFind = false
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			Cyclopaedia_FAQ.UpdateTitle(hChild)
			break
		end
	end
	
	local hWnd = hList:GetParent():GetParent()
	hSelect.bSelect = true
	Cyclopaedia_FAQ.UpdateTitle(hSelect)
	if hSelect.bKoreaLogo then
		Cyclopaedia_FAQ.UpdateKoreaLogoInfo(hWnd)
	else
		Cyclopaedia_FAQ.UpdateInfo(hWnd, hSelect.dwClassID, hSelect.tInfo)
	end
end

function Cyclopaedia_FAQ.UpdateTitle(hItem)
	local hImage = hItem:Lookup(1)
	if hItem.bSelect then
		hImage:Show()
	elseif hItem.bMouse then
		hImage:Show()
	else
		hImage:Hide()
	end
end

function Cyclopaedia_FAQ.UpdateKoreaLogoInfo(hWnd)
	local hInfo = hWnd:Lookup("Wnd_Info", "")
	hInfo:Clear()

	local hLogo = hInfo:AppendItemFromIni(INI_PATH, "Handle_KoreaIcon")
	hLogo:Show()
	local szText = GetFormatText("\n" .. g_tStrings.KOREA_LOGO_LEVEL .. "\n", 157)
	szText = szText .. GetFormatText(g_tStrings.KOREA_LOGO_LEVEL_CONTENT .. "\n\n", 162)
	hInfo:AppendItemFromString(szText)
	
	hInfo:FormatAllItemPos()
	Cyclopaedia_FAQ.UpdateInfoScroll(hInfo, true)
end

function Cyclopaedia_FAQ.UpdateInfo(hWnd, dwClassID, tInfo)
	local hInfo = hWnd:Lookup("Wnd_Info/Wnd_ScrollInfo", "")
	hInfo:Clear()
	
	for dwIndex, dwSubClassID in ipairs(tInfo) do
		local tQuestion = Table_GetFAQContent(dwClassID, dwSubClassID)
		local szText = GetFormatText(dwIndex .. "." .. tQuestion.szQuestion .. "\n", 157)
		szText = szText .. GetFormatText(tQuestion.szAnswer .. "\n\n", 162)
		
		hInfo:AppendItemFromString(szText)
	end 
	
	hInfo:FormatAllItemPos()
    hList:GetParent():Lookup("Scroll_FAQInfo"):ScrollHome()
	--Cyclopaedia_FAQ.UpdateInfoScroll(hInfo, true)
end

function Cyclopaedia_FAQ.UpdateInfoScroll(hList, bHome)
	local hWndInfo = hList:GetParent()
	local hScroll = hWndInfo:Lookup("Scroll_FAQInfo")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if bHome then
		hScroll:ScrollHome()
	end
	if nStepCount > 0 then
		hScroll:Show()
		hWndInfo:Lookup("Btn_FAQInfoUp"):Show()
		hWndInfo:Lookup("Btn_FAQInfoDown"):Show()
	else
		hScroll:Hide()
		hWndInfo:Lookup("Btn_FAQInfoUp"):Hide()
		hWndInfo:Lookup("Btn_FAQInfoDown"):Hide()
	end	
end