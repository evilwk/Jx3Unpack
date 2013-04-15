--szText是已经格式化的信息字符串
--nWidth是最大的显示宽度
--Rect是一个指定窗口位置的矩形区域，tip将要显示在这个矩形区域周围。
function OutputTip(szText, nWidth, Rect, nPosType, bLink, szLink, bAppend, bSub, bAddSub, nClosePos)
	local frame = GetTipFrame(bLink, szLink, bSub, bAddSub)
	local handle = frame:Lookup("", "Handle_Message")
	if not bAppend then
		handle:Clear()
	end
	
	frame.OnFrameBreathe = nil
	frame.bFadeOut = false
	frame:SetAlpha(255)
	
    local nDelta = 24
    if nClosePos == 1 then
        nDelta = 0
    elseif nClosePos == 2 then
        nDelta = 0
        handle:AppendItemFromString(GetFormatText("\n"))
    end
    
	handle:SetSize(nWidth, 10000)
    handle:AppendItemFromString(szText)
	handle:FormatAllItemPos()

	if not nPosType then
		nPosType = ALW.CENTER
	end
    
	AdjustTipPanelSize(frame, bLink, nDelta)
	if bSub then
		if bAddSub then
			local fOrg = GetTipFrame(bLink, szLink, true)
			local x, y = fOrg:GetAbsPos()
			if not Rect or Rect[5] or x < Rect[1] then
				frame.bPosLeft = true
				frame:SetPoint("TOPRIGHT", 0, 0, fOrg, "TOPLEFT", 0, 0)
			else
				frame:SetPoint("TOPLEFT", 0, 0, fOrg, "TOPRIGHT", 0, 0)
			end
		else
			local fOrg = GetTipFrame(bLink, szLink)
			local x, y = fOrg:GetAbsPos()
			if not Rect or Rect[5] or x < Rect[1] then
				frame.bPosLeft = true
				frame:SetPoint("TOPRIGHT", 0, 0, fOrg, "TOPLEFT", 0, 0)
			else
				frame:SetPoint("TOPLEFT", 0, 0, fOrg, "TOPRIGHT", 0, 0)
			end
		end
	elseif Rect then
		if Rect[5] then
			frame:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -52, -90)
			local x, y = frame:GetAbsPos()
			local w, h = frame:GetSize()
			local bX = (x > Rect[1] and x < Rect[1] + Rect[3]) or (x + w > Rect[1] and x + w < Rect[1] + Rect[3]) or (Rect[1] > x and Rect[1] < x + w) or (Rect[1] + Rect[3] > x and Rect[1] + Rect[3] < x + w)
			local bY = (y > Rect[2] and y < Rect[2] + Rect[4]) or (y + h > Rect[2] and y + h < Rect[2] + Rect[4]) or (Rect[2] > y and Rect[2] < y + h) or (Rect[2] + Rect[4] > y and Rect[2] + Rect[4] < y + h)
			if bX and bY then
				local w, h = Station.GetClientSize()
				if not bY and bX then	
					frame:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", Rect[1] - w, -90)
				else
					frame:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -52, Rect[2] - h)
				end
			end
		else
			Rect[3] = math.max(Rect[3], 40)
			Rect[4] = math.max(Rect[4], 40)
			frame:CorrectPos(Rect[1], Rect[2], Rect[3], Rect[4], nPosType)
		end
	else
		frame:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -52, -90)
	end
	frame:Show()
	frame:BringToTop()
end

function HideTip(bFadeOut)
	local frame = Station.Lookup("Topmost1/TipPanel_Normal")
	if not frame then
		return
	end
	if bFadeOut then
		if not frame.bFadeOut then
			frame.bFadeOut = true
			frame.OnFrameBreathe = function()
				if this.bFadeOut then
					local a = this:GetAlpha()
					a = a - 8
					if a < 0 then
						this.bFadeOut = false
					end
					this:SetAlpha(a)
				end
			end
		end
	else
		local handle = frame:Lookup("", "Handle_Message")
		handle:Clear()
		frame:Hide()
	end
	
	local frame = Station.Lookup("Topmost1/TipPanel_Sub")
	if frame then
		local handle = frame:Lookup("", "Handle_Message")
		handle:Clear()
		frame:Hide()	
	end

	local frame = Station.Lookup("Topmost1/TipPanel_AddSub")
	if frame then
		local handle = frame:Lookup("", "Handle_Message")
		handle:Clear()
		frame:Hide()	
	end
end

function AdjustTipPanelSize(frame, bLink, nDelta)
	local handle = frame:Lookup("", "")
	local handleMsg = handle:Lookup("Handle_Message")

	local w, h = handleMsg:GetAllItemSize()

	handleMsg:SetSize(w, h)
	handleMsg:SetItemStartRelPos(0, 0)
	
	
	if bLink then
		w, h = w + 19 + nDelta, h + 19
	else
		w, h = w + 19, h + 19
	end
	
	local image = handle:Lookup("Image_Bg")
	image:SetSize(w, h)	
	
	handle:SetSize(10000, 10000)
	handle:FormatAllItemPos()
	w, h = handle:GetAllItemSize()
	handle:SetSize(w, h)
	
	frame:SetSize(w, h)
	
	if bLink then
		frame:SetMousePenetrable(0)
		local btn = frame:Lookup("Btn_Close")
		btn.OnLButtonClick = function()
			if frame.szSubName then
				Wnd.CloseWindow(frame.szSubName)
			end		
			Wnd.CloseWindow(this:GetRoot():GetName())
		end
		w1, h1 = btn:GetSize()
		local x, y = btn:GetRelPos()
		btn:SetRelPos(w - w1 - 4 , y)
		frame:EnableDrag(1)
		frame:SetDragArea(0, 0, w, h)
	else
		frame:Lookup("Btn_Close"):Hide()
	end
end

function CloseLinkTipPanel()
	local bRet = false
	local frame = Station.Lookup("Topmost"):GetFirstChild()
	while frame do
		local fN = frame:GetNext()
		if frame.bTipLink then
			bRet = true
			Wnd.CloseWindow(frame:GetName())
		end
		frame = fN
	end
	
	if bRet then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	return bRet
end

function GetTipFrame(bLink, szLink, bSub, bAddSub)
	local frame = nil
	if bLink then
		if bSub then
			if bAddSub then
				frame = Wnd.OpenWindow("TipPanel", "TL_ADD_SUB_"..szLink)
				frame.bSub = true
				frame.bAddSub = true
				frame.szOrgName = "TL_"..szLink
				frame.szSubName = "TL_SUB_"..szLink
			else
				frame = Wnd.OpenWindow("TipPanel", "TL_SUB_"..szLink)
				frame.bSub = true
				frame.szOrgName = "TL_"..szLink
				frame.szAddSubName = "TL_ADD_SUB_"..szLink
			end
		else
			frame = Wnd.OpenWindow("TipPanel", "TL_"..szLink)
			frame.szSubName = "TL_SUB_"..szLink
			frame.szAddSubName = "TL_ADD_SUB_"..szLink
		end
		frame:ChangeRelation("Topmost")
		frame:RegisterEvent("UI_SCALED")
		frame.OnEvent = function(event)
			if event == "UI_SCALED" then
				AdjustTipPanelSize(this, this.bTipLink)
				this:CorrectPos()
			end
		end
		frame.OnFrameDragSetPosEnd = function()
			if this.bSub then
				if this.bAddSub then
					local fSub = Station.Lookup("Topmost/"..this.szSubName)
					if fSub then
						if this.bPosLeft then
							fSub:SetPoint("TOPLEFT", 0, 0, this, "TOPRIGHT", 0, 0)
						else
							fSub:SetPoint("TOPRIGHT", 0, 0, this, "TOPLEFT", 0, 0)
						end
					end
					local fOrg = Station.Lookup("Topmost/"..this.szOrgName)
					if fOrg then
						if this.bPosLeft then
							fOrg:SetPoint("TOPLEFT", 0, 0, fSub or this, "TOPRIGHT", 0, 0)
						else
							fOrg:SetPoint("TOPRIGHT", 0, 0, fSub or this, "TOPLEFT", 0, 0)
						end
					end					
				else
					local fOrg = Station.Lookup("Topmost/"..this.szOrgName)
					if fOrg then
						if this.bPosLeft then
							fOrg:SetPoint("TOPLEFT", 0, 0, this, "TOPRIGHT", 0, 0)
						else
							fOrg:SetPoint("TOPRIGHT", 0, 0, this, "TOPLEFT", 0, 0)
						end
					end
				end
			else
				local fSub = Station.Lookup("Topmost/"..this.szSubName)
				if fSub then
					if fSub.bPosLeft then
						fSub:SetPoint("TOPRIGHT", 0, 0, this, "TOPLEFT", 0, 0)
					else
						fSub:SetPoint("TOPLEFT", 0, 0, this, "TOPRIGHT", 0, 0)
					end
				end			
			end
		end
	elseif bSub then
		if bAddSub then
			frame = Station.Lookup("Topmost1/TipPanel_AddSub")
			if not frame then
				frame = Wnd.OpenWindow("TipPanel", "TipPanel_AddSub")
			end
		else
			frame = Station.Lookup("Topmost1/TipPanel_Sub")
			if not frame then
				frame = Wnd.OpenWindow("TipPanel", "TipPanel_Sub")
			end
		end
	else
		frame = Station.Lookup("Topmost1/TipPanel_Normal")
		if not frame then
			frame = Wnd.OpenWindow("TipPanel", "TipPanel_Normal")
		end
	end
	frame.bTipLink = bLink
	return frame
end

function GetTipHandle(bLink, szLink, bSub)
	local frame = GetTipFrame(bLink, szLink, bSub)
	if frame then
		return frame:Lookup("", "Handle_Message")
	end
	return nil
end