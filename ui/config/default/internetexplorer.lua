IE_Base = class()

function IE_Base.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this.nOpenTime = GetTickCount()
	
	this:GetSelf():EnableDrage(this, true)
end

function IE_Base.OnEvent(event)
	if event == "UI_SCALED" then
		if this.bMaxSize then
			local wC, hC = Station.GetClientSize()
		end
		this:CorrectPos()
	end
end

function IE_Base:EnableDrage(frame, bEnable)
	if bEnable then
		frame:Lookup("Btn_DL"):RegisterLButtonDrag()
		frame:Lookup("Btn_DTL"):RegisterLButtonDrag()
		frame:Lookup("Btn_DT"):RegisterLButtonDrag()
		frame:Lookup("Btn_DTR"):RegisterLButtonDrag()
		frame:Lookup("Btn_DR"):RegisterLButtonDrag()
		frame:Lookup("Btn_DRB"):RegisterLButtonDrag()
		frame:Lookup("Btn_DB"):RegisterLButtonDrag()
		frame:Lookup("Btn_DLB"):RegisterLButtonDrag()
	else
		frame:Lookup("Btn_DL"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DTL"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DT"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DTR"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DR"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DRB"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DB"):UnregisterLButtonDrag()
		frame:Lookup("Btn_DLB"):UnregisterLButtonDrag()
	end
end

function IE_Base.OnLButtonClick(event)
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseInternetExplorer(this:GetRoot().nIndex)
	elseif szName == "Btn_GoBack" then
		this:GetParent():Lookup("WebPage_Page"):GoBack()
	elseif szName == "Btn_GoForward" then
		this:GetParent():Lookup("WebPage_Page"):GoForward()
	elseif szName == "Btn_Refresh" then
		this:GetParent():Lookup("WebPage_Page"):Refresh()
	elseif szName == "Btn_GoTo" then
		local szInput = this:GetParent():Lookup("Edit_Input"):GetText()
		if szInput ~= "" then
			this:GetParent():Lookup("WebPage_Page"):Navigate(szInput)
		end	
	end
end

function IE_Base.OnHistoryChanged()
	this:GetParent():Lookup("Btn_GoBack"):Enable(this:CanGoBack())
	this:GetParent():Lookup("Btn_GoForward"):Enable(this:CanGoForward())
end

function IE_Base.OnTitleChanged()
	szName = this:GetLocationName()
	this:GetRoot():Lookup("", "Text_Title"):SetText(szName)
	local szAddr = this:GetLocationURL()
	local edit = this:GetParent():Lookup("Edit_Input")
	if szAddr ~= edit.szAddr then
		edit:SetText(szAddr);
		edit.szAddr = szAddr
	end
end

function IE_Base.OnCheckBoxCheck(event)
	local szName = this:GetName()
	if szName == "CheckBox_MaxSize" then
		local wC, hC = Station.GetClientSize()
		local frame = this:GetRoot()
		frame.wOrg, frame.hOrg = frame:GetSize()
		frame.xOrg, frame.yOrg = frame:GetRelPos()
		frame:GetSelf():Resize(frame, wC, hC)
		frame:SetRelPos(0, 0)
		frame.bMaxSize = true
		Station.SetFocusWindow(frame:Lookup("WebPage_Page"))
		frame:GetSelf():EnableDrage(frame, false)
	end
end

function IE_Base.OnCheckBoxUncheck(event)
	local szName = this:GetName()
	if szName == "CheckBox_MaxSize" then
		local wC, hC = Station.GetClientSize()
		local frame = this:GetRoot()
		if not frame.wOrg then
			return
		end
		if frame.wOrg > wC then
			frame.wOrg = wC
		end
		if frame.hOrg > hC then
			frame.hOrg = hC
		end
		frame:GetSelf():Resize(frame, frame.wOrg, frame.hOrg)
		if frame.xOrg + frame.wOrg > wC then
			frame.xOrg = wC - frame.wOrg
		end
		if frame.yOrg + frame.hOrg > hC then
			frame.yOrg = hC - frame.hOrg
		end
		frame:SetRelPos(frame.xOrg, frame.yOrg)
		frame:CorrectPos()
		frame.bMaxSize = false
		Station.SetFocusWindow(frame:Lookup("WebPage_Page"))
		frame:GetSelf():EnableDrage(frame, true)
	end
end

function IE_Base.OnEditSpecialKeyDown(event)
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		local szInput = this:GetText()
		if szInput ~= "" then
			this:GetParent():Lookup("WebPage_Page"):Navigate(szInput)
		end
		return 1
	end
end

function IE_Base.OnItemLButtonDBClick()
	local szName = this:GetName()
	if szName == "Text_Title" then
		local frame = this:GetRoot()
		if frame.bMaxSize then
			frame:Lookup("CheckBox_MaxSize"):Check(false)
		else
			frame:Lookup("CheckBox_MaxSize"):Check(true)
		end
	end
end

function IE_Base.OnDragButtonBegin()
	this.fDragX, this.fDragY = Station.GetMessagePos()
	this.bOnDraging = true
	local frame = this:GetRoot()
	this.fDragW, this.fDragH = frame:GetSize()
	this.fDragFrameX, this.fDragFrameY = frame:GetAbsPos()
end

function IE_Base.OnDragButton()
	local x, y = Station.GetMessagePos()
	local w, h = Station.GetClientSize()
	if x < 0 or y < 0 or x > w or y > h then
		return
	end
	
	local frame = this:GetRoot()
	local self = frame:GetSelf()
	local szName = this:GetName()
	local fx, fy = frame:GetRelPos()
	local ax, ay = nil, nil
	if szName == "Btn_DL" then
		ax = this.fDragX - x
		self:Resize(frame, this.fDragW + ax, this.fDragH)
	elseif szName == "Btn_DTL" then
		ax = this.fDragX - x
		ay = this.fDragY - y
		self:Resize(frame, this.fDragW + ax, this.fDragH + ay)
	elseif szName == "Btn_DT" then
		ay = this.fDragY - y
		self:Resize(frame, this.fDragW, this.fDragH + ay)
	elseif szName == "Btn_DTR" then
		ay = this.fDragY - y
		self:Resize(frame, this.fDragW - this.fDragX + x, this.fDragH + ay)
	elseif szName == "Btn_DR" then
		self:Resize(frame, this.fDragW - this.fDragX + x, this.fDragH)
	elseif szName == "Btn_DRB" then
		self:Resize(frame, this.fDragW - this.fDragX + x, this.fDragH + y - this.fDragY)
	elseif szName == "Btn_DB" then
		self:Resize(frame, this.fDragW, this.fDragH + y - this.fDragY)
	elseif szName == "Btn_DLB" then
		ax = this.fDragX - x
		self:Resize(frame, this.fDragW + ax, this.fDragH + y - this.fDragY)
	end
	if ax or ay then
		if ax then fx = this.fDragFrameX - ax end
		if ay then fy = this.fDragFrameY - ay end
		frame:SetAbsPos(fx, fy)
	end
end

function IE_Base:Resize(frame, w, h)
	if w < 400 then w = 400 end
	if h < 200 then h = 200 end
	
	local handle = frame:Lookup("", "")
	handle:SetSize(w, h)
	handle:Lookup("Image_Bg"):SetSize(w, h)
	handle:Lookup("Image_BgT"):SetSize(w - 6, 64)
	handle:Lookup("Image_Edit"):SetSize(w - 300, 25)
	handle:Lookup("Text_Title"):SetSize(w - 168, 30)
	handle:FormatAllItemPos()
	
	local webPage = frame:Lookup("WebPage_Page")
	webPage:SetSize(w - 12, h - 76)
	
	frame:Lookup("Edit_Input"):SetSize(w - 306, 20)
	
	frame:Lookup("Btn_GoTo"):SetRelPos(w - 110, 38)
	frame:Lookup("Btn_Close"):SetRelPos(w - 40, 10)
	frame:Lookup("CheckBox_MaxSize"):SetRelPos(w - 70, 10)
	
	frame:Lookup("Btn_DL"):SetSize(10, h - 20)
	frame:Lookup("Btn_DT"):SetSize(w - 20, 10)
	frame:Lookup("Btn_DTR"):SetRelPos(w - 10, 0)
	frame:Lookup("Btn_DR"):SetRelPos(w - 10, 10)
	frame:Lookup("Btn_DR"):SetSize(10, h - 20)
	frame:Lookup("Btn_DRB"):SetRelPos(w - 10, h - 10)
	frame:Lookup("Btn_DB"):SetRelPos(10, h - 10)
	frame:Lookup("Btn_DB"):SetSize(w - 20, 10)
	frame:Lookup("Btn_DLB"):SetRelPos(0, h - 10)
	
	frame:SetSize(w, h)
	frame:SetDragArea(0, 0, w, 30)
end

function IE_Base.OnDragButtonEnd()
	local x, y = Station.GetMessagePos()
	local frame = this:GetRoot()
	frame.bOnDraging = false
	local self = frame:GetSelf()
	self.OnDragButton()
	if self.nMainGroupIndex then
		local handle = frame:Lookup("Wnd_Message", "Handle_Message")
		local w, h = handle:GetSize()	
		ChatPanel_Base_MgDragEnd(self.nMainGroupIndex, w, h)
	end
	this.bOnDraging = false
	if not this.bMouseOver then
		local szName = this:GetName()
		if szName == "Btn_DragTop" then
			if Cursor.GetCurrentIndex() == CURSOR.TOP_BOTTOM then
				Cursor.Switch(CURSOR.NORMAL)
			end	
		elseif szName == "Btn_DragTopRight" then
			if Cursor.GetCurrentIndex() == CURSOR.RIGHTTOP_LEFTBOTTOM then
				Cursor.Switch(CURSOR.NORMAL)
			end			
		elseif szName == "Btn_DragRight" then
			if Cursor.GetCurrentIndex() == CURSOR.LEFT_RIGHT then
				Cursor.Switch(CURSOR.NORMAL)
			end
		end		
	end
end

function IE_Base.OnFrameDragEnd()
	this:CorrectPos()
end

function IE_Base.OnMouseLeave()
	local szName = this:GetName()
	if szName == "Btn_DT" or szName == "Btn_DB" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.TOP_BOTTOM then
			Cursor.Switch(CURSOR.NORMAL)
		end
	elseif szName == "Btn_DTR" or szName == "Btn_DLB" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.RIGHTTOP_LEFTBOTTOM then
			Cursor.Switch(CURSOR.NORMAL)
		end
	elseif szName == "Btn_DTL" or szName == "Btn_DRB" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.LEFTTOP_RIGHTBOTTOM then
			Cursor.Switch(CURSOR.NORMAL)
		end
	elseif szName == "Btn_DL" or szName == "Btn_DR" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.LEFT_RIGHT then
			Cursor.Switch(CURSOR.NORMAL)
		end
	end
end

function IE_Base.OnMouseEnter()
	local frame = this:GetRoot()
	if frame.bMaxSize then
		return
	end
	local szName = this:GetName()
	if szName == "Btn_DT" or szName == "Btn_DB" then
		if not IsCursorInExclusiveMode or not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.TOP_BOTTOM)
		end
	elseif szName == "Btn_DTR" or szName == "Btn_DLB" then
		if not IsCursorInExclusiveMode or not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.RIGHTTOP_LEFTBOTTOM)
		end
	elseif szName == "Btn_DTL" or szName == "Btn_DRB" then
		if not IsCursorInExclusiveMode or not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.LEFTTOP_RIGHTBOTTOM)
		end	
	elseif szName == "Btn_DL" or szName == "Btn_DR" then
		if not IsCursorInExclusiveMode or not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.LEFT_RIGHT)
		end
	end
end

function IE_Base.OnFrameHide()
	if Login then
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			if Login.m_StateLeaveFunction == Login.LeavePassword then
				Login.ShowSdoaWindows(true)
			end
		end	
	end
end

function IE_GetNewIEFramePos()
	local nLastTime = 0
	local nLastIndex = nil
	for i = 1, 10, 1 do
		local frame = Station.Lookup("Topmost/IE"..i)
		if frame and frame:IsVisible() then
			if frame.nOpenTime > nLastTime then
				nLastTime = frame.nOpenTime
				nLastIndex = i
			end
		end
	end
	if nLastIndex then
		local frame = Station.Lookup("Topmost/IE"..nLastIndex)
		x, y = frame:GetAbsPos()
		local wC, hC = Station.GetClientSize()
		if x + 890 <= wC and y + 630 <= hC then
			return x + 30, y + 30
		end
	end
	return 40, 40
end

function OpenInternetExplorer(szAddr, bDisableSound)
	if Login then
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			if Login.m_StateLeaveFunction == Login.LeavePassword then
				Login.ShowSdoaWindows(false)
			end
		end	
	end

	local nIndex = nil
	local nLast = nil
	for i = 1, 10, 1 do
		if not IsInternetExplorerOpened(i) then
			nIndex = i
			break
		elseif not nLast then
			nLast = i
		end
	end
	if not nIndex then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_OPEN_TOO_MANY)
		return nil
	end
	local x, y = IE_GetNewIEFramePos()
	local frame = Wnd.OpenWindow("InternetExplorer", "IE"..nIndex)
	frame.bIE = true
	frame.nIndex = nIndex
	
	frame:BringToTop()
	if nLast then
		frame:SetAbsPos(x, y)
		frame:CorrectPos()
		frame.x = x
		frame.y = y
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		frame.x, frame.y = frame:GetAbsPos()
	end
	local webPage = frame:Lookup("WebPage_Page")
	if szAddr then
		webPage:Navigate(szAddr)
	end
	Station.SetFocusWindow(webPage)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	return webPage
end

function OpenInternetExplorerForBindCard(szConst, szAccount, szPasswordTreePath, szCode, szOfficialWeb, bDisableSound)
	local nIndex = nil
	local nLast = nil
	for i = 1, 10, 1 do
		if not IsInternetExplorerOpened(i) then
			nIndex = i
			break
		elseif not nLast then
			nLast = i
		end
	end
	if not nIndex then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_OPEN_TOO_MANY)
		return nil
	end
	local x, y = IE_GetNewIEFramePos()
	local frame = Wnd.OpenWindow("InternetExplorer", "IE"..nIndex)
	frame.bIE = true
	frame.nIndex = nIndex
	
	frame:BringToTop()
	if nLast then
		frame:SetAbsPos(x, y)
		frame:CorrectPos()
		frame.x = x
		frame.y = y
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		frame.x, frame.y = frame:GetAbsPos()
	end
	local webPage = frame:Lookup("WebPage_Page")
	if szConst and szAccount and szPasswordTreePath and szCode and szOfficialWeb then
		webPage:NavigateBindCard(szConst, szAccount, szPasswordTreePath, szCode, szOfficialWeb)
	end
	Station.SetFocusWindow(webPage)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	return webPage
end

function CloseLastInternetExplorer()
	local fLast = nil
	local frame = Station.Lookup("Topmost"):GetFirstChild()
	while frame do
		if frame.bIE then
			fLast = frame
		end	
		frame = frame:GetNext()
	end
		
	if fLast then
		Wnd.CloseWindow(fLast:GetName())
		return true
	end
	return false
end

function CloseInternetExplorer(nIndex, bDisableSound)
	if not IsInternetExplorerOpened(nIndex) then
		return
	end
	Wnd.CloseWindow("IE"..nIndex)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsInternetExplorerOpened(nIndex)
	local frame = Station.Lookup("Topmost/IE"..nIndex)
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function GetInternetExplorerIndex(szUrl)
	if not szUrl then
		return
	end
	
	local nIndex = nil	
	local frame = Station.Lookup("Topmost"):GetFirstChild()
	while frame do
		if frame.bIE then
			local webPage = frame:Lookup("WebPage_Page")
			local szAddr = webPage:GetLocationURL()
			if szUrl == szAddr then
				nIndex = frame.nIndex
				break
			end
		end	
		frame = frame:GetNext()
	end
	
	return nIndex
end

function GetInternetExplorerIndexFromTitle(szPatterns)
	if not szPatterns or szPatterns == "" then
		return
	end
	
	local nIndex = nil	
	local frame = Station.Lookup("Topmost"):GetFirstChild()
	while frame do
		if frame.bIE then
			local webPage = frame:Lookup("WebPage_Page")
			local szTitle = webPage:GetLocationName()
			
			if string.find(szTitle, szPatterns) then
				nIndex = frame.nIndex
				break
			end
		end	
		frame = frame:GetNext()
	end
	
	return nIndex
end
