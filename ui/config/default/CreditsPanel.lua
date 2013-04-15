CreditsPanel = 
{
	nFinishWaitTime = 5000,
	nStart=1280,
	nTitleSize=40,
	nNameSize=30,
	nSpeed = 4,
	nVersion = 4,
	aSpeed = 
	{
		{4, 1},
		{2, 1},
		{1, 1},
		{1, 2},
		{1, 4},
		{1, 6},
		{1, 8},
		{1, 10},
		{1, 12},
	},	
}

CreditsPanel.tVersion = {}
CreditsPanel.tVersion[1] = {"Btn_Version1", 30000} -- {szButtonName, nTotalLen}
CreditsPanel.tVersion[2] = {"Btn_Version2", 30000}
CreditsPanel.tVersion[3] = {"Btn_Version3", 30000}
CreditsPanel.tVersion[4] = {"Btn_Version4", 30000}

function CreditsPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:Lookup("", "Handle_Credits"):EnableFormatWhenAppend(1)
	CreditsPanel.UpdateSize(this)
	CreditsPanel.nStart = Station.GetClientSize()
	CreditsPanel.UpdateVersionState(this)
end

function CreditsPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		CloseCreditsPanel()
		return 1
	end
end

function CreditsPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCreditsPanel()
	elseif szName == "Btn_Play" then
		CreditsPanel.bPause = false
		CreditsPanel.UpdateBtnState(this:GetParent())
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_Pause" then
		CreditsPanel.bPause = true
		CreditsPanel.UpdateBtnState(this:GetParent())
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_FF" then
		CreditsPanel.bPause = false
		CreditsPanel.nSpeed = CreditsPanel.nSpeed + 1
		if CreditsPanel.nSpeed > #(CreditsPanel.aSpeed) then
			CreditsPanel.nSpeed = #(CreditsPanel.aSpeed)
		end
		CreditsPanel.UpdateBtnState(this:GetParent())
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_REW" then
		CreditsPanel.bPause = false
		CreditsPanel.nSpeed = CreditsPanel.nSpeed - 1
		if CreditsPanel.nSpeed < 1 then
			CreditsPanel.nSpeed = 1
		end
		CreditsPanel.UpdateBtnState(this:GetParent())
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
    else 
        nVersion = CreditsPanel.GetVersion(szName)
        if nVersion > 0 then
            CreditsPanel.bPause = false
            CreditsPanel.nVersion = nVersion
            local frame = this:GetRoot()
            CreditsPanel.Clear(frame)
            CreditsPanel.UpdateVersionState(frame)
            CreditsPanel.UpdateBtnState(frame:Lookup("Wnd_Control"))
            PlaySound(SOUND.UI_SOUND,g_sound.Button)
        end
    end
end

function CreditsPanel.GetVersion(szName)
    local nVersion = -1
    for nIndex, v in ipairs(CreditsPanel.tVersion) do
        if szName == v[1] then
            nVersion = nIndex 
            break
        end
    end
    
    return nVersion
end
function CreditsPanel.Clear(frame)
	frame.nAddIndex = nil
	frame.nX = nil
	frame.bFinish = nil
	local hList = frame:Lookup("", "Handle_Credits")
	hList:Clear()
	hList:SetItemStartRelPos(0, 0)
end

function CreditsPanel.UpdateVersionState(frame)
	local text = frame:Lookup("Wnd_Title", "Text_Title")
    text:SetText(tStrCreditsVersion[CreditsPanel.nVersion])
    local wnd = frame:Lookup("Wnd_Version")
    for nIndex, szVersion in ipairs(tStrCreditsVersion) do
        wnd:Lookup("Btn_Version" .. nIndex, "Text_Version" .. nIndex):SetText(szVersion)
    end
end

function CreditsPanel.UpdateBtnState(wnd)
	if CreditsPanel.nSpeed == #(CreditsPanel.aSpeed) then
		wnd:Lookup("Btn_FF"):Enable(false)
	else
		wnd:Lookup("Btn_FF"):Enable(true)
	end

	if CreditsPanel.nSpeed == 1 then
		wnd:Lookup("Btn_REW"):Enable(false)
	else
		wnd:Lookup("Btn_REW"):Enable(true)
	end
	
	if CreditsPanel.bPause then
		wnd:Lookup("Btn_Play"):Show(true)
		wnd:Lookup("Btn_Pause"):Show(false)
	else
		wnd:Lookup("Btn_Play"):Show(false)
		wnd:Lookup("Btn_Pause"):Show(true)	
	end

end

function CreditsPanel.OnFrameRender()
	local hList = this:Lookup("", "Handle_Credits")
	
	if not this.bFinish then
		local a = tCredits[CreditsPanel.nVersion]
		this.nAddIndex = this.nAddIndex or 1
		for i = 1, 2, 1 do
			local t = a[this.nAddIndex]
			if not t then
				this.bFinish = true
				break
			end
			
			local szAdd = ""
			if t[1] == "title" then
				szAdd = "<text>text="..EncodeComponentsString(t[4]).." font=13 intpos=1 x="..(CreditsPanel.nStart + t[2]).." y="..t[3].."</text>"
			elseif t[1] == "name" then
				szAdd = "<text>text="..EncodeComponentsString(t[4]).." font=13 intpos=1 x="..(CreditsPanel.nStart + t[2]).." y="..t[3].."</text>"
			elseif t[1] == "logo" then
				szAdd = "<image>path="..EncodeComponentsString(t[4]).." frame="..t[5].." intpos=1 x="..(CreditsPanel.nStart + t[2]).." y="..t[3].."</image>"
			end
			hList:AppendItemFromString(szAdd)
			
			this.nAddIndex = this.nAddIndex + 1
		end
	end
	
	--this:Lookup("Wnd_Title", "Text_Title"):SetText("FPS:"..GetFPS())
	
	if CreditsPanel.bPause then
		return
	end
	
	if this.bExit then
		if GetTickCount() - this.dwLast > CreditsPanel.nFinishWaitTime then
			CloseCreditsPanel()
			return
		end
		return
	end
	
	this.nCount = this.nCount or 0
	this.nCount = this.nCount + 1
	if this.nCount >= CreditsPanel.aSpeed[CreditsPanel.nSpeed][1] then
		this.nCount = 0
		this.nX = this.nX or 1
		this.nX = this.nX - CreditsPanel.aSpeed[CreditsPanel.nSpeed][2]
		hList:SetItemStartRelPos(this.nX, 0)		
	end
	
    local nVersion = CreditsPanel.nVersion
    if -this.nX > CreditsPanel.tVersion[nVersion][2] then
        this.bExit = true
    end
	
	if this.dwLast then
		while GetTickCount() < this.dwLast + 15 do
			local i = 0;
			i = i + 1;
		end
	end
	this.dwLast = GetTickCount()
end

function CreditsPanel.OnEvent(event)
	if event == "UI_SCALED" then
		CreditsPanel.UpdateSize(this)
	end
end

function CreditsPanel.UpdateSize(frame)
	local wC, hC = Station.GetClientSize()
	frame:SetSize(wC, hC)
	
	local w, h = wC, 400
	local x, y = 0, (hC - h) / 2
	
	local handle = frame:Lookup("", "")
	handle:SetSize(w, h)
	handle:SetRelPos(x, y)
	handle:SetAbsPos(x, y)
	
	local img = handle:Lookup("Image_Bg")
	img:SetSize(w, h)
	local hList = handle:Lookup("Handle_Credits")
	hList:SetSize(w, h - 40)
	hList:SetRelPos(0, 20)
	hList:FormatAllItemPos()
	handle:FormatAllItemPos()
	
	local wnd = frame:Lookup("Wnd_Title")
	local wB, hB = wnd:GetSize()
	local xB, yB = (wC - wB) / 2, y - 100
	if yB < 0 then
		yB = 0
	end
	wnd:SetAbsPos(xB, yB)
	
	local wnd = frame:Lookup("Wnd_Control")
	local wB, hB = wnd:GetSize()
	local xB, yB = (wC - wB) / 2, hC - y + 70
	if yB + hB > hC then
		yB = hC - hB
	end
	wnd:SetAbsPos(xB, yB)

	local wnd = frame:Lookup("Wnd_Version")
	local wB, hB = wnd:GetSize()
	local xB, yB = wC - wB - 100, hC - hB - 40
	wnd:SetAbsPos(xB, yB)
end

function OpenCreditsPanel(bDisableSound)
	if IsCreditsPanelOpened() then
		return
	end
	
	CreditsPanel.bPause = false
	CreditsPanel.nSpeed = 4
	CreditsPanel.nVersion = 4
	
	local szBgMusic = Table_GetPath("LOGIN_BGM")
	PlayBgMusic(szBgMusic)
	
	if not Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = true
		LoginSingleRole.PauseCameraAnimation(true)
	end

	CreditsPanel.OldFont = {}
	local aFont = {}
	aFont.szName, aFont.szFile, aFont.nSize, aFont.aStyle = Font.GetFont(6)
	table.insert(CreditsPanel.OldFont, aFont)
	aFont = {}
	aFont.szName, aFont.szFile, aFont.nSize, aFont.aStyle = Font.GetFont(2)
	table.insert(CreditsPanel.OldFont, aFont)
	Font.SetFont(2, aFont.szName, aFont.szFile, CreditsPanel.nNameSize, aFont.aStyle)
	Font.SetFont(6, aFont.szName, aFont.szFile, CreditsPanel.nTitleSize, aFont.aStyle)
	
	local frame = Station.OpenWindow("CreditsPanel")
	Station.SetFocusWindow(frame)
	Station.Hide()
	
	Login.ShowSdoaWindows(false)
		
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsCreditsPanelOpened()
	local frame = Station.Lookup("Topmost1/CreditsPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseCreditsPanel(bDisableSound)
	if not IsCreditsPanelOpened() then
		return
	end


	local szBgMusic = Table_GetPath("LOGIN_BGM")
	PlayBgMusic(szBgMusic)
	
	if CreditsPanel.OldFont then
		for k, aFont in pairs(CreditsPanel.OldFont) do
			Font.SetFont(2, aFont.szName, aFont.szFile, aFont.nSize, aFont.aStyle)
			Font.SetFont(6, aFont.szName, aFont.szFile, aFont.nSize, aFont.aStyle)			
		end
		CreditsPanel.OldFont = nil
	end
		
	Station.CloseWindow("CreditsPanel")
	
	if Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = false
		LoginSingleRole.PauseCameraAnimation()
	end	
	
	Station.Show()
	Login.ShowSdoaWindows(true)
	
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
	
end


