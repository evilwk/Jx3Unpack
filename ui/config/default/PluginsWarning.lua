PluginsWarning = {}

function PluginsWarning.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    PluginsWarning.Init(this)
    PluginsWarning.OnEvent("UI_SCALED")
end

function PluginsWarning.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
    end
end


function PluginsWarning.Init(frame)
    PluginsWarning.biniting = true;
    
    frame:Lookup("CheckBox_Cancel"):Check(true)
    frame:Lookup("CheckBox_Sure"):Check(false)
    
    Station.SetFocusWindow(this)
    PluginsWarning.biniting = false;
end

function PluginsWarning.EnterGame(frame)
    local bEnableOverdue = frame:Lookup("CheckBox_Sure"):IsCheckBoxChecked()
    local szRole = RoleList_GetSelectRole()
    local szCurrentVersion = GetAddOnVersion()
    AddOnMgr_setAddOnLoadParam(szRole, bEnableOverdue, szCurrentVersion)
    ClosePluginsWarning()
    Login.StepNext()
end

function PluginsWarning.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Close" then
        ClosePluginsWarning()
    elseif szName == "Btn_Loading" then
        PluginsWarning.EnterGame(this:GetRoot())
    end
end

function PluginsWarning.OnCheckBoxCheck()
    if PluginsWarning.biniting then
        return
    end
    
    local szName = this:GetName()
    local frame = this:GetRoot();
    
    if szName == "CheckBox_Cancel" then
        frame:Lookup("CheckBox_Sure"):Check(false)
    elseif szName == "CheckBox_Sure" then
        frame:Lookup("CheckBox_Cancel"):Check(false)
    end
end

function PluginsWarning.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	
	if szKey == "Esc" then
		ClosePluginsWarning()
		return 1
    end
    return 0;
end

--========================================================
function IsPluginsWarningOpened()
    local frame = Station.Lookup("Topmost/PluginsWarning")
    if frame and frame:IsVisible() then
        return true
    end
end

function OpenPluginsWarning(bDisableSound)
	local frame = Wnd.OpenWindow("PluginsWarning")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,   g_sound.OpenFrame)
	end 
end

function ClosePluginsWarning(bDisableSound)
    if IsPluginsWarningOpened() then
		Wnd.CloseWindow("PluginsWarning")
	end
    
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,   g_sound.CloseFrame)
	end
end

function IsShowPluginsWarning()
    local szRole = RoleList_GetSelectRole()
    InitRoleAddonSetting(szRole)
    
    local szCurrentVersion = GetAddOnVersion()
    local szSaveVersion = AddOnMgr_GetRoleAddonSaveVersion(szRole)
    if szCurrentVersion ~= szSaveVersion and IsEnableOverdueAddOn() then
        return true;
    end
    return false;
end
