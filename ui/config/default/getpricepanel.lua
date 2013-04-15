GetPricePanel = {}

function GetPricePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
end

function GetPricePanel.OnFrameBreathe()
	if this.fnAutoClose and this.fnAutoClose() then
		if frame.fnCancel then
			frame.fnCancel()
		end
		Wnd.CloseWindow("GetPricePanel")
	end
end

function GetPricePanel.OnEvent(event)
	if event == "UI_SCALED" then
		if this.rect then
			this:CorrectPos(this.rect[1], this.rect[2], this.rect[3], this.rect[4], ALW.CENTER)
		else
			this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		end
	end
end

function GetPricePanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		local thisSave = this
		this = this:Lookup("Btn_Sure")
		GetPricePanel.OnLButtonClick()
		this = thisSave
		return 1
	elseif szKey == "Esc" then
		local thisSave = this
		this = this:Lookup("Btn_Cancel")
		GetPricePanel.OnLButtonClick()
		this = thisSave
		return 1
	elseif szKey == "Tab" then
		local focus = Station.GetFocusWindow()
		if not focus then		
			this:Lookup("Edit_Copper"):SelectAll()
			Station.SetFocusWindow(this:Lookup("Edit_Copper"))
		elseif focus:GetName() == "Edit_Copper" then
			this:Lookup("Edit_Gold"):SelectAll()
			Station.SetFocusWindow(this:Lookup("Edit_Gold"))
		elseif focus:GetName() == "Edit_Gold" then
			this:Lookup("Edit_Silver"):SelectAll()
			Station.SetFocusWindow(this:Lookup("Edit_Silver"))
		elseif focus:GetName() == "Edit_Silver" then
			this:Lookup("Edit_Copper"):SelectAll()
			Station.SetFocusWindow(this:Lookup("Edit_Copper"))
		else
			this:Lookup("Edit_Copper"):SelectAll()
			Station.SetFocusWindow(this:Lookup("Edit_Copper"))		
		end
		return 1
	end
	return 0
end

function GetPricePanel.OnLButtonClick()
	local szName = this:GetName()
	local frame = this:GetRoot()
	if szName == "Btn_Sure" then
		local szGlod = frame:Lookup("Edit_Gold"):GetText()
		local szSilver = frame:Lookup("Edit_Silver"):GetText()
		local szCopper = frame:Lookup("Edit_Copper"):GetText()
		local nGold, nSilver, nCopper = 0, 0, 0
		if szGlod ~= "" then
			nGold = tonumber(szGlod)
		end
		if szSilver ~= "" then
			nSilver = tonumber(szSilver)
		end
		if szCopper ~= "" then
			nCopper = tonumber(szCopper)
		end
		
		local nMoney = GoldSilverAndCopperToMoney(nGold, nSilver, nCopper)
		if frame.fnAction then
			frame.fnAction(nMoney)
		end
		Wnd.CloseWindow("GetPricePanel")
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	elseif szName == "Btn_Cancel" then
		if frame.fnCancel then
			frame.fnCancel()
		end
		Wnd.CloseWindow("GetPricePanel")
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function GetUserSetPrice(szMsg, nDefault, fnAction, fnCancel, fnAutoClose, rect)
	local frame = Station.Lookup("Topmost/GetPricePanel")
	if frame and frame:IsVisible() then
		if frame.fnCancel then
			frame.fnCancel()
		end
		Wnd.CloseWindow("GetPricePanel")
	end

	frame = Wnd.OpenWindow("GetPricePanel")
	frame.fnAction = fnAction
	frame.fnCancel = fnCancel
	frame.fnAutoClose = fnAutoClose
	frame.rect = rect

	frame:Lookup("", "Text_Msg"):SetText(szMsg)

	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nDefault)
	frame:Lookup("Edit_Gold"):SetText(nGold)
	frame:Lookup("Edit_Silver"):SetText(nSilver)
	frame:Lookup("Edit_Copper"):SetText(nCopper)
	frame:Lookup("Edit_Copper"):SelectAll()
	Station.SetFocusWindow(frame:Lookup("Edit_Copper"))
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	
	if rect then
		frame:CorrectPos(rect[1], rect[2], rect[3], rect[4], ALW.CENTER)
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function CloseGetPricePanel()
	local frame = Station.Lookup("Topmost/GetPricePanel")
	if frame and frame:IsVisible() then
		if frame.fnCancel then
			frame.fnCancel()
		end
		Wnd.CloseWindow("GetPricePanel")
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
		return true	
	end
	return false
end