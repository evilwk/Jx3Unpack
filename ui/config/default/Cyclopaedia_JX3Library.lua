local INI_PATH =  "ui/Config/Default/Cyclopaedia_JX3Library.ini"
local STEP_SIZE = 10
local FONT_TITLE = 59

Cyclopaedia_JX3Library = {}

function Cyclopaedia_JX3Library.Update(hWnd)
	local tJX3Library = Table_GetJX3LibraryList()
	Cyclopaedia_JX3Library.UpdateList(hWnd, tJX3Library)
	local hList = hWnd:Lookup("", "Handle_List")
	Cyclopaedia_JX3Library.Select(hList:Lookup(0))
end

function Cyclopaedia_JX3Library.OnEditSpecialKeyDown(hItem)
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = hItem:GetName()
	if szName == "Edit_LibrarySearch" and szKey == "Enter" then
		local hWnd = this:GetParent()
		local szText = hItem:GetText()
		Cyclopaedia_JX3Library.SearchInfo(hWnd, szText)
	end
end

function Cyclopaedia_JX3Library.OnItemLButtonDown(hItem)
	local szName = hItem:GetName()
	if szName == "TreeLeaf_JX3Library" then
		if hItem.bLibraryClass or hItem.bLibrarySubClass then
			if hItem:IsExpand() then
				hItem:Collapse()
			else
				hItem:Expand()
			end
			local hList = hItem:GetParent()
			hList:FormatAllItemPos()
			Cyclopaedia_JX3Library.UpdateListScroll(hList)
		end
		
		Cyclopaedia_JX3Library.Select(hItem)
	end
end

function Cyclopaedia_JX3Library.OnLButtonClick(hButton)
	local szName = hButton:GetName()
	if szName == "Btn_LibrarySearch" then
		local hWnd = hButton:GetParent()
		local szText = hWnd:Lookup("Edit_LibrarySearch"):GetText()
		Cyclopaedia_JX3Library.SearchInfo(hWnd, szText)
	end
end

function Cyclopaedia_JX3Library.OnLButtonDown(hButton)
	local szName = hButton:GetName()
	local hWnd = hButton:GetParent()
    if szName == "Btn_jX3InfoUp" then
		hWnd:Lookup("Scroll_LibraryInfo"):ScrollPrev()
	elseif szName == "Btn_Jx3InfoDown" then
		hWnd:Lookup("Scroll_LibraryInfo"):ScrollNext()
	elseif szName == "Btn_jX3LeftUp" then
		hWnd:Lookup("Scroll_Left"):ScrollPrev()
	elseif szName == "Btn_Jx3LeftDown" then
		hWnd:Lookup("Scroll_Left"):ScrollNext()
	end
end

function Cyclopaedia_JX3Library.OnScrollBarPosChanged(hScroll)
	local szName = hScroll:GetName()
	local nCurrentValue = hScroll:GetScrollPos()
	if szName == "Scroll_LibraryInfo" then
		local hWndInfo = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWndInfo:Lookup("Btn_jX3InfoUp"):Enable(false)
		else
			hWndInfo:Lookup("Btn_jX3InfoUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWndInfo:Lookup("Btn_Jx3InfoDown"):Enable(false)
		else
			hWndInfo:Lookup("Btn_Jx3InfoDown"):Enable(true)
		end
		hWndInfo:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	elseif szName == "Scroll_Left" then
		local hWnd = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_jX3LeftUp"):Enable(false)
		else
			hWnd:Lookup("Btn_jX3LeftUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWnd:Lookup("Btn_Jx3LeftDown"):Enable(false)
		else
			hWnd:Lookup("Btn_Jx3LeftDown"):Enable(true)
		end
		hWnd:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end

function Cyclopaedia_JX3Library.OnItemMouseEnter(hItem)
	if hItem.bLibraryClass or hItem.bLibrarySubClass or hItem.bLibraryTitle then
		hItem.bMouse = true
		Cyclopaedia_JX3Library.UpdateTitle(hItem)
	end
end

function Cyclopaedia_JX3Library.OnItemMouseLeave(hItem)
	if hItem.bLibraryClass or hItem.bLibrarySubClass or hItem.bLibraryTitle then
		hItem.bMouse = false
		Cyclopaedia_JX3Library.UpdateTitle(hItem)
	end
end

function Cyclopaedia_JX3Library.OnItemMouseWheel(hItem)
	local nDistance = Station.GetMessageWheelDelta()
	local szName = hItem:GetName()
	
	if szName == "Handle_List" then
		local hWnd = hItem:GetParent():GetParent()
		hWnd:Lookup("Scroll_Left"):ScrollNext(nDistance)
	elseif szName == "Handle_LibraryInfo" then
		local hWndInfo = hItem:GetParent()
		hWndInfo:Lookup("Scroll_LibraryInfo"):ScrollNext(nDistance)
	end
end

function Cyclopaedia_JX3Library.UpdateList(hWnd, tJX3Library, bExpand)
	local hList = hWnd:Lookup("", "Handle_List")
	hList:Clear()
	
	for _, tClass in ipairs(tJX3Library) do
		local hClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Class", "TreeLeaf_JX3Library")
		if bExpand then
			hClass:Expand()
		end
		hClass:Lookup("Text_Class"):SetText(tClass.tInfo.szName)
		hClass.dwClassID = tClass.tInfo.dwClassID
		hClass.dwSubClassID = tClass.tInfo.dwSubClassID
		hClass.dwID = tClass.tInfo.dwID
		hClass.bLibraryClass = true
		
		for _, tSub in ipairs(tClass.tList) do
			local hSubClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_SubClass", "TreeLeaf_JX3Library")
			if bExpand then
				hSubClass:Expand()
			end
			hSubClass:Lookup("Text_SubClass"):SetText(tSub.tInfo.szName)
			hSubClass.dwClassID = tClass.tInfo.dwClassID
			hSubClass.dwSubClassID = tSub.tInfo.dwSubClassID
			hSubClass.dwID = tSub.tInfo.dwID
			hSubClass.bLibrarySubClass = true
			
			for _, tRecord in ipairs(tSub.tList) do
				local hTitle = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Page", "TreeLeaf_JX3Library")
				hTitle:Lookup("Text_Page"):SetText(tRecord.tInfo.szName)
				hTitle.dwClassID = tClass.tInfo.dwClassID
				hTitle.dwSubClassID = tSub.tInfo.dwSubClassID
				hTitle.dwID = tRecord.tInfo.dwID
				hTitle.bLibraryTitle = true
			end
		end
	end
	hList:FormatAllItemPos()
	
	Cyclopaedia_JX3Library.UpdateListScroll(hList, true)
end

function Cyclopaedia_JX3Library.Select(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	local bFind = false
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			Cyclopaedia_JX3Library.UpdateTitle(hChild)
			break
		end
	end
	
	hSelect.bSelect = true
	Cyclopaedia_JX3Library.UpdateTitle(hSelect)
	Cyclopaedia_JX3Library.UpdateInfo(hList:GetParent():GetParent(), hSelect.dwClassID, hSelect.dwSubClassID, hSelect.dwID)
end

function Cyclopaedia_JX3Library.UpdateTitle(hItem)
	local hImage = hItem:Lookup(1)
	if hItem.bSelect then
		hImage:Show()
	elseif hItem.bMouse then
		hImage:Show()
	else
		hImage:Hide()
	end
end

function Cyclopaedia_JX3Library.UpdateNoSearch(hWnd)
		local hList = hWnd:Lookup("", "Handle_List")
		hList:Clear()
		local hNoSearch = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Class", "TreeLeaf_JX3NoSearch")
		hNoSearch:Lookup("Text_Class"):SetText(g_tStrings.NOT_FINED)
		hList:FormatAllItemPos()
		Cyclopaedia_JX3Library.UpdateListScroll(hList)
		
		local hInfo = hWnd:Lookup("Wnd_Info", "")
		hInfo:Clear()
		Cyclopaedia_JX3Library.UpdateInfoScroll(hInfo, true)
end

function Cyclopaedia_JX3Library.UpdateInfo(hWnd, dwClassID, dwSubClassID, dwID)
	local tRecord = Table_GetJX3LibraryContent(dwClassID, dwSubClassID, dwID)
	local hInfo = hWnd:Lookup("Wnd_Info", "")
	hInfo:Clear()
	
	hInfo:AppendItemFromString(tRecord.szContent)
	if tRecord.szLink ~= "" then
		hInfo:AppendItemFromString(GetFormatText("\n\n\n\n" .. g_tStrings.CYCLOPAEDIA_LINK, FONT_TITLE))
		hInfo:AppendItemFromString(tRecord.szLink)
	end
	
	hInfo:FormatAllItemPos()
	Cyclopaedia_JX3Library.UpdateInfoScroll(hInfo, true)
end

function Cyclopaedia_JX3Library.UpdateInfoScroll(hList, bHome)
	local hWndInfo = hList:GetParent()
	local hScroll = hWndInfo:Lookup("Scroll_LibraryInfo")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if bHome then
		hScroll:ScrollHome()
	end
	if nStepCount > 0 then
		hScroll:Show()
		hWndInfo:Lookup("Btn_jX3InfoUp"):Show()
		hWndInfo:Lookup("Btn_Jx3InfoDown"):Show()
	else
		hScroll:Hide()
		hWndInfo:Lookup("Btn_jX3InfoUp"):Hide()
		hWndInfo:Lookup("Btn_Jx3InfoDown"):Hide()
	end	
end

function Cyclopaedia_JX3Library.UpdateListScroll(hList, bHome)
	local hWnd = hList:GetParent():GetParent()
	local hScroll = hWnd:Lookup("Scroll_Left")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_jX3LeftUp"):Show()
		hWnd:Lookup("Btn_Jx3LeftDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_jX3LeftUp"):Hide()
		hWnd:Lookup("Btn_Jx3LeftDown"):Hide()
	end	
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function Cyclopaedia_JX3Library.SearchInfo(hWnd, szText)
	local tJX3Library = Table_GetJX3LibraryList()
	local tResult = {}
	
	local bSearch = false
	for _, tClass in pairs(tJX3Library) do
		if StringFindW(tClass.tInfo.szName, szText) then
			table.insert(tResult, tClass)
			bSearch = true
		else
			for _, tSub in pairs(tClass.tList) do
				if StringFindW(tSub.tInfo.szName, szText) then
					table.insert(tResult, tSub)
					bSearch = true
				else
					for _, tRecord in pairs(tSub.tList) do
						if StringFindW(tRecord.tInfo.szName, szText) then
							table.insert(tResult, tRecord)
							bSearch = true
						end
					end
				end
			end
		end
	end
	
	if bSearch then
		Cyclopaedia_JX3Library.UpdateList(hWnd, tResult, true)
		local hList = hWnd:Lookup("", "Handle_List")
		Cyclopaedia_JX3Library.Select(hList:Lookup(0))
	else
		Cyclopaedia_JX3Library.UpdateNoSearch(hWnd)
	end
end

function Cyclopaedia_LinkJX3Library(hFrame, dwClassID, dwSubClassID, dwID)
	local hWnd = hFrame:Lookup("PageSet_Total/Page_JX3Library/Wnd_JX3Library")
	Cyclopaedia_JX3Library.Update(hWnd)
	local hList = hWnd:Lookup("", "Handle_List")
	
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hTitle = hList:Lookup(i)
		if (hTitle.bLibraryClass and hTitle.dwClassID == dwClassID) 
		or (hTitle.bLibrarySubClass and hTitle.dwClassID == dwClassID and hTitle.dwSubClassID == dwSubClassID) then
			hTitle:Expand()
			hList:FormatAllItemPos()
			Cyclopaedia_JX3Library.UpdateListScroll(hList)
			Cyclopaedia_JX3Library.Select(hTitle)
		end
		
		if hTitle.dwClassID == dwClassID and hTitle.dwSubClassID == dwSubClassID and hTitle.dwID == dwID then
			Cyclopaedia_JX3Library.Select(hTitle)
			break
		end
	end
end