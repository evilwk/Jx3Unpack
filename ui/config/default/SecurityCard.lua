SecurityCard = {}

SecurityCard.m_nTime = 0

function SecurityCard.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	SecurityCard.CreateQList(this)
	SecurityCard.CreateALList(this)
	SecurityCard.CreateARList(this)
	
	SecurityCard.OnEvent("UI_SCALED")
end

function SecurityCard.OnFrameShow()
	local focus = Station.GetFocusWindow()
	if focus and focus:IsValid() then
		this:BringToTop()
		Station.SetFocusWindow(this)
	end
	SecurityCard.m_nQOffsetValue = 0
	SecurityCard.m_nLOffsetValue = 0
	SecurityCard.m_nROffsetValue = 0
	SecurityCard.m_tSecurityCardQ = {}
	SecurityCard.m_nCurrentQIndex = 1
	SecurityCard.m_szCurrentLValue = ""
	SecurityCard.m_szCurrentRValue = ""
	SecurityCard.m_szSecurityCardA = ""
	SecurityCard.m_bScrollQList = false
	SecurityCard.m_nErrorCount = 0
	
	SecurityCard.HideHelp(this)
end

function SecurityCard.OnFrameBreathe()
	local nTime = GetTickCount()
	
	if SecurityCard.m_bScrollQList then
		SecurityCard.ScrollQList(this, nTime - SecurityCard.m_nTime)
	end
	
	SecurityCard.ScrollAList(this, nTime - SecurityCard.m_nTime)
	
	SecurityCard.m_nTime = nTime
end

function SecurityCard.OnEvent(event)
	if event == "UI_SCALED" then
		local wndAll = this:Lookup("Wnd_All")
		this:SetSize(Station.GetClientSize())
		wndAll:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		SecurityCard.SetHelpWndPos(this)
	end
end

function SecurityCard.OnItemLButtonClick()
	local szName = this:GetName()
	local hRoot = this:GetRoot()
	if szName == "Handle_ALButton" then
		if SecurityCard.m_szCurrentLValue ~= "" then
			return
		end
		
		SecurityCard.m_szCurrentLValue = this:Lookup("Text_ALNormal"):GetText()
		SecurityCard.EnableALList(hRoot, false)
	elseif szName == "Handle_ARButton" then
		if SecurityCard.m_szCurrentRValue ~= "" then
			return
		end
		
		SecurityCard.m_szCurrentRValue = this:Lookup("Text_ARNormal"):GetText()
		SecurityCard.EnableARList(hRoot, false)
	end
	
	if SecurityCard.m_szCurrentLValue ~= "" and SecurityCard.m_szCurrentRValue ~= "" then
		SecurityCard.StepNext(hRoot)
	end
end

function SecurityCard.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_ALButton" then
		if SecurityCard.m_szCurrentLValue ~= "" then
			return
		end
		
		this:Lookup("Image_ALDown"):Show()
	elseif szName == "Handle_ARButton" then
		if SecurityCard.m_szCurrentRValue ~= "" then
			return
		end
		
		this:Lookup("Image_ARDown"):Show()
	end
end

function SecurityCard.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Handle_ALButton" then
		if SecurityCard.m_szCurrentLValue ~= "" then
			return
		end
		
		this:Lookup("Image_ALDown"):Hide()
	elseif szName == "Handle_ARButton" then
		if SecurityCard.m_szCurrentRValue ~= "" then
			return
		end
		
		this:Lookup("Image_ARDown"):Hide()
	end
end

function SecurityCard.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_ALButton" then
		SecurityCard.ShowAListText(this:GetRoot(), false)
		if SecurityCard.m_szCurrentLValue == "" then
			this:Lookup("Image_ALOver"):Show()
		end
	elseif szName == "Handle_ARButton" then
		SecurityCard.ShowAListText(this:GetRoot(), false)
		if SecurityCard.m_szCurrentRValue == "" then
			this:Lookup("Image_AROver"):Show()
		end
	end
end

function SecurityCard.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_ALButton" then
		SecurityCard.ShowAListText(this:GetRoot(), true)
		this:Lookup("Image_ALOver"):Hide()
	elseif szName == "Handle_ARButton" then
		SecurityCard.ShowAListText(this:GetRoot(), true)
		this:Lookup("Image_AROver"):Hide()
	end
end

function SecurityCard.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		SecurityCard.HideHelp(this:GetRoot())
	elseif szName == "Btn_Backspace" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		SecurityCard.Restart(this:GetRoot())
	elseif szName == "Btn_Sure" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login_MibaoVerify(SecurityCard.m_szSecurityCardA)
	elseif szName == "Btn_Cancel" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.HideSecurityCard()
		Login.EnterPassword()
	elseif szName == "Btn_Help" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		SecurityCard.ShowHelp(this:GetRoot())
	end
end

function SecurityCard.Start(hFrame)
	if not hFrame then
		return
	end
	
	SecurityCard.m_szCurrentLValue = ""
	SecurityCard.m_szCurrentRValue = ""
	
	SecurityCard.EnableALList(hFrame, true)
	
	SecurityCard.EnableARList(hFrame, true)
	
	SecurityCard.MatrixShowQ(hFrame)
	
	SecurityCard.QListShowQ(hFrame)
	
	SecurityCard.TipShowQ(hFrame)
end

function SecurityCard.StepNext(hFrame)
	if not hFrame then
		return
	end
	
	SecurityCard.SaveCurrentValue()
	SecurityCard.MatrixShowA(hFrame)
	SecurityCard.QListFinishQ(hFrame)
	
	SecurityCard.m_nCurrentQIndex = SecurityCard.m_nCurrentQIndex + 1
	
	if SecurityCard.m_nCurrentQIndex > #SecurityCard.m_tSecurityCardQ then
		SecurityCard.Stop(hFrame)
	else
		SecurityCard.m_bScrollQList = true
		SecurityCard.Start(hFrame)
	end
end

function SecurityCard.Stop(hFrame)
	if not hFrame then
		return
	end
	
	hFrame:Lookup("Wnd_All"):Lookup("Btn_Sure"):Enable(true)
end

function SecurityCard.Restart(hFrame)
	if not hFrame then
		return
	end
	
	SecurityCard.m_szSecurityCardA = ""
	SecurityCard.m_nCurrentQIndex = 1
	SecurityCard.ResetQList(hFrame)
	SecurityCard.ResetMatrix(hFrame)
	hFrame:Lookup("Wnd_All"):Lookup("Btn_Sure"):Enable(false)
	SecurityCard.Start(hFrame)
end

function SecurityCard.SaveCurrentValue()
	SecurityCard.m_szSecurityCardA = SecurityCard.m_szSecurityCardA..SecurityCard.m_szCurrentLValue..SecurityCard.m_szCurrentRValue
end

function SecurityCard.ResetMatrix(hFrame)
	local tMatrixRow = {"A", "B", "C", "D", "E", "F", "G", "H"}
	local tMatrixColumn = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
	
	for nRow = 1, #tMatrixRow do
		for nColumn = 1, #tMatrixColumn do
			local szRow = tMatrixRow[nRow]
			local szColumn = tMatrixColumn[nColumn]
			
			hFrame:Lookup("Wnd_All"):Lookup("", "Text_"..szRow..szColumn):Hide()
			hFrame:Lookup("Wnd_All"):Lookup("", "Image_"..szRow..szColumn):Show()
		end
	end
end

function SecurityCard.MatrixShowQ(hFrame)
	if not hFrame then
		return
	end
	
	local szCurrentQValue = SecurityCard.m_tSecurityCardQ[SecurityCard.m_nCurrentQIndex]
	
	hFrame:Lookup("Wnd_All"):Lookup("", "Text_"..szCurrentQValue):Hide()
	hFrame:Lookup("Wnd_All"):Lookup("", "Image_"..szCurrentQValue):Hide()
end

function SecurityCard.MatrixShowA(hFrame)
	if not hFrame then
		return
	end
	
	local szCurrentQValue = SecurityCard.m_tSecurityCardQ[SecurityCard.m_nCurrentQIndex]
	
	hFrame:Lookup("Wnd_All"):Lookup("", "Image_"..szCurrentQValue):Show()
	hFrame:Lookup("Wnd_All"):Lookup("", "Text_"..szCurrentQValue):Show()
end

function SecurityCard.ScrollAList(hFrame, nTime)
	if not hFrame then
		return
	end
	
	local hALList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ALButtonList")
	local hARList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ARButtonList")
	local nLScrollDeltaValue = SecurityCard.GetScrollDeltaValue(hALList)
	local nRScrollDeltaValue = SecurityCard.GetScrollDeltaValue(hARList)
	
	nTime = nTime * 0.001
	SecurityCard.m_nLOffsetValue = SecurityCard.m_nLOffsetValue + nLScrollDeltaValue * nTime
	SecurityCard.m_nROffsetValue = SecurityCard.m_nROffsetValue + nRScrollDeltaValue * nTime
	
	SecurityCard.m_nLOffsetValue = SecurityCard.UpdateAListPosition(hALList, SecurityCard.m_nLOffsetValue)
	SecurityCard.m_nROffsetValue = SecurityCard.UpdateAListPosition(hARList, SecurityCard.m_nROffsetValue)
end

function SecurityCard.GetScrollDeltaValue(hI)
	if not hI then
		return 0
	end
	
	local nClientWidth, nClientHeight = Station.GetClientSize()
	local nCursorX, nCursorY = Cursor.GetPos()
	local nItemPosX, nItemPosY = hI:GetAbsPos()
	local nItemWidth, nItemHeight = hI:GetSize()
	local nXDis1 = nCursorX - nItemPosX
	local nXDis2 = nCursorX - (nItemPosX + nItemWidth)
	local nYDis1 = nCursorY - nItemPosY
	local nYDis2 = nCursorY - (nItemPosY + nItemHeight)
	local nXDis, nYDis = 0, 0
	
	if nXDis1 * nXDis2 < 0 then
		nXDis = 0
	else
		nXDis = math.min(math.abs(nXDis1), math.abs(nXDis2))
	end
	
	if nYDis1 * nYDis2 < 0 then
		nYDis = 0
	else
		nYDis = math.min(math.abs(nYDis1), math.abs(nYDis2))
	end
		
	if not nClientWidth or nClientWidth == 0 or not nClientHeight or nClientHeight == 0 then
		return 0
	end
	
	local nSpeed = 160
	return (nXDis / nClientWidth + nYDis / nClientHeight) * nSpeed
end

function SecurityCard.TipShowQ(hFrame)
	if not hFrame then
		return
	end
	
	local hI = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_Tip")
	local szCurrentQValue = SecurityCard.m_tSecurityCardQ[SecurityCard.m_nCurrentQIndex]
	local szTip = FormatString(g_tGlue.STR_SECURITYCARD_TIP, szCurrentQValue)
	
	hI:Clear()
	hI:AppendItemFromString(szTip)
	hI:FormatAllItemPos()
end

function SecurityCard.CreateQList(hFrame)
	if not hFrame then
		return
	end
	SecurityCard.ResetQList(hFrame)
end

function SecurityCard.ResetQList(hFrame)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_QButtonList")
	hList:Clear()
	
    for i = 1, 5 do
		hList:AppendItemFromIni("UI/Config/Default/SecurityCard.ini", "Handle_QButton", "Handle_QButton")
		local hI = hList:Lookup(hList:GetItemCount() - 1)
		
		if i < 3 then
			hI:Lookup("Text_QNormal"):SetText("")
		else
			hI:Lookup("Text_QNormal"):SetText("??")
		end
    end
    
	hList:FormatAllItemPos()
    
    hList:SetItemStartRelPos(0, 0)
end

function SecurityCard.QListShowQ(hFrame)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_QButtonList")
	local szCurrentQValue = SecurityCard.m_tSecurityCardQ[SecurityCard.m_nCurrentQIndex]
	hList:Lookup(SecurityCard.m_nCurrentQIndex + 1):Lookup("Text_QNormal"):SetText(szCurrentQValue)
end

function SecurityCard.QListFinishQ(hFrame)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_QButtonList")
	hList:Lookup(SecurityCard.m_nCurrentQIndex + 1):Lookup("Text_QNormal"):SetFontScheme(46)
end

function SecurityCard.ScrollQList(hFrame, nTime)
	if not hFrame or SecurityCard.m_nCurrentQIndex < 2 then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_QButtonList")
	local _, nHeight = hList:Lookup(0):GetSize()
	
	if SecurityCard.m_nQOffsetValue >= nHeight then
		SecurityCard.m_bScrollQList = false
		SecurityCard.m_nQOffsetValue = 0
		return
	end
	
	nTime = nTime * 0.001
	local nSpeed = 50
	SecurityCard.m_nQOffsetValue = SecurityCard.m_nQOffsetValue + nSpeed * nTime
	
	if SecurityCard.m_nQOffsetValue > nHeight then
		SecurityCard.m_nQOffsetValue = nHeight
	end
	
	local nStartRelPos = (SecurityCard.m_nCurrentQIndex - 2) * nHeight + SecurityCard.m_nQOffsetValue
	hList:SetItemStartRelPos(0, -nStartRelPos)
end

function SecurityCard.CreateALList(hFrame)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ALButtonList")
	hList:Clear()
	
    for i = 1, #g_tGlue.tSecurityCardNumber do
		hList:AppendItemFromIni("UI/Config/Default/SecurityCard.ini", "Handle_ALButton", "Handle_ALButton")
		local hI = hList:Lookup(hList:GetItemCount() - 1)
		
		hI:Lookup("Text_ALNormal"):SetText(g_tGlue.tSecurityCardNumber[i])
		hI:Lookup("Image_ALNormal"):Show()
		hI:Lookup("Image_ALOver"):Hide()
		hI:Lookup("Image_ALDown"):Hide()
		hI:Lookup("Image_ALDisable"):Hide()
    end
    
	hList:FormatAllItemPos()
end

function SecurityCard.ResetALList(hFrame)
	if not hFrame then
		return
	end
	
    SecurityCard.EnableALList(hFrame, true)
end

function SecurityCard.CreateARList(hFrame)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ARButtonList")
	hList:Clear()
	
    for i = 1, #g_tGlue.tSecurityCardNumber do
		hList:AppendItemFromIni("UI/Config/Default/SecurityCard.ini", "Handle_ARButton", "Handle_ARButton")
		local hI = hList:Lookup(hList:GetItemCount() - 1)
		
		hI:Lookup("Text_ARNormal"):SetText(g_tGlue.tSecurityCardNumber[i])
		hI:Lookup("Image_ARNormal"):Show()
		hI:Lookup("Image_AROver"):Hide()
		hI:Lookup("Image_ARDown"):Hide()
		hI:Lookup("Image_ARDisable"):Hide()
    end
    
	hList:FormatAllItemPos()
end

function SecurityCard.ResetARList(hFrame)
	if not hFrame then
		return
	end
	
    SecurityCard.EnableARList(hFrame, true)
end

function SecurityCard.EnableALList(hFrame, bEnable)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ALButtonList")
	
    for i = 1, hList:GetItemCount() do
		local hI = hList:Lookup(i - 1)
		
		if bEnable then
			hI:Lookup("Image_ALDisable"):Hide()
		else
			hI:Lookup("Image_ALDisable"):Show()
		end
    end
end

function SecurityCard.EnableARList(hFrame, bEnable)
	if not hFrame then
		return
	end
	
	local hList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ARButtonList")
	
    for i = 1, hList:GetItemCount() do
		local hI = hList:Lookup(i - 1)
		
		if bEnable then
			hI:Lookup("Image_ARDisable"):Hide()
		else
			hI:Lookup("Image_ARDisable"):Show()
		end
    end
end

function SecurityCard.UpdateAListPosition(hList, nDeltaValue)
	if not hList then
		return 0
	end
	
	local _, nHeight = hList:Lookup(0):GetSize()
	local nNeedFormat = false
	
	while nDeltaValue >= nHeight do
		hList:Lookup(0):SetIndex(hList:GetItemCount() - 1)
		nDeltaValue = nDeltaValue - nHeight
		
		nNeedFormat = true;
	end
	
	if nNeedFormat then
		hList:FormatAllItemPos()
	end
	
	hList:SetItemStartRelPos(0, -nDeltaValue)
	
	return nDeltaValue
end

function SecurityCard.SetSecurityCardPosion(szPosition)
	if not szPosition or szPosition == "" then
		Trace("SecurityCard Position is empty!")
		return
	end
	
	if #szPosition ~= 6 then
		Trace("SecurityCard Position Error: "..szPosition)
		return
	end
	
	SecurityCard.m_tSecurityCardQ = {}
	
	local i = 1
	for szValue in string.gfind(szPosition, "%u%d") do
		SecurityCard.m_tSecurityCardQ[i] = szValue
		i = i + 1
	end
	
	if i < 4 then
		Trace("SecurityCard Position Error: "..szPosition)
		return
	end
		
	
	local hFrame = Station.Lookup("Topmost/SecurityCard")
	if hFrame then
		SecurityCard.Restart(hFrame)
	end
end

function SecurityCard.ErrorClose(szMsg)
	local nWidth, nHeight = Station.GetClientSize()
	local msg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = szMsg,
		szName = "SecurityCardErrorNeedClose",
		fnAutoClose = function() return not IsSecurityCardOpened() end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, 
		    fnAction = function()
				Login.HideSecurityCard()
				Login.EnterPassword()
		    end 
		 },
	}
	MessageBox(msg)
end

function SecurityCard.ErrorRetry(szMsg, szPosition)
	local nWidth, nHeight = Station.GetClientSize()
	local msg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = szMsg,
		szName = "SecurityCardErrorNeedRetry",
		fnAutoClose = function() return not IsSecurityCardOpened() end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, 
		    fnAction = function()
		        SecurityCard.m_nErrorCount = SecurityCard.m_nErrorCount + 1
		        Trace("SecurityCard.m_nErrorCount "..SecurityCard.m_nErrorCount)
		        if SecurityCard.m_nErrorCount == 10 then
		        	Login.HideSecurityCard()
		        	Login.EnterPassword()
		        else
		        	SecurityCard.SetSecurityCardPosion(szPosition)
		        end
		    end 
		 },
	}
	MessageBox(msg)
end

function SecurityCard.SetHelpWndPos(hFrame)
	local wndAll = hFrame:Lookup("Wnd_All")
	local wndHelp = hFrame:Lookup("Wnd_Help")

	local nPosX, nPosY = wndAll:GetAbsPos()
	local nWidth = wndAll:GetSize()
	wndHelp:SetAbsPos(nPosX + nWidth, nPosY)
end

function SecurityCard.ShowHelp(hFrame)
	local wndHelp = hFrame:Lookup("Wnd_Help")
	if wndHelp:IsVisible() then
		return
	end
	
	SecurityCard.SetHelpWndPos(hFrame)
	wndHelp:Show()
end

function SecurityCard.HideHelp(hFrame)
	local wndHelp = hFrame:Lookup("Wnd_Help")
	if not wndHelp:IsVisible() then
		return
	end
	wndHelp:Hide()
end

function IsSecurityCardOpened()
	local hFrame = Station.Lookup("Topmost/SecurityCard")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

function SecurityCard.ShowAListText(hFrame, bShow)
	SecurityCard.ShowALListText(hFrame, bShow)
	SecurityCard.ShowARListText(hFrame, bShow)
end

function SecurityCard.ShowALListText(hFrame, bShow)
	local hALList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ALButtonList")
	if not hALList then
		return
	end
	
	for i = 1, hALList:GetItemCount() do
		local hI = hALList:Lookup(i - 1)
		if bShow then
			hI:Lookup("Text_ALNormal"):Show()
		else
			hI:Lookup("Text_ALNormal"):Hide()
		end
	end
end

function SecurityCard.ShowARListText(hFrame, bShow)
	local hARList = hFrame:Lookup("Wnd_All"):Lookup("", "Handle_SecurityCard/Handle_ARButtonList")
	if not hARList then
		return
	end
	
	for i = 1, hARList:GetItemCount() do
		local hI = hARList:Lookup(i - 1)
		if bShow then
			hI:Lookup("Text_ARNormal"):Show()
		else
			hI:Lookup("Text_ARNormal"):Hide()
		end
	end
end
