GuildRename={

m_pFocusWindow = nil;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	GuildRename.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	GuildRename.m_pFocusWindow = Station.GetFocusWindow()

	Station.SetFocusWindow("Topmost/GuildRename")
	this:FocusHome()
end;

OnFrameHide=function()
	if GuildRename.m_pFocusWindow and GuildRename.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(GuildRename.m_pFocusWindow)
	end
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end;

OnLButtonClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "Btn_OK" then
		EditAnswer = this:GetParent():Lookup("Edit_Answer")
		nRoleNameLength = EditAnswer:GetTextLength()
		szRoleName = EditAnswer:GetText()
		
		if GuildRename.CheckGuildName(nRoleNameLength, szRoleName) then
			RemoteCallToServer("OnRenameConflictTong", szRoleName)
		end
	elseif szName == "Btn_Cancel" then
		Station.Lookup("Topmost/GuildRename"):Hide()
	end
end;

CheckGuildName = function(nNameLength, szName)
	local szMsg = ""
	if not szName or nNameLength == 0 then
		szMsg = g_tStrings.tGuildRenameError["NAME_CANNOT_EMPTY"]
	end
	if szMsg ~= "" then
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg =
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = szMsg,
			szName = "CheckGuildName",
			{
			    szOption = g_tStrings.STR_HOTKEY_SURE,
			},
		}
		MessageBox(tMsg)
		
		return false
	end

	return true
end;

};

function OpenGuildRename(bDisableSound)
	if IsGuildRenameOpened() then
		return
	end
	
	local frame = Station.Lookup("Topmost/GuildRename")
	if not frame then
		frame = Wnd.OpenWindow("GuildRename")
	end
	frame:Show()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsGuildRenameOpened()
	local frame = Station.Lookup("Topmost/GuildRename")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseGuildRename(bDisableSound)
	if not IsGuildRenameOpened() then
		return
	end
	
	local frame = Station.Lookup("Topmost/GuildRename")
	frame:Hide()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end