GetNumberPanel = {}
function GetNumberPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	Station.SetFocusWindow("Topmost/GetNumberPanel/Edit_Number")
end

function GetNumberPanel.OnEvent(event)
	if event == "UI_SCALED" then
		if this.rect then
			this:CorrectPos(this.rect[1], this.rect[2], this.rect[3], this.rect[4], ALW.CENTER)
		else
			this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		end
	end
end

function GetNumberPanel.OnFrameBreathe()
	if GetNumberPanel.fAutoClose and GetNumberPanel.fAutoClose() then
		Wnd.CloseWindow(this:GetName())
	end
end

function GetNumberPanel.OnLButtonClick()
	szSelfName = this:GetName()
	if szSelfName == "Btn_Dec" then
		GetNumberPanel.AddNumber(-1)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szSelfName == "Btn_Add" then
		GetNumberPanel.AddNumber(1)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
    elseif szSelfName == "Btn_Sure" then
    	GetNumberPanel.NotifyListenerGetNumber(this:GetParent():Lookup("Edit_Number"))
    	return
    elseif szSelfName == "Btn_Cancel" then
    	GetNumberPanel.NotifyListenerCancelGetNumber()
    	return
	end
end

function GetNumberPanel.OnEditChanged()
	if this.bSet then
		return
	end
	this.bSet = true
	local szText = this:GetText()
	if not szText or szText == "" then
		this.bSet = false
		return
	end
	local nNumber = tonumber(szText)
	
	if nNumber < 0 then
		nNumber = 0
	end
	if nNumber > GetNumberPanel.nMax then
		nNumber = GetNumberPanel.nMax
	end	
	this:SetText(nNumber)
	this.bSet = false
end

function GetNumberPanel.AddNumber(nAdd)
	local edit = Station.Lookup("Topmost/GetNumberPanel/Edit_Number")
	
	local szText = edit:GetText()
	if szText == "" then
		szText = "0"
	end
	local nNumber = tonumber(szText)
	
	nNumber = nNumber + nAdd
	if nNumber < 0 then
		nNumber = 0
	end
	if nNumber > GetNumberPanel.nMax then
		nNumber = GetNumberPanel.nMax
	end	
	edit:SetText(nNumber)
end

function GetNumberPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		if GetNumberPanel.fActionSure then
			GetNumberPanel.fActionSure(this:Lookup("Edit_Input"):GetText())
		end
		Wnd.CloseWindow("GetNamePanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		return 1
	elseif szKey == "Esc" then
		if GetNumberPanel.fActionCancel then
			GetNumberPanel.fActionCancel(this:Lookup("Edit_Input"):GetText())
		end	
		Wnd.CloseWindow("GetNamePanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		return 1
	elseif szKey == "Left" then
		GetNumberPanel.AddNumber(-1)
		return 1
	elseif szKey == "Right" then
		GetNumberPanel.AddNumber(1)
		return 1
	elseif szKey == "Up" then
		GetNumberPanel.AddNumber(1)
		return 1
	elseif szKey == "Down" then
		GetNumberPanel.AddNumber(-1)
		return 1
	end
	return 0
end

function GetNumberPanel.NotifyListenerGetNumber(edit)
	local szText = edit:GetText()
	if szText == "" then
		szText = "0"
	end
	local nNumber = tonumber(szText)
	
	if GetNumberPanel.fActionSure then
		GetNumberPanel.fActionSure(nNumber)
	end
	
	Wnd.CloseWindow("GetNumberPanel")
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
end

function GetNumberPanel.NotifyListenerCancelGetNumber()
	if GetNumberPanel.fActionCancel then
		GetNumberPanel.fActionCancel()
	end
	Wnd.CloseWindow("GetNumberPanel")
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
end

---------------------插件重新实现方法:--------------------------------
--2, GetNumberPanel = nil
--2, 重载下面函数
----------------------------------------------------------------------

function GetUserInputNumber(nDefault, nMax, rect, fActionSure, fActionCancel, fAutoClose)
	Wnd.OpenWindow("GetNumberPanel")
	local frame = Station.Lookup("Topmost/GetNumberPanel")
	
	GetNumberPanel.nMax = nMax
	if GetNumberPanel.nMax < 0 then
		GetNumberPanel.nMax = 0 
	elseif GetNumberPanel.nMax > 99999 then
		GetNumberPanel.nMax = 99999
	end
	
	local edit = frame:Lookup("Edit_Number")
	if nDefault < 0 then
		nDefault = 0
	end
	edit:SetText(nDefault)
	edit:SelectAll()
	
	GetNumberPanel.fActionSure = fActionSure
	GetNumberPanel.fActionCancel = fActionCancel
	GetNumberPanel.fAutoClose = fAutoClose
	frame.rect = rect
	
	if rect then
		frame:CorrectPos(rect[1], rect[2], rect[3], rect[4], ALW.CENTER)
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
	PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
end

function CloseGetNumberPanel()
	local frame = Station.Lookup("Topmost/GetNumberPanel")
	if frame then
		GetNumberPanel.NotifyListenerCancelGetNumber()
		return true
	end
	return false
end

