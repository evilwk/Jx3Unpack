---------------------------messagebox----------------------------------
--[[eg.

function fDropHandleObj()
	local player = GetClientPlayer()
	local box = Hand_Get()
	local nBox = box:GetObjectType()
	local nIndex = box:GetBoxIndex()
	player.DestroyItem(nBox, nIndex)
	Hand_Clear()
end

local msg = 
{
	x = 10, y = 20,
	szName = "DropItemSure",
	szMessage = g_tStrings.MSG_SURE_DROP_ITEM,
	fnAutoClose = function()  return true  end,
	fnAction = function(nIndex) end,
	fnCancelAction = function() end;
	bVisibleWhenHideUI = true; --在隐藏UI的模式下仍然显示。
	szCloseSound = ""
	{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnDropHandleObj, szSound = ""},
	{szOption = g_tStrings.STR_HOTKEY_CANCEL},
}
MessageBox(msg)
]]

function MessageBox(msg, bDisableSound)
	if not msg.szName then
		Trace("msg name must be seted!\n")
		return
	end
	
	local frame = Station.Lookup("Topmost2/MB_"..msg.szName)
	if not frame then
		frame = Station.Lookup("Topmost/MB_"..msg.szName)
	end
	if not frame then
		frame = Wnd.OpenWindow("MessageBox", "MB_"..msg.szName)
		frame:RegisterEvent("UI_SCALED")
	end
	if msg.bModal then
		frame:ChangeRelation("Topmost2")
	end
	
	frame.bMessageBox = true
	frame:BringToTop()
	
	if msg.bVisibleWhenHideUI then
		frame:ShowWhenUIHide()
	end
	
	frame.bModal = msg.bModal
	frame.fnAutoClose = msg.fnAutoClose
	frame.fnAction = msg.fnAction
	frame.fnCancelAction = msg.fnCancelAction
	frame.szCloseSound = msg.szCloseSound

	local dwStartTime = GetTickCount()
	
	frame.OnFrameBreathe = function()
		if this.fnAutoClose and this.fnAutoClose() then
			Wnd.CloseWindow(this:GetName())
			return 
		end
		
		local hButton = this:Lookup("Wnd_All"):GetFirstChild()
		local nButtonCount = 1
		while hButton do
			if hButton.nCountDownTime then
				local hText = hButton:Lookup("", "Text_Option"..nButtonCount)
				local nSeconds = hButton.nCountDownTime - (GetTickCount() - hButton.dwStartTime) / 1000
				nSeconds = math.floor(nSeconds)
				if nSeconds < 0 then
					nSeconds = 0
				end
				hText:SetText(FormatString(g_tStrings.MSG_BRACKET, hButton.szOption, nSeconds))
			end
			nButtonCount = nButtonCount + 1
			hButton = hButton:GetNext()
		end
	end
	
	frame.OnFrameDestroy = function()
		if not this.bInitiative and this.fnCancelAction then
			this.fnCancelAction()
		end
		if this.szCloseSound then
			PlaySound(SOUND.UI_SOUND, this.szCloseSound)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		end
	end
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			if this.UpdateAnchor then
				this:UpdateAnchor()
			end
		end
	end
	
	frame.UpdateAnchor = function(frame)
		if frame.bModal then
			local wndAll = frame:Lookup("Wnd_All")
			local w, h = wndAll:GetSize()
			local wAll, hAll = Station.GetClientSize()
			frame:SetSize(wAll, hAll)
			frame:SetRelPos(0, 0)
			wndAll:SetRelPos((wAll - w) / 2, (hAll - h) / 2)
		else
			frame:SetPoint(frame.Anchor.s, 0, 0, frame.Anchor.r, frame.Anchor.x, frame.Anchor.y)
			frame:CorrectPos()
		end	
	end
	
	
	local wndAll = frame:Lookup("Wnd_All")
	local handle = wndAll:Lookup("", "")
	
	local handleMsg = handle:Lookup("Handle_Message")
	handleMsg:Clear()

	if msg.bRichText then
		handleMsg:AppendItemFromString(msg.szMessage)
	else
		handleMsg:AppendItemFromString("<text>text="..EncodeComponentsString(msg.szMessage).." font=18 </text>")	--默认字体0
	end

	local nOptionCount = 0
	for i = 1, 5, 1 do
		local v = msg[i]
		if v and v.szOption then
			nOptionCount = nOptionCount + 1
			local btn = wndAll:Lookup("Btn_Option"..nOptionCount)
			btn:Show()
			btn.fnAction = v.fnAction
			btn.nIndex = i
			btn.szSound = v.szSound
			btn.nCountDownTime = v.nCountDownTime
			btn.szOption = v.szOption
			if v.dwStartTime then
				btn.dwStartTime = v.dwStartTime
			else
				btn.dwStartTime = dwStartTime
			end
			
			btn.OnLButtonClick = function()
				local frame = nil
				if this:IsValid() then
					frame = this:GetRoot()
				end
				if this.fnAction then
					this.fnAction()
				elseif frame and  frame.fnAction then
					frame.fnAction(i)
				end
				
				if frame then
					frame.bInitiative = true
				end
				
				if this.szSound then
					if frame and frame:IsValid() then
						frame.szCloseSound = this.szSound	
					else
						PlaySound(SOUND.UI_SOUND, this.szSound)
					end
				end
				if frame and frame:IsValid() then
					Wnd.CloseWindow(frame:GetName())
				end
			end	
			
			local text = btn:Lookup("", "Text_Option"..nOptionCount)
			if v.nFont then
				text:SetFontScheme(v.nFont)
			end
			text:SetText(v.szOption)
		end
	end
	
	for i = nOptionCount + 1, 5, 1 do
		wndAll:Lookup("Btn_Option"..i):Hide()
	end

	local btn = wndAll:Lookup("Btn_Option1")
	local wBtn, hBtn = btn:GetSize()
	local fMinW = wBtn * nOptionCount + 2 * 20 -- 20为两头空出来的距离
	if nOptionCount > 1 then
		fMinW = fMinW + (nOptionCount - 1) * 10	--	10位按钮之间最小的距离
	end
	
	if fMinW > 500 then --500是自动换行的宽
		handleMsg:SetSize(fMinW, 1000)	
	else
		handleMsg:SetSize(500, 1000)
	end
	handleMsg:FormatAllItemPos()
	local w, hOrg = handleMsg:GetAllItemSize()
	h = hOrg + 15 + hBtn + 5
	if w < fMinW then
		w = fMinW
	end
	handleMsg:SetSize(w, h)

	local img = handle:Lookup("Image_Bg")
	img:SetSize(w + 54, h + 40)
	------------计算按钮位置-----------------
	for i = 1, nOptionCount, 1 do
		btn = wndAll:Lookup("Btn_Option"..i)
		local RelX = 28 + ((w - nOptionCount * wBtn) / (nOptionCount + 1)) * i + wBtn * (i - 1)
		local RelY = 28 + hOrg + 15	
		btn:SetRelPos(RelX, RelY)
	end

	handle:SetSize(3600, 3600)
	handle:FormatAllItemPos()

	w, h = handle:GetAllItemSize()
	handle:SetSize(w, h)
	wndAll:SetSize(w, h)
	wndAll:SetRelPos(0, 0)
	frame:SetSize(w, h)
	if not msg.bModal then
		if msg.x and msg.y then
			frame:SetRelPos(msg.x - w / 2,  msg.y - h / 2)
			frame.Anchor = GetFrameAnchor(frame, "TOPCENTER")
		else
			local y = 300
			local yE = y + h
			local a = {}
			local f = Station.Lookup("Topmost"):GetFirstChild()
			while f do
				if f.bMessageBox and f ~= frame then
					local _, yF = f:GetAbsPos()
					local _, hF = f:GetSize()
					table.insert(a, {yF, yF + hF})
				end
				f = f:GetNext()
			end
			table.sort(a, function(v1, v2) return v1[1] < v2[1] end)
			for k, v in pairs(a) do
				if not (y >= v[2] or yE <= v[1]) then
					y = v[2]
					yE = y + h
				end
			end
			frame.Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = y}
		end
	end
	frame:UpdateAnchor()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseLastMessageBox()
	local fLast = nil

	local frame = Station.Lookup("Topmost2"):GetFirstChild()
	while frame do
		if frame.bMessageBox then
			fLast = frame
		end	
		frame = frame:GetNext()
	end
	
	if not fLast then	
		frame = Station.Lookup("Topmost"):GetFirstChild()
		while frame do
			if frame.bMessageBox then
				fLast = frame
			end	
			frame = frame:GetNext()
		end
	end
		
	if fLast then
		Wnd.CloseWindow(fLast:GetName())
		return true
	end
	return false
end

function CloseMessageBox(szName)
	if Station.Lookup("Topmost2/MB_"..szName) then
		Wnd.CloseWindow("MB_"..szName)
		return true
	end
	
	if Station.Lookup("Topmost/MB_"..szName) then
		Wnd.CloseWindow("MB_"..szName)
		return true
	end
	return false
end