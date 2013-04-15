function GetUserPercentage(fnAction, fnCancelAction, fDefaut, szMsg, rect, fnAutoClose)
	local frame = Wnd.OpenWindow("GetPercentagePanel")
	if not frame then
		if fnCancelAction then
			fnCancelAction()
		end
		return
	end
	
	frame.fnAction = fnAction
	frame.fnCancelAction = fnCancelAction
	frame.fnAutoClose = fnAutoClose
	
	local scroll = frame:Lookup("Scroll_P")
	scroll.OnScrollBarPosChanged = function()
		local nCurrentValue = this:GetScrollPos()
		local frame = this:GetRoot()
		if frame then
			frame:Lookup("", "Text_p"):SetText(nCurrentValue.."%")
			if frame.fnAction then
				frame.fnAction(nCurrentValue / 100)
			end
		end
	end
	
	scroll:SetScrollPos(100 * fDefaut)
	if not szMsg then
		szMsg = ""
	end
	frame:Lookup("", "Text_Title"):SetText(szMsg)
	frame:Lookup("", "Text_p"):SetText(scroll:GetScrollPos().."%")
	
	frame.OnFrameKeyDown = function()
		if GetKeyName(Station.GetMessageKey()) == "Esc" then
			if this.fnCancelAction then
				this.fnCancelAction()
			end
			Wnd.CloseWindow(this:GetName())
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
			return 1
		end
		return 0
	end
	
	frame.OnFrameBreathe = function()
		if this.fnAutoClose and this.fnAutoClose() or Station.GetActiveFrame() ~= this then
			if this.fnCancelAction then
				this.fnCancelAction()
			end
			Wnd.CloseWindow(this:GetName())
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		end
	end
	
	local btn = frame:Lookup("Btn_Close")
	btn.OnLButtonClick = function()
		local frame = this:GetRoot()
		if frame.fnCancelAction then
			frame.fnCancelAction()
		end
		Wnd.CloseWindow(frame:GetName())
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
	
	if rect then
		frame:CorrectPos(rect[1], rect[2], rect[3], rect[4], ALW.CENTER)
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
	
	Station.SetActiveFrame(frame)
	PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
end