LoadingPanel = {}

function LoadingPanel.OnFrameCreate()
	this:RegisterEvent("LOGIN_NOTIFY")
	this:RegisterEvent("UPDATE_REGION_INFO")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("SCENE_BEGIN_LOAD")
	this:RegisterEvent("SCENE_END_LOAD")
	this:RegisterEvent("SWITCH_GS_NOTIFY")
	this:RegisterEvent("SYNC_ROLE_DATA_BEGIN")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("WM_CLOSE")
	this:RegisterEvent("DISCONNECT")
	this:RegisterEvent("KICK_ACCOUNT")
	this:RegisterEvent("PLAYER_EXIT_GAME")
	this:RegisterEvent("WM_QUIT")
	this:RegisterEvent("LOGIN_GAME")
	this:RegisterEvent("APPLY_UI_SETTING")
	this:RegisterEvent("APPLY_VIDEO_SETTING")
	this:RegisterEvent("CONNECT_GAME_SERVER_FAILED")
	this:RegisterEvent("PLAYER_ENTER_GAME")
	this:RegisterEvent("CHAT_PANEL_INIT")
	this:RegisterEvent("IE_NEW_WINDOW")
	this:RegisterEvent("SNDA_FULL_INFO_NOTIFY")
	
	LoadingPanel.OnEvent("UI_SCALED")
	
	local hKoreaIcon = this:Lookup("", "Handle_KoreaIcon")
	local _, _, szVersionLineName = GetVersion()
	if szVersionLineName == "zhkr" then
		hKoreaIcon:Show()
	else
		hKoreaIcon:Hide()
	end
end

--function LoadingPanel.OnFrameRender()
function LoadingPanel.OnFrameBreathe()
	if LoadingPanel.bReloading then
		LoadingPanel.ReloadUI(this)
		return
	end
	
	if not this.bLoading then
		return
	end
	
	local logicScene = GetClientScene()
	if not logicScene then
		return
	end
	
	local loadingScene = KG3DEngine.GetScene(logicScene.dwID)
	if not loadingScene then
		return
	end
	local fP = loadingScene:GetLoadingProcess()
	if this.bLogin then
		if fP >= 1.0 then
			local bEnd, fPUI = LoadingPanel.LoadUI()
			if bEnd and this.bLogicFinish then
				LoadingPanel.EndLoading(this)
			else
				LoadingPanel.SetPercentage(this, 0.5 + fPUI * 0.5, true)
			end
		else
			LoadingPanel.SetPercentage(this, 0.1 + fP * 0.4, true)
		end
	else
		if fP >= 1.0 then
			if this.bLoadingComplete then
				--空转几秒
				if this.nIdling < 96 then
					LoadingPanel.SetPercentage(this, 0.8 + this.nIdling / 64, true)
					this.nIdling = this.nIdling + 1
				elseif this.bLogicFinish then
					LoadingPanel.EndLoading(this)
				end
			else
				LoadingComplete()
				this.bLoadingComplete = true
				this.nIdling = 0
			end
		else
			LoadingPanel.SetPercentage(this, 0.1 + fP * 0.7, true)
		end
	end
end

function LoadingPanel.EndLoading(frame)
	Station.ClearIdleTime()
	frame.bLoading = nil
	frame:Lookup("", "Image_Progress"):SetPercentage(1.0)
	frame:Hide()
	LoadingPanel.bInLoading = false
	frame.bLoadingComplete = false
	
	if not LoadingPanel.bReloading then
		ConfirmClientReady()
	end
	
	FireEvent("LOADING_END")
end

function LoadingPanel.BeginLoading(frame, szFile)
	FireEvent("LOADING_BEGIN")
	Station.ClearIdleTime()
	if not UIShell.IsAreadyInGame() then
		frame.bLogin = true
		frame.bLogicFinish = false
		Login.EnterGame()
	else
		frame.bLogin = false
	end
	
	LoadingPanel.bInLoading = true
	
	StopBgMusic()
	frame:Show()
	frame:BringToTop()
	frame.dwID = arg0
	frame.bLoading = true
	frame.bLoadingComplete = false
	local bDefault = true
	if g_FirstLogin and not LoadingPanel.bHasLogin then
		LoadingPanel.GetLoadingBg(frame, "\\ui\\Image\\FirstLoginBg.tga", 1024, 640)
		bDefault = false
	else
		local iniR = Ini.Open(szFile.."minimap\\config.ini")
		if iniR then
			local szImage = iniR:ReadString("loading", "image", "")
			local w = iniR:ReadFloat("loading", "width", 1024)
			local h = iniR:ReadFloat("loading", "height", 640)
			if szImage and szImage ~= "" and w ~= 0 and h ~= 0 then
				LoadingPanel.GetLoadingBg(frame, szFile.."minimap\\"..szImage, w, h)
				bDefault = false
			end
			iniR:Close()
		end
	end
	if bDefault then
		LoadingPanel.GetLoadingBg(frame, "\\ui\\Image\\bg.tga", 1024, 640)
	end
	
	local szMsg, bRich = "", false
	local szTipFile = szFile.."minimap\\loadingtip.tab"
	if IsFileExist(szTipFile) then
		local tTip = KG_Table.Load(szTipFile, {{f="S", t="szTip"}}, FILE_OPEN_MODE.NORMAL)
		if tTip then
			local nCount = tTip:GetRowCount()
			local tRow = tTip:GetRow(math.random(1, nCount))
			if tRow then
				szMsg, bRich = tRow.szTip, true
			end
			tTip = nil
		end
	end
	
	if not szMsg or szMsg == "" then
		szMsg = Helper.GetLoadingMsg(not LoadingPanel.bHasLogin)
		bRich = false
	end
	szMsg = szMsg or ""
	if bRich then
		frame:Lookup("", "Text_Msg"):SetText("")
		local hMsg = frame:Lookup("", "Handle_Msg")
		hMsg:Clear()
		hMsg:AppendItemFromString(szMsg)
		hMsg:FormatAllItemPos()
	else
		frame:Lookup("", "Handle_Msg"):Clear()
		frame:Lookup("", "Text_Msg"):SetText(szMsg)
	end
	
	local szStory, bRich = "", false
	if not g_FirstLogin or LoadingPanel.bHasLogin then
		local szStoryFile = szFile.."minimap\\loadingstory.tab"
		if IsFileExist(szStoryFile) then
			local tStory = KG_Table.Load(szStoryFile, {{f="S", t="szStory"}}, FILE_OPEN_MODE.NORMAL)
			if tStory then
				local nCount = tStory:GetRowCount()
				local tRow = tStory:GetRow(math.random(1, nCount))
				if tRow then
					szStory, bRich = tRow.szStory, true
				end
				tStory = nil
			end
		end

		if not szStory or szStory == "" then
			szStory = Helper.GetLoadingStory()
			bRich = false
		end
	end
	
	szMsg = szMsg or ""
	if bRich then
		frame:Lookup("", "Text_Tip"):SetText("")
		local hMsg = frame:Lookup("", "Handle_Tip")
		hMsg:Clear()
		hMsg:AppendItemFromString(szStory)
		hMsg:FormatAllItemPos()		
	else
		frame:Lookup("", "Handle_Tip"):Clear()
		frame:Lookup("", "Text_Tip"):SetText(szStory)
	end

	LoadingPanel.bHasLogin = true
	
	LoadingPanel.SetPercentage(frame, 0)
	
	Station.SetFocusWindow(frame)
	
	LoadingPanel.SetPercentage(this, 0.025)
	Station.Paint()
end

function LoadingPanel.CorrectShow(img)
	if img.szFile and img.w and img.h then
		local w, h = this:GetSize()
		
		local fScale = w / img.w
		if fScale < h / img.h then
			fScale = h / img.h
		end
		local wS, hS = img.w * fScale, img.h * fScale
		local xL, yL = (wS - w) / (2 * wS), (hS - h) / (2 * hS)	
		img:FromTextureFile(img.szFile)			
	end	
end

function LoadingPanel.GetLoadingBg(frame, szFile, w, h)
	local img = frame:Lookup("", "Image_Bg")
	if img.szFile and img.szFile == szFile then
		return
	end
	
	img.szFile = szFile
	img.w = w
	img.h = h
	
	LoadingPanel.CorrectShow(img)
end

function LoadingPanel.SetPercentage(frame, fP, bNotPaint)
	frame:Lookup("", "Image_Progress"):SetPercentage(fP)
	if not bNotPaint then
		Station.Paint()
	end
end

function LoadingPanel.OnEvent(event)
	if event == "LOGIN_NOTIFY" then
		Login.HandleResult(arg0, arg1)
	elseif event == "SNDA_FULL_INFO_NOTIFY" then -- 盛大版防沉迷补填
		Login.SndaBindCard(arg0)
	elseif event == "SWITCH_GS_NOTIFY" then
		this.bLogicFinish = false
	elseif event == "SYNC_ROLE_DATA_BEGIN" then --登陆调用, 跟新服务器调用
		LoadingPanel.SetPercentage(this, 0.1)
		Station.Paint()
	elseif event == "SYNC_ROLE_DATA_END" then
		this.bLogicFinish = true
	elseif event == "UPDATE_REGION_INFO" then
	elseif event == "SCENE_BEGIN_LOAD" then --切换场景和登陆都要调用
		LoadingPanel.szFile = arg1
		LoadingPanel.BeginLoading(this, arg1)
	elseif event == "SCENE_END_LOAD" then
		LoadingPanel.SetPercentage(this, 0.05)
		Station.Paint()
	elseif event == "UI_SCALED" then
		local fS = Station.GetMaxUIScale() / Station.GetUIScale()
		local w, h = Station.GetClientSize()
		this:SetSize(w, h)
		local handle = this:Lookup("", "")
		if handle.fS then
			handle:Scale(fS / handle.fS, fS / handle.fS)
		else
			handle:Scale(fS, fS)
		end
		handle.fS = fS
		handle:SetSize(w, h)
		
		local img = handle:Lookup("Image_Bg")
		img:SetSize(w, h)
		LoadingPanel.CorrectShow(img)
		
		local imgL = handle:Lookup("Image_Left")
		local wL, hL = imgL:GetSize()
		local imgC = handle:Lookup("Image_Center")
		local wC, hC = imgC:GetSize()
		local imgR = handle:Lookup("Image_Right")
		local wR, hR = imgR:GetSize()
		local imgP = handle:Lookup("Image_Progress")
		local wP, hP = imgP:GetSize()
		
		imgL:SetRelPos(w * 0.1, h * 0.894)
		imgC:SetRelPos(w * 0.1 + wL, h * 0.894)
		imgC:SetSize(w * 0.8 - wL - wR, hC)
		imgR:SetRelPos(w * 0.9 - wR, h * 0.90)
		
		imgP:SetRelPos(w * 0.108 + wL * 0.31, h * 0.895 + (hC - hP) / 2)
		imgP:SetSize(w * 0.79 - wL - wR + wL * 1.28, hP)
		
		local tM = handle:Lookup("Text_Msg")
		tM:SetRelPos(w * 0.1, h * 0.8 + 70)
		tM:SetSize(w * 0.8, 25)
		
		local hM = handle:Lookup("Handle_Msg")
		hM:SetRelPos(w * 0.2, h * 0.8 + 70)
		hM:SetSize(w * 0.6, 60)

		local tS = handle:Lookup("Text_Tip")
		local wS, hS = tS:GetSize()
		tS:SetRelPos(w - wS - 100, 115)

		local hT = handle:Lookup("Handle_Tip")
		local wS, hS = hT:GetSize()
		hT:SetRelPos(w - wS - 100, 115)
		
		handle:FormatAllItemPos()
	elseif event == "WM_CLOSE" then
		if IsDropLinePanelOpened and IsDropLinePanelOpened() then
			ExitGame()
		else
			OpenExitPanel("loginclose")
		end
	elseif event == "DISCONNECT" then
		OpenDropLinePanel()
	elseif event == "KICK_ACCOUNT" then
		ReInitUI(LOAD_LOGIN_REASON.KICK_OUT_BY_OTHERS)
	elseif event == "CONNECT_GAME_SERVER_FAILED" then
		Login.EndWait()
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg =
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = g_tGlue.tLoginString.CONNECT_GAME_SERVER_FAILED,
			szName = "ConnectGameServerFailed",
			{
				szOption = g_tStrings.STR_HOTKEY_SURE,
				fnAction = function()
					ReInitUI(LOAD_LOGIN_REASON.RETURN_GAME_LOGIN)
				end
			},
		}
		MessageBox(tMsg)
	elseif event == "CHAT_PANEL_INIT" then
		local szMessage = LoginRoleList.m_tLastLoginInfo.szEndTime.."\n"..
		g_tGlue.STR_LAST_LOGIN_TIME..LoginRoleList.m_tLastLoginInfo.szTime.."\n"..
		g_tGlue.STR_LAST_LOGIN_IP..LoginRoleList.m_tLastLoginInfo.szIP.."\n"
		
		if LoginRoleList.m_tLastLoginInfo.szCity ~= g_tGlue.LOGIN_INFO_CANNOT_GET then
		    szMessage = szMessage..g_tGlue.STR_LAST_LOGIN_CITY..LoginRoleList.m_tLastLoginInfo.szCity.."\n"
		end
		
		szMessage = szMessage..g_tGlue.STR_CURRENT_LOGIN_TIME..LoginRoleList.m_tCurrentLoginInfo.szTime .."\n"
		
		if LoginRoleList.m_tCurrentLoginInfo.szIP ~= g_tGlue.LOGIN_INFO_CANNOT_GET then
		    szMessage = szMessage..g_tGlue.STR_CURRENT_LOGIN_IP..LoginRoleList.m_tCurrentLoginInfo.szIP.."\n"
		end
		
		if LoginRoleList.m_tCurrentLoginInfo.szCity ~= g_tGlue.LOGIN_INFO_CANNOT_GET then
		    szMessage = szMessage..g_tGlue.STR_CURRENT_LOGIN_CITY..LoginRoleList.m_tCurrentLoginInfo.szCity.."\n"
		end
		
		OutputMessage("MSG_SYS", szMessage)
	elseif event == "PLAYER_EXIT_GAME" or event == "WM_QUIT" then
		local a = LoadingPanel.aSaveSetting or {}
		for i, f in pairs(a) do
			f()
		end
		LogoutGame()
	elseif event == "APPLY_UI_SETTING" or event == "APPLY_VIDEO_SETTING" then
		local a = LoadingPanel.aSaveSetting or {}
		for i, f in pairs(a) do
			f()
		end
	elseif event == "IE_NEW_WINDOW" then
		arg0 = OpenInternetExplorer()
	end
end

function LoadingPanel.LoadUI()

	if not LoadingPanel.nUIStep then
		UIShell.CloseAllLoginWindow()
		LoadingPanel.nUIStep = 1
		return false, 0.125
	end
	
	if LoadingPanel.nUIStep == 1 then
		LoadDefaultScriptLib()
		UI_PreLoadImage();
		
		LoadingPanel.nUIStep = 2
		return false, 0.25		
	end
		
	if LoadingPanel.nUIStep == 2 then
		Wnd.LoadFrameList("\\UI\\Config\\framelist.ini")
		
		LoadingPanel.nUIStep = 3
		return false, 0.3
	end
	
	if LoadingPanel.nUIStep == 3 then
		UIShell.m_bLoadMainUI = true
		LoadLoginRoleAddon()
		
		LoadingPanel.nUIStep = 4
		return false, 0.6	
	end
	
	--加载用户设置
	if LoadingPanel.nUIStep == 4 then
		if not LoadingPanel.nLoadSettingStep then
			LoadingPanel.nLoadSettingStep = 1
		else
			LoadingPanel.nLoadSettingStep = LoadingPanel.nLoadSettingStep + 1
		end
		local f = LoadingPanel.aLoadSetting[LoadingPanel.nLoadSettingStep]
		if f then
			f()
			return false, 0.6 + (0.70 - 0.6) * LoadingPanel.nLoadSettingStep / (#LoadingPanel.aLoadSetting)
		else
			FireEvent("PLAYER_ENTER_GAME")
			LoadingPanel.nUIStep = 5
			return false, 0.70
		end
	end
	
	if LoadingPanel.nUIStep == 5 then
		if LoadingPanel.bReloading then
			local player = GetClientPlayer()
			FireUIEvent("PLAYER_ENTER_SCENE", player.dwID)
			FireEvent("SYNC_ROLE_DATA_END")
		else
			LoadingComplete()
		end
		
		LoadingPanel.nUIStep = 6
		return false, 0.72
	end

	if LoadingPanel.nUIStep < 64 then
		LoadingPanel.nUIStep = LoadingPanel.nUIStep + 1
		return false, 0.72 + 0.2 * (LoadingPanel.nUIStep - 7) / (64 - 7)
	end
	
	if LoadingPanel.nUIStep == 64 then
		FireEvent("LOGIN_GAME")
		LoadingPanel.nUIStep = 65
		return false, 0.95
	end
	
	if LoadingPanel.nUIStep < 70 then
		LoadingPanel.nUIStep = LoadingPanel.nUIStep + 1
		return false, 0.95 + 0.05 * (LoadingPanel.nUIStep - 65) / (70 - 65)
	end
	
	if LoadingPanel.nUIStep == 70 then
		LoadUIScaleSetting()
		LoadingPanel.nUIStep = 71
		return true, 1.0
	end
	
	return true, 1.0
end


function IsInLoading()
	return LoadingPanel.bInLoading
end

function AddLoadSettingFunction(f)
	if not LoadingPanel.aLoadSetting then
		LoadingPanel.aLoadSetting = {}
	end
	table.insert(LoadingPanel.aLoadSetting, f)
end

function AddSaveSettingFunction(f)
	if not LoadingPanel.aSaveSetting then
		LoadingPanel.aSaveSetting = {}
	end
	table.insert(LoadingPanel.aSaveSetting, f)
end

function SaveClientSetting()
	local szIniFile = "config.ini"
	iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end
	
	if iniS then
		local settings = GetVideoSettings()
		local x, y = Station.GetWindowPosition()

		iniS:WriteInteger("Main", "CanvasWidth", settings.Width)
		iniS:WriteInteger("Main", "CanvasHeight", settings.Height)
		iniS:WriteInteger("Main", "FullScreen", settings.FullScreen)
		iniS:WriteInteger("Main", "Panauision", settings.Panauision)
		iniS:WriteInteger("Main", "ExclusiveMode", settings.ExclusiveMode)
		iniS:WriteInteger("Main", "Maximize", settings.Maximize)
		iniS:WriteInteger("Main", "RefreshRate", settings.RefreshRate)
		iniS:WriteInteger("Main", "X", x)
		iniS:WriteInteger("Main", "Y", y)
	
		iniS:Save(szIniFile)
		iniS:Close()
	end
end
AddSaveSettingFunction(SaveClientSetting)



local function ReloadLoginFile()
	local tFilter = 
    {
        ["\\ui\\script\\table.lua"] = true,
        ["\\ui\\script\\enum_ui.lua"] = true,
        ["\\ui\\script\\enum_gameworld.lua"] = true,
       	["\\ui\\script\\base.lua"] = true,
		["\\ui\\script\\followmodule.lua"] = true,
		["\\ui\\script\\scroll.lua"] = true,
        ["\\ui\\script\\common.lua"] = true,
        ["\\ui\\script\\tip.lua"] = true,
        ["\\ui\\script\\messagebox.lua"] = true,
		["\\ui\\script\\remotecommand.lua"] = true,
		["\\ui\\script\\autotip.lua"] = true,
		["\\ui\\script\\popupmenu.lua"] = true,
		["\\ui\\script\\autowndpos.lua"] = true,
		["\\ui\\script\\Talent.lua"] = true,
		["\\ui\\script\\sfx.lua"] = true,
		
		["\\ui\\string\\string.lua"] = true,
		["\\ui\\string\\auctionstring.lua"] = true,
		["\\ui\\string\\expressionstring.lua"] = true,
		["\\ui\\string\\loadstring.lua"] = true,
		["\\ui\\string\\toturstring.lua"] = true,
		["\\ui\\string\\hotkeystring.lua"] = true,
		["\\ui\\string\\reputationstring.lua"] = true,
		["\\ui\\string\\dungeonstring.lua"] = true,
		["\\ui\\string\\BreakthroughQuest.lua"] = true,
		["\\ui\\string\\auctionstring.lua"] = true,
		["\\ui\\string\\EquipInquireString.lua"] = true,
    }
	for k, v in pairs(tFilter) do
        LoadScriptFile(k)
    end
end

function LoadingPanel.ReloadUI(frame)
	if not LoadingPanel.nUIStep then
		ReloadLoginFile();
	end
	local bEnd, fPUI = LoadingPanel.LoadUI()
	if bEnd then
		LoadingPanel.EndLoading(frame)
		LoadingPanel.bReloading = nil
	else
		LoadingPanel.SetPercentage(frame, 0.5 + fPUI * 0.5, true)
	end
end

function rl()
	UIShell.CloseAllWindow()
	
	LoadingPanel.bReloading = true
	LoadingPanel.nUIStep = nil
	
	local hFrame = Wnd.OpenWindow("LoadingPanel")
	LoadingPanel.BeginLoading(hFrame, LoadingPanel.szFile)
	hFrame.bLoading = false
end