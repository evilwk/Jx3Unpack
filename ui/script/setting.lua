
local szCurrentSoundVersion = "0.4"

g_SoundSetting = 
{
	bEnable = true,
	bEnableUISound = true,
	bEnableErrorSound = false,
	bEnableSceneSound = true,
	bEnableCharacterSound = true,
	bEnableCharacterSpeak = true,
	bEnableBgMusic = true,
	bEnable3DSound = true,
	bBgMusicLoop = true,
	fTotalVolume = 0.8,
	fUIVolume = 0.8,
	fErrorVolume = 0.78,
	fSceneVolume = 0.23,
	fChVolume = 0.7,
	fSpeakVolume = 1.0,
	fBgVolume = 0.17,
	bEnableHelpSound = true,
	bEnableTipSound = true,
	fHelpVolume = 0.78,
	fTipVolume = 0.78,
	bFemale = true,
	szVersion = szCurrentSoundVersion,
	bEnableLoseFocusPlay = true
}

g_MovieRecordSetting = 
{
	nRSize = 2,
	nFilter = MOVIE.FILTER_LINEAR,
	nQuality = MOVIE.QUALITY_CINEMATIC1,
	nCode = MOVIE.MPEG2,
	nFps = MOVIE.FPS_25,
	bRecordWhenStart = false,
}


RegisterCustomData("Global\\g_SoundSetting")
RegisterCustomData("Global\\g_MovieRecordSetting")

local szLastBgMusic = ""
local OldPlayBgMusic = PlayBgMusic
PlayBgMusic = function(szName)
	szLastBgMusic = szName
	OldPlayBgMusic(szName)
end

local dwPlayingSoundID = nil
local bTipSound = false
function PlayHelpSound(szSound)
	if dwPlayingSoundID then
		if IsPlaying2DSound(dwPlayingSoundID) then
			if bTipSound then
				Stop2DSound(dwPlayingSoundID)
				dwPlayingSoundID = nil
				bTipSound = false
			else
				return
			end
		end
	end
	local dwID = Play2DSound(SOUND.FRESHER_TIP, "ui\\sound\\help\\"..szSound..".wav", 0, 1, false)
	if dwID then
		dwPlayingSoundID = dwID
		bTipSound = false
	end
end

function PlayTipSound(szSound)
	if dwPlayingSoundID then
		if IsPlaying2DSound(dwPlayingSoundID) then
			return
		end
	end
	local szFile = ""
	if g_SoundSetting.bFemale then
		szFile = "ui\\sound\\female\\"..szSound..".wav"
	else
		szFile = "ui\\sound\\male\\"..szSound..".wav"
	end
	local dwID = Play2DSound(SOUND.SYSTEM_TIP, szFile, 0, 1, false)
	if dwID then
		dwPlayingSoundID = dwID
		bTipSound = true
	end
end

function GetSoundSetting()
	return g_SoundSetting
end

function SetSoundSetting(tSetting)
	for k, v in pairs(tSetting) do
		g_SoundSetting[k] = v
	end
	ApplySoundSetting()
end

function ApplySoundSetting()
	EnableAllSound(g_SoundSetting.bEnable)
	EnableSound(SOUND.UI_SOUND, g_SoundSetting.bEnableUISound)
	EnableSound(SOUND.UI_ERROR_SOUND, g_SoundSetting.bEnableErrorSound)
	EnableSound(SOUND.SCENE_SOUND, g_SoundSetting.bEnableSceneSound)
	EnableSound(SOUND.CHARACTER_SOUND, g_SoundSetting.bEnableCharacterSound)
	EnableSound(SOUND.BG_MUSIC, g_SoundSetting.bEnableBgMusic)
	EnableSound(SOUND.FRESHER_TIP, g_SoundSetting.bEnableHelpSound)
	EnableSound(SOUND.SYSTEM_TIP, g_SoundSetting.bEnableTipSound)
	EnableSound(SOUND.CHARACTER_SPEAK, g_SoundSetting.bEnableCharacterSpeak)
	Enable3DSound(true)
	SetBgMusicLoop(g_SoundSetting.bBgMusicLoop)
	EnableSoundWhenLoseFocus(g_SoundSetting.bEnableLoseFocusPlay)
	
	SetTotalVolume(g_SoundSetting.fTotalVolume)
	SetVolume(SOUND.UI_SOUND, g_SoundSetting.fUIVolume)
	SetVolume(SOUND.UI_ERROR_SOUND, g_SoundSetting.fErrorVolume)
	SetVolume(SOUND.SCENE_SOUND, g_SoundSetting.fSceneVolume)
	SetVolume(SOUND.CHARACTER_SOUND, g_SoundSetting.fChVolume)
	SetVolume(SOUND.BG_MUSIC, g_SoundSetting.fBgVolume)
	SetVolume(SOUND.FRESHER_TIP, g_SoundSetting.fHelpVolume)
	SetVolume(SOUND.SYSTEM_TIP, g_SoundSetting.fTipVolume)
	SetVolume(SOUND.CHARACTER_SPEAK, g_SoundSetting.fSpeakVolume)
	
	if g_SoundSetting.bEnable and g_SoundSetting.bEnableBgMusic and szLastBgMusic ~= "" then
		PlayBgMusic(szLastBgMusic)
	end
end

function GetMovieRecordSetting()
	return g_MovieRecordSetting
end

function SetMovieRecordSetting(tSetting)
	g_MovieRecordSetting.nRSize = tSetting.nRSize
	g_MovieRecordSetting.nFilter = tSetting.nFilter
	g_MovieRecordSetting.nQuality = tSetting.nQuality
	g_MovieRecordSetting.nCode = tSetting.nCode
	g_MovieRecordSetting.nFps = tSetting.nFps
end

local OnCustomDataLoaded = function(event)
	if event == "CUSTOM_DATA_LOADED" and arg0 == "Global" then		
		if g_SoundSetting.szVersion ~= szCurrentSoundVersion then
			if g_SoundSetting.szVersion ~= "0.3" then
				g_SoundSetting.bEnableHelpSound = true
				g_SoundSetting.bEnableTipSound = true
				g_SoundSetting.fBgVolume = 0.3
				g_SoundSetting.fHelpVolume = 1.0
				g_SoundSetting.fTipVolume =1.0
				g_SoundSetting.bFemale = true
			end

			g_SoundSetting.fChVolume = 0.5
			g_SoundSetting.fSpeakVolume = 1.0
			g_SoundSetting.bEnableCharacterSpeak = true
			g_SoundSetting.szVersion = szCurrentSoundVersion
		end
		
		ApplySoundSetting()
		if g_MovieRecordSetting.bRecordWhenStart then
			StartMovieRecord()
		end
	end
end

RegisterEvent("CUSTOM_DATA_LOADED", OnCustomDataLoaded)

