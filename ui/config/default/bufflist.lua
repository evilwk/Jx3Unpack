BuffList = 
{
	nMax = 16,
	nLine = 1,
	nSize = 40,
	bShowText = true,
	Sort = "left_to_right",
	DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT",  x = 25, y = 120},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT",  x = 25, y = 120},
	AnchorAdjust = {x = 0, y = 20}
}

RegisterCustomData("BuffList.nSize")
RegisterCustomData("BuffList.nLine")
RegisterCustomData("BuffList.bShowText")
RegisterCustomData("BuffList.Sort")
RegisterCustomData("BuffList.Anchor")

function BuffList.OnFrameCreate()
	this:RegisterEvent("BUFF_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("BUFF_SET_LINE")
	this:RegisterEvent("BUFF_SET_SORT")
	this:RegisterEvent("BUFF_SET_SHOW_TEXT")
	this:RegisterEvent("BUFF_SET_SIZE")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("BUFFLIST_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	BuffList.Init(this)
	BuffList.UpdateBuff(this)
	
	BuffList.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.BUFF)
end

function BuffList.OnFrameDrag()
end

function BuffList.OnFrameDragSetPosEnd()
end

function BuffList.OnFrameDragEnd()
	this:CorrectPos()
	BuffList.Anchor = GetFrameAnchor(this)
end

function BuffList.UpdateAnchor(frame)
	if BuffList.Anchor.x ~= BuffList.DefaultAnchor.x or BuffList.Anchor.y ~= BuffList.DefaultAnchor.y then
		BuffList.AnchorAdjust.x = 0
		BuffList.AnchorAdjust.y = 0
	end
	frame:SetPoint(BuffList.Anchor.s, 0, 0, BuffList.Anchor.r, BuffList.Anchor.x + BuffList.AnchorAdjust.x, BuffList.Anchor.y + BuffList.AnchorAdjust.y)
	frame:CorrectPos()
end

function BuffList.OnEvent(event)
	if event == "BUFF_UPDATE" then
		if arg0 ~= GetClientPlayer().dwID then
			return
		end
		if arg7 then
			BuffList.UpdateBuff(this)
			return
		end
		if not arg3 then
			return
		end
		if arg1 then
			BuffList.RemoveBuff(this, arg2)
			return
		end
		BuffList.UpdateSingleBuff(this, {nIndex = arg2, dwID = arg4, nStackNum = arg5, nEndFrame = arg6, nLevel = arg8})
	elseif event == "SYNC_ROLE_DATA_END" then
		BuffList.UpdateBuff(this)
	elseif event == "BUFF_SET_LINE" then
		BuffList.Init(this)
	elseif event == "BUFF_SET_SORT" then
		BuffList.Init(this)
	elseif event == "BUFF_SET_SHOW_TEXT" then
		BuffList.Init(this)
	elseif event == "BUFF_SET_SIZE" then
		BuffList.Init(this)
	elseif event == "UI_SCALED" then
		BuffList.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "BUFFLIST_ANCHOR_CHANGED" then
		BuffList.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		BuffList.Init(this)
		BuffList.UpdateAnchor(this)
	end
end

function BuffList.OnFrameBreathe()
	local handle = this:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	local nLogic = GetLogicFrameCount()
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		if not box:IsVisible() then
			return
		end
		
		if box.Info.bSparking then
			local nLeft = box.Info.nEndFrame - nLogic
			if nLeft < 480 then --30s
				local alpha = box:GetAlpha()
				if box.bAdd then
					alpha = alpha + 20
					if alpha > 255 then
						box.bAdd = false
					end
				else
					alpha = alpha - 20
					if alpha < 0 then
						box.bAdd = true
					end				
				end
				box:SetAlpha(alpha)
			else			
				box:SetAlpha(255)
			end						
		end
		local text = hText:Lookup(i)
		if text.Info.bShowTime then
			local nLeft = text.Info.nEndFrame - nLogic
			if nLeft < 0 then nLeft = 0 end
			local nH, nM, nS = GetTimeToHourMinuteSecond(nLeft, true)
			if nH >= 1 then
				if nM >= 1 or nS >= 1 then
					nH = nH + 1
				end
				text:SetText(nH)
				text:SetFontScheme(162)
			elseif nM >= 1 then
				if nS >= 1 then
					nM = nM + 1
				end
				text:SetText("  "..nM.."¡ä")
				text:SetFontScheme(163)
			else
				text:SetText("  "..nS.."¡å")
				text:SetFontScheme(166)
			end
		else
			text:SetText("")
		end
	end
end

function BuffList.Init(frame)
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	handle:SetSize(10000, 10000)
	hBox:SetSize(10000, 10000)
	hText:SetSize(10000, 10000)
	local nW = math.ceil(BuffList.nMax / BuffList.nLine)
	local nIndex = 0
	for i = 1, BuffList.nLine, 1 do
		local y, yT
		if BuffList.bShowText then
			y = (i - 1) * (BuffList.nSize + 20)
			yT = y + BuffList.nSize
		else
			y = (i - 1) * BuffList.nSize
			yT = y + BuffList.nSize
		end
		for j = 1, nW, 1 do
			if nIndex >= BuffList.nMax then
				break
			end
			local box = hBox:Lookup(nIndex)
			if not box then
				hBox:AppendItemFromString("<box>w=40 h=40 eventid=938 lockshowhide=1 </box>")
				box = hBox:Lookup(nIndex)
			end
			local text = hText:Lookup(nIndex)
			if not text then
				hText:AppendItemFromString("<text>w=40 h=20 halign=1 lockshowhide=1 </text>")
				text = hText:Lookup(nIndex)
			end
			box:SetSize(BuffList.nSize, BuffList.nSize)
			text:SetSize(BuffList.nSize, 20)
			
			if BuffList.Sort == "left_to_right" then
				local x = (j - 1) * BuffList.nSize
				box:SetRelPos(x, y)
				text:SetRelPos(x, yT)
			else
				local x = (nW - j) * BuffList.nSize
				box:SetRelPos(x, y)
				text:SetRelPos(x, yT)
			end
			nIndex = nIndex + 1
		end
	end
	
	hBox:FormatAllItemPos()
	hBox:SetSizeByAllItemSize()
	if BuffList.bShowText then
		hText:FormatAllItemPos()
		hText:SetSizeByAllItemSize()
		hText:Show()
	else
		hText:SetSize(0, 0)
		hText:Hide()
	end
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
	BuffList.UpdateAnchor(frame)
	UpdateCustomModeWindow(frame)
end

function BuffList.UpdateBuff(frame)
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	
	local player = GetClientPlayer()
	local t = nil
	if player then
		t =player.GetBuffList()
	end	
	if not t then
		for i = 0, nCount, 1 do
			local box = hBox:Lookup(i)
			if box:IsVisible() then
				box:Hide()
				hText:Lookup(i):Hide()
			else
				break
			end
		end
		return
	end
	local nIndex = 0
	for k, v in ipairs(t) do
		if v.bCanCancel and Table_BuffIsVisible(v.dwID, v.nLevel) then
			local box = hBox:Lookup(nIndex)
			local text = hText:Lookup(nIndex)
			BuffList.UpdateSingleBuffInfo(box, text, v)
			nIndex = nIndex + 1
		end
	end
	
	for i = nIndex, nCount, 1 do
		local box = hBox:Lookup(i)
		if box:IsVisible() then
			box:Hide()
			hText:Lookup(i):Hide()
		else
			break
		end		
	end
end

function BuffList.RemoveBuff(frame, nIndex)
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	local nBoxIndex = nil
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		if not box:IsVisible() then
			return
		end
		
		if box.Info.nIndex == nIndex then
			nBoxIndex = i
			break
		end
	end
	
	if not nBoxIndex then
		return
	end
	
	for i = nBoxIndex + 1, nCount, 1 do
		local box = hBox:Lookup(i)
		if box:IsVisible() then
			local boxP = hBox:Lookup(i - 1)
			boxP.Info = box.Info
			boxP:SetObject(box:GetObject())
			boxP:SetObjectIcon(box:GetObjectIcon())
			boxP:SetObjectCoolDown(box:IsObjectCoolDown())
			boxP:SetCoolDownPercentage(box:GetCoolDownPercentage())
			boxP:SetOverText(0, box:GetOverText(0))
			boxP:SetAlpha(box:GetAlpha())
			local text = hText:Lookup(i)
			local textP = hText:Lookup(i - 1)
			textP.Info = text.Info
			textP:SetText(text:GetText())
			textP:SetFontScheme(text:GetFontScheme())
		else
			hBox:Lookup(i - 1):Hide()
			hText:Lookup(i - 1):Hide()
			return
		end
	end
	hBox:Lookup(nCount):Hide()
	hText:Lookup(nCount):Hide()
end

function BuffList.UpdateSingleBuffInfo(box, text, v)
	local dwID, nLevel = v.dwID, v.nLevel
	box:Show()
	box:SetAlpha(255)
	box.Info = v
	box.Info.bSparking = Table_BuffNeedSparking(dwID, nLevel)
	box.Info.bShowTime = Table_BuffNeedShowTime(dwID, nLevel)
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwID)
	box:SetObjectIcon(Table_GetBuffIconID(dwID, nLevel))				
	if v.nStackNum > 1 then
		box:SetOverText(0, v.nStackNum)
	else
		box:SetOverText(0, "")
	end
	
	text:Show()
	text.Info = box.Info
end

function BuffList.UpdateSingleBuff(frame, v)
	local dwID, nLevel = v.dwID, v.nLevel
	if not Table_BuffIsVisible(dwID, nLevel) then
		return
	end
	
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		if box:IsVisible() then
			if box.Info.nIndex == v.nIndex then
				local text = hText:Lookup(i)
				BuffList.UpdateSingleBuffInfo(box, text, v)
				return
			end
		else
			local text = hText:Lookup(i)
			BuffList.UpdateSingleBuffInfo(box, text, v)
			return
		end
	end
end

function BuffList.OnItemMouseEnter()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(1)
		local nTime = math.floor(this.Info.nEndFrame - GetLogicFrameCount()) / 16 + 1
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputBuffTip(GetClientPlayer().dwID, this.Info.dwID, this.Info.nLevel, this.Info.nStackNum, false, nTime, {x, y, w, h})					
	end
end

function BuffList.OnItemRefreshTip()
	return BuffList.OnItemMouseEnter()
end

function BuffList.OnItemMouseHover()
	BuffList.OnItemMouseEnter()
end

function BuffList.OnItemRButtonDown()
	this:SetObjectPressed(1)
end

function BuffList.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function BuffList.OnItemRButtonClick()
	GetClientPlayer().CancelBuff(this.Info.nIndex)
end

function BuffList.OnItemRButtonDBClick()
	BuffList.OnItemRButtonClick()
end

function BuffList.OnItemMouseLeave()
	if this:GetType() == "Box" then
		HideTip()
		this:SetObjectMouseOver(0)
	end		
end

function OpenBuffList()
	local frame = Wnd.OpenWindow("BuffList")
	BuffList.Init(frame)
end

function SetBuffListLine(nLine)
	if BuffList.nLine == nLine then
		return
	end
	
	BuffList.nLine = nLine
	FireEvent("BUFF_SET_LINE")
end

function GetBuffListLine()
	return BuffList.nLine
end

function SetBuffListShowText(bShow)
	if BuffList.bShowText == bShow then
		return
	end
	
	BuffList.bShowText = bShow
	
	FireEvent("BUFF_SET_SHOW_TEXT")
end

function IsBuffListShowText()
	return BuffList.bShowText
end

function SetBuffListSortType(szType)
	if BuffList.Sort == szType then
		return
	end
	
	BuffList.Sort = szType
	
	FireEvent("BUFF_SET_SORT")
end

function GetBuffListSortType()
	return BuffList.Sort
end

function SetBuffListAnchor(Anchor)
	BuffList.Anchor = Anchor
	
	FireEvent("BUFFLIST_ANCHOR_CHANGED")
end

function SetBuffListSize(nSize)
	if nSize < 12 then
		nSize = 12
	end
	if nSize > 64 then
		nSize = 64
	end
	
	if BuffList.nSize == nSize then
		return
	end
	
	BuffList.nSize = nSize
	FireEvent("BUFF_SET_SIZE")
end

function GetBuffListSize()
	return BuffList.nSize
end

function GetBuffListAnchor(Anchor)
	return BuffList.Anchor
end

function BuffList_SetAnchorDefault()
	BuffList.Anchor.s = BuffList.DefaultAnchor.s
	BuffList.Anchor.r = BuffList.DefaultAnchor.r
	BuffList.Anchor.x = BuffList.DefaultAnchor.x
	BuffList.Anchor.y = BuffList.DefaultAnchor.y
	FireEvent("BUFFLIST_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", BuffList_SetAnchorDefault)
