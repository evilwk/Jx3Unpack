local szBgMusic = Table_GetPath("LOGIN_BGM")
local szDefaultCGPath = "JX3CG";
local LOGIN_LOGO_KOR_FLAG = 1
local LOGIN_LOGO_XSJ_LOGO = 2
local LOGIN_LOGO_KOR_LOGO = 3
local LOGIN_LOGO_CG = 4
local LOGIN_LOGO_KOR_FLAG_LIVE_TIME = 1000 * 3
local LOGIN_LOGO_KOR_LOGO_LIVE_TIME = 1000 * 2
LoginLogo={

ShowCG = function(szPath, bCanCancel)
	if not szPath then
		szPath = Table_GetPath(szDefaultCGPath)
	end
    LoginLogo.nLogoState = LOGIN_LOGO_CG
    LoginLogo.bCanCancel = bCanCancel
	LoginLogo.SetLogoPath(szPath)
end;

ShowLogo = function()
    local _, _, szVersionLineName = GetVersion()
	if szVersionLineName == "zhkr" then
		LoginLogo.nLogoState = LOGIN_LOGO_KOR_FLAG
	else
		LoginLogo.nLogoState = LOGIN_LOGO_XSJ_LOGO
	end
	local szFilePath = Table_GetPath("XSJLOGO")
	LoginLogo.SetLogoPath(szFilePath)
end;

SetLogoPath = function(szPath)
    LoginLogo.szPath = szPath
end;

OnFrameShow=function()
	LoginLogo.PlayLogo(this)
	this:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 0)
end;

PlayLogo = function(hFrame)
	LoginLogo.nStartPlayTime = GetTickCount()
	
	local hWndKorFlag = hFrame:Lookup("Wnd_KorLogoPage2")
	local hWndMovie = hFrame:Lookup("Movie_Logo")
	local hWndKorLogo = hFrame:Lookup("Wnd_KorLogoPage1")
	if LoginLogo.nLogoState == LOGIN_LOGO_KOR_FLAG then
		hWndKorFlag:Show()
		hWndMovie:Hide()
		hWndKorLogo:Hide()
		local hText = hWndKorFlag:Lookup("", "Text_LogoMsg")
		hText:SetText(g_tStrings.KOREA_LOGO_LEVEL_CONTENT)
	elseif LoginLogo.nLogoState == LOGIN_LOGO_XSJ_LOGO or 
    LoginLogo.nLogoState == LOGIN_LOGO_CG 
    then
		hWndKorFlag:Hide()
		hWndMovie:Show()
		hWndKorLogo:Hide()
		if LoginLogo.IsLogoExit(LoginLogo.szPath) then
			local movie = this:Lookup("Movie_Logo")
			local szFullPath = GetFullPath(LoginLogo.szPath)
			movie:Play(szFullPath)
			StopBgMusic()
			LoginLogo.pFocusWindow=Station.GetFocusWindow()
			this:BringToTop()
			Station.SetFocusWindow(this)
		end
	elseif LoginLogo.nLogoState == LOGIN_LOGO_KOR_LOGO then
		hWndKorFlag:Hide()
		hWndMovie:Hide()
		hWndKorLogo:Show()
	end
end;

OnFrameHide=function()
	local movie = this:Lookup("Movie_Logo")
	movie:Stop()
	PlayBgMusic(szBgMusic)
	if LoginLogo.pFocusWindow and LoginLogo.pFocusWindow:IsValid() then
		Station.SetFocusWindow(LoginLogo.pFocusWindow)
	end
end;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	
	LoginLogo.UpdateSize(this)
end;

UpdateSize = function(hFrame)
	local fWidth, fHeight = Station.GetClientSize()
	hFrame:SetSize(fWidth, fHeight)
	hFrame:Lookup("Movie_Logo"):SetSize(fWidth, fHeight)
	hFrame:SetRelPos(0, 0)
end;

OnFrameBreathe=function()
	if not LoginLogo.nStartPlayTime then
		return 
	end	 
	if LoginLogo.nLogoState == LOGIN_LOGO_KOR_FLAG then
		if GetTickCount() - LoginLogo.nStartPlayTime > LOGIN_LOGO_KOR_FLAG_LIVE_TIME then
			LoginLogo.nLogoState = LOGIN_LOGO_XSJ_LOGO
			LoginLogo.PlayLogo(this)
		end
	elseif LoginLogo.nLogoState == LOGIN_LOGO_XSJ_LOGO or LoginLogo.nLogoState == LOGIN_LOGO_CG then
        StopBgMusic()
		local movie = this:Lookup("Movie_Logo")
		if not LoginLogo.IsLogoExit(LoginLogo.szPath) or movie:IsFinished() then
			PlayBgMusic(szBgMusic)
			local _, _, szVersionLineName = GetVersion()
			if LoginLogo.nLogoState == LOGIN_LOGO_XSJ_LOGO and szVersionLineName == "zhkr" then
				LoginLogo.nLogoState = LOGIN_LOGO_KOR_LOGO
				LoginLogo.PlayLogo(this)
			else
				Login.StepNext()
			end
		end
	elseif LoginLogo.nLogoState == LOGIN_LOGO_KOR_LOGO then
		if GetTickCount() - LoginLogo.nStartPlayTime > LOGIN_LOGO_KOR_LOGO_LIVE_TIME then
			LoginLogo.nLogoState = LOGIN_LOGO_KOR_FLAG
			Login.StepNext()
		end
	end
end;

OnFrameDestroy=function()
end;

OnFrameKeyDown = function()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		LoginLogo.OnResopneEsc(this)
	end
end;

OnEditSpecialKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		LoginLogo.OnResopneEsc(this)
		return 1
	end
	
	return 0
end;

OnResopneEsc = function(hFrame)
	if LoginLogo.nLogoState == LOGIN_LOGO_XSJ_LOGO then
		local _, _, szVersionLineName = GetVersion()
		if szVersionLineName == "zhkr" then
			LoginLogo.nLogoState = LOGIN_LOGO_KOR_LOGO
			LoginLogo.PlayLogo(hFrame)
		else
			Login.StepNext()
		end
    elseif LoginLogo.nLogoState == LOGIN_LOGO_CG then
        local nCount = Login_GetRoleCount()
        if LoginLogo.bCanCancel or nCount > 1 then
            Login.StepNext()
        end
	end
end;

OnEvent=function(szEvent)
	if szEvent == "UI_SCALED" then
		LoginLogo.UpdateSize(this)
	end
end;

IsLogoExit = function(szPath)
	return IsFileExist(szPath)
end;
	
};

local function OnLoadingEnd()
    LoginLogo.ShowLogo()
	Login.EnterLogo()
end

RegisterEvent("CLIENT_LOADING_END", OnLoadingEnd)
