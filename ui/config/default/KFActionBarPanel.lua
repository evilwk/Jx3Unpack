KFActionBarPanel = 
{
    bNotShowTip = false;
}

RegisterCustomData("Account/KFActionBarPanel.bNotShowTip")

local function CloseKFActionBarPanel(bDisableSound)
    if not IsKFActionBarPanelOpened() then
        return
    end
    
    local frame = Station.Lookup("Normal/KFActionBarPanel")
    local hCheck = frame:Lookup("CheckBox_Never")
    KFActionBarPanel.bNotShowTip = hCheck:IsCheckBoxChecked()
    
    Wnd.CloseWindow("KFActionBarPanel")
    if not bDisableSound then
        PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
    end
end

local function PopuShortKeyItem(frame)
    local hBtn  = frame:Lookup("Btn_Short")
    local hText = frame:Lookup("", "Text_Short")
    if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end
	
	local xT, yT = hText:GetAbsPos()
	local wT, hT = hText:GetSize()
	local menu = 
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function() 
			if hBtn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = hBtn:GetAbsPos()
				local w, h = hBtn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
					hBtn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if hText:IsValid() then
				hText:SetText(g_tStrings.ACTION_BAR_BING[UserData])
                frame.nPage = UserData
			end
		end,
		fnAutoClose = function() return not IsKFActionBarPanelOpened() end,
        
        {szOption = g_tStrings.ACTION_BAR_BING[1], UserData = 1},
        {szOption = g_tStrings.ACTION_BAR_BING[2], UserData = 2},
        {szOption = g_tStrings.ACTION_BAR_BING[3], UserData = 3},
        {szOption = g_tStrings.ACTION_BAR_BING[4], UserData = 4},
	}
	PopupMenu(menu)
end

function KFActionBarPanel.OnFrameCreate()
    
end

function KFActionBarPanel.OnLButtonClick()
    local szName = this:GetName();
    if szName == "Btn_Short" then
        PopuShortKeyItem(this:GetRoot())
    elseif szName == "Btn_Sure" then
        local frame = this:GetRoot()
        KungFuPanel.UpdateKfBind(frame.dwKungFuID, frame.nPage)
        CloseKFActionBarPanel()
    elseif szName == "Btn_Cancel" then
        CloseKFActionBarPanel()
    end
end

function IsKFActionBarPanelOpened()
	local frame = Station.Lookup("Normal/KFActionBarPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenKFActionBarPanel(dwKungFuID, dwSkillLevel, bDisableSound)
    local player = GetClientPlayer()
    local bCool = player.GetSkillCDProgress(dwKungFuID, dwSkillLevel)
    local nPage = GetKungfuActionBarPage(dwKungFuID) or 0
    
    if bCool or KFActionBarPanel.bNotShowTip == true or nPage ~= 0 then
        CloseKFActionBarPanel();
        return
    end
    
    if IsKFActionBarPanelOpened() then
        return
    end

    local frame = Wnd.OpenWindow("KFActionBarPanel")
    frame:Show()
    frame.dwKungFuID = dwKungFuID
    frame.nPage = 1
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

