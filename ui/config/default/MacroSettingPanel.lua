---------------------------------------
--------------ºêÉèÖÃÃæ°å---------------
------Created by Hu Chang Yin----------
------	  ²ÝÊ÷Öª´º²»¾Ã¹é	 ----------
------	  °Ù°ãºì×Ï¶··¼·Æ	 ----------
------	  Ñî»¨ÓÜ¼ÔÎÞ²ÅË¼	 ----------
------	  Î©½âÂþÌì×÷Ñ©·É	 ----------
---------------------------------------


MacroSettingPanel = 
{
	aIcon = 
	{
		402,	403,	404,	405,	407,	408,	410,	411,	413,	414,	416,
		417,	418,	419,	420,	421,	422,	423,  424,	426,	427,	428,
		430,	432,	433,  434,	436,	437,	438,	440,	441,	607,	608,
		609,	610,	630,	631,	621,	617,	620,	621,	622,	623,	624,
		625,	626,	629,	630,	631,	634,	635,	636,	637,	638,	640,
		641,	642,	643,	644,	646,	647,	648,	649,	650,	652,	653,
		654,	655,	656,  886,	891,	892,	894,	895,	896,	897,	898,
		899,  900,	901,	902,	903,	904,	905,	906,	907,	908,  912,
		913,	914,	915,	1438,	1439,	1440,	1441,	1442,	1443,	1444, 1445,
		1446,	1447,	1448,	1449,	1450,	1452,	1453,	1454,	1455, 1456,	1482,
		1483,	1484,	1485,	1486,	1488,	1489,	1490,	1491, 1492,	1496,	1497,
		1498,	1499,	1500,	1501,	1502, 1503,	1504,	1505,	1506,	1507,	1508,
		1509,	1510,	1511,	1513,	1514,	1515,	1516,	1517,	1518,	1519,	1520,		
		2240,	2242,	2247,	2249,	2256,	2259,	2264,	2269,	2274,	2276,	2271,													
	},
}

local aMacroData = {}
local function SetMacroData(box)
	aMacroData[box] = box.dwID
end

function MacroSettingPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	MacroSettingPanel.OnEvent("UI_SCALED")
	
	this:Lookup("", "Text_MaxByte"):SetText(FormatString(g_tStrings.MACRO_INPUT_LIMIT, 0, 1024))
	
	local hBox = this:Lookup("", "Handle_Icon")
	hBox:Clear()
	for i = 1, 22, 1 do 
		hBox:AppendItemFromIni("UI/Config/default/MacroSettingPanel.ini", "Box_Icon")
	end
	hBox:FormatAllItemPos()
	MacroSettingPanel.nPageCount = math.ceil(#(MacroSettingPanel.aIcon) / 22)
	MacroSettingPanel.nCurrentPage = 1
	 
	MacroSettingPanel.Update(this)
	MacroSettingPanel.UpdateSelect(this)
end

function MacroSettingPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end
	local hList = this:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local box = hList:Lookup(i):Lookup("Box_Skill")
		UpdateMacroCDProgress(player, box)
	end
end

function MacroSettingPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function MacroSettingPanel.Update(frame)
	local hList = frame:Lookup("", "Handle_List")
	hList:Clear()
	aMacroData = {}
	for k, v in pairs(g_Macro) do
		MacroSettingPanel.NewMacroTitle(hList, k)
	end
	MacroSettingPanel.UpdateScrollInfo(hList)
end

function MacroSettingPanel.NewMacroTitle(hList, dwID)
	if not IsMacroRemoved(dwID) then
		local hI = hList:AppendItemFromIni("UI/Config/default/MacroSettingPanel.ini", "HI")
		hI:Lookup("Name"):SetText(GetMacroName(dwID))
		
		local box = hI:Lookup("Box_Skill")
		box:SetObject(UI_OBJECT_MACRO, dwID)
		box:SetObjectIcon(GetMacroIcon(dwID))
		box.dwID = dwID
		SetMacroData(box)
		
		hI.dwID = dwID
		hI.bMacroTitle = true
		return hI
	end
end

function MacroSettingPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if this.bMacroTitle then
		this.bOver = true
		MacroSettingPanel.UpdateState(this)
	elseif szName == "Box_Skill" then
		this:SetObjectMouseOver(true)
		if not this:IsEmpty() then
			local frame = this:GetRoot()
			if this.dwID then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputMacroTip(this.dwID, {x, y, w, h})
			end
		end
	elseif szName == "Box_Icon" then
		this:SetObjectMouseOver(true)		
	end
end

function MacroSettingPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if this.bMacroTitle then
		this.bOver = false
		MacroSettingPanel.UpdateState(this)
	elseif szName == "Box_Skill" then
		this:SetObjectMouseOver(false)
		HideTip()
	elseif szName == "Box_Icon" then
		this:SetObjectMouseOver(false)
	end
end

function MacroSettingPanel.OnItemLButtonDrag()
	if this:GetName() == "Box_Skill" then	
		if this:IsEmpty() then
			return
		end
		
		if IsCursorInExclusiveMode() then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			PlayTipSound("010")
			return
		end
				
		Hand_Pick(this, nil, true)
	end
end

function MacroSettingPanel.OnItemLButtonDragEnd()
	if this:GetName() == "Box_Skill" then	
		this.bDisableClick = true
		if Hand_IsEmpty() then
			return
		end
		local frame = this:GetRoot()
		local boxHand = Hand_Get()
		local dwType, dwID = boxHand:GetObject()
		if dwType == UI_OBJECT_MACRO and dwID == this.dwID then
			Hand_Clear()
		end
	end
end

function MacroSettingPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_Skill" then
		this.bDisableClick = nil
		this:SetObjectPressed(true)
	end	
end

function MacroSettingPanel.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box_Skill" then
		this:SetObjectPressed(false)
	end	
end

function MacroSettingPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Box_Skill" then
		if this.bDisableClick then
			this.bDisableClick = nil
			return
		end
		if aMacroData[this] then
			ExcuteMacroByID(aMacroData[this])
		end
		MacroSettingPanel.Sel(this:GetParent())
	elseif this.bMacroTitle then
		MacroSettingPanel.Sel(this)
	elseif szName == "Box_Icon" then
		local hBox = this:GetParent()
		local nCount = hBox:GetItemCount() - 1
		for i = 0, nCount, 1 do
			hBox:Lookup(i):SetObjectInUse(false)
		end
		this:GetParent().nIconID = this.nIconID
		this:SetObjectInUse(true)
		this:GetRoot():Lookup("Btn_Apply"):Enable(true)
	end
end

function MacroSettingPanel.OnItemLButtonDBClick()
	MacroSettingPanel.OnItemLButtonClick()
end

function MacroSettingPanel.OnItemRButtonDown()
	local szName = this:GetName()
	if szName == "Box_Skill" then
		this.bDisableClick = nil
		this:SetObjectPressed(true)
	end	
end

function MacroSettingPanel.OnItemRButtonUp()
	local szName = this:GetName()
	if szName == "Box_Skill" then
		this:SetObjectPressed(false)
	end	
end

function MacroSettingPanel.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Box_Skill" then
		if this.bDisableClick then
			this.bDisableClick = nil
			return
		end
		if aMacroData[this] then
			ExcuteMacroByID(aMacroData[this])
		end		
	end
end

function MacroSettingPanel.OnItemRButtonDBClick()
	MacroSettingPanel.OnItemRButtonClick()
end

function MacroSettingPanel.Sel(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			MacroSettingPanel.UpdateState(hB)
		end
	end
	
	hI.bSel = true
	MacroSettingPanel.UpdateState(hI)
	local frame = hP:GetRoot()
	frame.dwID = hI.dwID
	MacroSettingPanel.UpdateSelect(frame)
end

function MacroSettingPanel.UnSel(frame)
	frame.dwID = nil
	MacroSettingPanel.UpdateSelect(frame)
end

function MacroSettingPanel.UpdateCurrentIconPage(hBox)
	local nStart = (MacroSettingPanel.nCurrentPage - 1) * 22 + 1
	local nEnd = nStart + 21
	local nIndex = 0
	for i = nStart, nEnd, 1 do
		local box = hBox:Lookup(nIndex)
		local nIconID = MacroSettingPanel.aIcon[i]
		if nIconID then
			box:Show()
			box:SetObject(UI_OBJECT_MACRO, 0)
			box:SetObjectIcon(nIconID)
			box:SetObjectInUse(nIconID == hBox.nIconID)
			box.nIconID = nIconID
		else
			box:Hide()
		end
		nIndex = nIndex + 1
	end
	hBox:GetParent():Lookup("Text_Page"):SetText(MacroSettingPanel.nCurrentPage.."/"..MacroSettingPanel.nPageCount)
	hBox:GetRoot():Lookup("Btn_Left"):Enable(MacroSettingPanel.nCurrentPage ~= 1)
	hBox:GetRoot():Lookup("Btn_Right"):Enable(MacroSettingPanel.nCurrentPage ~= MacroSettingPanel.nPageCount)
end

function MacroSettingPanel.UpdateSelect(frame)
	if not frame.dwID then
		frame:Lookup("Btn_Apply"):Enable(false)
		frame:Lookup("Btn_Delete"):Enable(false)
		frame:Lookup("Edit_Name"):SetText("")
		frame:Lookup("Edit_Desc"):SetText("")
		frame:Lookup("Edit_Content"):SetText("")
		
		local hBox = frame:Lookup("", "Handle_Icon")
		hBox.nIconID = nil
		MacroSettingPanel.nCurrentPage = 1
		MacroSettingPanel.UpdateCurrentIconPage(hBox)
		return
	end
	
	frame:Lookup("Edit_Name"):SetText(GetMacroName(frame.dwID))
	local szDesc = GetMacroDesc(frame.dwID)
	frame:Lookup("Edit_Desc"):SetText(szDesc)
	frame:Lookup("Edit_Content"):SetText(GetMacroContent(frame.dwID))
	
	local hBox = frame:Lookup("", "Handle_Icon")	
	local nIconID = GetMacroIcon(frame.dwID)
	local nPage = MacroSettingPanel.nCurrentPage
	for k, v in pairs(MacroSettingPanel.aIcon) do
		if v == nIconID then
			nPage = math.ceil(k / 22)
			break
		end
	end
	
	hBox.nIconID = nIconID	
	if nPage == MacroSettingPanel.nCurrentPage then
		local nCount = hBox:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local box = hBox:Lookup(i)
			box:SetObjectInUse(box.nIconID == nIconID)
		end
	else
		MacroSettingPanel.nCurrentPage = nPage
		MacroSettingPanel.UpdateCurrentIconPage(hBox)
	end
	
	frame:Lookup("Btn_Apply"):Enable(false)
	frame:Lookup("Btn_Delete"):Enable(true)
end

function MacroSettingPanel.OnEditChanged()
	local szName = this:GetName()
	local frame = this:GetParent()
	if frame.dwID then
		frame:Lookup("Btn_Apply"):Enable(true)
	end
	if szName == "Edit_Content" then
		local nUse = this:GetTextLength()
		frame:Lookup("", "Text_MaxByte"):SetText(FormatString(g_tStrings.MACRO_INPUT_LIMIT, nUse, 1024))
	end
end

function MacroSettingPanel.GetNewMacroName()
	local nIndex = 1
	local szName = FormatString(g_tStrings.MACRO_NEW_I, nIndex)
	while true do
		local bOk = true
		for k, v in pairs(g_Macro) do
			if GetMacroName(k) == szName then
				nIndex = nIndex + 1
				szName = FormatString(g_tStrings.MACRO_NEW_I, nIndex)
				bOk = false
				break
			end
		end	
		if bOk then
			break
		end
	end
	return szName
end

function MacroSettingPanel.NewMacro(frame)
	local szName = frame:Lookup("Edit_Name"):GetText()
	local szDesc = frame:Lookup("Edit_Desc"):GetText()
	local szContent = frame:Lookup("Edit_Content"):GetText()	
	local hBox = frame:Lookup("", "Handle_Icon")
	local nIconID = hBox.nIconID
	
	if frame.dwID then
		szName = ""
		szDesc = ""
		szContent = ""
		nIconID = nil
	end
	
	if szName == "" then
		szName = MacroSettingPanel.GetNewMacroName()
	end
	if not nIconID then
		nIconID = MacroSettingPanel.aIcon[math.random(1, #(MacroSettingPanel.aIcon))]
	end

	local dwID = AddMacro(szName, nIconID, szDesc, szContent)
	local hList = frame:Lookup("", "Handle_List")
	local hI = MacroSettingPanel.NewMacroTitle(hList, dwID)
	MacroSettingPanel.Sel(hI)
	MacroSettingPanel.UpdateScrollInfo(hList)		
	frame:Lookup("Edit_Name"):SelectAll()
	Station.SetFocusWindow(frame:Lookup("Edit_Name"))
end

function MacroSettingPanel.UpdateState(hI)
	local img = hI:Lookup("Sel")
	if not img then
		return
	end
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(127)
	else
		img:Hide()
	end
end

function MacroSettingPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_List" then
		local nCurrentValue = this:GetScrollPos()
		local frame = this:GetParent()
		if nCurrentValue == 0 then
			frame:Lookup("Btn_Up"):Enable(false)
		else
			frame:Lookup("Btn_Up"):Enable(true)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_Down"):Enable(false)
		else
			frame:Lookup("Btn_Down"):Enable(true)
		end
		
	    local handle = frame:Lookup("", "Handle_List")
	    handle:SetItemStartRelPos(0, - nCurrentValue * 10)
    end
end

function MacroSettingPanel.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()

	local nStep = math.ceil((hAll - h) / 10)
	
	local scroll = handle:GetRoot():Lookup("Scroll_List")
	if nStep > 0 then
		scroll:Show()
		scroll:GetParent():Lookup("Btn_Up"):Show()
		scroll:GetParent():Lookup("Btn_Down"):Show()
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_Up"):Hide()
		scroll:GetParent():Lookup("Btn_Down"):Hide()			
	end	
	scroll:SetStepCount(nStep)
end

function MacroSettingPanel.OnLButtonHold()
    local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)
    end
end

function MacroSettingPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	return 1
end

function MacroSettingPanel.OnLButtonDown()
	MacroSettingPanel.OnLButtonHold()
end

function MacroSettingPanel.ChangeMacro(frame)
	if not frame.dwID then
		frame:Lookup("Btn_Apply"):Enable(false)
		return
	end
	
	local szName = frame:Lookup("Edit_Name"):GetText()
	local szDesc = frame:Lookup("Edit_Desc"):GetText()
	local szContent = frame:Lookup("Edit_Content"):GetText()
	local nIconID = frame:Lookup("", "Handle_Icon").nIconID
	SetMacro(frame.dwID, szName, nIconID, szDesc, szContent)
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == frame.dwID then
			hI:Lookup("Name"):SetText(szName)
			hI:Lookup("Box_Skill"):SetObjectIcon(nIconID)
		end
	end
	frame:Lookup("Btn_Apply"):Enable(false)
end

function MacroSettingPanel.DelMacro(frame)
	if not frame.dwID then
		frame:Lookup("Btn_Delete"):Enable(false)
		return
	end
	
	RemoveMacro(frame.dwID)
	
	local nIndex = nil
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == frame.dwID then
			hList:RemoveItem(i)
			nIndex = i
			break
		end
	end
	nIndex = nIndex or 0
	if nIndex >= hList:GetItemCount() then
		nIndex = hList:GetItemCount() - 1
	end
	if nIndex < 0 then
		nIndex = 0
	end
	local hI = hList:Lookup(nIndex)
	if hI then
		MacroSettingPanel.Sel(hI)
	else
		frame.dwID = nil
		MacroSettingPanel.UpdateSelect(frame)
	end
	MacroSettingPanel.UpdateScrollInfo(hList)
end

function MacroSettingPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		MacroSettingPanel.ChangeMacro(this:GetParent())
		CloseMacroSettingPanel()
	elseif szName == "Btn_Cancel" then
		CloseMacroSettingPanel()
	elseif szName == "Btn_New" then
		MacroSettingPanel.NewMacro(this:GetParent())
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_Close" then
		CloseMacroSettingPanel()
	elseif szName == "Btn_Apply" then
		MacroSettingPanel.ChangeMacro(this:GetParent())
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_Delete" then
		local frame = this:GetParent()
		local msg = 
		{
			szMessage = g_tStrings.MACRO_DELETE_SURE,
			szName = "del_macro_sure",
			fnAutoClose = function() return not IsMacroSettingPanelOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() if frame:IsValid() then MacroSettingPanel.DelMacro(frame) end end, },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
		}
		MessageBox(msg)
	elseif szName == "Btn_Left" then
		if MacroSettingPanel.nCurrentPage > 1 then
			MacroSettingPanel.nCurrentPage = MacroSettingPanel.nCurrentPage - 1
			MacroSettingPanel.UpdateCurrentIconPage(this:GetRoot():Lookup("", "Handle_Icon"))
		end
	elseif szName == "Btn_Right" then
		if MacroSettingPanel.nCurrentPage < MacroSettingPanel.nPageCount then
			MacroSettingPanel.nCurrentPage = MacroSettingPanel.nCurrentPage + 1
			MacroSettingPanel.UpdateCurrentIconPage(this:GetRoot():Lookup("", "Handle_Icon"))
		end
	end
end

function OpenMacroSettingPanel(bDisableSound)
	if IsMacroSettingPanelOpened() then
		return
	end
	
	Wnd.OpenWindow("MacroSettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseMacroSettingPanel(bDisableSound)
	if not IsMacroSettingPanelOpened() then
		return
	end
	Wnd.CloseWindow("MacroSettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsMacroSettingPanelOpened()
	local frame = Station.Lookup("Topmost/MacroSettingPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
