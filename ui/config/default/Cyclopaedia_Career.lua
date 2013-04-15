Cyclopaedia_Career = {}

local INI_PATH = "ui/Config/Default/Cyclopaedia_Career.ini"
local STEP_SIZE = 10

function Cyclopaedia_Career.Update(hWnd)
	Cyclopaedia_Career.UpdateList(hWnd)
	Cyclopaedia_Career.Select(hWnd:Lookup("", "Handle_CareerList"):Lookup(0))
	FireDataAnalysisEvent("CYCLOPAEDIA_CAREER_OPEN")
end

function Cyclopaedia_Career.UpdateList(hWnd)
	local hList = hWnd:Lookup("", "Handle_CareerList")
	hList:Clear()
	
	local tCareer = Table_GetCareerAllEventTitle()
	for k, v in ipairs(tCareer) do
		if v.nLevel <= 70 then
			local hTitle = hList:AppendItemFromIni(INI_PATH, "HI_List")
			hTitle:Lookup("Text_List"):SetFontScheme(163)
			hTitle:Lookup("Text_List"):SetText(FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, v.nLevel) .. "  ".. v.szName)
			hTitle.nLevel = v.nLevel
		end
	end
	hList:FormatAllItemPos()
end

function Cyclopaedia_Career.Select(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	local hWnd = hList:GetParent():GetParent()
	
	for i = 0, nCount - 1 do
		local hTitle = hList:Lookup(i)
		if hTitle.bSelect then
			hTitle.bSelect = false
			Cyclopaedia_Career.UpdateTitle(hTitle)
			break
		end
	end
	hSelect.bSelect = true
	hWnd.nLevel = hSelect.nLevel
	Cyclopaedia_Career.UpdateTitle(hSelect)
	Cyclopaedia_Career.UpdateInfo(hWnd:Lookup("Wnd_Info"), hSelect.nLevel)
end

function Cyclopaedia_Career.UpdateTitle(hTitle)
	if hTitle.bSelect then
		hTitle:Lookup("TN_List"):Show()
	elseif hTitle.bMouse then
		hTitle:Lookup("TN_List"):Show()
	else
		hTitle:Lookup("TN_List"):Hide()
	end
end

function Cyclopaedia_Career.OnScrollBarPosChanged(hScroll)
	local szName = hScroll:GetName()
	local nCurrentValue = hScroll:GetScrollPos()
	local hWnd = hScroll:GetParent()
	
	if szName == "Scroll_RCareer" then
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_RCareerUp"):Enable(false)
		else
			hWnd:Lookup("Btn_RCareerUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWnd:Lookup("Btn_RCareerDown"):Enable(false)
		else
			hWnd:Lookup("Btn_RCareerDown"):Enable(true)
		end
	    hWnd:Lookup("", "Handle_CareerText"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end


function Cyclopaedia_Career.UpdateInfo(hWnd, nLevel)
	local tInfo = Table_GetCareerInfo(nLevel)
	local hHandleInfo = hWnd:Lookup("", "Handle_CareerText")
	hHandleInfo:Clear()
	
	local hImage  = hHandleInfo:AppendItemFromIni(INI_PATH, "Image_Message")
	hImage:FromTextureFile(tInfo.szImage)
	
	local szText = Coures.GetFormatNote(tInfo.szIntroduction, 135, 136)
	hHandleInfo:AppendItemFromString(szText)
	hHandleInfo:FormatAllItemPos()
	
	Cyclopaedia_Career.UpdateInfoScroll(hHandleInfo)
end

function Cyclopaedia_Career.UpdateInfoScroll(hList)
	local hWnd = hList:GetParent():GetParent()
	local hScroll = hWnd:Lookup("Scroll_RCareer")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_RCareerUp"):Show()
		hWnd:Lookup("Btn_RCareerDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_RCareerUp"):Hide()
		hWnd:Lookup("Btn_RCareerDown"):Hide()
	end	
end

function Cyclopaedia_Career.OnItemLButtonDown(hItem)
	local szName = hItem:GetName()
	if szName == "HI_List" then
		Cyclopaedia_Career.Select(hItem)
	end
end

function Cyclopaedia_Career.OnItemMouseEnter(hItem)
	local szName = hItem:GetName()
	if szName == "HI_List" then
		hItem.bMouse = true
		Cyclopaedia_Career.UpdateTitle(hItem)
	elseif szName == "Handle_Coures" then
		local hText = hItem:Lookup("Text_Coures")
		hText.nOldFont = hText:GetFontScheme()
		hText:SetFontScheme(188)
	end
end

function Cyclopaedia_Career.OnItemMouseLeave(hItem)
	local szName = hItem:GetName()
	if szName == "HI_List" then
		hItem.bMouse = false
		Cyclopaedia_Career.UpdateTitle(hItem)
	elseif szName == "Handle_Coures" then
		local hText = hItem:Lookup("Text_Coures")
		hText:SetFontScheme(hText.nOldFont)
	end
end

function Cyclopaedia_Career.OnItemLButtonClick(hItem)
	local szName = hItem:GetName()
	if szName == "Handle_Coures" then
		local hWnd = hItem:GetParent():GetParent():GetParent()
		local nLevel = hWnd.nLevel
		OpenCoures(nLevel)
	end
end

function Cyclopaedia_Career.OnItemMouseWheel(hItem)
	local nDistance = Station.GetMessageWheelDelta()
	local szName = hItem:GetName()
	local hWnd = hItem:GetParent():GetParent()
	
	if szName == "Handle_CareerText" then
		hWnd:Lookup("Scroll_RCareer"):ScrollNext(nDistance)
	end
	
end

function Cyclopaedia_Career.OnLButtonDown(hButton)
	local szName = hButton:GetName()
	local hWnd = hButton:GetParent()
	if szName == "Btn_RCareerUp" then
		hWnd:Lookup("Scroll_RCareer"):ScrollPrev()
	elseif szName == "Btn_RCareerDown" then
		hWnd:Lookup("Scroll_RCareer"):ScrollNext()
	end
end

function Cyclopaedia_LinkCareer(hFrame, nLevel)
	local hWnd = hFrame:Lookup("PageSet_Total/Page_Career/Wnd_Career")
	local hList = hWnd:Lookup("", "Handle_CareerList")
	
	local nCount = hList:GetItemCount()
	for i = 1, nCount - 1 do
		local hTitle = hList:Lookup(i)
		if hTitle.nLevel == nLevel then
			Cyclopaedia_Career.Select(hTitle)
			break
		end
	end
end




