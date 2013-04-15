SoundSettingPanel = 
{
	tSoundSettings = {}	
}

RegisterCustomData("SoundSettingPanel.tSoundSettings")

function SoundSettingPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	
	SoundSettingPanel.Init(this)
end

function SoundSettingPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function SoundSettingPanel.Init(frame)
	
	frame.bDisable = true
	frame.bDisableSound = true
	
	SoundSettingPanel.DumpSoundSetting(frame)
	
	local sl = frame:Lookup("Scroll_MainVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fTotalVolume))

	local sl = frame:Lookup("Scroll_UIVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fUIVolume))

	local sl = frame:Lookup("Scroll_ErrorVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fErrorVolume))

	local sl = frame:Lookup("Scroll_SceneVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fSceneVolume))

	local sl = frame:Lookup("Scroll_ChVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fChVolume))

	local sl = frame:Lookup("Scroll_BgVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fBgVolume))

	local sl = frame:Lookup("Scroll_HelpVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fHelpVolume))

	local sl = frame:Lookup("Scroll_TipVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fTipVolume))

	local sl = frame:Lookup("Scroll_SpeakVolume")
	sl:SetScrollPos(SoundSettingPanel.VolumeToPos(frame.fSpeakVolume))

	local ch = frame:Lookup("CheckBox_Silence")
	ch:Check( frame.bSilence)
	
	local ch = frame:Lookup("CheckBox_UISound")
	ch:Check(frame.bUISound)
	
	local ch = frame:Lookup("CheckBox_ErrorSound")
	ch:Check(frame.bErrorSound)
	
	local ch = frame:Lookup("CheckBox_SceneSound")
	ch:Check(frame.bSceneSound)
	
	local ch = frame:Lookup("CheckBox_RoleSound")
	ch:Check(frame.bChSound)

	local ch = frame:Lookup("CheckBox_BgSound")
	ch:Check(frame.bBgMUsic)

	local ch = frame:Lookup("CheckBox_BgLoop")
	ch:Check(frame.bBgLoop)

	local ch = frame:Lookup("CheckBox_Speak")
	ch:Check(frame.bEnableCharacterSpeak)

	local ch = frame:Lookup("CheckBox_Help")
	ch:Check(frame.bEnableHelpSound)

	local ch = frame:Lookup("CheckBox_Tip")
	ch:Check(frame.bEnableTipSound)

	local ch = frame:Lookup("CheckBox_TipFemale")
	ch:Check(frame.bFemale)
	
	local ch = frame:Lookup("CheckBox_Focus")
	ch:Check(frame.bEnableLoseFocusPlay)
	
	SoundSettingPanel.SetChanged(frame, false)
	
	frame.bDisableSound = false
	frame.bDisable = false
end

function SoundSettingPanel.PosToVolume(nPos)
	return nPos / 100
end

function SoundSettingPanel.VolumeToPos(nVolume)
	return nVolume * 100
end

function SoundSettingPanel.Default(frame)
	frame.bDisableSound = true
	frame:Lookup("Scroll_MainVolume"):SetScrollPos(80)
	frame:Lookup("Scroll_UIVolume"):SetScrollPos(80)
	frame:Lookup("Scroll_ErrorVolume"):SetScrollPos(78)
	frame:Lookup("Scroll_SceneVolume"):SetScrollPos(23)
	frame:Lookup("Scroll_ChVolume"):SetScrollPos(70)
	frame:Lookup("Scroll_BgVolume"):SetScrollPos(17)
	frame:Lookup("Scroll_HelpVolume"):SetScrollPos(78)
	frame:Lookup("Scroll_TipVolume"):SetScrollPos(78)
	frame:Lookup("Scroll_SpeakVolume"):SetScrollPos(100)
	frame:Lookup("CheckBox_Silence"):Check(false)
	frame:Lookup("CheckBox_UISound"):Check(true)
	frame:Lookup("CheckBox_ErrorSound"):Check(false)
	frame:Lookup("CheckBox_SceneSound"):Check(true)
	frame:Lookup("CheckBox_RoleSound"):Check(true)
	frame:Lookup("CheckBox_BgSound"):Check(true)
	frame:Lookup("CheckBox_BgLoop"):Check(true)
	frame:Lookup("CheckBox_Speak"):Check(true)
	frame:Lookup("CheckBox_Help"):Check(true)
	frame:Lookup("CheckBox_Tip"):Check(true)
	frame:Lookup("CheckBox_TipFemale"):Check(true)
	frame:Lookup("CheckBox_Focus"):Check(true)
	frame.bDisableSound = false
end

function SoundSettingPanel.OnScrollBarPosChanged()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	local nCurrentValue = this:GetScrollPos()
	local nVolume = SoundSettingPanel.PosToVolume(nCurrentValue)
	SoundSettingPanel.SetChanged(frame, true)
	local tSetting = GetSoundSetting()
	local szName = this:GetName()
	if szName == "Scroll_MainVolume" then
		tSetting.fTotalVolume = nVolume
	elseif szName == "Scroll_UIVolume" then
		tSetting.fUIVolume = nVolume
	elseif szName == "Scroll_ErrorVolume" then
		tSetting.fErrorVolume = nVolume
	elseif szName == "Scroll_SceneVolume" then
		tSetting.fSceneVolume = nVolume
	elseif szName == "Scroll_ChVolume" then
		tSetting.fChVolume = nVolume
	elseif szName == "Scroll_BgVolume" then
		tSetting.fBgVolume = nVolume
	elseif szName == "Scroll_HelpVolume" then
		tSetting.fHelpVolume = nVolume
	elseif szName == "Scroll_TipVolume" then
		tSetting.fTipVolume = nVolume
	elseif szName == "Scroll_SpeakVolume" then
		tSetting.fSpeakVolume = nVolume
	end
	SetSoundSetting(tSetting)
end

function SoundSettingPanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	SoundSettingPanel.SetChanged(frame, true)
	local tSetting = GetSoundSetting()
	local szName = this:GetName()
	if szName == "CheckBox_Silence" then
		tSetting.bEnable = false
	elseif szName == "CheckBox_UISound" then
		tSetting.bEnableUISound = true
	elseif szName == "CheckBox_ErrorSound" then
		tSetting.bEnableErrorSound = true
	elseif szName == "CheckBox_SceneSound" then
		tSetting.bEnableSceneSound = true
	elseif szName == "CheckBox_RoleSound" then
		tSetting.bEnableCharacterSound = true
	elseif szName == "CheckBox_BgSound" then
		tSetting.bEnableBgMusic = true
	elseif szName == "CheckBox_BgLoop" then
		tSetting.bBgMusicLoop = true
	elseif szName == "CheckBox_Speak" then
		tSetting.bEnableCharacterSpeak = true
	elseif szName == "CheckBox_Help" then
		tSetting.bEnableHelpSound = true
	elseif szName == "CheckBox_Tip" then
		tSetting.bEnableTipSound = true
	elseif szName == "CheckBox_TipFemale" then
		tSetting.bFemale = true
	elseif szName == "CheckBox_Focus" then
		tSetting.bEnableLoseFocusPlay = true
	end
	SetSoundSetting(tSetting)
	if not frame.bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

function SoundSettingPanel.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	SoundSettingPanel.SetChanged(frame, true)
	local tSetting = GetSoundSetting()
	local szName = this:GetName()
	if szName == "CheckBox_Silence" then
		tSetting.bEnable = true
	elseif szName == "CheckBox_UISound" then
		tSetting.bEnableUISound = false
	elseif szName == "CheckBox_ErrorSound" then
		tSetting.bEnableErrorSound = false
	elseif szName == "CheckBox_SceneSound" then
		tSetting.bEnableSceneSound = false
	elseif szName == "CheckBox_RoleSound" then
		tSetting.bEnableCharacterSound = false
	elseif szName == "CheckBox_BgSound" then
		tSetting.bEnableBgMusic = false
	elseif szName == "CheckBox_BgLoop" then
		tSetting.bBgMusicLoop = false
	elseif szName == "CheckBox_Speak" then
		tSetting.bEnableCharacterSpeak = false
	elseif szName == "CheckBox_Help" then
		tSetting.bEnableHelpSound = false
	elseif szName == "CheckBox_Tip" then
		tSetting.bEnableTipSound = false
	elseif szName == "CheckBox_TipFemale" then
		tSetting.bFemale = false
	elseif szName == "CheckBox_Focus" then
		tSetting.bEnableLoseFocusPlay = false
	end
	SetSoundSetting(tSetting)
	if not frame.bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

--Êý¾Ý·ÖÎö
function SoundSettingPanel.OnDataAnalysis_AdjustVolume(frame)
	if frame.bDisable or frame.bDisableSound then
		return
	end	
	
	local tSetting = GetSoundSetting()
	
	if not tSetting.bEnable and not frame.bSilence then
		FireDataAnalysisEvent("CLOSE_SOUND")
	end

	if not tSetting.bEnableUISound and frame.bUISound then
		FireDataAnalysisEvent("CLOSE_UI_SFX")
	end
	
	if not tSetting.bEnableErrorSound and frame.bErrorSound then
		FireDataAnalysisEvent("CLOSE_ERROR_TIP_SFX")
	end
	
	if not tSetting.bEnableCharacterSound and frame.bChSound then
		FireDataAnalysisEvent("CLOSE_CHARACTER_SFX")
	end
	
	if not tSetting.bEnableBgMusic and frame.bBgMUsic then
		FireDataAnalysisEvent("CLOSE_BACKGROUND_MUSIC")
	end
	
	if not tSetting.bEnable3DSound and frame.b3DSound then
		FireDataAnalysisEvent("CLOSE_3D_SFX")
	end

	local nDefVolume
	if frame.fTotalVolume ~= tSetting.fTotalVolume then
		nDefVolume = SoundSettingPanel.PosToVolume(80)
		FireDataAnalysisEvent("ADJUST_MAIN_VOLUME", {nDefVolume, tSetting.fTotalVolume})
	end
	
	if frame.fBgVolume ~= tSetting.fBgVolume then
		nDefVolume = SoundSettingPanel.PosToVolume(50)
		FireDataAnalysisEvent("ADJUST_BACKGROUND_MUSIC", {nDefVolume, tSetting.fBgVolume})
	end
	
	if frame.fSceneVolume ~= tSetting.fSceneVolume then
		nDefVolume = SoundSettingPanel.PosToVolume(90)
		FireDataAnalysisEvent("ADJUST_SCENE_SFX", {nDefVolume, tSetting.fSceneVolume})
	end
		
	if frame.fChVolume ~= tSetting.fChVolume then
		nDefVolume = SoundSettingPanel.PosToVolume(90)
		FireDataAnalysisEvent("ADJUST_CHARACTER_SFX", {nDefVolume, tSetting.fChVolume})
	end
		
	if frame.fUIVolume ~= tSetting.fUIVolume then
		nDefVolume = SoundSettingPanel.PosToVolume(90)
		FireDataAnalysisEvent("ADJUST_UI_SFX", {nDefVolume, tSetting.fUIVolume})
	end
	
	if frame.fErrorVolume ~= tSetting.fErrorVolume then
		nDefVolume = SoundSettingPanel.PosToVolume(70)
		FireDataAnalysisEvent("ADJUST_ERROR_TIP_SFX", {nDefVolume, tSetting.fErrorVolume})
	end
end

function SoundSettingPanel.DumpSoundSetting(frame)
	local tSetting = GetSoundSetting()
	
	SoundSettingPanel.OnDataAnalysis_AdjustVolume(frame)
	
	frame.fTotalVolume = tSetting.fTotalVolume
	frame.fUIVolume = tSetting.fUIVolume
	frame.fErrorVolume = tSetting.fErrorVolume
	frame.fSceneVolume = tSetting.fSceneVolume
	frame.fChVolume = tSetting.fChVolume
	frame.fBgVolume = tSetting.fBgVolume
	frame.fHelpVolume = tSetting.fHelpVolume
	frame.fTipVolume = tSetting.fTipVolume
	frame.fSpeakVolume = tSetting.fSpeakVolume
	
	frame.bSilence = not tSetting.bEnable
	frame.bUISound = tSetting.bEnableUISound
	frame.bErrorSound = tSetting.bEnableErrorSound
	frame.bSceneSound = tSetting.bEnableSceneSound
	frame.bChSound = tSetting.bEnableCharacterSound
	frame.bBgMUsic = tSetting.bEnableBgMusic
	frame.bBgLoop = tSetting.bBgMusicLoop
	frame.bEnableCharacterSpeak = tSetting.bEnableCharacterSpeak
	frame.bEnableHelpSound = tSetting.bEnableHelpSound
	frame.bEnableTipSound = tSetting.bEnableTipSound
	frame.bFemale = tSetting.bFemale
	frame.bEnableLoseFocusPlay = tSetting.bEnableLoseFocusPlay
	
end

function SoundSettingPanel.Cancel(frame)
	if frame.bChanged then
		local tSetting = GetSoundSetting()
		tSetting.fTotalVolume = frame.fTotalVolume
		tSetting.fUIVolume = frame.fUIVolume
		tSetting.fErrorVolume = frame.fErrorVolume
		tSetting.fSceneVolume = frame.fSceneVolume
		tSetting.fChVolume = frame.fChVolume
		tSetting.fBgVolume = frame.fBgVolume
		tSetting.fHelpVolume = frame.fHelpVolume
		tSetting.fTipVolume = frame.fTipVolume
		tSetting.fSpeakVolume = frame.fSpeakVolume
		
		tSetting.bEnable = not frame.bSilence
		tSetting.bEnableUISound = frame.bUISound
		tSetting.bEnableErrorSound = frame.bErrorSound
		tSetting.bEnableSceneSound = frame.bSceneSound
		tSetting.bEnableCharacterSound = frame.bChSound
		tSetting.bEnableBgMusic = frame.bBgMUsic
		tSetting.bBgMusicLoop = frame.bBgLoop
		tSetting.bEnableCharacterSpeak = frame.bEnableCharacterSpeak
		tSetting.bEnableHelpSound = frame.bEnableHelpSound
		tSetting.bEnableTipSound = frame.bEnableTipSound
		tSetting.bFemale = frame.bFemale
		tSetting.bEnableLoseFocusPlay = frame.bEnableLoseFocusPlay
		
		SetSoundSetting(tSetting)	
	end
end

function SoundSettingPanel.SetChanged(frame, bChanged)
	frame.bChanged = bChanged
	frame:Lookup("Btn_Apply"):Enable(frame.bChanged)
end

function SoundSettingPanel.ApplySetting(frame)
	SoundSettingPanel.DumpSoundSetting(frame)
	SoundSettingPanel.SetChanged(frame, false)
end

function SoundSettingPanel.OnLButtonClick()
	local szSelfName = this:GetName()
    if szSelfName == "Btn_Close" then
    	CloseSoundSettingPanel()
    elseif szSelfName == "Btn_Cancel" then
    	SoundSettingPanel.Cancel(this:GetRoot())
    	CloseSoundSettingPanel()
    elseif szSelfName == "Btn_Sure" then
    	SoundSettingPanel.OnDataAnalysis_AdjustVolume(this:GetRoot())
    	
    	CloseSoundSettingPanel()
    elseif szSelfName == "Btn_Default" then
    	SoundSettingPanel.Default(this:GetRoot())
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
    elseif szSelfName == "Btn_Apply" then
    	SoundSettingPanel.ApplySetting(this:GetRoot())
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

function OpenSoundSettingPanel(bDisableSound)
	if IsSoundSettingPanelOpened() then
		return
	end
	
	Wnd.OpenWindow("SoundSettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseSoundSettingPanel(bDisableSound)
	local frame = Station.Lookup("Topmost/SoundSettingPanel")
	if not IsSoundSettingPanelOpened() then
		return
	end
	Wnd.CloseWindow("SoundSettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsSoundSettingPanelOpened()
	local frame = Station.Lookup("Topmost/SoundSettingPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end