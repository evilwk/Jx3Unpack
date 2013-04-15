local HANDLE_STEP_SIZE = 10
local LIMIT_TIME = 2 * 60 * 1000
local WORD_MIN_NUMBER = 5
local WORD_MAX_NUMBER = 256

local tTextTableToHelper = 
{
	["Quests"] = g_tTotur.tQuest,
	["Operator"] = g_tTotur.tOperator,
	["Equip"] = g_tTotur.tEquip,
	["Items"] = g_tTotur.tItem,
	["Fight"] = g_tTotur.tFight,
	["Kungfu"] = g_tTotur.tKungfu,
	["Communicate"] = g_tTotur.tCommunicate,
	["Traffic"] = g_tTotur.tTraffic,
	["Crafts"] = g_tTotur.tCraft,
}

local funSort = function(tLeft, tRight)
	return tLeft.Level < tRight.Level 
end

GMPanel = 
{
	szIP = tUrl.GameMasterReportUrl, szObjectName = tUrl.GameMasterReportWebPage, szVerb = "POST", nPort = 80, szAda = g_tStrings.MSG_FILE,
	szMsg = g_tStrings.MSG_GMPANEL,
}

function GMPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("GMAPPEAL_SHOW")
--	this:RegisterEvent("INTERACTION_SEND_RESULT")
--	this:RegisterEvent("INTERACTION_REQUEST_RESULT")
	GMPanel.OnEvent("UI_SCALED")
	
	GMPanel.UpdateScrollInfo(this:Lookup("PageSet_Total/Page_GM", ""))
	
	local handle = this:Lookup("PageSet_Total/Page_GM/Wnd_GMHelp", "")
	GMPanel.SetHelpText(handle, GMPanel.szMsg)
	
	GMPanel.InitAppeal(this)
		
	GMPanel.SelectBugPage(this:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG/CheckBox_Quest"))
	GMPanel.SelectCraft(this:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_Craft/CheckBox_SN"))

	GMPanel.Clear(this)

	local hPage = this:Lookup("PageSet_Total/Page_Helper")
	GMPanel.SelectPage(hPage)
end

function GMPanel.InitAppeal(frame)
	local handle = frame:Lookup("PageSet_Total/Page_GM/Wnd_Appeal", "Handle_Messege")
	handle:Clear()
	GMPanel.UpdateAppealScrollInfo(handle)
end

function GMPanel.SetHelpText(handle, szMsg)
	local nFirst, nLast, szAdd = string.find(szMsg, "<sp (.-)>")
	while nFirst do
		local szPrev = string.sub(szMsg, 1, nFirst - 1)
		
		if szPrev and szPrev ~= "" then
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(szPrev).." font=106 </text>")
		end
		if szAdd and szAdd ~= "" then
			local szHeader = string.sub(szAdd, 1, 3)
			if szHeader == "lk " then
				szAdd = string.sub(szAdd, 4, -1)
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szAdd).." font=105 eventid=277 </text>")
				local text = handle:Lookup(handle:GetItemCount() - 1)
				text.OnItemLButtonClick = function()
					OpenInternetExplorer(this:GetText())
				end
				text.OnItemMouseEnter = function()
					this:SetFontScheme(139)
					GMPanel.UpdateGMHelpScrollInfo(this:GetParent())
				end
				text.OnItemMouseLeave = function()
					this:SetFontScheme(105)
					GMPanel.UpdateGMHelpScrollInfo(this:GetParent())
				end
			elseif szHeader == "cr " then
				szAdd = string.sub(szAdd, 4, -1)
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szAdd).." font=100 </text>")
			else
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szAdd).." font=106 </text>")
			end
		end
		
		szMsg = string.sub(szMsg, nLast + 1, -1)
		nFirst, nLast, szAdd = string.find(szMsg, "<sp (.-)>")
	end
	if szMsg and szMsg ~= "" then
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(szMsg).." font=106 </text>")
	end
	GMPanel.UpdateGMHelpScrollInfo(handle)
end

function GMPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif event == "INTERACTION_SEND_RESULT" then
		if arg0 == "Advice" then
			if arg1 then
				OutputMessage("MSG_SYS", g_tStrings.MSG_SUBMIT_SEND_SUCCEED)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_SUBMIT_SEND_FAIL)
			end
		end
	elseif event == "INTERACTION_REQUEST_RESULT" then
	elseif event == "GMAPPEAL_SHOW" then
		GMPanel.OpenGMAppealPage()
	end	
end

function GMPanel.OnItemLButtonDown()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if this.bSel then
			return
		end
		if this:GetParent():GetParent():GetName() == "Page_GM" then
			GMPanel.SelectGMPage(this)
		elseif this:GetParent():GetParent():GetName() == "Page_Helper" then
			GMPanel.SelectHelperPage(this)
		end
	end
end

function GMPanel.OnItemMouseEnter()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if not this.bSel then
			this:Lookup(0):Show()
			this:Lookup(0):SetAlpha(127)
		end
	end
end

function GMPanel.OnItemMouseLeave()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if not this.bSel then
			this:Lookup(0):Hide()
		end
	end
end

function GMPanel.SelectGMPage(hI)
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB:Lookup(0):Hide()
		hB.bSel = false
		
		local szLeft = string.sub(hB:GetName(), 4, -1)
		hP:GetParent():Lookup("Wnd_"..szLeft):Hide()
	end
	
	hI:Lookup(0):Show()
	hI:Lookup(0):SetAlpha(255)
	hI.bSel = true
	
	local szLeft = string.sub(hI:GetName(), 4, -1)
	hP:GetParent():Lookup("Wnd_"..szLeft):Show()
	
	local hPage = hP:GetParent():Lookup("Wnd_" .. szLeft)
	if szLeft == "Appeal" then
		GMPanel.SetDefalutAppeal(hPage)
		GMPanel.GMReplyShow(false)
	elseif szLeft == "Report" then
		GMPanel.SetDefaultReport(hPage)
	elseif szLeft == "Rabot" then
		GMPanel.SetDefaultRabot(hPage)
	end
end

function GMPanel.SetDefalutAppeal(hPage)
	local hEdit =  hPage:Lookup("Edit_Appeal")
	local szText = hEdit:GetText()
	if szText == "" then
		hEdit:SetText(g_tStrings.MSG_GM_APPEAL)
		hEdit.bEdit = true
		hEdit:SetFontScheme(161)
	end
end

function GMPanel.SetDefaultReport(hPage)
	local hText = hPage:Lookup("", "Text_ReportName")
	local szText = hText:GetText()
	if szText == "" then
		hText:SetFontScheme(161)
		hText:SetText(g_tStrings.REPORT_NAME_INIT)
	end
	local hContent = hPage:Lookup("", "Handle_ReportContent")
	local nCount = hContent:GetItemCount()
	if nCount == 0 then
		hContent:AppendItemFromString(GetFormatText(g_tStrings.REPORT_CONTENT_INIT, 161))
		hContent:FormatAllItemPos()
	end
end

function GMPanel.SetDefaultRabot(hPage)
	local hEdit = hPage:Lookup("Edit_RabotName")
	local szText = hEdit:GetText()
	if szText == "" then
		hEdit:SetText(g_tStrings.REPORT_NAME_INIT)
		hEdit.bEdit = true
		hEdit:SetFontScheme(161)
	end
end

function GMPanel.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()

	local nStep = math.ceil((hAll - h) / 10)
	
	local scroll = handle:GetParent():Lookup("Scroll_List")
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

function GMPanel.UpdateGMHelpScrollInfo(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()

	local nStep = math.ceil((hAll - h) / 10)
	
	local scroll = handle:GetParent():Lookup("Scroll_MList")
	if nStep > 0 then
		scroll:Show()
		scroll:GetParent():Lookup("Btn_MUp"):Show()
		scroll:GetParent():Lookup("Btn_MDown"):Show()
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_MUp"):Hide()
		scroll:GetParent():Lookup("Btn_MDown"):Hide()
	end
	scroll:SetStepCount(nStep)
end

function GMPanel.UpdateAppealScrollInfo(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()

	local nStep = math.ceil((hAll - h) / 10)
	
	local scroll = handle:GetParent():GetParent():Lookup("Scroll_Messege")
	
	local nEnd = scroll:GetScrollPos() == scroll:GetStepCount()
	
	if nStep > 0 then
		scroll:Show()
		scroll:GetParent():Lookup("Btn_MessegeUp"):Show()
		scroll:GetParent():Lookup("Btn_MessegeDn"):Show()
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_MessegeUp"):Hide()
		scroll:GetParent():Lookup("Btn_MessegeDn"):Hide()
	end
	scroll:SetStepCount(nStep)
	if nEnd then
		scroll:ScrollEnd()
	end 
end

function GMPanel.SelectBugPage(checkBox)
	local wndParent = checkBox:GetParent()
	local wndBrother = wndParent:GetFirstChild()
	while wndBrother do
		if wndBrother:GetType() == "WndCheckBox" then
			if wndBrother == checkBox then
				wndBrother:Check(true)
				local szLeft = string.sub(wndBrother:GetName(), 10, -1)
				wndParent:Lookup("Wnd_"..szLeft):Show()
			else
				wndBrother:Check(false)
				local szLeft = string.sub(wndBrother:GetName(), 10, -1)
				wndParent:Lookup("Wnd_"..szLeft):Hide()
			end
		end
		wndBrother = wndBrother:GetNext()
	end
end

function GMPanel.SelectCraft(checkBox)
	local wndParent = checkBox:GetParent()
	local wndBrother = wndParent:GetFirstChild()
	while wndBrother do
		if wndBrother:GetType() == "WndCheckBox" then
			if wndBrother == checkBox then
				wndBrother:Check(true)
			else
				wndBrother:Check(false)
			end
		end
		wndBrother = wndBrother:GetNext()
	end
end

function GMPanel.SelectAdviceType(checkBox)
	local wndParent = checkBox:GetParent()
	local wndBrother = wndParent:GetFirstChild()
	while wndBrother do
		if wndBrother:GetType() == "WndCheckBox" then
			if wndBrother == checkBox then
				wndBrother:Check(true)
			else
				wndBrother:Check(false)
			end
		end
		wndBrother = wndBrother:GetNext()
	end
end

function GMPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local wndParent = this:GetParent()
	local szParentName = wndParent:GetName()
	if szParentName == "Wnd_PutInBUG" then
		GMPanel.SelectBugPage(this)
	elseif szParentName == "Wnd_Craft" then
		GMPanel.SelectCraft(this)
	elseif szParentName == "Wnd_Advice" then
		GMPanel.SelectAdviceType(this)
	elseif szName == "CheckBox_Helper" then
		local hFrame = wndParent:Lookup("Page_Helper")
		GMPanel.SelectPage(hFrame)
	elseif szName == "CheckBox_GM" then
		local hFrame = wndParent:Lookup("Page_GM")
		GMPanel.SelectPage(hFrame)
	end
end

function GMPanel.OnCheckBoxUncheck()
end

function GMPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_Helpers" then
		local hFrame = this:GetParent()
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_HelpersUp"):Enable(false)
		else
			hFrame:Lookup("Btn_HelpersUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_HelpersDown"):Enable(false)
		else
			hFrame:Lookup("Btn_HelpersDown"):Enable(true)
		end
		
		local hHandle = hFrame:Lookup("", "")
		hHandle:SetItemStartRelPos(0, - nCurrentValue * HANDLE_STEP_SIZE)
		
	elseif szName == "Scroll_List" then
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
		
		local handle = frame:Lookup("", "")
		handle:SetItemStartRelPos(0, - nCurrentValue * 10)
	elseif szName == "Scroll_MList" then
		local frame = this:GetParent()
		if nCurrentValue == 0 then
			frame:Lookup("Btn_MUp"):Enable(false)
		else
			frame:Lookup("Btn_MUp"):Enable(true)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_MDown"):Enable(false)
		else
			frame:Lookup("Btn_MDown"):Enable(true)
		end
		
	    local handle = frame:Lookup("", "")
	    handle:SetItemStartRelPos(0, - nCurrentValue * 10)
	elseif szName == "Scroll_Messege" then
		local frame = this:GetParent()
		if nCurrentValue == 0 then
			frame:Lookup("Btn_MessegeUp"):Enable(false)
		else
			frame:Lookup("Btn_MessegeUp"):Enable(true)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_MessegeDn"):Enable(false)
		else
			frame:Lookup("Btn_MessegeDn"):Enable(true)
		end
		
	    local handle = frame:Lookup("", "Handle_Messege")
	    handle:SetItemStartRelPos(0, - nCurrentValue * 10)		
    end
end

function GMPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local frame = this:GetRoot()
	local wndGMHelp = frame:Lookup("PageSet_Total/Page_GM/Wnd_GMHelp")
	local wndAppeal = frame:Lookup("PageSet_Total/Page_GM/Wnd_Appeal")
	local szName = this:GetName()
	
	if szName == "Handle_Helpers" then
		frame:Lookup("PageSet_Total/Page_Helper/Wnd_Helpers"):Lookup("Scroll_Helpers"):ScrollNext(nDistance)
	elseif wndGMHelp:IsVisible() then
		wndGMHelp:Lookup("Scroll_MList"):ScrollNext(nDistance)
	elseif wndAppeal:IsVisible() then
		wndAppeal:Lookup("Scroll_Messege"):ScrollNext(nDistance)
	else
		frame:Lookup("PageSet_Total/Page_GM/Scroll_List"):ScrollNext(nDistance)
	end
	return 1
end

function GMPanel.OnLButtonDown()
	GMPanel.OnLButtonHold()
end

function GMPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)	
	elseif szName == "Btn_MUp" then
		this:GetParent():Lookup("Scroll_MList"):ScrollPrev(1)	
	elseif szName == "Btn_MDown" then
		this:GetParent():Lookup("Scroll_MList"):ScrollNext(1)
	elseif szName == "Btn_MessegeUp" then
		this:GetParent():Lookup("Scroll_Messege"):ScrollPrev(1)
	elseif szName == "Btn_MessegeDn" then
		this:GetParent():Lookup("Scroll_Messege"):ScrollNext(1)
	elseif szName == "Btn_HelpersUp" then
		this:GetParent():Lookup("Scroll_Helpers"):ScrollNext(1)
	elseif szName == "Btn_HelpersDown" then
		this:GetParent():Lookup("Scroll_Helpers"):ScrollNext(1)
    end
end

function GMPanel.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_QA" or szName == "Edit_NPCA" or szName == "Edit_MapA" or szName == "Edit_IA" or szName == "Edit_ChA" or
		szName == "Edit_SA" or szName == "Edit_CA" or szName == "Edit_TipA" or szName == "Edit_OtherA" or szName == "Edit_AdA" then
		if this:GetText() == GMPanel.szAda then
			this:SetText("")
		end
	elseif this.bEdit and (szName == "Edit_Appeal" or szName == "Edit_RabotName") then
		this:ClearText()
		this.bEdit = false
		this:SetFontScheme(162)
	end
end

function GMPanel.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_QA" or szName == "Edit_NPCA" or szName == "Edit_MapA" or szName == "Edit_IA" or szName == "Edit_ChA" or
		szName == "Edit_SA" or szName == "Edit_CA" or szName == "Edit_TipA" or szName == "Edit_OtherA" or szName == "Edit_AdA" then
		local szText = this:GetText()
		if szText == "" then
			this:SetText(GMPanel.szAda)
		end
	end
end

function GMPanel.Clear(frame)
	local bugPage = frame:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG")
	
	local questPage = bugPage:Lookup("Wnd_Quest")
	questPage:Lookup("Edit_QT"):ClearText()
	questPage:Lookup("Edit_QTM"):ClearText()
	questPage:Lookup("Edit_QTS"):ClearText()
	questPage:Lookup("Edit_QA"):SetText(GMPanel.szAda)
	questPage.aInfo = {}
	
	local npcPage = bugPage:Lookup("Wnd_NPC")
	npcPage:Lookup("Edit_NPCT"):ClearText()
	npcPage:Lookup("Edit_NPCTM"):ClearText()
	npcPage:Lookup("Edit_NPCTS"):ClearText()
	npcPage:Lookup("Edit_NPCA"):SetText(GMPanel.szAda)
	npcPage.aInfo = {}
	
	local mapPage = bugPage:Lookup("Wnd_Map")
	mapPage:Lookup("Edit_MapT"):ClearText()
	mapPage:Lookup("Edit_CT"):ClearText()
	mapPage:Lookup("Edit_MapTM"):ClearText()
	mapPage:Lookup("Edit_MapA"):SetText(GMPanel.szAda)
	mapPage.aInfo = {}
	
	local itemPage = bugPage:Lookup("Wnd_Item")
	itemPage:Lookup("Edit_IT"):ClearText()
	itemPage:Lookup("Edit_FT"):ClearText()
	itemPage:Lookup("Edit_ITM"):ClearText()
	itemPage:Lookup("Edit_IA"):SetText(GMPanel.szAda)
	itemPage.aInfo = {}

	local charPage = bugPage:Lookup("Wnd_Char")
	charPage:Lookup("Edit_ChT"):ClearText()
	charPage:Lookup("Edit_SeT"):ClearText()
	charPage:Lookup("Edit_ChTM"):ClearText()
	charPage:Lookup("Edit_ChA"):SetText(GMPanel.szAda)
	charPage.aInfo = {}
	
	local schoolPage = bugPage:Lookup("Wnd_School")
	schoolPage:Lookup("Edit_ST"):ClearText()
	schoolPage:Lookup("Edit_SKT"):ClearText()
	schoolPage:Lookup("Edit_STM"):ClearText()
	schoolPage:Lookup("Edit_SA"):SetText(GMPanel.szAda)
	schoolPage.aInfo = {}
	
	local craftPage = bugPage:Lookup("Wnd_Craft")
	craftPage:Lookup("Edit_CTM"):ClearText()
	craftPage:Lookup("Edit_CA"):SetText(GMPanel.szAda)
	craftPage.aInfo = {}
	
	local tipPage = bugPage:Lookup("Wnd_Tip")
	tipPage:Lookup("Edit_TipTM"):ClearText()
	tipPage:Lookup("Edit_TipA"):SetText(GMPanel.szAda)
	tipPage.aInfo = {}
	
	local otherPage = bugPage:Lookup("Wnd_Other")
	otherPage:Lookup("Edit_OtherTM"):ClearText()
	otherPage:Lookup("Edit_OtherA"):SetText(GMPanel.szAda)
	otherPage.aInfo = {}
	
	local advicePage = frame:Lookup("PageSet_Total/Page_GM/Wnd_Advice")
	advicePage:Lookup("Edit_AdviceTM"):ClearText()
	advicePage:Lookup("Edit_Email"):ClearText()
	advicePage:Lookup("Edit_CellPhone"):ClearText()
	advicePage:Lookup("Edit_AdA"):SetText(GMPanel.szAda)
	advicePage:Lookup("CheckBox_AQuest"):Check(false)
	advicePage:Lookup("CheckBox_ACraft"):Check(false)
	advicePage:Lookup("CheckBox_ASchool"):Check(false)
	advicePage:Lookup("CheckBox_AMap"):Check(false)
	advicePage:Lookup("CheckBox_AOther"):Check(false)
	
	local hEditSearch = frame:Lookup("PageSet_Total/Page_Helper/Edit_Search")
	hEditSearch:ClearText()
	
	local hReportPage = frame:Lookup("PageSet_Total/Page_GM/Wnd_Report")
	hReportPage:Lookup("", "Text_ReportName"):SetText("")
	hReportPage:Lookup("", "Handle_ReportContent"):Clear()
	hReportPage:Lookup("Edit_Report"):ClearText()
	
	
	local hRabotPage = frame:Lookup("PageSet_Total/Page_GM/Wnd_Rabot")
	hRabotPage:Lookup("Edit_RabotName"):ClearText()
	hRabotPage:Lookup("Edit_RabotScence"):ClearText()
	hRabotPage:Lookup("Edit_Rabot"):ClearText()
	hRabotPage.dwMapID = nil
	hRabotPage.fPosX = nil
	hRabotPage.fPosY = nil
	hRabotPage.fPosZ = nil
end

function GMPanel.GetCurrentGMPage(frame)
	local t = 
	{
		"Wnd_GMHelp",
		"Wnd_PutInBUG",
		"Wnd_Advice",
		"Wnd_Report",
		"Wnd_Lock",
		"Wnd_Appeal",
		"Wnd_Rabot",
	}
	for k, v in pairs(t) do
		local page = frame:Lookup(v)
		if page:IsVisible() then
			return page, v
		end
	end
	return frame:Lookup(t[1]), t[1]
end

function GMPanel.GetCurrentBugPage(frame)
	local t = 
	{
		"Wnd_Quest",
		"Wnd_NPC",
		"Wnd_Map",
		"Wnd_Item",
		"Wnd_Char",
		"Wnd_School",
		"Wnd_Craft",
		"Wnd_Tip",
		"Wnd_Other",
	}
	local wndParent = frame:Lookup("Wnd_PutInBUG")
	for k, v in pairs(t) do
		local page = wndParent:Lookup(v)
		if page:IsVisible() then
			return page, v
		end
	end
	return wndParent:Lookup(t[1]), t[1]
end

function GMPanel.FillBasicInfo(szType)
	Interaction_Clear()
	Interaction_AddParam("Type", szType)
	local _, szVersion = GetVersion()
	Interaction_AddParam("Version", szVersion)			
	Interaction_AddParam("Account", GetUserAccount())
	local szRegion, szServer = GetUserServer()
	Interaction_AddParam("Region", szRegion)
	Interaction_AddParam("Server", szServer)
	Interaction_AddParam("ServerList", tostring(Login.m_szServerIP)..":"..tostring(Login.m_nServerPort))
	Interaction_AddParam("RoleName", GetUserRoleName())
	local player = GetClientPlayer()
	Interaction_AddParam("Level", player.nLevel)
	Interaction_AddParam("MapName", Table_GetMapName(player.GetScene().dwMapID))
	Interaction_AddParam("x",player.nX)
	Interaction_AddParam("y",player.nY)
	Interaction_AddParam("z",player.nZ)
end

function GMPanel.FillFileInfo(edit)
	local szFile = edit:GetText()
	if szFile == "" or szFile == GMPanel.szAda then
		return
	end
	
	if not IsUnpakFileExist(szFile) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_FILE_NOT_FOUND)
		return
	end
	
	local nSize = GetUnpakFileSize(szFile)
	if nSize == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_FILE_TOO_SMALL)
		return
	end
	
	if nSize > 1024 * 1024 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_FILE_TOO_BIG)
		return
	end
	Interaction_AddParam("File",szFile, true)	
end

function GMPanel.SendDataToGMWEB(szPrefix)
	local tAllParam = Interaction_GetParams()
	local nParamNumber = 0
	local szMsg = ""
	local szParam = ""
	for _, tParam in ipairs(tAllParam) do
		if tParam.szName ~= "Server" and tParam.szName ~= "RoleName" then
			szParam = szParam .. tParam.szName .. ":" .. tParam.szValue .. ";"
			nParamNumber = nParamNumber + 1
		end
	end
	szMsg = "[" .. szPrefix .. "]" .. "ParamNum:" .. nParamNumber .. ";" .. szParam
	SendGmMessage(szMsg)
end

function GMPanel.SubmitQuestBug(bugPage)
	local szQuestName = bugPage:Lookup("Edit_QT"):GetText()
	local szMessage = bugPage:Lookup("Edit_QTM"):GetText()
	local szMap = bugPage:Lookup("Edit_QTS"):GetText()
	if szMap == "" then
		szMap = g_tStrings.UNKNOWN_MAP
	end
	if szQuestName == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_QUEST_NAME, 
			szName = "BugQuestName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugQuestMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("QuestBug")
		Interaction_AddParam("QuestName", szQuestName)
		local dwID = 0
		if bugPage.aInfo and bugPage.aInfo.dwQuestID then
			dwID = bugPage.aInfo.dwQuestID
		end
		Interaction_AddParam("QuestID", dwID)		
		Interaction_AddParam("InputMapName",  szMap)
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_QA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitNpcBug(bugPage)
	local szName = bugPage:Lookup("Edit_NPCT"):GetText()
	local szMessage = bugPage:Lookup("Edit_NPCTM"):GetText()
	local szMap = bugPage:Lookup("Edit_NPCTS"):GetText()
	if szMap == "" then
		szMap = g_tStrings.UNKNOWN_MAP
	end
	if szName == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_NPC_NAME, 
			szName = "BugNpcName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugNpcMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("NpcBug")
		Interaction_AddParam("NpcName", szName)
		local dwID = 0
		if bugPage.aInfo and bugPage.aInfo.dwNpcTemplateID then
			dwID = bugPage.aInfo.dwNpcTemplateID
		end
		Interaction_AddParam("NpcTemplateID", dwID)

		local player = GetClientPlayer()
		Interaction_AddParam("x",  player.nX)
		Interaction_AddParam("y",  player.nY)
		Interaction_AddParam("z",  player.nZ)
		Interaction_AddParam("InputMapName",  szMap)
		
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_NPCA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitMapBug(bugPage)
	local szName = bugPage:Lookup("Edit_MapT"):GetText()
	local szPos = bugPage:Lookup("Edit_CT"):GetText()
	local szMessage = bugPage:Lookup("Edit_MapTM"):GetText()
	if szPos == "" then
		szPos = g_tStrings.MSG_UNKNOW_POS
	end
	if szName == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_MAP_NAME, 
			szName = "BugMapName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugMapMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("MapBug")
		Interaction_AddParam("InputMapName", szName)
		Interaction_AddParam("Position", szPos)
		
		local player = GetClientPlayer()
		Interaction_AddParam("x",  player.nX)
		Interaction_AddParam("y",  player.nY)
		Interaction_AddParam("z",  player.nZ)		
		
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_MapA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitItemBug(bugPage)
	local szName = bugPage:Lookup("Edit_IT"):GetText()
	local szFrom = bugPage:Lookup("Edit_FT"):GetText()
	local szMessage = bugPage:Lookup("Edit_ITM"):GetText()
	if szFrom == "" then
		szFrom = g_tStrings.MSG_UNKNOW_SOURCE
	end
	if szName == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_QUEST_NAME, 
			szName = "BugItemName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugItemMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("ItemBug")
		Interaction_AddParam("ItemName", szName)
		Interaction_AddParam("From", szFrom)
		local nVersion, nTabType, nTableIndex = 0, 0, 0
		if bugPage.aInfo and bugPage.aInfo.nVersion then
			nVersion, nTabType, nTableIndex = bugPage.aInfo.nVersion, bugPage.aInfo.nTabType, bugPage.aInfo.nTableIndex
		end
		Interaction_AddParam("ItemVersion", nVersion)
		Interaction_AddParam("ItemTableType", nTabType)
		Interaction_AddParam("ItemTableIndex", nTableIndex)
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_IA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitCharBug(bugPage)
	local szName = bugPage:Lookup("Edit_ChT"):GetText()
	local szSex = bugPage:Lookup("Edit_SeT"):GetText()
	local szMessage = bugPage:Lookup("Edit_ChTM"):GetText()
	if szSex == "" then
		szSex = g_tStrings.MSG_UNKNOW_SEX
	end
	if szName == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_QUEST_NAME, 
			szName = "BugCharName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugCharMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("PlayerBug")
		Interaction_AddParam("PlayerName", szName)
		Interaction_AddParam("Sex", szSex)
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_ChA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitSchoolBug(bugPage)
	local szName = bugPage:Lookup("Edit_ST"):GetText()
	local szSkill = bugPage:Lookup("Edit_SKT"):GetText()
	local szMessage = bugPage:Lookup("Edit_STM"):GetText()
	if szName == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_SCHOOL_NAME, 
			szName = "BugSchoolName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif szSkill == "" then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_INPUT_SKILL_NAME, 
			szName = "BugSchoolName", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)				
	elseif string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugSchoolMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("SkillBug")
		Interaction_AddParam("SchoolName", szName)
		Interaction_AddParam("SkillName", szSkill)
		local dwID, dwLevel = 0, 0
		if bugPage.aInfo then
			if bugPage.aInfo.dwID then
				dwID, dwLevel = bugPage.aInfo.dwID, bugPage.aInfo.dwLevel
			end
		end
		Interaction_AddParam("SkillID", dwID)
		Interaction_AddParam("SkillLevel", dwLevel)
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_SA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.GetCurrentBugCraft(page)
	local szResult = ""
	if page:Lookup("CheckBox_SN"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_HERBALISM
	elseif page:Lookup("CheckBox_CJ"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_MINING
	elseif page:Lookup("CheckBox_SS"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_DISSECTING
	elseif page:Lookup("CheckBox_YD"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_READING
	elseif page:Lookup("CheckBox_PR"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_COOKING
	elseif page:Lookup("CheckBox_ZZ"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_SMITHING
	elseif page:Lookup("CheckBox_FZ"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_TAILORING
	elseif page:Lookup("CheckBox_YS"):IsCheckBoxChecked() then
		szResult = g_tStrings.CRAFT_LEECHCRAFT
	end
	return szResult
end

function GMPanel.SubmitCraftBug(bugPage)
	local szMessage = bugPage:Lookup("Edit_CTM"):GetText()
	if string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugCraftMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("CraftBug")
		Interaction_AddParam("CraftType", GMPanel.GetCurrentBugCraft(bugPage))
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_CA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitTipBug(bugPage)
	local szMessage = bugPage:Lookup("Edit_TipTM"):GetText()
	if string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugTipMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("Textbug")
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_TipA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.SubmitOtherBug(bugPage)
	local szMessage = bugPage:Lookup("Edit_OtherTM"):GetText()
	if string.len(szMessage) < 10 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW, 
			szName = "BugOtherMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		GMPanel.FillBasicInfo("OtherBug")
		Interaction_AddParam("Detail", szMessage)
		GMPanel.FillFileInfo(bugPage:Lookup("Edit_OtherA"))
		GMPanel.SendDataToGMWEB("Bug")
		Interaction_Send("Bug", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
		
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
			szName = "BugMsg", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
		}
		MessageBox(msg)
	end
end

function GMPanel.GetCurrentAdviceType(page)
	local szResult = ""
	if page:Lookup("CheckBox_AQuest"):IsCheckBoxChecked() then
		szResult = "Quest"
	elseif page:Lookup("CheckBox_ACraft"):IsCheckBoxChecked() then
		szResult = "Craft"
	elseif page:Lookup("CheckBox_ASchool"):IsCheckBoxChecked() then
		szResult = "Skill"
	elseif page:Lookup("CheckBox_AMap"):IsCheckBoxChecked() then
		szResult = "Map"
	elseif page:Lookup("CheckBox_AOther"):IsCheckBoxChecked() then
		szResult = "Other"
	end
	return szResult
end

function GMPanel.SubmitAdvice(page)
	local szAdvice = page:Lookup("Edit_AdviceTM"):GetText()
	local szEmail = page:Lookup("Edit_Email"):GetText()
	local szCellPhone = page:Lookup("Edit_CellPhone"):GetText()
	
	if string.len(szAdvice) < 20 then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE_TOO_FEW1, 
			szName = "AdviceMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		local szType = GMPanel.GetCurrentAdviceType(page)
		if szType == "" then
			local wAll, hAll = Station.GetClientSize()
			local msg = 
			{
				x = wAll / 2, y = hAll / 2,
				szMessage = g_tStrings.MSG_CHOOSE_SUBMIT_TYPE, 
				szName = "AdviceMsgType", 
				fnAutoClose = function() return not IsGMPanelOpened() end,
				{szOption = g_tStrings.STR_RETURN},
			}
			MessageBox(msg)		
		else
			GMPanel.FillBasicInfo("Advice")
			Interaction_AddParam("Email", szEmail)
			Interaction_AddParam("CellPhone", szCellPhone)
			Interaction_AddParam("AdviceType", szType)
			Interaction_AddParam("Advice", szAdvice)
			GMPanel.FillFileInfo(page:Lookup("Edit_AdA"))
			GMPanel.SendDataToGMWEB("Advice")
			Interaction_Send("Advice", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
			
			local wAll, hAll = Station.GetClientSize()
			local msg = 
			{
				x = wAll / 2, y = hAll / 2,
				szMessage = g_tStrings.MSG_QUEST_SEND_SUCCEED, 
				szName = "AdviceMsg", 
				fnAutoClose = function() return not IsGMPanelOpened() end,
				{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = function() 	local frame = Station.Lookup("Normal/GMPanel") if frame then GMPanel.Clear(frame) end end},
			}
			MessageBox(msg)		
		end
	end
end

function GMPanel.SubmitData(frame)
	local page, szName = GMPanel.GetCurrentGMPage(frame)
	if szName == "Wnd_GMHelp" then
	elseif szName == "Wnd_PutInBUG" then
		local bugPage, szBugPageName = GMPanel.GetCurrentBugPage(frame)
		if szBugPageName == "Wnd_Quest" then
			GMPanel.SubmitQuestBug(bugPage)
		elseif szBugPageName == "Wnd_NPC" then
			GMPanel.SubmitNpcBug(bugPage)
		elseif szBugPageName == "Wnd_Map" then
			GMPanel.SubmitMapBug(bugPage)
		elseif szBugPageName == "Wnd_Item" then
			GMPanel.SubmitItemBug(bugPage)
		elseif szBugPageName == "Wnd_Char" then
			GMPanel.SubmitCharBug(bugPage)
		elseif szBugPageName == "Wnd_School" then
			GMPanel.SubmitSchoolBug(bugPage)
		elseif szBugPageName == "Wnd_Craft" then
			GMPanel.SubmitCraftBug(bugPage)
		elseif szBugPageName == "Wnd_Tip" then
			GMPanel.SubmitTipBug(bugPage)
		elseif szBugPageName == "Wnd_Other" then
			GMPanel.SubmitOtherBug(bugPage)
		end
	elseif szName == "Wnd_Advice" then
		GMPanel.SubmitAdvice(page)
	elseif szName == "Wnd_Appeal" then
		GMPanel.SubmitAppeal(page)
	elseif szName == "Wnd_Rabot" then
		GMPanel.SubmitRabot(page)
	elseif szName == "Wnd_Report" then
		GMPanel.SubmitReport(page)
	end
end

function GMPanel.SubmitRabot(hPage)
	local hRoleName = hPage:Lookup("Edit_RabotName")
	local szRoleName = hRoleName:GetText()
	local szCustom = hPage:Lookup("Edit_Rabot"):GetText()
	local hFrame = hPage:GetRoot()
	
	local fWidth, fHeight = Station.GetClientSize()
	local tMsg = 
	{
		x = fWidth / 2, y = fHeight / 2,
		fnAutoClose = function() return not IsGMPanelOpened() end,
	}
	
	if hFrame.dwLastRabotTime and GetTickCount() - hFrame.dwLastRabotTime < LIMIT_TIME then	
	elseif szRoleName == "" or hRoleName.bEdit then
		tMsg.szName = "RabotRefuse"
		tMsg.szMessage = g_tStrings.RABOT_REFUSE
		table.insert(tMsg, {szOption = g_tStrings.STR_RETURN})
		MessageBox(tMsg)
	elseif string.len(szCustom) < WORD_MIN_NUMBER or string.len(szCustom) > WORD_MAX_NUMBER then
		tMsg.szName = "RabotMsgLess"
		tMsg.szMessage = g_tStrings.MSG_DESCRIBE
		table.insert(tMsg, {szOption = g_tStrings.STR_RETURN})
		MessageBox(tMsg)
	else
		RemoteCallToServer("OnReportCheat", szRoleName, szCustom, hPage.dwMapID, hPage.fPosX, hPage.fPosY, hPage.fPosZ)
		hPage.dwMapID, hPage.fPosX, hPage.fPosY, hPage.fPosZ = nil, nil, nil, nil
		local hSure = hPage:Lookup("Btn_Rabot_Sure")
		hSure:Enable(false)
		hFrame.dwLastRabotTime = GetTickCount() 
		hPage:Lookup("Edit_RabotName"):ClearText()
		hPage:Lookup("Edit_RabotScence"):ClearText()
		hPage:Lookup("Edit_Rabot"):ClearText()
		GMPanel.SetDefaultRabot(hPage)
		
		tMsg.szName = "RabotSure"
		tMsg.szMessage = g_tStrings.REPORT_INFO
		table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_SURE})
		MessageBox(tMsg)
	end	
end

function GMPanel.SubmitReport(hPage)
	local hFrame = hPage:GetRoot()
	local szRoleName = hPage:Lookup("", "Text_ReportName"):GetText()
	local szContent = hPage:Lookup("", "Handle_ReportContent"):Lookup(0):GetText()
	local szCustom = hPage:Lookup("Edit_Report"):GetText()
	
	local fWidth, fHeight = Station.GetClientSize()
	local tMsg = 
	{
		x = fWidth / 2, y = fHeight / 2,
		fnAutoClose = function() return not IsGMPanelOpened() end,
	}
		
	if hFrame.dwLastReportTime and GetTickCount() - hFrame.dwLastReportTime < LIMIT_TIME then
	elseif not hPage.bCanSubmit then
		tMsg.szName = "CanNotReport"
		tMsg.szMessage = g_tStrings.REPORT_REFUSE
		table.insert(tMsg, {szOption = g_tStrings.STR_RETURN})
		MessageBox(tMsg)
	else
		RemoteCallToServer("OnReportTrick", szRoleName, szContent, szCustom)
		hFrame.dwLastReportTime = GetTickCount()
		local hSure = hPage:Lookup("Btn_Report_Sure")
		hSure:Enable(false)
		hPage:Lookup("", "Text_ReportName"):SetText("")
		hPage:Lookup("", "Handle_ReportContent"):Clear()
		hPage:Lookup("Edit_Report"):ClearText()
		GMPanel.SetDefaultReport(hPage)
		hPage.bCanSubmit = false
		
		tMsg.szName = "ReportSure"
		tMsg.szMessage = g_tStrings.REPORT_INFO
		table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_SURE})
		MessageBox(tMsg)
	end
end

function GMPanel.SubmitAppeal(page)
	local hEditAppeal = page:Lookup("Edit_Appeal")
	local szText = hEditAppeal:GetText()
	local frame = page:GetRoot()
	if frame.dwLastMessageTime and GetTickCount() - frame.dwLastMessageTime < LIMIT_TIME then
	elseif string.len(szText) < WORD_MIN_NUMBER or string.len(szText) > LIMIT_TIME or hEditAppeal.bEdit then
		local wAll, hAll = Station.GetClientSize()
		local msg = 
		{
			x = wAll / 2, y = hAll / 2,
			szMessage = g_tStrings.MSG_DESCRIBE, 
			szName = "AppealMsgLess", 
			fnAutoClose = function() return not IsGMPanelOpened() end,
			{szOption = g_tStrings.STR_RETURN},
		}
		MessageBox(msg)
	else
		SendGmMessage(szText)
		local handle = page:Lookup("","Handle_Messege")
		local player = GetClientPlayer()
		local szName = player.szName..g_tStrings.STR_TWO_CHINESE_SPACE..GetLocalTimeText().."\n"
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(player.szName..g_tStrings.STR_TWO_CHINESE_SPACE..GetLocalTimeString().."\n").."font=163 </text>\n")
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText.."\n").."font=106 </text>\n")
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.MSG_APPEAL).."font=163 </text>\n")
		GMPanel.UpdateAppealScrollInfo(handle)
		LastAppealTime = os.time()
		local btn = page:Lookup("Btn_Appeal_Sure")
		frame.dwLastMessageTime = GetTickCount()
		btn:Enable(false)
		page:Lookup("Edit_Appeal"):ClearText()
		GMPanel.SetDefalutAppeal(page)
	end
end

function GMPanel.GetAddFile(btn, szEdit)
	local szFile = GetOpenFileName(g_tStrings.MSG_CHOOSE_FILE)
	if szFile == "" then
		return
	end
	
	if not IsUnpakFileExist(szFile) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_CHOOSE_FILE_NOT_FOUND)
		return
	end
	
	local nSize = GetUnpakFileSize(szFile)
	if nSize == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_CHOOSE_FILE_EMPTY)
		return
	end
	
	if nSize > 1024 * 1024 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_CHOOSE_FILE_TOO_BIG)
		return
	end
	
	btn:GetParent():Lookup(szEdit):SetText(szFile)
end

function GMPanel.OnLButtonClick()
	local szName = this:GetName()
    if szName == "Btn_Close" or szName == "Btn_Cancel" then
    	CloseGMPanel()
    elseif szName == "Btn_Bug_Sure" or szName == "Btn_Advice_Sure" or szName == "Btn_Appeal_Sure" or szName == "Btn_Rabot_Sure" or szName == "Btn_Report_Sure" then
    	GMPanel.SubmitData(this:GetParent():GetParent())
    elseif szName == "Btn_Get" then
    	local player = GetClientPlayer()
		local szName = Table_GetMapName(player.GetScene().dwMapID)
		local page = this:GetParent()
		page:Lookup("Edit_MapT"):SetText(szName)
		page:Lookup("Edit_CT"):SetText(player.nX..","..player.nY..","..player.nZ)
    	Station.SetFocusWindow(page:Lookup("Edit_MapTM"))
    elseif szName == "Btn_AdScan" then
    	GMPanel.GetAddFile(this, "Edit_AdA")
    elseif szName == "Btn_OtherScan" then
    	GMPanel.GetAddFile(this, "Edit_OtherA")    
    elseif szName == "Btn_TipScan" then
    	GMPanel.GetAddFile(this, "Edit_TipA")
    elseif szName == "Btn_CScan" then
    	GMPanel.GetAddFile(this, "Edit_CA")
    elseif szName == "Btn_SScan" then
    	GMPanel.GetAddFile(this, "Edit_SA")
    elseif szName == "Btn_ChScan" then
    	GMPanel.GetAddFile(this, "Edit_ChA")
    elseif szName == "Btn_IScan" then
    	GMPanel.GetAddFile(this, "Edit_IA")
    elseif szName == "Btn_MapScan" then
    	GMPanel.GetAddFile(this, "Edit_MapA")
    elseif szName == "Btn_NPCScan" then
    	GMPanel.GetAddFile(this, "Edit_NPCA")
    elseif szName == "Btn_Scan" then
    	GMPanel.GetAddFile(this, "Edit_QA")
    elseif szName == "Btn_Search" then
    	GMPanel.SearchHelper(this:GetParent())
    end
end

function GMPanel.GMReplyShow(nEnable)
	local argS = arg0
		arg0 = nEnable
		FireEvent("GMREPLY_SHOW")
		arg0 = argS
end

function GMPanel.OpenGMAppealPage()
	local hFrame = OpenGMPanel("Bug")
	local hPage = hFrame:Lookup("PageSet_Total/Page_GM", "HI_Appeal")
	GMPanel.SelectGMPage(hPage)
end

function GMPanel.OnFrameBreathe()
	local hAppealBtn = this:Lookup("PageSet_Total/Page_GM/Wnd_Appeal/Btn_Appeal_Sure")
	if this.dwLastMessageTime then
		GMPanel.CheckSubmit(this.dwLastMessageTime, hAppealBtn)
	end
	
	local hRabotBtn = this:Lookup("PageSet_Total/Page_GM/Wnd_Rabot/Btn_Rabot_Sure")
	if this.dwLastRabotTime then
		GMPanel.CheckSubmit(this.dwLastRabotTime, hRabotBtn)
	end
	
	local hReportBtn = this:Lookup("PageSet_Total/Page_GM/Wnd_Report/Btn_Report_Sure")
	if this.dwLastReportTime then
		GMPanel.CheckSubmit(this.dwLastReportTime, hReportBtn)
	end
end

function GMPanel.CheckSubmit(dwLastTime, hButton)
	if dwLastTime and GetTickCount() - dwLastTime < LIMIT_TIME then
		local dwRemainTime = (LIMIT_TIME - GetTickCount() + dwLastTime ) / 1000
		local dwMinutes = dwRemainTime / 60 - dwRemainTime / 60 % 1
		local dwSeconds = dwRemainTime % 60 - dwRemainTime % 60 % 1
		hButton:Lookup("", ""):Lookup(0):SetText(g_tStrings.SUBMIT.."("..dwMinutes..":"..dwSeconds..")")
	else
		hButton:Enable(true)
		hButton:Lookup("", ""):Lookup(0):SetText(g_tStrings.SUBMIT)
	end
	
end

function GMPanel.OnEditSpecialKeyDown()
	local nResult = 0
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szName == "Edit_Appeal" and szKey == "Enter" and IsCtrlKeyDown() then
		GMPanel.SubmitData(this:GetRoot():Lookup("PageSet_Total/Page_GM"))
		nResult = 1
	elseif szName == "Edit_Search" and szKey == "Enter" then
		GMPanel.SearchHelper(this:GetParent())
		nResult = 1
	end
	return nResult
end

function GMPanel.SelectPage(hFrame)
	if hFrame:GetName() == "Page_Helper" then
		hFrame:Show()
		local hGMPage = hFrame:GetParent():Lookup("Page_GM")
		hGMPage:Hide()
		local hPage = hFrame:Lookup("", ""):Lookup(0)
		GMPanel.SelectHelperPage(hPage)
		hFrame:GetParent():Lookup("CheckBox_GM"):Check(false)
		hFrame:GetParent():Lookup("CheckBox_Helper"):Check(true)
	elseif hFrame:GetName() == "Page_GM" then
		local hHelperPage = hFrame:GetParent():Lookup("Page_Helper")
		hFrame:Show()
		hHelperPage:Hide()
		local hPage = hFrame:Lookup("", ""):Lookup(0)
		GMPanel.SelectGMPage(hPage)
		hFrame:GetParent():Lookup("CheckBox_GM"):Check(true)
		hFrame:GetParent():Lookup("CheckBox_Helper"):Check(false)
	end
end

function GMPanel.SelectHelperPage(hSelect)
	local hHlperList = hSelect:GetParent()
	local nCount = hHlperList:GetItemCount()
	for i = 0, nCount - 1 do
		local hPage = hHlperList:Lookup(i)
		if hPage:GetType() == "Handle" then
			hPage:Lookup(0):Hide()
			hPage.bSel = false
		end
	end
	
	hSelect:Lookup(0):Show()
	hSelect:Lookup(0):SetAlpha(255)
	hSelect.bSel = true
	
	local hScroll = hHlperList:GetParent():Lookup("Wnd_Helpers/Scroll_Helpers")
	hScroll:ScrollHome()
	GMPanel.SetHelperText(hSelect)
end

function GMPanel.ClearHelperPageSelected(hFrame)
	local hHlperList = hFrame:Lookup("", "")
	local nCount = hHlperList:GetItemCount()
	for i = 0, nCount - 1 do
		local hPage = hHlperList:Lookup(i)
		if hPage:GetType() == "Handle" then
			hPage:Lookup(0):Hide()
			hPage.bSel = false
		end
	end
end

function GMPanel.SetHelperText(hSelect)
	local szSelectName = hSelect:GetName()
	
	local szName = string.sub(szSelectName, 4, -1)
	if not szName or szName == "" then
		Log("GM Panel SetHelperText false")
	end
	local tText = {}
	if szName == "Reminded" then
		tText = GetRemindedHelper()
	else
		assert(tTextTableToHelper[szName])

		for Key, tValue in pairs(tTextTableToHelper[szName]) do
			table.insert(tText, tValue)
		end
		table.sort(tText, funSort)
	end
	
	local hPage = hSelect:GetParent():GetParent():Lookup("Wnd_Helpers")
	local hHandle = hPage:Lookup("", "")
	
	hHandle:Clear()
	local szInIFilePath = "ui/Config/Default/GMPanel.ini"
	local nTextCount = 0
	for Key, tHelp in ipairs(tText) do
		hHandle:AppendItemFromIni(szInIFilePath, "Handle_HelperText", "Handle_HelperText" .. nTextCount)
		local hText = hHandle:Lookup("Handle_HelperText" .. nTextCount)
		hMessage = hText:Lookup("Handle_HelperMessage")
		if szName == "Reminded" then
			hMessage:AppendItemFromString(tHelp)
		else
			hMessage:AppendItemFromString(Helper.GetFormatedText(tHelp.Text))
		end
		
		hMessage:AppendItemFromString(GetFormatText("\n " , 0))
		hMessage:FormatAllItemPos()
		local fWidth = hMessage:GetSize()
		local _ , fHeight = hMessage:GetAllItemSize()
		hMessage:SetSize(fWidth, fHeight)
			
		hText:FormatAllItemPos()
		hText:SetSize(fWidth, fHeight)
		
		nTextCount = nTextCount + 1
	end
	hHandle:FormatAllItemPos()
	GMPanel.UpdateHelperScrollInfo(hHandle)
end

function GMPanel.UpdateHelperScrollInfo(hHandle)
	hHandle:FormatAllItemPos()
	local fWidth, fHeight = hHandle:GetSize()
	local fWidthAll, fHeightAll = hHandle:GetAllItemSize()

	local nStep = math.ceil((fHeightAll - fHeight) / HANDLE_STEP_SIZE)
	
	local hScroll = hHandle:GetParent():Lookup("Scroll_Helpers")
	
	if nStep > 0 then
		hScroll:Show()
		hScroll:GetParent():Lookup("Btn_HelpersUp"):Show()
		hScroll:GetParent():Lookup("Btn_HelpersDown"):Show()
	else
		hScroll:Hide()
		hScroll:GetParent():Lookup("Btn_HelpersUp"):Hide()
		hScroll:GetParent():Lookup("Btn_HelpersDown"):Hide()
	end
	hScroll:SetStepCount(nStep)
end

function GMPanel.SearchHelper(hFrame)
	
	GMPanel.ClearHelperPageSelected(hFrame)
	
	local szText = hFrame:Lookup("Edit_Search"):GetText()
	
	local hHandle = hFrame:Lookup("Wnd_Helpers"):Lookup("", "")
	hHandle:Clear()
	local nTextCount = 0
	local szInIFilePath = "ui/Config/Default/GMPanel.ini"
	
	for szKey, szTitle in pairs(g_tStrings.tToturTitle) do 
		local bAll = false
		if StringFindW(szTitle, szText) then
			bAll = true
		end
		
		local tText  = {}
		tHelpers = tTextTableToHelper[szKey]
		for _, tValue in pairs(tHelpers) do
			local szHelpText = GMPanel.GetHelpText(tValue.Text)
			if bAll or StringFindW(szHelpText, szText) then
				table.insert(tText, tValue)			
			end
		end
		table.sort(tText, funSort)
		
		for Key, tHelp in ipairs(tText) do
			
			hHandle:AppendItemFromIni(szInIFilePath, "Handle_HelperText", "Handle_HelperText" .. nTextCount)
			local hText = hHandle:Lookup("Handle_HelperText" .. nTextCount)
			hMessage = hText:Lookup("Handle_HelperMessage")
			hMessage:AppendItemFromString(Helper.GetFormatedText(tHelp.Text))
			hMessage:AppendItemFromString(GetFormatText("\n ", 0))
			hMessage:FormatAllItemPos()
			local fWidth , fHeight = hMessage:GetAllItemSize()
			hMessage:SetSize(fWidth, fHeight)
				
			hText:FormatAllItemPos()
			hText:SetSize(fWidth, fHeight)
			
			nTextCount = nTextCount + 1
		end
				
	end
	
	--- not search anything
	if nTextCount == 0 then
		local hText = hHandle:AppendItemFromIni(szInIFilePath, "Handle_HelperText", "Handle_HelperText_No")
		hMessage = hText:Lookup("Handle_HelperMessage")
		hMessage:AppendItemFromString(GetFormatText(g_tStrings.NOT_FINED, 162))
		hMessage:FormatAllItemPos()
		local fWidth , fHeight = hMessage:GetAllItemSize()
		hMessage:SetSize(fWidth, fHeight)
			
		hText:FormatAllItemPos()
		hText:SetSize(fWidth, fHeight)
	end
	hHandle:FormatAllItemPos()
	GMPanel.UpdateHelperScrollInfo(hHandle)
end

function GMPanel.GetHelpText(szText)
	local szFormatedContent = ""
	for szColoredSection in szText:gmatch("{%a+}[^{]+") do
		local szColorName = szColoredSection:match("{(.*)}")
		local szFormatedSection = szColoredSection
		if szColorName then
			szFormatedSection = szFormatedSection:gsub("{%a+}", "")
		end
		
		szFormatedSection = GMPanel.GetHelpTextHokeyDesc(szFormatedSection)
		szFormatedContent = szFormatedContent .. szFormatedSection
	end
	
	return szFormatedContent
end

function GMPanel.GetHelpTextHokeyDesc(szText)
	local szResult = ""
	local nFirst, nLast, szKey = string.find(szText, "<(.-)>")
	while nFirst do
		local szPrev = string.sub(szText, 1, nFirst - 1)
		
		if szPrev and szPrev ~= "" then
			szResult = szResult..szPrev
		end
		if szKey and szKey ~= "" then
			szResult = szResult..Helper.GetHotkey(szKey)
		end
		
		szText = string.sub(szText, nLast + 1, -1)		
		nFirst, nLast, szKey = string.find(szText, "<(.-)>")
	end	
	if szText and szText ~= "" then
		szResult = szResult..szText
	end
	
	return szResult
end

function GMPanel_LinkItem(dwItemIDOrdwBox, dwX)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_Item")
	if not page then
		return false
	end
	local item = nil
	if dwX then
		item = GetPlayerItem(GetClientPlayer(), dwItemIDOrdwBox, dwX)
	else
		item = GetItem(dwItemIDOrdwBox)
	end
	if not item then
		return false
	end
	page:Lookup("Edit_IT"):SetText(GetItemNameByItem(item))
	page.aInfo = {}
	page.aInfo.nVersion = item.nVersion
	page.aInfo.nTabType = item.dwTabType
	page.aInfo.nTableIndex = item.dwIndex
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_FT"))
	return true
end

function GMPanel_LinkItemInfo(nVersion, nTabtype, nIndex)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_Item")
	if not page then
		return false
	end
	local itemInfo = GetItemInfo(nTabtype, nIndex)
	if not itemInfo then
		return false
	end
	page:Lookup("Edit_IT"):SetText(GetItemNameByItemInfo(itemInfo))
	page.aInfo = {}
	page.aInfo.nVersion = nVersion
	page.aInfo.nTabType = nTabtype
	page.aInfo.nTableIndex = nIndex
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_FT"))
	return true
end

function GMPanel_LinkSkill(dwID, dwLevel)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_School")
	if not page then
		return false
	end
	local skill = GetSkill(dwID, dwLevel)
	if not skill then
		return false
	end
	page:Lookup("Edit_SKT"):SetText(Table_GetSkillName(dwID, dwLevel))
	page.aInfo = {}
	page.aInfo.dwID = dwID
	page.aInfo.dwLevel = dwLevel
	
	page:Lookup("Edit_ST"):SetText(Table_GetSkillSchoolName(skill.dwBelongSchool))
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_STM"))		
	return true
end

function GMPanel_LinkQuest(dwQuestID)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_Quest")
	if not page then
		return false
	end	
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if not tQuestStringInfo then
		return false
	end
	
	page:Lookup("Edit_QT"):SetText(tQuestStringInfo.szName)
	page.aInfo = {}
	page.aInfo.dwQuestID = dwQuestID
	
	local szName = Table_GetMapName(GetClientPlayer().GetScene().dwMapID)
	page:Lookup("Edit_QTS"):SetText(szName)
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_QTM"))		
	return true
end

function GMPanel_LinkNpcName(szName)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_NPC")
	if not page then
		return false
	end	
	
	page:Lookup("Edit_NPCT"):SetText(szName)
	page.aInfo = {}
	
	local szName = Table_GetMapName(GetClientPlayer().GetScene().dwMapID)
	page:Lookup("Edit_NPCTS"):SetText(szName)
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_NPCTM"))		
	return true
end

function GMPanel_LinkNpcID(dwID)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_NPC")
	if not page then
		return false
	end
	local npc = GetNpc(dwID)
	if not npc then
		return false
	end
	
	page:Lookup("Edit_NPCT"):SetText(npc.szName)
	page.aInfo = {}
	page.dwNpcTemplateID = npc.dwTemplateID
	
	local szName = Table_GetMapName(GetClientPlayer().GetScene().dwMapID)
	page:Lookup("Edit_NPCTS"):SetText(szName)
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_NPCTM"))		
	return true
end

function GMPanel_LinkPlayerName(szName)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_Char")
	if not page then
		return false
	end	
	
	page:Lookup("Edit_ChT"):SetText(szName)
	page.aInfo = {}
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_SeT"))		
	return true
end

function GMPanel_LinkPlayerID(dwID)
	local page = Station.Lookup("Normal/GMPanel/PageSet_Total/Page_GM/Wnd_PutInBUG/Wnd_Char")
	if not page then
		return false
	end
	local player = GetPlayer(dwID)
	if not player then
		return false
	end
	
	page:Lookup("Edit_ChT"):SetText(player.szName)

	local szName = ""
	szName = g_tStrings.tRoleTypeFormalName[player.nRoleType]
	page:Lookup("Edit_SeT"):SetText(szName)
	
	page:GetRoot():BringToTop()
	Station.SetFocusWindow(page:Lookup("Edit_ChTM"))		
	return true
end

function IsGMPanelReceiveItem()
	local frame = Station.Lookup("Normal/GMPanel")
	if frame and frame:IsVisible() then
		local pageBug = frame:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG")
		if pageBug:IsVisible() and pageBug:Lookup("Wnd_Item"):IsVisible() then
			return true
		end
	end
	return false
end

function IsGMPanelReceiveSkill()
	local frame = Station.Lookup("Normal/GMPanel")
	if frame and frame:IsVisible() then
		local pageBug = frame:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG")
		if pageBug:IsVisible() and pageBug:Lookup("Wnd_School"):IsVisible() then
			return true
		end
	end
	return false
end

function IsGMPanelReceiveQuest()
	local frame = Station.Lookup("Normal/GMPanel")
	if frame and frame:IsVisible() then
		local pageBug = frame:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG")
		if pageBug:IsVisible() and pageBug:Lookup("Wnd_Quest"):IsVisible() then
			return true
		end
	end
	return false
end

function IsGMPanelReceiveNpc()
	local frame = Station.Lookup("Normal/GMPanel")
	if frame and frame:IsVisible() then
		local pageBug = frame:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG")
		if pageBug:IsVisible() and pageBug:Lookup("Wnd_NPC"):IsVisible() then
			return true
		end
	end
	return false
end

function IsGMPanelReceivePlayer()
	local frame = Station.Lookup("Normal/GMPanel")
	if frame and frame:IsVisible() then
		local pageBug = frame:Lookup("PageSet_Total/Page_GM/Wnd_PutInBUG")
		if pageBug:IsVisible() and pageBug:Lookup("Wnd_Char"):IsVisible() then
			return true
		end
	end
	return false
end

function GMPanel_BugReportNpcName(szName)
	hFrame = OpenGMPanel("Bug")
	local hPage = hFrame:Lookup("PageSet_Total/Page_GM")
	GMPanel.Clear(hFrame)
	GMPanel.SelectGMPage(hPage:Lookup("", "HI_PutInBUG"))
	GMPanel.SelectBugPage(hPage:Lookup("Wnd_PutInBUG/CheckBox_NPC"))
	GMPanel_LinkNpcName(szName)
end

function GMPanel_BugReportNpcID(dwID)
	hFrame = OpenGMPanel("Bug")
	local hPage = hFrame:Lookup("PageSet_Total/Page_GM")
	GMPanel.Clear(hFrame)
	GMPanel.SelectGMPage(hPage:Lookup("", "HI_PutInBUG"))
	GMPanel.SelectBugPage(hPage:Lookup("Wnd_PutInBUG/CheckBox_NPC"))
	GMPanel_LinkNpcID(dwID)
end

function GMPanel_BugReportPlayerName(szName)
	hFrame = OpenGMPanel("Bug")
	local hPage = hFrame:Lookup("PageSet_Total/Page_GM")
	GMPanel.Clear(hFrame)
	GMPanel.SelectGMPage(hPage:Lookup("", "HI_PutInBUG"))
	GMPanel.SelectBugPage(hPage:Lookup("Wnd_PutInBUG/CheckBox_Char"))
	GMPanel_LinkPlayerName(szName)
end

function GMPanel_BugReportPlayerID(dwID)
	hFrame = OpenGMPanel("Bug")
	local hPage = hFrame:Lookup("PageSet_Total/Page_GM")
	GMPanel.Clear(hFrame)
	GMPanel.SelectGMPage(hPage:Lookup("", "HI_PutInBUG"))
	GMPanel.SelectBugPage(hPage:Lookup("Wnd_PutInBUG/CheckBox_Char"))
	GMPanel_LinkPlayerID(dwID)
end

function GMPanel_ReportPlayer(szRoleName, szContent)
	local hFrame = OpenGMPanel("Bug")
	local hGMPage = hFrame:Lookup("PageSet_Total/Page_GM")
	GMPanel.SelectGMPage(hGMPage:Lookup("", "HI_Report"))
	GMPanel.Clear(hFrame)
	
	local hPage = hGMPage:Lookup("Wnd_Report")
	hPage:Lookup("", "Text_ReportName"):SetFontScheme(162)
	hPage:Lookup("", "Text_ReportName"):SetText(szRoleName)
	local hReportContent = hPage:Lookup("", "Handle_ReportContent")
	hReportContent:AppendItemFromString(GetFormatText(szContent, 162))
	hReportContent:FormatAllItemPos()
	hPage.bCanSubmit = true
end

function GMPanel_ReportRabot(szRoleName, szMapName, dwMapID, fPosX, fPosY, fPosZ)
	local hFrame = OpenGMPanel("Bug")
	local hGMPage = hFrame:Lookup("PageSet_Total/Page_GM")
	GMPanel.SelectGMPage(hGMPage:Lookup("", "HI_Rabot"))
	GMPanel.Clear(hFrame)
	
	local hPage = hGMPage:Lookup("Wnd_Rabot")
	local hEditRoleName = hPage:Lookup("Edit_RabotName")
	hEditRoleName:SetFontScheme(162)
	hEditRoleName:SetText(szRoleName)
	hEditRoleName.bEdit = false
	hPage:Lookup("Edit_RabotScence"):SetText(szMapName)
	hPage.dwMapID = dwMapID
	hPage.fPosX = fPosX
	hPage.fPosY = fPosY
	hPage.fPosZ = fPosZ
end

function OpenGMPanel(szName, bDisableSound)
	if not IsGMPanelOpened() then
		Wnd.OpenWindow("GMPanel")
	end
	
	local hFrame = Station.Lookup("Normal/GMPanel")
		
	hFrame:Show()
	hFrame:BringToTop()
	hFrame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	
	if szName then
		local hPage = nil
		if szName == "Bug" then
			hPage = hFrame:Lookup("PageSet_Total/Page_GM")
		elseif szName == "Helper" then
			hPage = hFrame:Lookup("PageSet_Total/Page_Helper")
		end
		
		GMPanel.SelectPage(hPage)
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
	return hFrame
end

function CloseGMPanel(bDisableSound)
	if not IsGMPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/GMPanel")
	frame:Hide()
	local hEditSearch = frame:Lookup("PageSet_Total/Page_Helper/Edit_Search")
	hEditSearch:ClearText()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsGMPanelOpened()
	local frame = Station.Lookup("Normal/GMPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function GMPanel_GMReply(szMessage, szName, szTime)
	local hFrame = Station.Lookup("Normal/GMPanel")
	if not hFrame then 
		hFrame = OpenGMPanel("Bug")
		CloseGMPanel()
	end
	
	if szName == nil then
		local nStart = string.find(szMessage, ":")
		if nStart then
			szName = string.sub(szMessage, 0, nStart - 1)
			szMessage = string.sub(szMessage, nStart + 1)
		else
			szName = "GM"
		end
	end
	
	if szName == "GM" and szMessage == "GM" then
		szMessage = g_tStrings.MSG_GM_REPLY
	end
	if szTime == nil then
		szTime = GetLocalTimeString()
	end
	
	local hHandle = hFrame:Lookup("PageSet_Total/Page_GM/Wnd_Appeal","Handle_Messege")
	hHandle:AppendItemFromString("<image>path=\"UI/Image/Minimap/Minimap.UITex\" frame=184</image>")
	hHandle:AppendItemFromString("<text>text="..EncodeComponentsString(szName..g_tStrings.STR_TWO_CHINESE_SPACE.. szTime .."\n").."font=163 </text>\n")
	GMPanel.GMReplyWebLink(hHandle, szMessage)
	GMPanel.UpdateAppealScrollInfo(hHandle)
	local hPage = hFrame:Lookup("PageSet_Total/Page_GM/Wnd_Appeal")
	if not IsElemVisible(hPage) then
		GMPanel.GMReplyShow(true)
	end
end

function GMPanel.GMReplyWebLink(hHandle, szMessage)
	local nFirst, nLast, szLink = string.find(szMessage, "<lk (.-)>")
	while nFirst do
		local szPrev = string.sub(szMessage, 1, nFirst - 1)
		
		if szPrev and szPrev ~= "" then
			hHandle:AppendItemFromString("<text>text="..EncodeComponentsString(szPrev).." font=106 </text>")
		end
		local nSeparate = string.find(szLink, "|")
		local szLinkMsg = string.sub(szLink, 1, nSeparate - 1)
		hHandle:AppendItemFromString("<text>text="..EncodeComponentsString(szLinkMsg).."font=105 eventid=277 </text>\n")
		local szLinkPath = string.sub(szLink, nSeparate + 1, -1)
		local hText = hHandle:Lookup(hHandle:GetItemCount() - 1)
		hText.OnItemLButtonClick = function()
			OpenInternetExplorer(szLinkPath)
		end
		hText.OnItemMouseEnter = function()
			this:SetFontScheme(139)
			GMPanel.UpdateAppealScrollInfo(this:GetParent())
		end
		hText.OnItemMouseLeave = function()
			this:SetFontScheme(105)
			GMPanel.UpdateAppealScrollInfo(this:GetParent())
		end
		
		szMessage = string.sub(szMessage, nLast + 1, -1)
		nFirst, nLast, szLink = string.find(szMessage, "<lk (.-)>")
	end
	if szMessage then
		hHandle:AppendItemFromString("<text>text="..EncodeComponentsString(szMessage .. "\n\n").."font=106 </text>\n")
	end	
end

function GetLocalTimeString()
	local nTime = GetCurrentTime()
	local szTime = FormatTimeString(nTime)
	return szTime
end

function OnUpdateGMMessage(dwMailID)
	local hMailClient = GetMailClient()
	if not hMailClient then
		return
	end 
	
	local szName, _, nTime, szMessage = hMailClient.GetGmMessage(dwMailID)
	szTime = FormatTimeString(nTime)
	GMPanel_GMReply(szMessage, szName, szTime)
	hMailClient.DeleteMail(dwMailID)
end

function FormatTimeString(nTime)
	local t = TimeToDate(nTime)
	return string.format("%d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.minute, t.second)
end

RegisterEvent("GET_GM_MESSAGE_MAIL", function() OnUpdateGMMessage(arg0) end)



