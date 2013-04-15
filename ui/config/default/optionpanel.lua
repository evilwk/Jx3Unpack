OptionPanel={
	
OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	
	----关掉他的子面板
	CloseHotkeyPanel(true)
	CloseUISettingPanel(true)
	CloseVideoManagerPanel(true)
	CloseSoundSettingPanel(true)
	CloseEditBox()
	CloseChatSettingPanel(true)
	CloseMacroSettingPanel(true)
	
	OptionPanel.OnEvent("UI_SCALED")
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end;

OnLButtonClick=function()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_HotKey" then
		OpenHotkeyPanel()
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_Quit" then
		if GetClientPlayer().bFightState then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.OPTION_QUIT_NOT_IN_FIGHT)
		else
			OpenExitPanel("close")
		end
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_ReturnChoose" then
		if GetClientPlayer().bFightState then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.OPTION_RETURNCHOOSE_NOT_IN_FIGHT)
		else
			OpenExitPanel("returntorole")
		end
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_ReturnLogin" then
		if GetClientPlayer().bFightState then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.OPTION_RETURNLOGIN_NOT_IN_FIGHT)
		else
			OpenExitPanel("returntologin")
		end
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_Macro" then
		OpenMacroSettingPanel()
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_ReturnGame" then
		CloseOptionPanel()
	elseif szSelfName == "Btn_Cancel" then	
		CloseOptionPanel()
	elseif szSelfName == "Btn_Video" then
		OpenVideoManagerPanel()
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_Sound" then
		OpenSoundSettingPanel()
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_UI" then
		OpenUISettingPanel()
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_Chat" then
		OpenChatSettingPanel()
		CloseOptionPanel(true)
	elseif szSelfName == "Btn_UICustomMode" then
		OpenUICustomModePanel()
		CloseOptionPanel(true)
	end
end;

}

---------------------插件重新实现方法:--------------------------------
--1, OptionPanel = nil
--2, 重载下面函数
----------------------------------------------------------------------

function OpenOptionPanel(bDisableSound)
	if IsOptionPanelOpened() then
		return
	end
	
	CorrectAutoPosFrameEscClose(true)
	
	local wndOptionPanel = Wnd.OpenWindow("OptionPanel")

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	

	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		wndOptionPanel:Lookup("Btn_ReturnChoose"):Enable(false)
	end
end

function CloseOptionPanel(bDisableSound)
	if not IsOptionPanelOpened() then
		return
	end
	Wnd.CloseWindow("OptionPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end		
end

function IsOptionPanelOpened()
	local frame = Station.Lookup("Topmost/OptionPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

--关闭自己和自己派生的面板，成功操作返回true，否则false
function CloseOptionAndOptionChildPanel()
	local bRet = false
	if IsHotkeyPanelOpened() then
		CloseHotkeyPanel(true)
		bRet = true
	end
	
	if IsUISettingPanelOpened() then
		CloseUISettingPanel(true)
		bRet = true
	end
	
	if IsVideoManagerPanelOpened() then
		CloseVideoManagerPanel(true)
		bRet = true
	end	
	
	if IsSoundSettingPanelOpened() then
		CloseSoundSettingPanel(true)
		bRet = true
	end
	
	if IsChatSettingPanelOpened() then
		CloseChatSettingPanel(true)
		bRet = true
	end
	
	if IsMacroSettingPanelOpened() then
		CloseMacroSettingPanel(true)
		bRet = true
	end

	if IsOptionPanelOpened() then
		CloseOptionPanel(true)
		bRet = true
	end
	if bRet then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	return bRet
end

function IsOptionOrOptionChildPanelOpened()
	if IsHotkeyPanelOpened() then
		return true
	end
	
	if IsUISettingPanelOpened() then
		return true
	end
	
	if IsVideoSettingPanelOpened() then
		return true
	end	
	
	if IsSoundSettingPanelOpened() then
		return true
	end
	
	if IsMacroSettingPanelOpened() then
		return true
	end

	if IsOptionPanelOpened() then
		return true
	end
	
	return false
end
