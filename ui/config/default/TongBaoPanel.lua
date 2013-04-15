TongBaoPanel = {}

function TongBaoPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("SYNC_COIN")
	
	this:Lookup("", "Text_Coin"):SetText(GetClientPlayer().nCoin)
	
	local hList = this:Lookup("", "Handle_Message")
	
	hList:AppendItemFromString(g_tStrings.STR_TONG_BAO_DESC)
	TongBaoPanel.UpdateScrollInfo(hList)
	
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
end

function TongBaoPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:CorrectPos()
	elseif event == "SYNC_COIN" then
		hFrame:Lookup("", "Text_Coin"):SetText(GetClientPlayer().nCoin)
	end
end

function TongBaoPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseTongBaoPanelPannel()
	elseif szName == "Btn_Recharge" then
		OpenInternetExplorer(tUrl.Recharge, true)
	elseif szName == "Btn_Cancel" then
		CloseTongBaoPanelPannel()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Scrollbar

function TongBaoPanel.UpdateScrollInfo(hList)
	hList:FormatAllItemPos()
	
	local _, nItemHeight = hList:GetAllItemSize()
	local _, nHeight = hList:GetSize()
	
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Scroll_TongBao")
	local nCountStep = math.ceil((nItemHeight - nHeight) / 10)
	hScroll:SetStepCount(nCountStep)
	
	if not hList.nScrollPos then
		hList.nScrollPos = 0
	end
	hScroll:SetScrollPos(hList.nScrollPos)
	
	local hBtnUp = hFrame:Lookup("Btn_Up")
	local hBtnDown = hFrame:Lookup("Btn_Down")
	if nCountStep > 0 then
		hBtnUp:Show()
		hBtnDown:Show()
		hScroll:Show()
	else
		hBtnUp:Hide()
		hBtnDown:Hide()
		hScroll:Hide()
	end
end

function TongBaoPanel.OnLButtonHold()
	local szName = this:GetName()
	local hScroll = this:GetRoot():Lookup("Scroll_TongBao")
	if szName == "Btn_Up" then
		hScroll:ScrollPrev(1)
	elseif szName == "Btn_Down" then
		hScroll:ScrollNext(1)
	end
end

function TongBaoPanel.OnLButtonDown()
	TongBaoPanel.OnLButtonHold()
end

function TongBaoPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Scroll_TongBao" then
		local hBtnUp = hFrame:Lookup("Btn_Up")
		local hBtnDown = hFrame:Lookup("Btn_Down")
		hBtnUp:Enable(nCurrentValue ~= 0)
		hBtnUp:Enable(nCurrentValue ~= this:GetStepCount())
		
	    hFrame:Lookup("", "Handle_Message"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	end
end

function TongBaoPanel.OnMouseWheel()
	local szName = this:GetName()
	if szName == "TongBaoPanel" then
		local nDistance = Station.GetMessageWheelDelta()
		local hScroll = this:GetRoot():Lookup("Scroll_TongBao")
		if hScroll:IsVisible() then
			hScroll:ScrollNext(nDistance)
		end
		return true
	else
		return false
	end
end

function OpenTongBaoPanelPannel(bDisableSound)
	Wnd.OpenWindow("TongBaoPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function IsTongBaoPanelPannelOpened()
	local frame = Station.Lookup("Topmost/TongBaoPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseTongBaoPanelPannel(bDisableSound)
	Wnd.CloseWindow("TongBaoPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end
