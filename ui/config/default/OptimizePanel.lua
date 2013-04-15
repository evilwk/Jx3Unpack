local a3DEngineOption = {}
local a3DEngineCaps = {}
	
OptimizePanel = {}

RegisterCustomData("Account\\OptimizePanel.bNotShowOptimizeTip")

local ENGINE_SETTING = {}

local function IsOptimizePanelOpened()
	local frame = Station.Lookup("Normal/OptimizePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

local function CloseOptimizePanel()
	if not IsOptimizePanelOpened() then
		return
	end
	
	Wnd.CloseWindow("OptimizePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function OptimizePanel.OnFrameCreate()
	this:Lookup("", "Text_Tip"):SetText(g_tStrings.STR_SETTING_FPS_TOO_LOW)
	this:Lookup("CheckBox_NoRemind"):Check(OptimizePanel.bNotShowOptimizeTip)
end

function OptimizePanel.InitSettings()
	a3DEngineOption = KG3DEngine.Get3DEngineOption()
	a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
		
	ENGINE_SETTING.bBloomEnable = false  --全屏柔光
	ENGINE_SETTING.bShockWaveEnable = false --屏幕扭曲
	ENGINE_SETTING.bGodRay = false		--体积光
	ENGINE_SETTING.bHDR = false --高动态范围光照
	ENGINE_SETTING.bDOF = false --景深效果
	ENGINE_SETTING.bMotionBlur = false	--动态模糊
	ENGINE_SETTING.bFlexBodySmooth =false --柔体平滑
	ENGINE_SETTING.nWaterDetail = a3DEngineCaps.nMinWaterDetail	    --水面精度
	ENGINE_SETTING.nVegetationDensity = a3DEngineCaps.nMinVegetationDensity --植被密度 min(8)
	ENGINE_SETTING.nShadowType = 0 		--阴影
	ENGINE_SETTING.dwMaxAnisotropy = a3DEngineCaps.dwMinAnisotropy    --材质过滤
	ENGINE_SETTING.bRenderGrass = false    --地表细节
	ENGINE_SETTING.fCameraDistance = a3DEngineCaps.fMinCameraDistance    --远景显示
	ENGINE_SETTING.bGrassAnimation = false --草地动画
	ENGINE_SETTING.bGrassAlphaBlend = false --透明混合渲染
	ENGINE_SETTING.nTextureScale = a3DEngineCaps.nMinTextureScale --贴图精度
	
	ENGINE_SETTING.nMultiSampleType = 0--抗锯齿
end

function OptimizePanel.OnEvent(szEvent)
	if szEvent == "OPTIMIZATION_HINT" then
		if OptimizePanel.bAlreadyActiveTip then
			return
		end
		
		OptimizePanel.InitSettings()
		if OptimizePanel.IsNeedChangeSetting(ENGINE_SETTING) then
			OpenOptimizePanel()
			OptimizePanel.bAlreadyActiveTip = true
		end	
	end
end

function OptimizePanel.IsNeedChangeSetting(tSetting)
	local Settings = GetVideoSettings()
	
	if a3DEngineOption.bBloomEnable ~= tSetting.bBloomEnable or 
	   a3DEngineOption.bShockWaveEnable ~= tSetting.bShockWaveEnable or
	   a3DEngineOption.bGodRay ~= tSetting.bGodRay or
	   a3DEngineOption.bHDR ~= tSetting.bHDR or   
	   a3DEngineOption.bDOF ~= tSetting.bDOF or
	   a3DEngineOption.bMotionBlur ~= tSetting.bMotionBlur or
	   a3DEngineOption.bFlexBodySmooth ~= tSetting.bFlexBodySmooth or
	   a3DEngineOption.nWaterDetail ~= tSetting.nWaterDetail or
	   a3DEngineOption.nVegetationDensity ~= tSetting.nVegetationDensity or
	   a3DEngineOption.nShadowType ~= tSetting.nShadowType or
	   a3DEngineOption.dwMaxAnisotropy ~= tSetting.dwMaxAnisotropy or
	   a3DEngineOption.bRenderGrass ~= tSetting.bRenderGrass or
	   a3DEngineOption.fCameraDistance ~= tSetting.fCameraDistance or
	   a3DEngineOption.bGrassAnimation ~= tSetting.bGrassAnimation or
	   a3DEngineOption.bGrassAlphaBlend ~= tSetting.bGrassAlphaBlend or
	   a3DEngineOption.nTextureScale ~= tSetting.nTextureScale or
	   Settings.MultiSampleType ~= tSetting.nMultiSampleType then
	   return true
	end
	return false
end

function OptimizePanel.SaveSetting(tSetting)
	a3DEngineOption.bPostEffectEnable = false
	a3DEngineOption.bBloomEnable = tSetting.bBloomEnable  --全屏柔光
	a3DEngineOption.bShockWaveEnable = tSetting.bShockWaveEnable --屏幕扭曲
	a3DEngineOption.bGodRay = tSetting.bGodRay		--体积光
	a3DEngineOption.bHDR = tSetting.bHDR
	a3DEngineOption.bDOF = tSetting.bDOF
	a3DEngineOption.bMotionBlur = tSetting.bMotionBlur	--动态模糊
	a3DEngineOption.bFlexBodySmooth = tSetting.bFlexBodySmooth --柔体平滑
	a3DEngineOption.nWaterDetail = tSetting.nWaterDetail    --水面精度
	a3DEngineOption.nVegetationDensity = tSetting.nVegetationDensity --植被密度 min(8)
	a3DEngineOption.nShadowType = tSetting.nShadowType 		--阴影
	a3DEngineOption.dwMaxAnisotropy = tSetting.dwMaxAnisotropy    --材质过滤
	a3DEngineOption.bRenderGrass = tSetting.bRenderGrass    --地表细节
	a3DEngineOption.fCameraDistance = tSetting.fCameraDistance    --远景显示
	a3DEngineOption.bGrassAnimation = tSetting.bGrassAnimation --草地动画
	a3DEngineOption.bGrassAlphaBlend = tSetting.bGrassAlphaBlend --透明混合渲染
	
	local bNeedNotice = false
	if a3DEngineOption.nTextureScale ~= tSetting.nTextureScale then
		a3DEngineOption.nTextureScale = tSetting.nTextureScale --贴图精度
		bNeedNotice = true
	end
	   
	KG3DEngine.Set3DEngineOption(a3DEngineOption)
	
	local Settings = GetVideoSettings()
	Settings.MultiSampleType = tSetting.nMultiSampleType
	SetVideoSettings(Settings)
	
	VideoSettingPanel.nConfigureLevel = CONFIGURE_LEVEL.CUSTOM
	FireEvent("VIDEO_SETTINGS_UPDATE")
	
	if bNeedNotice then
		local msg =
		{
			szMessage = g_tStrings.STR_NEED_RESTART,
			szName = "Set3DEngineSetting",
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(msg)
	end
end

function OptimizePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local frame = this:GetRoot()
		local bChecked = frame:Lookup("CheckBox_NoRemind"):IsCheckBoxChecked()
		OptimizePanel.bNotShowOptimizeTip = bChecked
		OptimizePanel.SaveSetting(ENGINE_SETTING)
		CloseOptimizePanel()
		
	elseif szName == "Btn_Close" then
		local frame = this:GetRoot()
		local bChecked = frame:Lookup("CheckBox_NoRemind"):IsCheckBoxChecked()
		OptimizePanel.bNotShowOptimizeTip = bChecked
		
		CloseOptimizePanel()
	end
end

function OpenOptimizePanel()
	if IsOptimizePanelOpened() then
		return
	end
	
	if OptimizePanel.bNotShowOptimizeTip then
		return
	end
	
	Wnd.OpenWindow("OptimizePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

RegisterEvent("OPTIMIZATION_HINT", function(szEvent) OptimizePanel.OnEvent(szEvent) end)