
GetNamePanel = {}
function GetNamePanel.OnFrameCreate()
	Station.SetFocusWindow("Topmost/GetNamePanel/Edit_Input")
end

function GetNamePanel.OnFrameBreathe()
	if this.fAutoClose and this.fAutoClose() then
		if this.fActionCancel then
			this.fActionCancel(this:Lookup("Edit_Input"):GetText())
		end		
		Wnd.CloseWindow(this:GetName())
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function GetNamePanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		if this.fActionSure then
			local frame = this:GetRoot() 
			local edit = frame:Lookup("Edit_Input")
			local szName = edit:GetText()
			if frame.bDisableES and szName:find("[%w%p_]") then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ARENA_ONLY_CHINESE)
				return
			end
			this.fActionSure(edit:GetText())
		end
		Wnd.CloseWindow("GetNamePanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		return 1
	elseif szKey == "Esc" then
		if this.fActionCancel then
			this.fActionCancel(this:Lookup("Edit_Input"):GetText())
		end	
		Wnd.CloseWindow("GetNamePanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		return 1
	end
	return 0
end

function GetNamePanel.OnLButtonClick()
	if this:GetName() == "Btn_Sure" then
		local fAction = this:GetRoot().fActionSure
		if fAction then
			local frame = this:GetRoot() 
			local edit = frame:Lookup("Edit_Input")
			local szName = edit:GetText()
			if frame.bDisableES and szName:find("[%w%p_]") then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ARENA_ONLY_CHINESE)
				return
			end
			fAction(this:GetRoot():Lookup("Edit_Input"):GetText())
		end
		Wnd.CloseWindow("GetNamePanel")	
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	elseif this:GetName() == "Btn_Cancel" then
		local fAction = this:GetRoot().fActionCancel
		if fAction then
			fAction(this:GetRoot():Lookup("Edit_Input"):GetText())
		end
		Wnd.CloseWindow("GetNamePanel")	
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

---------------------插件重新实现方法:--------------------------------
--2, GetNamePanel = nil
--2, 重载下面函数
----------------------------------------------------------------------

function GetUserInput(szMsg, fActionSure, fActionCancel, fAutoClose, rect, szDefault, nLimit, bNum, bRich, bDisableES)
	Wnd.OpenWindow("GetNamePanel")
	local frame = Station.Lookup("Topmost/GetNamePanel")
	frame.fActionSure = fActionSure
	frame.fActionCancel = fActionCancel
	frame.fAutoClose = fAutoClose
	frame.bDisableES = bDisableES
	
	local hMsg = frame:Lookup("", "Handle_Msg")
	local text = frame:Lookup("", "Text_Msg")
	if bRich then
		hMsg:Show()
		hMsg:Clear()
		hMsg:AppendItemFromString(szMsg)
		hMsg:FormatAllItemPos()
		text:Hide()
	else
		hMsg:Hide()
		text:SetText(szMsg)
		text:Show()
	end
	
	local edit = frame:Lookup("Edit_Input")
	if bNum then
		edit:SetType(0)
	else
		edit:SetType(2)
	end
	if not nLimit then
		nLimit = -1
	end
	edit:SetLimit(nLimit)
	if szDefault then
		edit:SetText(szDefault)
		edit:SelectAll()
	end
	
	if rect then
		frame:CorrectPos(rect[1], rect[2], rect[3], rect[4], ALW.CENTER)
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
	PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
end

function CloseGetNamePanel()
	local frame = Station.Lookup("Topmost/GetNamePanel")
	if frame then
		local fAction = frame.fActionCancel
		if fAction then
			fAction(frame:Lookup("Edit_Input"):GetText())
		end
		Wnd.CloseWindow("GetNamePanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		return true
	end
	return false
end

