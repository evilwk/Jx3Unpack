VideoManagerPanel = 
{
	nConfigureLevel = CONFIGURE_LEVEL.CUSTOM,
}

local l_hFrame
local l_nConfigLevel
		
local function Init(hFrame)
    l_hFrame = hFrame
    l_hFrame:Lookup("Btn_Apply"):Enable(false)
end

local function InitSetttingCheck(nLevel)
    l_hFrame.bIniting = true

	local aVideoSettings = GetVideoSettings()
    local tSettings = {}
	
	l_nConfigLevel = nLevel
	tSettings.nConfigureLevel = nLevel
    --Set1-------------------------------------
    tSettings.bFullScreen = aVideoSettings.FullScreen
	tSettings.bPanauision = aVideoSettings.Panauision
	tSettings.bExclusiveMode = aVideoSettings.ExclusiveMode
    
    --Set2-------------------------------------
    tSettings.nWidth = aVideoSettings.Width
    tSettings.nHeight = aVideoSettings.Height
    tSettings.nRefreshRate = aVideoSettings.RefreshRate
	VideoManagerPanel.SetSetting(l_hFrame, tSettings)
	
    l_hFrame.bIniting = false
end

function VideoManagerPanel.SetSetting(frame, tSettings)
	local hWndSet = frame:Lookup("Wnd_Set1")
	local hWndBase = frame:Lookup("Wnd_BaseSet")
	
    local nLevel = tSettings.nConfigureLevel
    if nLevel ~= nil then
        hWndSet:Lookup("CheckBox_Lowmost"):Check(CONFIGURE_LEVEL.LOW_MOST == nLevel)
		hWndSet:Lookup("CheckBox_Low"):Check(CONFIGURE_LEVEL.LOW == nLevel)
		hWndSet:Lookup("CheckBox_Medium"):Check(CONFIGURE_LEVEL.MEDIUM == nLevel)
		hWndSet:Lookup("CheckBox_Advanced"):Check(CONFIGURE_LEVEL.HIGH == nLevel)
		hWndSet:Lookup("CheckBox_Perfect"):Check(CONFIGURE_LEVEL.PERFECTION == nLevel)
		hWndSet:Lookup("CheckBox_Custom"):Check(CONFIGURE_LEVEL.CUSTOM == nLevel)
	end
    
	local _, szText = VideoManagerPanel.GetCheckConfigLevel()
	frame:Lookup("", "Text_Peizhi"):SetText(szText)
	
	local nFrame, szImage = VideoManagerPanel.GetViewImage()
	frame:Lookup("", "Image_Lowmost"):FromUITex(szImage, 0)
	
	if tSettings.bFullScreen ~= nil then
        hWndBase:Lookup("CheckBox_Bigwin"):Check(tSettings.bFullScreen)
		
    end
    
    if tSettings.bPanauision ~= nil then
        hWndBase:Lookup("CheckBox_KuanPin"):Check(tSettings.bPanauision)	
    end
    
	local hFull = hWndBase:Lookup("CheckBox_QuanPin")
	if tSettings.bExclusiveMode ~=nil and tSettings.bFullScreen ~= nil and tSettings.bFullScreen then
		hFull:Enable(true)
		hFull:Check(tSettings.bExclusiveMode)
		VideoManagerPanel.UpdateFullScreen(hFull, true)
	elseif tSettings.bFullScreen ~= nil then
		hFull:Enable(false)
		hFull:Check(false)
		VideoManagerPanel.UpdateFullScreen(hFull, false)
	end
	VideoManagerPanel.UpdateWndSize(tSettings.nWidth, tSettings.nHeight)
end

function VideoManagerPanel.UpdateWndSize(nWidth, nHeight)
	local hWndBase = l_hFrame:Lookup("Wnd_BaseSet")
	local textSize = hWndBase:Lookup("", "Text_Size")
	textSize.MenuValue = {nWidth, nHeight}
	textSize:SetText(textSize.MenuValue[1].." X "..textSize.MenuValue[2])
end

function VideoManagerPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("VIDEO_CONFIG_CHANGED")
    
    Init(this)
    InitSetttingCheck(VideoManagerPanel.nConfigureLevel)
    
	local a3DEngineOption = KG3DEngine.Get3DEngineOption()
	VideoManagerPanel.a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
		
    this:SetPoint("CENTER", 0, 0, "CENTER", 0, -80)
end

function VideoManagerPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
        local aVideoSettings = GetVideoSettings()
		VideoManagerPanel.UpdateWndSize(aVideoSettings.Width, aVideoSettings.Height)
			
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, -80)
		
    elseif szEvent == "VIDEO_CONFIG_CHANGED" then
		VideoManagerPanel.nConfigureLevel = CONFIGURE_LEVEL.CUSTOM
        InitSetttingCheck(VideoManagerPanel.nConfigureLevel);
        VideoManagerPanel.SetChanged(false)
    end
end

function VideoManagerPanel.GetSettingTable(nLevel)
    local tSettings = Table_GetVideoSetting(nLevel)
    local tFilter = Table_GetVideoSetting(CONFIGURE_LEVEL.ATTEND)
    for k, v in pairs(tFilter) do
        if k ~= "nConfigureLevel" and (v == 0 or v == false) then
            tSettings[k] = nil
        end
    end
    if nLevel == CONFIGURE_LEVEL.LOW_MOST then
        tSettings.bFullScreen = true
        tSettings.bExclusiveMode = true
    end
    return tSettings
end

function VideoManagerPanel.SetChanged(bChanged)
	l_hFrame.bChanged = bChanged
	l_hFrame:Lookup("Btn_Apply"):Enable(l_hFrame.bChanged)
end

function VideoManagerPanel.UpdateFullScreen(hCheckFull, bEnable)
    local nFont = 18
    if not bEnable then
        nFont = 161
    end
	hCheckFull:Lookup("", "Text_QuanPin"):SetFontScheme(nFont)
end

--============Mouse or key Message===========
function VideoManagerPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Size" then
    	if not this:IsEnabled() then
			return
		end
		local tData = {}
		for k, v in ipairs(VideoManagerPanel.a3DEngineCaps.aAdapterModes) do
			if v.nWidth >= 640 then
				table.insert(tData, {fnAction=function() VideoManagerPanel.SetChanged(true) end, 
				name = v.nWidth.."X"..v.nHeight, value = {v.nWidth, v.nHeight}})
			end
		end
		local text = this:GetParent():Lookup("", "Text_Size")
		PopupMenuEx(this, tData, IsVideoManagerPanelOpened, text)
		return true
	end
end
	
function VideoManagerPanel.OnLButtonClick()
    local szName = this:GetName()
    
    if szName == "Btn_Close" or szName == "Btn_Cancel" then
        if IsVideoSettingPanelOpened() then
            return
        end
    
        CloseVideoManagerPanel()
    elseif szName == "Btn_Apply" then
        VideoManagerPanel.ApplySettting()
        VideoManagerPanel.SetChanged(false)
        
    elseif szName == "Btn_OpenVideo" then
        OpenVideoSettingPanel()
    elseif szName == "Btn_Sure" then
        if l_hFrame.bChanged then
            VideoManagerPanel.ApplySettting()
        end
        CloseVideoManagerPanel()
    end
end

function VideoManagerPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local frame = this:GetRoot()
    
	if frame.bIniting then
		return
	end
    
	if szName == "CheckBox_Custom" then
		if l_nConfigLevel ==  CONFIGURE_LEVEL.CUSTOM then
			VideoManagerPanel.UpdateCheckState(szName)
		else
			this:Check(false)
		end
		OpenVideoSettingPanel()
		return
	end
	
	if szName == "CheckBox_Bigwin" then
		local wndBasic = this:GetParent()
		local hFull = wndBasic:Lookup("CheckBox_QuanPin")
		hFull:Enable(true)
		hFull:Check(Station.IsExclusiveMode())
		VideoManagerPanel.UpdateFullScreen(hFull, true)
		
	elseif szName == "CheckBox_QuanPin" then
		local wndBasic = this:GetParent()
		wndBasic:Lookup("CheckBox_KuanPin"):Check(false)
		wndBasic:Lookup("CheckBox_KuanPin"):Enable(false)
		
	elseif szName == "CheckBox_Lowmost" or szName == "CheckBox_Low" or szName == "CheckBox_Medium" or
       szName == "CheckBox_Advanced" or szName == "CheckBox_Perfect" then
        VideoManagerPanel.UpdateCheckState(szName)
    end
	
	VideoManagerPanel.SetChanged(true)
end

function VideoManagerPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	local frame = this:GetRoot()
    
	if frame.bIniting then
		return
	end
	
	if szName == "CheckBox_Custom" then
		if l_nConfigLevel ==  CONFIGURE_LEVEL.CUSTOM then
			this:Check(true)
		end
		OpenVideoSettingPanel()
		return
	end
	
	if szName == "CheckBox_Bigwin" then
		local wndBasic = this:GetParent()
		local hFull = wndBasic:Lookup("CheckBox_QuanPin")
		hFull:Check(false)
		hFull:Enable(false)
		VideoManagerPanel.UpdateFullScreen(hFull, false)
	elseif szName == "CheckBox_QuanPin" then
		local wndBasic = this:GetParent()
		wndBasic:Lookup("CheckBox_KuanPin"):Enable(true)
	end
	VideoManagerPanel.SetChanged(true)
end

function VideoManagerPanel.GetViewImage()
	local szImage= ""
    local hWndSet = l_hFrame:Lookup("Wnd_Set1")
    local nFrame = 0
    if hWndSet:Lookup("CheckBox_Lowmost"):IsCheckBoxChecked() then
		nFrame = 3
		szImage = "ui/Image/QuicklySetPanel/Setting1.UITex"
    elseif hWndSet:Lookup("CheckBox_Low"):IsCheckBoxChecked() then
		nFrame = 1
		szImage = "ui/Image/QuicklySetPanel/Setting2.UITex"
	elseif hWndSet:Lookup("CheckBox_Medium"):IsCheckBoxChecked() then
		nFrame = 0
		szImage = "ui/Image/QuicklySetPanel/Setting3.UITex"
	elseif hWndSet:Lookup("CheckBox_Advanced"):IsCheckBoxChecked() then
		nFrame = 2
		szImage = "ui/Image/QuicklySetPanel/Setting4.UITex"
	elseif hWndSet:Lookup("CheckBox_Perfect"):IsCheckBoxChecked() then
		nFrame = 4
		szImage = "ui/Image/QuicklySetPanel/Setting5.UITex"
	elseif hWndSet:Lookup("CheckBox_Custom"):IsCheckBoxChecked() then
		nFrame = 4
		szImage = "ui/Image/QuicklySetPanel/Setting5.UITex"
	end
    return nFrame, szImage
end

function VideoManagerPanel.OnItemLButtonClick()
    --[[
	local szName = this:GetName()
	if szName == "Image_Lowmost" then
	local x, y = l_hFrame:GetAbsPos()
		local _, szImage = VideoManagerPanel.GetViewImage()
		local w, h = 0, 0 
        OutputTip("<image>path=\""..szImage.."\" </image>", 1000, {x - 45, y - 45, w, h}, nil, true, "Video_ImageTip", nil, nil, nil, 1)
	end
	]]
end

function VideoManagerPanel.OnItemMouseEnter()
    local szName = this:GetName()
    if szName == "Handle_Lowmost" then
        local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        OutputTip(g_tStrings.STR_LOWMOST_TIP, 400, {x, y, w, h, 1})		
         
    elseif szName == "Handle_Low" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(g_tStrings.STR_LOW_TIP, 400, {x, y, w, h, 1})	
	elseif szName == "Handle_Medium" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(g_tStrings.STR_MEDIUM_TIP, 400, {x, y, w, h, 1})	
        
	elseif szName == "Handle_Advanced" then 
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(g_tStrings.STR_ADVANCED_TIP, 400, {x, y, w, h, 1})	
        
	elseif szName == "Handle_Perfect" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(g_tStrings.STR_PERFECT_TIP, 400, {x, y, w, h, 1})
    elseif szName == "Handle_Custom" then
    	local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(g_tStrings.STR_CUSTOM_TIP, 400, {x, y, w, h, 1})
	end
end

function VideoManagerPanel.OnItemMouseLeave()
    HideTip()
end

function VideoManagerPanel.OnScrollBarPosChanged()
    if l_hFrame.bIniting then
		return
	end
	
	VideoManagerPanel.SetChanged(true)
end

--============Mouse or key Message===========

function VideoManagerPanel.UpdateCheckState(szName)
    local hWndSet = l_hFrame:Lookup("Wnd_Set1")
    l_hFrame.bIniting = true
	
    hWndSet:Lookup("CheckBox_Lowmost"):Check(szName == "CheckBox_Lowmost")
	hWndSet:Lookup("CheckBox_Low"):Check(szName == "CheckBox_Low")
	hWndSet:Lookup("CheckBox_Medium"):Check(szName == "CheckBox_Medium")
	hWndSet:Lookup("CheckBox_Advanced"):Check(szName == "CheckBox_Advanced")
	hWndSet:Lookup("CheckBox_Perfect"):Check(szName == "CheckBox_Perfect")
	hWndSet:Lookup("CheckBox_Custom"):Check(szName == "CheckBox_Custom")

	l_nConfigLevel, szText = VideoManagerPanel.GetCheckConfigLevel()
	l_hFrame:Lookup("", "Text_Peizhi"):SetText(szText)
	
	local nFrame, szImage = VideoManagerPanel.GetViewImage()
	l_hFrame:Lookup("", "Image_Lowmost"):FromUITex(szImage, 0)
    l_hFrame.bIniting = false
end

function VideoManagerPanel.GetCheckConfigLevel()
    local hWndSet = l_hFrame:Lookup("Wnd_Set1")
    local nLevel, hText
    if hWndSet:Lookup("CheckBox_Lowmost"):IsCheckBoxChecked() then
		nLevel = CONFIGURE_LEVEL.LOW_MOST
		hText  = hWndSet:Lookup("CheckBox_Lowmost"):Lookup("", ""):Lookup(0)
		
    elseif hWndSet:Lookup("CheckBox_Low"):IsCheckBoxChecked() then
		nLevel = CONFIGURE_LEVEL.LOW
		hText  = hWndSet:Lookup("CheckBox_Low"):Lookup("", ""):Lookup(0)
		
	elseif hWndSet:Lookup("CheckBox_Medium"):IsCheckBoxChecked() then
		nLevel = CONFIGURE_LEVEL.MEDIUM
		hText  = hWndSet:Lookup("CheckBox_Medium"):Lookup("", ""):Lookup(0)
		
	elseif hWndSet:Lookup("CheckBox_Advanced"):IsCheckBoxChecked() then
		nLevel = CONFIGURE_LEVEL.HIGH
		hText  = hWndSet:Lookup("CheckBox_Advanced"):Lookup("", ""):Lookup(0)
		
	elseif hWndSet:Lookup("CheckBox_Perfect"):IsCheckBoxChecked() then
		nLevel = CONFIGURE_LEVEL.PERFECTION
		hText  = hWndSet:Lookup("CheckBox_Perfect"):Lookup("", ""):Lookup(0)
		
	elseif hWndSet:Lookup("CheckBox_Custom"):IsCheckBoxChecked() then
		nLevel = CONFIGURE_LEVEL.CUSTOM
		hText  = hWndSet:Lookup("CheckBox_Custom"):Lookup("", ""):Lookup(0)
	end
    return nLevel, hText:GetText()
end

function VideoManagerPanel.ApplySettting()
	local nLevel = VideoManagerPanel.GetCheckConfigLevel()
	local tSettings
	if nLevel ~= VideoManagerPanel.nConfigureLevel then
		tSettings = VideoManagerPanel.GetSettingTable(nLevel) or {}
	else
		tSettings = {}
	end
	
	tSettings.nConfigureLevel = VideoManagerPanel.nConfigureLevel
	tSettings.bPostEffectEnable = false
	if tSettings.bShockWaveEnable or tSettings.bBloomEnable or tSettings.bGodRay or 
	   tSettings.bMotionBlur or tSettings.bHDR or tSettings.bDOF then
		tSettings.bPostEffectEnable = true	
	end
    
	local wndBase = l_hFrame:Lookup("Wnd_BaseSet")
	tSettings.bFullScreen = wndBase:Lookup("CheckBox_Bigwin"):IsCheckBoxChecked()
    tSettings.bExclusiveMode = wndBase:Lookup("CheckBox_QuanPin"):IsCheckBoxChecked()
    tSettings.bPanauision = wndBase:Lookup("CheckBox_KuanPin"):IsCheckBoxChecked()
    
    local textSize = wndBase:Lookup("", "Text_Size")
    tSettings.nWidth = textSize.MenuValue[1]
    tSettings.nHeight = textSize.MenuValue[2]
	
	VideoManagerPanel.nConfigureLevel = nLevel
    VideoSettingPanel_SaveSettings(tSettings)
end

function IsVideoManagerPanelOpened()
	local frame = Station.Lookup("Topmost/VideoManagerPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenVideoManagerPanel(bDisableSound)
	if IsVideoManagerPanelOpened() then
		return
	end
    
	Wnd.OpenWindow("VideoManagerPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function CloseVideoManagerPanel(bDisableSound)
	if not IsVideoManagerPanelOpened() then
		return
	end
    
    if  IsVideoSettingPanelOpened() then
        CloseVideoSettingPanel()
    end
    
	Wnd.CloseWindow("VideoManagerPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

RegisterCustomData("EnaterGlobal\\VideoManagerPanel.nConfigureLevel")