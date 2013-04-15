cSlider = class()
function cSlider:ctor(nMin, nMax, nStep)
	self.nMin = nMin
	self.nMax = nMax
	self.nStep = nStep
end

function cSlider:ReInit(nMin, nMax, nStep)
	self.nMin = nMin
	self.nMax = nMax
	self.nStep = nStep
end

function cSlider:GetValue(nStep)
	return self.nMin + (nStep - 0) * (self.nMax - self.nMin) / (self.nStep - 0) 
end

function cSlider:GetStep(nValue)
	return 0 + (nValue - self.nMin) * (self.nStep - 0) / (self.nMax - self.nMin)
end

function cSlider:ChangeToArea(nMin, nMax, nStep)
	return nMin + (nMax - nMin) * (self:GetValue(nStep) - self.nMin) / (self.nMax - self.nMin)
end

function cSlider:ChangeToAreaFromValue(nMin, nMax, nValue)
	return nMin + (nMax - nMin) * (nValue - self.nMin) / (self.nMax - self.nMin)
end

function cSlider:GetStepFromArea(nMin, nMax, nValue)	 
	return self:GetStep(self.nMin + (self.nMax - self.nMin) * (nValue - nMin) / (nMax - nMin))
end

cMultipleSlider = class()
function cMultipleSlider:ctor(nMax, nStep)
	self.nMax = nMax
	self.nStep = nStep
end

function cMultipleSlider:ReInit(nMax, nStep)
	self.nMax = nMax
	self.nStep = nStep
end

function cMultipleSlider:GetValue(nStep)
    local nMidStep = math.floor(self.nStep / 2)
	local nMinValue = 1 / self.nMax
    
    if nStep <= nMidStep then
        --nMinValue +  nStep * (1 - nMinValue) / (nMidStep)
		return (nMinValue * (nMidStep - nStep) + nStep ) /  nMidStep
	else
        local nAddStep = nStep - nMidStep
		return 1 + (nAddStep * (self.nMax - 1) / nMidStep)
	end
end

function cMultipleSlider:GetStep(nValue)
    local nMidStep = math.floor(self.nStep / 2)
	local nMinValue = 1 / self.nMax
    
    if nValue <= 1 then
        local nAddValue = nValue - nMinValue
        local nPerValue = (1 - nMinValue) / nMidStep
        --return  math.floor(nAddValue / nPerValue)
        return math.floor((nAddValue * nMidStep) / (1 - nMinValue))
    else
        local nAddValue = nValue - 1
        local nPerValue = (self.nMax - 1) / nMidStep
        --return nMidStep + math.floor(nAddValue / nPerValue)
        return nMidStep + math.floor((nAddValue * nMidStep) / (self.nMax - 1))
    end
end

local g_tAttendFour = {};
CONFIGURE_LEVEL =
{
    ENABLE = 0,
    ATTEND = 1,
    DEFAULT = 2,
    LOW_MOST = 3,
    LOW = 4,
    MEDIUM = 5,
    HIGH = 6,
    PERFECTION = 7,
    CUSTOM = 8,
	
	ATTEND_FOUR = 100,
	VALUE1 = 101,
	VALUE2 = 102,
	VALUE3 = 103,
	VALUE4 = 104,
}

local CURRENT_VERSION = 5
VideoSettingPanel =
{
	bOptimizeUniform = false,
	bOptimizeRide = false,
	bOptimizeWeapon = false,
	bOptimizeQiChang = false,
	nConfigureLevel = CONFIGURE_LEVEL.CUSTOM,
	nVersion = 1
}
local OBJECT = VideoSettingPanel

local a3DEngineOption = {}
local a3DEngineCaps = {}
local SETTINGS = {}
local CONFIG_SETTINGS = {}
local CONFIG_ENABLE = {}

function Table_GetVideoSetting(nLevel)
	local tSettings = g_tTable.VideoSetting:Search(nLevel)
	return tSettings
end

local function IsUIEnable(szKey)
    if CONFIG_ENABLE[szKey] == false or CONFIG_ENABLE[szKey] == 0 then
        return false
    end
    return true
end

function VideoSettingPanel.GetFourStep(szKey, value)
	if g_tAttendFour[szKey] == 1 or g_tAttendFour[szKey] == true then
		local t = Table_GetVideoSetting(CONFIGURE_LEVEL["VALUE1"])
		local nPrev = t[szKey]
		local t = Table_GetVideoSetting(CONFIGURE_LEVEL["VALUE4"])
		local nLast = t[szKey]
		local nSignal = nLast - nPrev
		
		for i=2, 4, 1 do
			local t = Table_GetVideoSetting(CONFIGURE_LEVEL["VALUE"..i])
			local nValue = t[szKey]
			local nDelta = nValue - nPrev
			local nMid   = nPrev + nDelta / 2
			if nSignal >= 0 and value <= nMid then
				return i - 1
			elseif (nSignal < 0 and value > nMid) then
				return i - 1
			end
			nPrev = nValue
		end
		return 4
	end
	return
end

function VideoSettingPanel.GetScrollValue(hScroll, szKey)
	if g_tAttendFour[szKey] == 1 or g_tAttendFour[szKey] == true then
		local nValue = hScroll:GetScrollPos()
		local t = Table_GetVideoSetting(CONFIGURE_LEVEL["VALUE"..(nValue + 1)])
		return t[szKey]
	elseif hScroll.Slider then
		return hScroll.Slider:GetValue(hScroll:GetScrollPos())
	else
		hScroll:GetScrollPos()
	end
end

function VideoSettingPanel.SetScroll(tSetting, hScroll, szKey, value)
	if not value then
		value = tSetting[szKey]
	end
	if value ~= nil then
		local nLevel = VideoSettingPanel.GetFourStep(szKey, value)
		if nLevel then
			hScroll:SetScrollPos(nLevel - 1)
		elseif hScroll.Slider then
			hScroll:SetScrollPos(hScroll.Slider:GetStep(value))
		else
			hScroll:SetScrollPos(value)
		end
	end
end

function VideoSettingPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("VIDEO_SETTINGS_UPDATE")
	
	VideoSettingPanel.InitConfigSetting()
	VideoSettingPanel.InitScroll(this)
	VideoSettingPanel.InitSettings(this)
	VideoSettingPanel.SetSettings(SETTINGS)
	VideoSettingPanel.UpdateOptionState(this)
	VideoSettingPanel.UpdateUIOptionEnable(this)
    
	VideoSettingPanel.SetChanged(this, false)
	
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
end

function VideoSettingPanel.FliterConfigOption()
    local tFilter = Table_GetVideoSetting(CONFIGURE_LEVEL.ATTEND)
    for k, v in pairs(tFilter) do
        if k ~= "nConfigureLevel" and (v == 0 or v == false) then
            CONFIG_SETTINGS[CONFIGURE_LEVEL.LOW_MOST][k] = nil
            CONFIG_SETTINGS[CONFIGURE_LEVEL.LOW][k] = nil
            CONFIG_SETTINGS[CONFIGURE_LEVEL.MEDIUM][k] = nil
            CONFIG_SETTINGS[CONFIGURE_LEVEL.HIGH][k] = nil
            CONFIG_SETTINGS[CONFIGURE_LEVEL.PERFECTION][k] = nil
        end
    end
    --CONFIG_SETTINGS[CONFIGURE_LEVEL.LOW_MOST].bFullScreen = true
	--CONFIG_SETTINGS[CONFIGURE_LEVEL.LOW_MOST].bExclusiveMode = true
end

function VideoSettingPanel.InitConfigSetting()
	g_tAttendFour = Table_GetVideoSetting(CONFIGURE_LEVEL.ATTEND_FOUR)
    CONFIG_ENABLE = Table_GetVideoSetting(CONFIGURE_LEVEL.ENABLE)
    CONFIG_SETTINGS[CONFIGURE_LEVEL.DEFAULT] = Table_GetVideoSetting(CONFIGURE_LEVEL.DEFAULT)
    CONFIG_SETTINGS[CONFIGURE_LEVEL.DEFAULT].nConfigureLevel = CONFIGURE_LEVEL.CUSTOM
    
    CONFIG_SETTINGS[CONFIGURE_LEVEL.LOW_MOST] = Table_GetVideoSetting(CONFIGURE_LEVEL.LOW_MOST)
    CONFIG_SETTINGS[CONFIGURE_LEVEL.LOW] = Table_GetVideoSetting(CONFIGURE_LEVEL.LOW)
    CONFIG_SETTINGS[CONFIGURE_LEVEL.MEDIUM] = Table_GetVideoSetting(CONFIGURE_LEVEL.MEDIUM)
    CONFIG_SETTINGS[CONFIGURE_LEVEL.HIGH] = Table_GetVideoSetting(CONFIGURE_LEVEL.HIGH)
    CONFIG_SETTINGS[CONFIGURE_LEVEL.PERFECTION] = Table_GetVideoSetting(CONFIGURE_LEVEL.PERFECTION)
    OBJECT.FliterConfigOption()
end

--[[
function Outputa3DEngineOption()
    Output(a3DEngineOption)
end
]]

function VideoSettingPanel.InitScroll(frame)
	local WndSet3 = frame:Lookup("Wnd_Set3")
	local WndSet4 = frame:Lookup("Wnd_Set4")
	
	local hWnd = WndSet4:Lookup("Scroll_Water")
	if not hWnd.SetDragStep then
		return
	end
	
	WndSet3:Lookup("Scroll_PlayerNumber"):SetDragStep(true)
	WndSet3:Lookup("Scroll_PlayerNumber1"):SetDragStep(true)
	
	WndSet4:Lookup("Scroll_Water"):SetDragStep(true)
	WndSet4:Lookup("Scroll_TS"):SetDragStep(true)
	WndSet4:Lookup("Scroll_FSAA"):SetDragStep(true)
	WndSet4:Lookup("Scroll_CD"):SetDragStep(true)
	WndSet4:Lookup("Scroll_SD"):SetDragStep(true)
	WndSet4:Lookup("Scroll_VD"):SetDragStep(true)
end

function VideoSettingPanel.InitSettings(frame)
    SETTINGS = SETTINGS or {}
    local aVideoSettings = GetVideoSettings()
    a3DEngineOption = KG3DEngine.Get3DEngineOption()
    a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
    
    --Set3--------------------------------------
    local wndSet3 = frame:Lookup("Wnd_Set3")
    SETTINGS.nMultiSampleType = aVideoSettings.MultiSampleType  --抗锯齿
	SETTINGS.bOptimizeUniform = VideoSettingPanel.bOptimizeUniform --玩家同模
	SETTINGS.bOptimizeRide = VideoSettingPanel.bOptimizeRide --坐骑同模
	SETTINGS.bOptimizeWeapon = VideoSettingPanel.bOptimizeWeapon --武器同模
    SETTINGS.bOptimizeQiChang = VideoSettingPanel.bOptimizeQiChang --屏蔽气场
    
	
	SETTINGS.bFXAA = a3DEngineOption.bFXAA
	SETTINGS.nFXAALevel = a3DEngineOption.nFXAALevel
	
    local hScrollPlayerN = wndSet3:Lookup("Scroll_PlayerNumber")-- 同屏人数
    local nTotalCount = #a3DEngineCaps.aMDLRenderLimit - 1
    hScrollPlayerN:SetStepCount(nTotalCount)
    SETTINGS.nMDLRenderLimit = a3DEngineOption.nMDLRenderLimit -- 同屏人数
    
	local hScrollPlayerN1 = wndSet3:Lookup("Scroll_PlayerNumber1")
    local nTotalCount = #a3DEngineCaps.aClientSFXLimit - 1
    hScrollPlayerN1:SetStepCount(nTotalCount)
    SETTINGS.nClientSFXLimit = a3DEngineOption.nClientSFXLimit -- 同屏特效数

    --set4------------------------------------------
    SETTINGS.bRenderGrass = a3DEngineOption.bRenderGrass --地表细节
	SETTINGS.bGrassAnimation = a3DEngineOption.bGrassAnimation --草地动画
	SETTINGS.bGrassAlphaBlend = a3DEngineOption.bGrassAlphaBlend -- 透明混合渲染
    
    SETTINGS.bShockWaveEnable = a3DEngineOption.bShockWaveEnable -- 屏幕扭曲
	
    SETTINGS.bDOF = a3DEngineOption.bDOF --景深效果
    SETTINGS.bHDR = a3DEngineOption.bHDR --高动态范围光照
	
	SETTINGS.bBloomEnable = a3DEngineOption.bBloomEnable --全屏柔光
	SETTINGS.bGodRay = a3DEngineOption.bGodRay --体积光
	--SETTINGS.bMotionBlur = a3DEngineOption.bMotionBlur --动态模糊
	
    --水面精度
	SETTINGS.nWaterDetail = a3DEngineOption.nWaterDetail
	
	--贴图精度最小值大于最大值， 3D那边用的是倒数 
    --贴图精度
	SETTINGS.nTextureScale = a3DEngineOption.nTextureScale
	--材质过滤
	SETTINGS.dwMaxAnisotropy = a3DEngineOption.dwMaxAnisotropy
	
	SETTINGS.fCameraDistance = a3DEngineOption.fCameraDistance
	
	SETTINGS.nShadowType = a3DEngineOption.nShadowType
	
	--精度最小值大于最大值， 3D那边用的是倒数
    --植被密度
	SETTINGS.nVegetationDensity = a3DEngineOption.nVegetationDensity
	
	--精度最小值大于最大值， 3D那边用的是倒数
    --地形精度
	--SETTINGS.nTerrainDetail = a3DEngineOption.nTerrainDetail
    
     CONFIG_SETTINGS[CONFIGURE_LEVEL.CUSTOM] = CONFIG_SETTINGS[CONFIGURE_LEVEL.CUSTOM] or {}
     for k, v in pairs(SETTINGS) do
        CONFIG_SETTINGS[CONFIGURE_LEVEL.CUSTOM][k] = v
     end
     CONFIG_SETTINGS[CONFIGURE_LEVEL.CUSTOM].nConfigureLevel = CONFIGURE_LEVEL.CUSTOM
end

function VideoSettingPanel.SetSettings(tSettings)
	local frame = Station.Lookup("Topmost/VideoSettingPanel")
	frame.bIniting = true    
    local wndSet3 = frame:Lookup("Wnd_Set3")
    local wndSet4 = frame:Lookup("Wnd_Set4")
    
    OBJECT.SetSetting3(wndSet3, tSettings)
    OBJECT.SetSetting4(wndSet4, tSettings)
    frame.bIniting = false
end

local function SetSetting3Enable(hWnd, bEnable)
    local nFont = 18
    if not bEnable then
        nFont = 161
    end
    
    hWnd:Lookup("Btn_FSAAB"):Enable(bEnable)
    hWnd:Lookup("CheckBox_Uniform"):Enable(bEnable)
    hWnd:Lookup("CheckBox_Ride"):Enable(bEnable)
    hWnd:Lookup("CheckBox_Weapon"):Enable(bEnable)
    
    hWnd:Lookup("", "Text_FSAATitle"):SetFontScheme(nFont)
    hWnd:Lookup("", "Text_FSAA"):SetFontScheme(nFont)
    
    local hScroll = hWnd:Lookup("Scroll_PlayerNumber")
    hScroll:Enable(bEnable)
    hScroll:Lookup("Btn_PlayerNumber"):Enable(bEnable)
    hScroll:Lookup("", "Text_Count"):SetFontScheme(nFont)
    hWnd:Lookup("", "Text_PlayerNumber"):SetFontScheme(nFont)
    
    hScroll = hWnd:Lookup("Scroll_PlayerNumber1")
    hScroll:Enable(bEnable)
    hScroll:Lookup("Btn_PlayerNumber1"):Enable(bEnable)
    hScroll:Lookup("", "Text_Count1"):SetFontScheme(nFont)
    hWnd:Lookup("", "Text_ClientSFXLimitTitle"):SetFontScheme(nFont)
end

function VideoSettingPanel.SetSetting3(hWnd, tSettings)
    local frame = hWnd:GetRoot()
    
    SetSetting3Enable(hWnd, true)
    if tSettings.nMultiSampleType ~= nil then
        local textFSAA = hWnd:Lookup("", "Text_FSAA")
		if tSettings.bFXAA then
			textFSAA.MenuValue = g_tStrings.STR_FXAA
		else
			textFSAA.MenuValue = tSettings.nMultiSampleType
		end
		
		if tSettings.bFXAA then
			textFSAA:SetText(g_tStrings.STR_FXAA)
		else
	        if tSettings.nMultiSampleType  <= 1 then
				textFSAA:SetText(g_tStrings.STR_CLOSE)
				frame:Lookup("Wnd_Set3"):Lookup("Btn_FSAAB"):Enable(not tSettings.bEnableScaleOutput)
			else
				textFSAA:SetText(tSettings.nMultiSampleType.."X")
			end	
		end
	end
    
    if tSettings.nMDLRenderLimit ~= nil then
        local hScrollPlayerN = hWnd:Lookup("Scroll_PlayerNumber")
        hScrollPlayerN:Lookup("", "Text_Count"):SetText(tSettings.nMDLRenderLimit)
        for nIndex, nPlayerNumber in ipairs(a3DEngineCaps.aMDLRenderLimit) do
            if nPlayerNumber >= tSettings.nMDLRenderLimit then
                hScrollPlayerN:SetScrollPos(nIndex - 1)
                break
            end
        end
	end
    
    if tSettings.bOptimizeUniform ~= nil then
        hWnd:Lookup("CheckBox_Uniform"):Check(tSettings.bOptimizeUniform)
    end
    
    if tSettings.bOptimizeRide ~= nil then
        hWnd:Lookup("CheckBox_Ride"):Check(tSettings.bOptimizeRide)
    end
    
    if tSettings.bOptimizeWeapon ~= nil then
        hWnd:Lookup("CheckBox_Weapon"):Check(tSettings.bOptimizeWeapon)
    end
    
    if tSettings.bOptimizeQiChang ~= nil then
        hWnd:Lookup("CheckBox_pb"):Check(tSettings.bOptimizeQiChang)
    end
    
    if tSettings.nClientSFXLimit ~= nil then
        local hScrollPlayerN1 = hWnd:Lookup("Scroll_PlayerNumber1")
        hScrollPlayerN1:Lookup("", "Text_Count1"):SetText(tSettings.nClientSFXLimit)
        for nIndex, nNumber in ipairs(a3DEngineCaps.aClientSFXLimit) do
            if nNumber >= tSettings.nClientSFXLimit then
                hScrollPlayerN1:SetScrollPos(nIndex - 1)
                break
            end
        end
    end
end

local function SetSetting4Enable(hWnd, bEnable)
    local nFont = 18
    if not bEnable then
        nFont = 161
    end
    
	hWnd:Lookup("CheckBox_RenderGrass"):Enable(bEnable)--地表细节
	hWnd:Lookup("CheckBox_GrassAnimation"):Enable(bEnable)--草地动画
	hWnd:Lookup("CheckBox_ClarityAntiAliasing"):Enable(bEnable)--混合透明渲染
	
    hWnd:Lookup("CheckBox_HDR"):Enable(bEnable)--高动态范围光照（HDR)
    hWnd:Lookup("CheckBox_ShockWave"):Enable(bEnable)--屏幕扭曲
	
	hWnd:Lookup("CheckBox_Bloom"):Enable(bEnable)--全屏柔光
	hWnd:Lookup("CheckBox_BulkLight"):Enable(bEnable)--体积光
	--hWnd:Lookup("CheckBox_MotionBlur"):Enable(bEnable)--动态模糊
    hWnd:Lookup("CheckBox_DOF"):Enable(bEnable)--景深效果
	
    local hScrollW = hWnd:Lookup("Scroll_Water")--水面精度
    hScrollW:Enable(bEnable)
	hScrollW:Lookup("Btn_SplitWater"):Enable(bEnable)
    hWnd:Lookup("", "Text_Water"):SetFontScheme(nFont)
    
	local hScrollTS = hWnd:Lookup("Scroll_TS")--贴图精度
	hScrollTS:Enable(bEnable)
	hScrollTS:Lookup("Btn_SplitTS"):Enable(bEnable)
    hWnd:Lookup("", "Title_TS"):SetFontScheme(nFont)
    
    local hScrollFSAA = hWnd:Lookup("Scroll_FSAA")--材质过滤
	hScrollFSAA:Enable(bEnable)
	hScrollFSAA:Lookup("Btn_SplitFSAA"):Enable(bEnable)
    hWnd:Lookup("", "Title_Detail"):SetFontScheme(nFont)
    
	local hScrollCD = hWnd:Lookup("Scroll_CD")--远景显示距离
	hScrollCD:Enable(bEnable)
	hScrollCD:Lookup("Btn_SplitCD"):Enable(bEnable)
    hWnd:Lookup("", "Title_CD"):SetFontScheme(nFont)
    
	local hScrollSD = hWnd:Lookup("Scroll_SD")--阴影质量
	hScrollSD:Enable(bEnable)
	hScrollSD:Lookup("Btn_SplitSD"):Enable(bEnable)
    hWnd:Lookup("", "Title_SD"):SetFontScheme(nFont)
    
	local hScrollVD = hWnd:Lookup("Scroll_VD")--植被密度
	hScrollVD:Enable(bEnable)
    hScrollVD:Lookup("Btn_SplitVD"):Enable(bEnable)
    hWnd:Lookup("", "Title_VD"):SetFontScheme(nFont)
end

function VideoSettingPanel.SetSetting4(hWnd, tSettings)
    SetSetting4Enable(hWnd, true)
    
    if tSettings.bRenderGrass ~= nil then
		hWnd:Lookup("CheckBox_RenderGrass"):Check(tSettings.bRenderGrass)--地表细节
		hWnd:Lookup("CheckBox_GrassAnimation"):Enable(tSettings.bRenderGrass)--草地动画
		hWnd:Lookup("CheckBox_ClarityAntiAliasing"):Enable(tSettings.bRenderGrass)--混合透明渲染
	end
	
	if tSettings.bRenderGrass ~= nil and tSettings.bGrassAnimation ~= nil then 
		hWnd:Lookup("CheckBox_GrassAnimation"):Check(tSettings.bGrassAnimation and tSettings.bRenderGrass)
	end
	
	if tSettings.bRenderGrass ~= nil and tSettings.bGrassAlphaBlend ~= nil then
		hWnd:Lookup("CheckBox_ClarityAntiAliasing"):Check(tSettings.bGrassAlphaBlend and tSettings.bRenderGrass)
	end
	
	if tSettings.bHDR ~= nil then
		hWnd:Lookup("CheckBox_HDR"):Check(tSettings.bHDR)--高动态范围光照（HDR)
	end
	
	if tSettings.bShockWaveEnable ~= nil then
		hWnd:Lookup("CheckBox_ShockWave"):Check(tSettings.bShockWaveEnable)--屏幕扭曲
	end
	
	if tSettings.bBloomEnable ~= nil then
		hWnd:Lookup("CheckBox_Bloom"):Check(tSettings.bBloomEnable)--全屏柔光
    end
	
	if tSettings.bGodRay ~= nil then
		hWnd:Lookup("CheckBox_BulkLight"):Check(tSettings.bGodRay)--体积光
	end
    --[[
    if tSettings.bMotionBlur ~= nil then
		hWnd:Lookup("CheckBox_MotionBlur"):Check(tSettings.bMotionBlur)--动态模糊
	end]]
	
	if tSettings.bDOF ~= nil then
        hWnd:Lookup("CheckBox_DOF"):Check(tSettings.bDOF)--景深效果
	end
	
	--if tSettings.bFlexBodySmooth ~= nil then
	--	hWnd:Lookup("CheckBox_FlexBodySmooth"):Check(tSettings.bFlexBodySmooth)--柔体平滑
	--end
	
	--水面精度
	VideoSettingPanel.SetScroll(tSettings, hWnd:Lookup("Scroll_Water"), "nWaterDetail")
	
	--贴图精度
	VideoSettingPanel.SetScroll(tSettings, hWnd:Lookup("Scroll_TS"), "nTextureScale")
	
	--材质过滤
	VideoSettingPanel.SetScroll(tSettings, hWnd:Lookup("Scroll_FSAA"), "dwMaxAnisotropy")
	
	--远景显示距离
	VideoSettingPanel.SetScroll(tSettings, hWnd:Lookup("Scroll_CD"), "fCameraDistance")
	
	--阴影质量
	VideoSettingPanel.SetScroll(tSettings, hWnd:Lookup("Scroll_SD"), "nShadowType")
	
	--植被密度
	VideoSettingPanel.SetScroll(tSettings, hWnd:Lookup("Scroll_VD"), "nVegetationDensity")
end

function VideoSettingPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif szEvent == "VIDEO_SETTINGS_UPDATE" then
		VideoSettingPanel.InitScroll(this)
		VideoSettingPanel.InitSettings(this)
		VideoSettingPanel.SetSettings(SETTINGS)
		VideoSettingPanel.UpdateOptionState(this)
		VideoSettingPanel.UpdateUIOptionEnable(this)
    
		VideoSettingPanel.SetChanged(this, false)
	end
end 

function VideoSettingPanel.UpdateOptionState(frame)
	frame.bIniting = true
	local bChange = false
    
	local wndSet2 = frame:Lookup("Wnd_Set2")
    local wndSet4 = frame:Lookup("Wnd_Set4")
    
    local fnUnCheckOption = function(hWnd, szName)
        local hCheck = hWnd:Lookup(szName)
        hCheck:Enable(false)
        hCheck:Check(false)
    end
    
    local UpdateCheck = function(hWnd, szKey, szName, tCaps)
        if not tCaps then
            tCaps = a3DEngineCaps
        end
        
        if not tCaps[szKey] then
            fnUnCheckOption(hWnd, szName)
        end
    end
    
    UpdateCheck(wndSet4, "bRenderGrassEnable", "CheckBox_RenderGrass")
    UpdateCheck(wndSet4, "bGrassAnimationEnable", "CheckBox_GrassAnimation")
	UpdateCheck(wndSet4, "bGrassAlphaBlendEnable", "CheckBox_ClarityAntiAliasing")
	
    if a3DEngineCaps.bPostEffectEnable then
        local Option = KG3DEngine.Get3DEngineOption()
        Option.bPostEffectEnable = true
        local Caps = KG3DEngine.Get3DEngineOptionCaps(Option)
        
        UpdateCheck(wndSet4, "bShockWaveEnable", "CheckBox_ShockWave", Caps)
        UpdateCheck(wndSet4, "bBloomEnable", "CheckBox_Bloom", Caps)
        UpdateCheck(wndSet4, "bGodRayEnable", "CheckBox_BulkLight", Caps)
        --UpdateCheck(wndSet4, "bMotionBlurEnable", "CheckBox_MotionBlur", Caps)
        UpdateCheck(wndSet4, "bHDREnable", "CheckBox_HDR", Caps)
        UpdateCheck(wndSet4, "bDOFEnable", "CheckBox_DOF", Caps)
    else
        fnUnCheckOption(wndSet4, "CheckBox_ShockWave")
        fnUnCheckOption(wndSet4, "CheckBox_Bloom")
        fnUnCheckOption(wndSet4, "CheckBox_BulkLight")
        --fnUnCheckOption(wndSet4, "CheckBox_MotionBlur")
        fnUnCheckOption(wndSet4, "CheckBox_HDR")
        fnUnCheckOption(wndSet4, "CheckBox_DOF")
	end
	
    local aShadowEnableMap =
    {
        [0] = a3DEngineCaps.bShadowNoneEnable,
        [1] = a3DEngineCaps.bShadowLowEnable,
        [2] = a3DEngineCaps.bShadowMiddleEanble,
        [3] = a3DEngineCaps.bShadowHighEnable,
    }
    local hScrollSD = wndSet4:Lookup("Scroll_SD")
    local nShadowType = VideoSettingPanel.GetScrollValue(hScrollSD, "nShadowType") 
    if not aShadowEnableMap[nShadowType] then
        if 0 ~= a3DEngineOption.nShadowType then
            a3DEngineOption.nShadowType = 0
            bChange = true
        end
        hScrollSD:SetScrollPos(0)
    end
	
    local wndSet3 = frame:Lookup("Wnd_Set3")
    local textFSAA = wndSet3:Lookup("", "Text_FSAA")
    if not SETTINGS.bFXAA and SETTINGS.nMultiSampleType ~= textFSAA.MenuValue then
        if SETTINGS.nMultiSampleType <= 1 then
            textFSAA:SetText(g_tStrings.STR_CLOSE)
        else
            textFSAA:SetText(SETTINGS.nMultiSampleType.."X")
        end
    end
    
    if bChange then
        KG3DEngine.Set3DEngineOption(a3DEngineOption)
        VideoSettingPanel.InitSettings(frame)
    end
    
	frame.bIniting = false
end

function VideoSettingPanel.UpdateUIOptionEnable(frame)
    frame.bIniting = true
    
    local wndSet3 = frame:Lookup("Wnd_Set3")
    local wndSet4 = frame:Lookup("Wnd_Set4")
    
    local UpdateCheck = function(hWnd, szKey, szName)
        if not IsUIEnable(szKey) then
            local hCheck = hWnd:Lookup(szName)
            hCheck:Enable(false)
            hCheck:Check(false)
        end
    end
    
    local UpdatePopuMenuBtn = function(hWnd, szKey, szName)
        if not IsUIEnable(szKey) then
            local hBtn = hWnd:Lookup(szName)
            hBtn:Enable(false)
        end
    end
    
    local UpdateScroll = function(hWnd, szKey, szName, szBtn, bEnd)
        if not IsUIEnable(szKey) then
            local hScroll = hWnd:Lookup(szName)
            hScroll:Enable(false)
            hScroll:Lookup(szBtn):Enable(false)
            hScroll:SetScrollPos(0)
            if bEnd then
                hScroll:SetScrollPos(hScroll:GetStepCount())
            end
        end
    end
    	
    UpdatePopuMenuBtn(wndSet3, "nMultiSampleType", "Btn_FSAAB")
    UpdateScroll(wndSet3, "nMDLRenderLimit", "Scroll_PlayerNumber", "Btn_PlayerNumber", true)
    UpdateScroll(wndSet3, "nClientSFXLimit", "Scroll_PlayerNumber1", "Btn_PlayerNumber1", true)
    
    UpdateCheck(wndSet3, "bOptimizeUniform", "CheckBox_Uniform")
    UpdateCheck(wndSet3, "bOptimizeRide", "CheckBox_Ride")
    UpdateCheck(wndSet3, "bOptimizeWeapon", "CheckBox_Weapon")
    UpdateCheck(wndSet3, "bOptimizeQiChang", "CheckBox_pb")
    
    UpdateCheck(wndSet4, "bRenderGrass", "CheckBox_RenderGrass")
    UpdateCheck(wndSet4, "bGrassAnimation", "CheckBox_GrassAnimation")
    UpdateCheck(wndSet4, "bGrassAlphaBlend", "CheckBox_ClarityAntiAliasing")
    UpdateCheck(wndSet4, "bHDR", "CheckBox_HDR")
    UpdateCheck(wndSet4, "bShockWaveEnable", "CheckBox_ShockWave")
    UpdateCheck(wndSet4, "bBloomEnable", "CheckBox_Bloom")
    UpdateCheck(wndSet4, "bGodRay", "CheckBox_BulkLight")
    --UpdateCheck(wndSet4, "bMotionBlur", "CheckBox_MotionBlur")
    UpdateCheck(wndSet4, "bDOF", "CheckBox_DOF")
    
    UpdateScroll(wndSet4, "nWaterDetail", "Scroll_Water", "Btn_SplitWater")
    UpdateScroll(wndSet4, "nTextureScale", "Scroll_TS", "Btn_SplitTS")
    UpdateScroll(wndSet4, "dwMaxAnisotropy", "Scroll_FSAA", "Btn_SplitFSAA")
    UpdateScroll(wndSet4, "fCameraDistance", "Scroll_CD", "Btn_SplitCD")
    UpdateScroll(wndSet4, "nShadowType", "Scroll_SD", "Btn_SplitSD")
    UpdateScroll(wndSet4, "nVegetationDensity", "Scroll_VD", "Btn_SplitVD")
	
    frame.bIniting = false
end

function VideoSettingPanel.OnScrollBarPosChanged()
	if this.bAdjust then
		return
	end
	
	local frame = this:GetRoot()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	
	if szName == "Scroll_PlayerNumber" then
		local nPlayerNumber = a3DEngineCaps.aMDLRenderLimit[nCurrentValue + 1]
		this:Lookup("", "Text_Count"):SetText(nPlayerNumber)
    elseif szName == "Scroll_PlayerNumber1" then
		local nPlayerNumber = a3DEngineCaps.aClientSFXLimit[nCurrentValue + 1]
		this:Lookup("", "Text_Count1"):SetText(nPlayerNumber)
    end
	
    if frame.bIniting then
		return
	end
	
	VideoSettingPanel.SetChanged(frame, true)
end

function VideoSettingPanel.CheckOption(frame, szName)
    frame.bIniting = true
    
	local nLevel	
	if szName == "CheckBox_Lowmost" then
		nLevel = CONFIGURE_LEVEL.LOW_MOST
    elseif szName == "CheckBox_Low" then
		nLevel = CONFIGURE_LEVEL.LOW
	elseif szName == "CheckBox_Medium" then
		nLevel = CONFIGURE_LEVEL.MEDIUM
	elseif szName == "CheckBox_Advanced" then 
		nLevel = CONFIGURE_LEVEL.HIGH
	elseif szName == "CheckBox_Perfect" then
		nLevel = CONFIGURE_LEVEL.PERFECTION
	elseif szName == "CheckBox_Custom" then
		nLevel = CONFIGURE_LEVEL.CUSTOM
	end
	
    if nLevel ~= CONFIGURE_LEVEL.CUSTOM then
        VideoSettingPanel.SetSettings(CONFIG_SETTINGS[CONFIGURE_LEVEL.CUSTOM])
    end
    VideoSettingPanel.SetSettings(CONFIG_SETTINGS[nLevel])
    VideoSettingPanel.UpdateUIOptionEnable(frame)
	
    frame.bIniting = false
end

function VideoSettingPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local frame = this:GetRoot()
	
	if frame.bIniting then
		return
	end
	
	if szName == "CheckBox_RenderGrass" then
		local wndRender = this:GetParent()
		wndRender:Lookup("CheckBox_GrassAnimation"):Enable(true)
		wndRender:Lookup("CheckBox_ClarityAntiAliasing"):Enable(true)
		
		wndRender:Lookup("CheckBox_GrassAnimation"):Check(a3DEngineOption.bGrassAnimation)
		wndRender:Lookup("CheckBox_ClarityAntiAliasing"):Check(a3DEngineOption.bGrassAlphaBlend)
		
	elseif szName == "CheckBox_Lowmost" or szName == "CheckBox_Low" or szName == "CheckBox_Medium" or 
           szName == "CheckBox_Advanced" or  szName == "CheckBox_Perfect" or szName == "CheckBox_Custom" then
		OBJECT.CheckOption(frame, szName)
        
    elseif szName == "CheckBox_Bloom" then
        local wndSet4 = frame:Lookup("Wnd_Set4")
        wndSet4:Lookup("CheckBox_BulkLight"):Check(false)
    elseif szName == "CheckBox_BulkLight" then
        local wndSet4 = frame:Lookup("Wnd_Set4")
        wndSet4:Lookup("CheckBox_Bloom"):Check(false)
	end
	
	VideoSettingPanel.SetChanged(frame, true)
end

function VideoSettingPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	local frame = this:GetRoot()
    
	if frame.bIniting then
		return
	end
	
	if szName == "CheckBox_RenderGrass" then
        local wndRender = frame:Lookup("Wnd_Set4")
		wndRender:Lookup("CheckBox_GrassAnimation"):Enable(false)
		wndRender:Lookup("CheckBox_ClarityAntiAliasing"):Enable(false)
		
		wndRender:Lookup("CheckBox_GrassAnimation"):Check(false)
		wndRender:Lookup("CheckBox_ClarityAntiAliasing"):Check(false)
	end
	
	VideoSettingPanel.SetChanged(frame, true)
end

function VideoSettingPanel.IsNeedToRestart(frame)	
	local wndSet4 = frame:Lookup("Wnd_Set4")
	
	-- local bCheck = wndRender:Lookup("CheckBox_FlexBodySmooth"):IsCheckBoxChecked()
	-- if a3DEngineOption.bFlexBodySmooth ~=  bCheck then
	--	return true
	-- end
	
	local hScroll = wndSet4:Lookup("Scroll_TS")
	local nTextureScale = VideoSettingPanel.GetScrollValue(hScroll, "nTextureScale")
	if a3DEngineOption.nTextureScale ~=  nTextureScale then
		return true
	end
	
	return false
end

function VideoSettingPanel.NotifyNeedRestart()
	local msg =
	{
		szMessage = g_tStrings.STR_NEED_RESTART,
		szName = "Set3DEngineSetting",
		{szOption = g_tStrings.STR_HOTKEY_SURE},
	}
	MessageBox(msg)
end

function VideoSettingPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Cancel" then
		CloseVideoSettingPanel()
	elseif szName == "Btn_Default" then
        local frame = this:GetRoot()
        local tDefault = CONFIG_SETTINGS[CONFIGURE_LEVEL.DEFAULT]
        VideoSettingPanel.SetSettings(tDefault)
		VideoSettingPanel.UpdateUIOptionEnable(frame)
            
        VideoSettingPanel.SetChanged(this:GetRoot(), true)
        
	elseif szName == "Btn_Sure" then
		local frame = this:GetRoot()
		
		if frame:Lookup("Btn_Apply"):IsEnabled() then
			local bNeedRestart = VideoSettingPanel.IsNeedToRestart(frame)
			VideoSettingPanel.SaveSettings(frame)
			if bNeedRestart then
				VideoSettingPanel.NotifyNeedRestart()
			end
			FireEvent("VIDEO_CONFIG_CHANGED")
		end
		CloseVideoSettingPanel()
	elseif szName == "Btn_Apply" then
		local frame = this:GetRoot()
		local bNeedRestart = VideoSettingPanel.IsNeedToRestart(frame)
		OBJECT.SaveSettings(frame)
		OBJECT.InitSettings(frame)
		OBJECT.UpdateOptionState(frame)
        OBJECT.UpdateUIOptionEnable(frame)
		
		if bNeedRestart then
			VideoSettingPanel.NotifyNeedRestart()
		end
		VideoSettingPanel.SetChanged(frame, false)
        FireEvent("VIDEO_CONFIG_CHANGED")
	end
end

function VideoSettingPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_FSAAB" then
		if not this:IsEnabled() then
			return
		end
		local frame = this:GetRoot();
		local function fnChange()
			VideoSettingPanel.SetChanged(frame, true)
		end
		
		local tData = {{name = g_tStrings.STR_CLOSE, value = 0}, fnAction=fnChange}
		for k, v in ipairs(a3DEngineCaps.aMultiSampleType) do
			if v ~= 1 then
				table.insert(tData, {name = v.."X", value = v, fnAction=fnChange})
			end
		end
		table.insert(tData, {name = g_tStrings.STR_FXAA, value = g_tStrings.STR_FXAA, fnAction=fnChange})
		local text = this:GetParent():Lookup("", "Text_FSAA")
		PopupMenuEx(this, tData, IsVideoSettingPanelOpened, text)
		return true
	end
end

function VideoSettingPanel.SaveSettings(frame)
	local wndSet1 = frame:Lookup("Wnd_Set1")
	local tSettingBasic = VideoSettingPanel.SaveBasicSettings(frame)
	local tSettingRender = VideoSettingPanel.SaveRenderSettings(frame)
    
	-- nMultiSampleType 在vdieosetting里， fxaa在 option里
	tSettingRender.bFXAA = tSettingBasic.bFXAA 
	tSettingRender.nFXAALevel = tSettingBasic.nFXAALevel or a3DEngineOption.nFXAALevel
	
	-- 抗锯齿开的时候， 开了高级渲染， 阴影低以下  会黑屏  排除这种情况
	--assert(tSettingBasic.bFXAA and tSettingBasic.nMultiSampleType ~= 0)
    if tSettingBasic.nMultiSampleType ~= 0 and (tSettingRender.bPostEffectEnable and tSettingRender.nShadowType <= 1) then
        tSettingBasic.nMultiSampleType = 0
    end
    
    VideoSettingPanel_SaveBasic(tSettingBasic)
    VideoSettingPanel_SaveRender(tSettingRender)
end

function VideoSettingPanel.SaveBasicSettings(frame)
    local wndSet3 = frame:Lookup("Wnd_Set3")
    local tSettings = {} 

	local textFSAA = wndSet3:Lookup("", "Text_FSAA")
	if textFSAA.MenuValue == g_tStrings.STR_FXAA then
		tSettings.nMultiSampleType = 0
		tSettings.bFXAA = true
	else
		tSettings.bFXAA = false
		tSettings.nMultiSampleType = textFSAA.MenuValue
	end

    tSettings.bOptimizeUniform = wndSet3:Lookup("CheckBox_Uniform"):IsCheckBoxChecked()
    tSettings.bOptimizeRide = wndSet3:Lookup("CheckBox_Ride"):IsCheckBoxChecked()
    tSettings.bOptimizeWeapon = wndSet3:Lookup("CheckBox_Weapon"):IsCheckBoxChecked() 
    tSettings.bOptimizeQiChang = wndSet3:Lookup("CheckBox_pb"):IsCheckBoxChecked() 
    return tSettings
end

function VideoSettingPanel_SaveBasic(tSettings)
    local tVideoSet = GetVideoSettings()
    if IsUIEnable("bFullScreen") and tSettings.bFullScreen ~= nil then
        tVideoSet.FullScreen = tSettings.bFullScreen
    end
    
    if IsUIEnable("bPanauision") and tSettings.bPanauision ~= nil then
        tVideoSet.Panauision = tSettings.bPanauision
    end
    
    if IsUIEnable("bExclusiveMode") and tSettings.bExclusiveMode ~= nil then
        tVideoSet.ExclusiveMode = tSettings.bExclusiveMode
    end
    
    if IsUIEnable("nWidth") and IsUIEnable("nHeight") and tSettings.nWidth ~= nil and tSettings.nHeight ~= nil then
        tVideoSet.Width = tSettings.nWidth
        tVideoSet.Height = tSettings.nHeight
    end
	
    if tSettings.nMultiSampleType ~= nil then
        tVideoSet.MultiSampleType = tSettings.nMultiSampleType
	end
    
	if tVideoSet.FullScreen and not tVideoSet.ExclusiveMode and tSettings.Panauision then
		tVideoSet.Height = tVideoSet.Width * 9 / 16
	end
	SetVideoSettings(tVideoSet)
    
    if IsUIEnable("bOptimizeUniform") and tSettings.bOptimizeUniform ~= nil then
        VideoSettingPanel.bOptimizeUniform = tSettings.bOptimizeUniform 
        if tSettings.bOptimizeUniform then
            rlcmd("uniform optimization on")
            rlcmd("disable animation blend")
        else
            rlcmd("uniform optimization off")
            rlcmd("enable animation blend")
        end
	end
    
    if IsUIEnable("bOptimizeRide") and tSettings.bOptimizeRide ~= nil then
        VideoSettingPanel.bOptimizeRide = tSettings.bOptimizeRide 
        if tSettings.bOptimizeRide then
            rlcmd("rides optimization on")
        else
            rlcmd("rides optimization off")
        end
	end
    
    if IsUIEnable("bOptimizeRide") and tSettings.bOptimizeWeapon ~= nil then
        VideoSettingPanel.bOptimizeWeapon = tSettings.bOptimizeWeapon 
        if tSettings.bOptimizeWeapon then
            rlcmd("weapon optimization on")
        else
            rlcmd("weapon optimization off")
        end
    end
    
    if IsUIEnable("bOptimizeQiChang") and tSettings.bOptimizeQiChang ~= nil then
        VideoSettingPanel.bOptimizeQiChang = tSettings.bOptimizeQiChang 
        if tSettings.bOptimizeQiChang then
            rlcmd("npc filter on 1")
            rlcmd("npc filter on 2")
        else
            rlcmd("npc filter off 1")
            rlcmd("npc filter off 2")
        end
    end
end

function VideoSettingPanel.SaveRenderSettings(frame)
	--local wndSet2 = frame:Lookup("Wnd_Set2")
    local wndSet3 = frame:Lookup("Wnd_Set3")
    local wndSet4 = frame:Lookup("Wnd_Set4")
	
    local tSettings = {}
    local SetValue=function(hWnd, szKey, szName)
        tSettings[szKey] = hWnd:Lookup(szName):IsCheckBoxChecked()
    end
    
    local hScrollPlayerNumber = wndSet3:Lookup("Scroll_PlayerNumber")
    local nPos = hScrollPlayerNumber:GetScrollPos()
    local nPlayerNumber = a3DEngineCaps.aMDLRenderLimit[nPos + 1]
    tSettings.nMDLRenderLimit = nPlayerNumber
    
    local hScrollPlayerNumber1 = wndSet3:Lookup("Scroll_PlayerNumber1")
    nPos = hScrollPlayerNumber1:GetScrollPos()
    nPlayerNumber = a3DEngineCaps.aClientSFXLimit[nPos + 1]
    tSettings.nClientSFXLimit = nPlayerNumber
    
    SetValue(wndSet4, "bRenderGrass", "CheckBox_RenderGrass")
    SetValue(wndSet4, "bGrassAnimation", "CheckBox_GrassAnimation")
    SetValue(wndSet4, "bGrassAlphaBlend", "CheckBox_ClarityAntiAliasing")
        
    SetValue(wndSet4, "bHDR", "CheckBox_HDR")
    SetValue(wndSet4, "bDOF", "CheckBox_DOF")
    SetValue(wndSet4, "bShockWaveEnable", "CheckBox_ShockWave")
    SetValue(wndSet4, "bBloomEnable", "CheckBox_Bloom")
    SetValue(wndSet4, "bGodRay", "CheckBox_BulkLight")

    local hScroll = wndSet4:Lookup("Scroll_SD")
    local nShadowType = VideoSettingPanel.GetScrollValue(hScroll, "nShadowType")
    tSettings.nShadowType = nShadowType
    
    local hScroll = wndSet4:Lookup("Scroll_Water")
    tSettings.nWaterDetail = VideoSettingPanel.GetScrollValue(hScroll, "nWaterDetail")

    local hScroll = wndSet4:Lookup("Scroll_TS")
    tSettings.nTextureScale = VideoSettingPanel.GetScrollValue(hScroll, "nTextureScale")
    
    local hScroll = wndSet4:Lookup("Scroll_CD")
    tSettings.fCameraDistance = VideoSettingPanel.GetScrollValue(hScroll, "fCameraDistance")
	
    local hScroll = wndSet4:Lookup("Scroll_FSAA")
    tSettings.dwMaxAnisotropy = VideoSettingPanel.GetScrollValue(hScroll, "dwMaxAnisotropy")

    hScroll = wndSet4:Lookup("Scroll_VD")
    tSettings.nVegetationDensity = VideoSettingPanel.GetScrollValue(hScroll, "nVegetationDensity")

	--高级渲染的子项来判断bPostEffectEnable（高级渲染）是否有开启
    tSettings.bPostEffectEnable = false
	if tSettings.bShockWaveEnable or tSettings.bBloomEnable or tSettings.bGodRay or 
	   tSettings.bMotionBlur or tSettings.bHDR or tSettings.bDOF then
		tSettings.bPostEffectEnable = true	
	end
    
    return tSettings
end

function VideoSettingPanel_SaveRender(tSettings)
    local SetValue=function(szKey)
        if IsUIEnable(szKey) and tSettings[szKey] ~= nil then
            a3DEngineOption[szKey] = tSettings[szKey]
        end
    end
    
    SetValue("nMDLRenderLimit")
    SetValue("nClientSFXLimit")
    SetValue("bRenderGrass")
    
    if a3DEngineOption.bRenderGrass then
        SetValue("bGrassAnimation")
        SetValue("bGrassAlphaBlend")
    end
    SetValue("bHDR")
    SetValue("bDOF")
    SetValue("bShockWaveEnable")
    SetValue("bBloomEnable")
    SetValue("bGodRay")
    --SetValue("bMotionBlur")
	SetValue("bFXAA")
	SetValue("nFXAALevel")
    
    SetValue("bEnableScaleOutput")
    if a3DEngineOption.bEnableScaleOutput then
        SetValue("bScaleOutputSmooth")
        SetValue("nScaleOutputSize")
    end
    
    if not IsUIEnable("bEnableScaleOutput") then
        a3DEngineOption.bEnableScaleOutput = false
    end
	
    if not IsUIEnable("bScaleOutputSmooth") then
        a3DEngineOption.bScaleOutputSmooth = false
    end
	
	
    SetValue("nShadowType")
    SetValue("nWaterDetail")
    SetValue("nTextureScale")
    SetValue("fCameraDistance")
    SetValue("dwMaxAnisotropy")
    SetValue("nForceShaderModel")
    SetValue("nForceShaderModel")
    --SetValue("nTerrainDetail")

    SetValue("nVegetationDensity")
    --SetValue("fCameraAngle")

	--高级渲染的子项来判断bPostEffectEnable（高级渲染）是否有开启
    a3DEngineOption.bPostEffectEnable = false
	if a3DEngineOption.bShockWaveEnable or a3DEngineOption.bBloomEnable or a3DEngineOption.bGodRay or 
	   a3DEngineOption.bMotionBlur or a3DEngineOption.bHDR or a3DEngineOption.bDOF or a3DEngineOption.nShadowType > 1 or 
	   a3DEngineOption.bFXAA then
		a3DEngineOption.bPostEffectEnable = true	
	end
	KG3DEngine.Set3DEngineOption(a3DEngineOption)
end

function VideoSettingPanel_SaveSettings(tSettings)
	a3DEngineOption = KG3DEngine.Get3DEngineOption()
	local bNeedRestart = false
	if tSettings.nTextureScale ~= nil then
		bNeedRestart = a3DEngineOption.nTextureScale ~= tSettings.nTextureScale
	end
	
    VideoSettingPanel_SaveBasic(tSettings)
    VideoSettingPanel_SaveRender(tSettings)
	if bNeedRestart then
		VideoSettingPanel.NotifyNeedRestart()
	end
end

function VideoSettingPanel.SetChanged(frame, bChanged)
	frame.bChanged = bChanged
	frame:Lookup("Btn_Apply"):Enable(frame.bChanged)
end

function VideoSettingPanel.ConvertVersion(nVersion)
	if CURRENT_VERSION == 5 and CURRENT_VERSION ~= nVersion then
		
		a3DEngineOption = KG3DEngine.Get3DEngineOption()
		a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
		if not a3DEngineOption.bMotionBlur or a3DEngineOption.nForceShaderModel ~= 0 then
			a3DEngineOption.bMotionBlur = false
			a3DEngineOption.nForceShaderModel = 0
			KG3DEngine.Set3DEngineOption(a3DEngineOption)
		end
	end
	
	if CURRENT_VERSION == 4 and CURRENT_VERSION ~= nVersion then
		a3DEngineOption = KG3DEngine.Get3DEngineOption()
		a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
		local fCameraAngle = a3DEngineOption.fCameraAngle
		fCameraAngle = math.min(fCameraAngle, a3DEngineCaps.fMaxCameraAngle)
		fCameraAngle = math.max(fCameraAngle, a3DEngineCaps.fMinCameraAngle)
		if a3DEngineOption.fCameraAngle ~= fCameraAngle then
			a3DEngineOption.fCameraAngle = fCameraAngle
			KG3DEngine.Set3DEngineOption(a3DEngineOption)
		end
	end
	
	if CURRENT_VERSION == 3 and CURRENT_VERSION ~= nVersion then
		a3DEngineOption = KG3DEngine.Get3DEngineOption()
		if not a3DEngineOption.bFXAA and VideoSettingPanel.nConfigureLevel == CONFIGURE_LEVEL.HIGH then
		   
			local aVideoSettings = GetVideoSettings()
			aVideoSettings.MultiSampleType = 0
			SetVideoSettings(aVideoSettings)
			
			a3DEngineOption.bFXAA = true
			KG3DEngine.Set3DEngineOption(a3DEngineOption)
		end
    end
	
    if CURRENT_VERSION == 1 or CURRENT_VERSION == 2 then
        if nVersion == 0 then
            VideoSettingPanel.nConfigureLevel = CONFIGURE_LEVEL.CUSTOM
        end
	end
end

--=================================================================
function OpenVideoSettingPanel(bDisableSound)
	if IsVideoSettingPanelOpened() then
		return
	end
	
	Wnd.OpenWindow("VideoSettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseVideoSettingPanel(bDisableSound)
	if not IsVideoSettingPanelOpened() then
		return
	end
	Wnd.CloseWindow("VideoSettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsVideoSettingPanelOpened()
	local frame = Station.Lookup("Topmost/VideoSettingPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

RegisterCustomData("EnaterGlobal\\VideoSettingPanel.bOptimizeUniform")
RegisterCustomData("EnaterGlobal\\VideoSettingPanel.bOptimizeRide")
RegisterCustomData("EnaterGlobal\\VideoSettingPanel.bOptimizeWeapon")
RegisterCustomData("EnaterGlobal\\VideoSettingPanel.bOptimizeQiChang")
RegisterCustomData("EnaterGlobal\\VideoSettingPanel.nVersion")

function SaveVideoSetting()
	-- global
	szIniFile = "config.ini"
	iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end
    
	local settings = GetVideoSettings()
	local x, y = Station.GetWindowPosition()
	if iniS then
		iniS:WriteInteger("Main", "CanvasWidth", settings.Width)
		iniS:WriteInteger("Main", "CanvasHeight", settings.Height)
		iniS:WriteInteger("Main", "FullScreen", settings.FullScreen)
		iniS:WriteInteger("Main", "Panauision", settings.Panauision)
		iniS:WriteInteger("Main", "ExclusiveMode", settings.ExclusiveMode)
		iniS:WriteInteger("Main", "Maximize", settings.Maximize)
		iniS:WriteInteger("Main", "RefreshRate", settings.RefreshRate)
		iniS:WriteInteger("Main", "X", x)
		iniS:WriteInteger("Main", "Y", y)
		
		iniS:WriteInteger("KG3DENGINE", "MultiSampleType", settings.MultiSampleType)
		iniS:WriteInteger("KG3DENGINE", "MultiSampleQuality", settings.MultiSampleQuality)
		iniS:WriteInteger("KG3DENGINE", "TripleBuffering", settings.TripleBuffering)
		iniS:WriteInteger("KG3DENGINE", "VSync", settings.VSync)
		iniS:WriteInteger("KG3DENGINE", "ColorDepth", settings.ColorDepth)
		
		iniS:Save(szIniFile)
		iniS:Close()
	end
end

function VideoSettingPanel_GetConfigLevel()
    return VideoSettingPanel.nConfigureLevel
end

AddSaveSettingFunction(SaveVideoSetting)

function VideoSettingPanel_InitOptimize()
	if VideoSettingPanel.bOptimizeUniform == 1 or VideoSettingPanel.bOptimizeUniform == true then
		rlcmd("uniform optimization on")
		rlcmd("disable animation blend")
	else
		rlcmd("uniform optimization off")
		rlcmd("enable animation blend")
	end
		
	if VideoSettingPanel.bOptimizeRide == 1 or VideoSettingPanel.bOptimizeRide == true then
		rlcmd("rides optimization on")
	else
		rlcmd("rides optimization off")
	end
	
	if VideoSettingPanel.bOptimizeWeapon == 1 or VideoSettingPanel.bOptimizeWeapon == true then
		rlcmd("weapon optimization on")
	else
		rlcmd("weapon optimization off")
	end
    
	if VideoSettingPanel.bOptimizeQiChang == 1 or VideoSettingPanel.bOptimizeQiChang == true then
		rlcmd("npc filter on 1")
    rlcmd("npc filter on 2")
	else
		rlcmd("npc filter off 1")
    rlcmd("npc filter off 2")
	end
end

local function OnCustomDataLoad()
    if arg0 == "EnaterGlobal" then
        VideoSettingPanel.ConvertVersion(VideoSettingPanel.nVersion)
        VideoSettingPanel.nVersion = CURRENT_VERSION
        VideoSettingPanel_InitOptimize()
    end
end

RegisterEvent("CUSTOM_DATA_LOADED", OnCustomDataLoad)
RegisterEvent("PLAYER_ENTER_GAME", VideoSettingPanel_InitOptimize)
