SprintHelp = {}

function SprintHelp.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	SprintHelp.UpdateAnchor()	
end

function SprintHelp.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		SprintHelp.UpdateAnchor()
	end
end

function SprintHelp.UpdateAnchor()
	this:SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 100, -100)
end

function SprintHelp.Update(hFrame, dwID)
    local tHelpText = Table_GetSprintHelp(dwID)
    if not tHelpText then
        Log("SprintHelp dwID = " .. dwID .. " is not exist")
        return
    end
    local hTitle = hFrame:Lookup("", "Text_Title")
    local hBottom = hFrame:Lookup("", "Handle_ContentBottom")
    local hTop = hFrame:Lookup("", "Handle_ContentTop")
    
    hBottom:Clear()
    hBottom:AppendItemFromString(tHelpText.szContentBottom)
    hTop:Clear()
    hTop:AppendItemFromString(tHelpText.szContentTop)
    hTitle:SetText(tHelpText.szTitle)
    
    hBottom:FormatAllItemPos()
    hTop:FormatAllItemPos()
end

function SprintHelp.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseSprintHelp()
	end
end

function OpenSprintHelp(dwID, bDisableSound)
    if not IsSprintHelpOpened() then
        Wnd.OpenWindow("SprintHelp")
    end
	local hFrame = Station.Lookup("Normal/SprintHelp")
    SprintHelp.Update(hFrame, dwID)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsSprintHelpOpened()
	local hFrame = Station.Lookup("Normal/SprintHelp")
	return hFrame and hFrame:IsVisible() 
end

function CloseSprintHelp(bDisableSound)
    if not IsSprintHelpOpened then
        return
    end
	Wnd.CloseWindow("SprintHelp")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end