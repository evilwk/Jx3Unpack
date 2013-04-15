local szBgMusic = Table_GetPath("LOGIN_BGM")
local UIMOVIE_SETP_FADE_IN = 1
local UIMOVIE_SETP_PLAY = 2
local UIMOVIE_SETP_FADE_OUT = 3
local UIMOVIE_SETP_FADE_IN_END = 4
local UIMOVIE_SETP_FADE_IN_END_TIME = 1000
local UIMOVIE_DEFAULT_FADE_IN_TIME = 2


UIMovie = {}

function UIMovie.Play(hFrame, szPath)
    local hMovie = hFrame:Lookup("Movie_Logo")
    SetTotalVolume(0)
    local szFullPath = GetFullPath(szPath)
    hMovie:Play(szFullPath)
    UIMovie.pFocusWindow = Station.GetFocusWindow()
    hFrame:BringToTop()
    Station.SetFocusWindow(hFrame)
end

function UIMovie.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
    this:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 0)
	UIMovie.UpdateSize(this)
end

function UIMovie.UpdateSize(hFrame)
	local fWidth, fHeight = Station.GetClientSize()
	hFrame:SetSize(fWidth, fHeight)
	hFrame:Lookup("Movie_Logo"):SetSize(fWidth, fHeight)
    hFrame:Lookup("", "Image_Bg"):SetSize(fWidth, fHeight)
	hFrame:SetRelPos(0, 0)
end

function UIMovie.UpdateBgAlpha(hFrame, fAlpha)
    local hImageBg = hFrame:Lookup("", "Image_Bg")
    hImageBg:SetAlpha(fAlpha)
end

function UIMovie.OnFrameFadeIn(hFrame)
    if hFrame.fAlpha > 255 then
        hFrame.nStep = UIMOVIE_SETP_FADE_IN_END
        hFrame.fAlpha = 255
    end
    UIMovie.UpdateBgAlpha(hFrame, hFrame.fAlpha)
    hFrame.fAlpha = hFrame.fAlpha + hFrame.fAlphaStep
end

function UIMovie.OnFrameFadeInEnd(hFrame)
    local nTime = GetTickCount()
    if not hFrame.fFadeInEndTime then
        hFrame.fFadeInEndTime = nTime
    end
    
    if nTime - hFrame.fFadeInEndTime > UIMOVIE_SETP_FADE_IN_END_TIME then
        hFrame.nStep = UIMOVIE_SETP_PLAY
        local hImageBg = hFrame:Lookup("", "Image_Bg")
        local hMovie = hFrame:Lookup("Movie_Logo")
        hImageBg:Hide()
        hMovie:Show()
        UIMovie.Play(hFrame, hFrame.szPath)
    end
end

function UIMovie.OnFrameFadeOut(hFrame)
    if hFrame.fAlpha < 0 then
        StopUIMovie()
        PlayBgMusic(szBgMusic)
        return
    end
    UIMovie.UpdateBgAlpha(hFrame, hFrame.fAlpha)
    hFrame.fAlpha = hFrame.fAlpha - hFrame.fAlphaStep
end

function UIMovie.OnMoviePlay(hFrame)
    local hMovie = this:Lookup("Movie_Logo")
    if hMovie:IsFinished() then
        hFrame.fAlpha = 255
        hFrame.nStep = UIMOVIE_SETP_FADE_OUT
        hMovie:Hide()
        local hImageBg = hFrame:Lookup("", "Image_Bg")
        hImageBg:Show()
        hMovie:Hide()
        SetTotalVolume(g_SoundSetting.fTotalVolume)
    end
end

function UIMovie.OnFrameBreathe()
    if not this.nStep then
        return
    end
    if this.nStep == UIMOVIE_SETP_FADE_IN then
       UIMovie.OnFrameFadeIn(this)
    elseif this.nStep == UIMOVIE_SETP_FADE_IN_END then
        UIMovie.OnFrameFadeInEnd(this)
    elseif this.nStep == UIMOVIE_SETP_PLAY then
       UIMovie.OnMoviePlay(this)
    elseif this.nStep == UIMOVIE_SETP_FADE_OUT then
       UIMovie.OnFrameFadeOut(this)
    end
end

function UIMovie.OnFrameDestroy()
    
end

function UIMovie.OnResopneEsc()
    if not UIMovie.bCanNotCanel then
        StopUIMovie()
    end
end

function UIMovie.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		UIMovie.UpdateSize(this)
	end
end

function UIMovie.Stop(hFrame)
    local hMovie = hFrame:Lookup("Movie_Logo")
    hMovie:Stop()
    ApplySoundSetting()
	if UIMovie.pFocusWindow and UIMovie.pFocusWindow:IsValid() then
		Station.SetFocusWindow(UIMovie.pFocusWindow)
	end
end

function UIMovie.SetAlphaStep(hFrame, nTime)
    if not nTime then
        nTime = UIMOVIE_DEFAULT_FADE_IN_TIME
    end
    hFrame.fAlphaStep = 255 / (nTime * 16)
end

function OpenUIMovie(szPath, nFadeInTime, bCanNotCanel, bDisableSound)
    if not IsUIMovieOpened() then
        Wnd.OpenWindow("UIMovie")
    end
    StopBgMusic()
	local hFrame = Station.Lookup("Topmost2/UIMovie")
    hFrame.szPath = szPath
    hFrame.fAlpha = 0
    UIMovie.bCanNotCanel = bCanNotCanel
    UIMovie.SetAlphaStep(hFrame, nFadeInTime)
    hFrame.nStep = UIMOVIE_SETP_FADE_IN
    local hMovie = hFrame:Lookup("Movie_Logo")
    hMovie:Hide()
    local hImageBg = hFrame:Lookup("", "Image_Bg")
    hImageBg:Show()
    
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsUIMovieOpened()
	local hFrame = Station.Lookup("Topmost2/UIMovie")
	if not hFrame then 
        return false
    end
    
    return true
end

function CloseUIMovie(bDisableSound)
    local hFrame = Station.Lookup("Topmost2/UIMovie")
    UIMovie.Stop(hFrame)
	Wnd.CloseWindow("UIMovie")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function PlayUIMovie(szPath, nFadeInTime, bCanNotCanel)
    if not IsFileExist(szPath) then
        return
    end
    OpenUIMovie(szPath, nFadeInTime, bCanNotCanel)
end

function StopUIMovie()
    RemoteCallToServer("On_UIMovie_EscEvent")
    CloseUIMovie()
end

RegisterAutoClose_Topmost("Topmost2/UIMovie", IsUIMovieOpened, UIMovie.OnResopneEsc)
--PlayUIMovie("ui/Video/XSJLOGO.avi")