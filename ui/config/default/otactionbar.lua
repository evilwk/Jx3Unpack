OTActionBar =
{
	
	PROGRESS_TYPE_ADD = 1; -- const
	PROGRESS_TYPE_DEC = 2; -- const
	
	g_nStartFrame = 0;
	g_nEndFrame  = 0;
	g_nProgressType = 0;
	
	g_nStartTime = 0;
	g_nEndTime = 0;
	
	bFadeOut = false;

	DefaultAnchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER",  x = 0, y = -255},
	Anchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER",  x = 0, y = -255}
}

RegisterCustomData("OTActionBar.Anchor")

function OTActionBar.OnFrameCreate()
	this:RegisterEvent("DO_SKILL_PREPARE_PROGRESS")
	this:RegisterEvent("DO_SKILL_CHANNEL_PROGRESS")
	this:RegisterEvent("OT_ACTION_PROGRESS_UPDATE")
	this:RegisterEvent("OT_ACTION_PROGRESS_BREAK")
	this:RegisterEvent("DO_PICK_PREPARE_PROGRESS")
	this:RegisterEvent("DO_CUSTOM_OTACTION_PROGRESS")
	this:RegisterEvent("DO_RECIPE_PREPARE_PROGRESS")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("OTACTION_BAR_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	OTActionBar.UpdateAnchor(this)
	OTActionBar.UpdateCustomModeWindow(this)	
end

function OTActionBar.OnFrameDrag()
end

function OTActionBar.OnFrameDragSetPosEnd()
end

function OTActionBar.OnFrameDragEnd()
	this:CorrectPos()
	OTActionBar.Anchor = GetFrameAnchor(this)
end

function OTActionBar.UpdateAnchor(frame)
	frame:SetPoint(OTActionBar.Anchor.s, 0, 0, OTActionBar.Anchor.r, OTActionBar.Anchor.x, OTActionBar.Anchor.y)
	frame:CorrectPos()
end

function OTActionBar.UpdateCustomModeWindow(frame)
	local bIn = UpdateCustomModeWindow(frame, g_tStrings.OT_ACTION_BAR, true)
	if bIn then
		frame:Show()
	else
		if not frame.bShow then
			frame:Hide()
		end
	end
end

function OTActionBar.ShowProgress(frame)
	frame:Show()
	frame.bShow = true
	OTActionBar.UpdateCustomModeWindow(frame)
end

function OTActionBar.HideProgress(frame)
	frame:Hide()
	frame.bShow = false
	OTActionBar.UpdateCustomModeWindow(frame)
end

function OTActionBar.OnEvent(event)
	if event == "DO_SKILL_PREPARE_PROGRESS" then
		OTActionBar.OnSkillPrepareProgress(event)
	elseif event == "DO_SKILL_CHANNEL_PROGRESS" then
		OTActionBar.OnSkillChannelProgress(event)
	elseif event == "OT_ACTION_PROGRESS_UPDATE" then
		OTActionBar.OnActionProgressUpdate(event)
	elseif event == "OT_ACTION_PROGRESS_BREAK" then
		if arg0 == GetClientPlayer().dwID then
			OTActionBar.OnActionProgressBreak(event)
		end
	elseif event == "DO_PICK_PREPARE_PROGRESS" then
		OTActionBar.OnPickPrepareProgress(event)
	elseif event == "DO_CUSTOM_OTACTION_PROGRESS" then
		OTActionBar.OnCustomOTActionProgress(event)
	elseif event == "DO_RECIPE_PREPARE_PROGRESS" then
		OTActionBar.OnRecipeOTActionProgress(event)
	elseif event == "UI_SCALED" then
		OTActionBar.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		OTActionBar.UpdateCustomModeWindow(this)
	elseif event == "OTACTION_BAR_ANCHOR_CHANGED" then
		OTActionBar.UpdateAnchor(this)		
	elseif event == "CUSTOM_DATA_LOADED" then
		OTActionBar.UpdateAnchor(this)
	end
end

function OTActionBar.UpdateTime()
	OTActionBar.g_nStartTime = GetTickCount()
	OTActionBar.g_nEndTime = OTActionBar.g_nStartTime + (OTActionBar.g_nEndFrame - OTActionBar.g_nStartFrame) * 1000 / GLOBAL.GAME_FPS
end

function OTActionBar.OnSkillPrepareProgress(event)
	local nTotalFrame = arg0;
	if (nTotalFrame <= 0) then
	    return;
	end
	
    local nCurrentFrame = GetLogicFrameCount(); 

	OTActionBar.g_nStartFrame 		= nCurrentFrame;
	OTActionBar.g_nEndFrame   		= nCurrentFrame + nTotalFrame;
	OTActionBar.g_nProgressType 	= OTActionBar.PROGRESS_TYPE_ADD;
	OTActionBar.UpdateTime()
	
	local szText = Table_GetSkillName(arg1, arg2);	
	OTActionBar.PrepaireProgressBar(0, szText)
end

function OTActionBar.OnRecipeOTActionProgress(event)
	local nTotalFrame = arg0;
	local nCraftID = arg1;
	local nRecipeID = arg2;
	
	if (nTotalFrame <= 0) then
	    return;
	end
	
 	local nCurrentFrame = GetLogicFrameCount(); 
	
	OTActionBar.g_nStartFrame 		= nCurrentFrame;
	OTActionBar.g_nEndFrame   		= nCurrentFrame + nTotalFrame;
	OTActionBar.g_nProgressType 	= OTActionBar.PROGRESS_TYPE_ADD;
	OTActionBar.UpdateTime()
	
	local szText = Table_GetRecipeName(arg1, arg2);
	OTActionBar.PrepaireProgressBar(0, szText);
end

function OTActionBar.OnCustomOTActionProgress(event)
	local nTotalFrame = arg0;
	if (nTotalFrame <= 0) then
	    return;
	end
	
    local nCurrentFrame = GetLogicFrameCount(); 
    OTActionBar.g_nStartFrame = nCurrentFrame;
    OTActionBar.g_nEndFrame = nCurrentFrame + nTotalFrame;
    OTActionBar.UpdateTime()

	if (arg2 == 0) then
		OTActionBar.g_nProgressType = OTActionBar.PROGRESS_TYPE_ADD;
	else
		OTActionBar.g_nProgressType = OTActionBar.PROGRESS_TYPE_DEC;
	end

	OTActionBar.PrepaireProgressBar(0, arg1);
end


function OTActionBar.OnPickPrepareProgress(event)
	local nTotalFrame = arg0;
	if (nTotalFrame <= 0) then
	    return;
	end
	
    local nCurrentFrame = GetLogicFrameCount(); 

	OTActionBar.g_nStartFrame 		= nCurrentFrame;
	OTActionBar.g_nEndFrame   	= nCurrentFrame + nTotalFrame;
	OTActionBar.g_nProgressType 	= OTActionBar.PROGRESS_TYPE_ADD;
	OTActionBar.UpdateTime()
	
	local doodad = GetDoodad(arg1);
	local szName = Table_GetDoodadName(doodad.dwTemplateID, doodad.dwNpcTemplateID)
	local doodadTemplate = GetDoodadTemplate(doodad.dwTemplateID);

	if doodadTemplate then
		local szBarText = Table_GetDoodadTemplateBarText(doodad.dwTemplateID)
		if szBarText ~= "" then
			szName = szBarText;
		end

		if  doodadTemplate.dwCraftID ~= 0 then
			local craft = GetCraft(doodadTemplate.dwCraftID);
			if craft then
				szName = Table_GetCraftName(doodadTemplate.dwCraftID)
			end
		end
	end	
	

	OTActionBar.PrepaireProgressBar(0, szName)
end

function OTActionBar.OnSkillChannelProgress(event)
	local nTotalFrame = arg0;
	if (nTotalFrame <= 0) then
	    return;
	end
	
    local nCurrentFrame = GetLogicFrameCount(); 

	OTActionBar.g_nStartFrame 		= nCurrentFrame;
	OTActionBar.g_nEndFrame   		= nCurrentFrame + nTotalFrame;
	OTActionBar.g_nProgressType 	= OTActionBar.PROGRESS_TYPE_DEC;
	OTActionBar.UpdateTime()
	
	local szText = Table_GetSkillName(arg1, arg2);
	OTActionBar.PrepaireProgressBar(0, szText)
end;

function OTActionBar.OnActionProgressUpdate(event)
    local nFrame = arg0;
	OTActionBar.g_nEndFrame  = OTActionBar.g_nEndFrame + nFrame;
	OTActionBar.g_nEndTime = OTActionBar.g_nEndTime + nFrame * 1000 / GLOBAL.GAME_FPS
end


function OTActionBar.OnActionProgressBreak()
	local handle = Station.Lookup("Topmost/OTActionBar", "")
	if not handle then
		Trace("[UI OTActionBar] Error get handle when OnSkillBreak!\n");	
		return
	end
		
	OTActionBar.FlashProgressBar(handle, false)	
end

function OTActionBar.OnFrameRender()
	if not this.bShow then
		return
	end
	
	--------------µ­³ö-----------
	local handle = this:Lookup("", "")
	if OTActionBar.bFadeOut then
		local nTime = GetTickCount()
		if not OTActionBar.nStartFadeTime then
			OTActionBar.nStartFadeTime = nTime
		end
		if nTime - OTActionBar.nStartFadeTime > 1000 then
			OTActionBar.HideProgress(this)
			OTActionBar.bFadeOut = false
			OTActionBar.nStartFadeTime = nil
		else
			handle:SetAlpha(255 * (1 - (nTime - OTActionBar.nStartFadeTime) / 1000))
		end
		return
	end
	------------------------------

	local nCurrentFrame = GetLogicFrameCount(); 
	if (nCurrentFrame >= OTActionBar.g_nEndFrame) then
	    OTActionBar.FlashProgressBar(handle, true);
	    return;
	end

	local nCurrentTime = GetTickCount()
	local nPast = nCurrentTime - OTActionBar.g_nStartTime
	local nTotoal = OTActionBar.g_nEndTime - OTActionBar.g_nStartTime
	local fP = nPast / nTotoal;	
	if OTActionBar.g_nProgressType == OTActionBar.PROGRESS_TYPE_DEC then
		fP = 1 - fP;
	end
	OTActionBar.SetProgressBarPercentage(handle, fP)	
end

function OTActionBar.PrepaireProgressBar(fPercentage, szName)
	local frame = Station.Lookup("Topmost/OTActionBar")
	OTActionBar.ShowProgress(frame)

	local handle = frame:Lookup("", "")
	handle:SetAlpha(255)
	
	local image = handle:Lookup("Image_Progress")
	image:Show()
	
	
	image = handle:Lookup("Image_FlashS")
	image:Hide()
	
	image = handle:Lookup("Image_FlashF")
	image:Hide()
	
	image = handle:Lookup("Image_Flash")
	image:Hide()
	
	local text = handle:Lookup("Text_Name")
	text:SetText(szName)
	
	OTActionBar.SetProgressBarPercentage(handle, fPercentage)
	
	OTActionBar.bFadeOut = false
end

function OTActionBar.SetProgressBarPercentage(handle, fPercentage)
	if fPercentage < 0 then
		fPercentage = 0
	end
	if fPercentage > 1 then
		fPercentage = 1
	end		
	handle:Lookup("Image_Progress"):SetPercentage(fPercentage)
end

function OTActionBar.FlashProgressBar(handle, bSuccess)
	local image = handle:Lookup("Image_Progress")
	image:Hide()
	
	if bSuccess then
		image = handle:Lookup("Image_FlashS")
		image:Show()
	else
		image = handle:Lookup("Image_FlashF")
		image:Show()
	end
	
	image = handle:Lookup("Image_Flash")
	image:Show()
	
	OTActionBar.bFadeOut = true
end

function OTActionBar_SetAnchorDefault()
	OTActionBar.Anchor.s = OTActionBar.DefaultAnchor.s
	OTActionBar.Anchor.r = OTActionBar.DefaultAnchor.r
	OTActionBar.Anchor.x = OTActionBar.DefaultAnchor.x
	OTActionBar.Anchor.y = OTActionBar.DefaultAnchor.y
	FireEvent("OTACTION_BAR_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", OTActionBar_SetAnchorDefault)

function LoadOTActionBarSetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		OpenDebuffList()
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"

	local iniS = Ini.Open(szIniFile)
	if not iniS then
		OpenDebuffList()
		return
	end
	
	local szSection = "OTActionBar"	
	
	local Anchor = {}
	local value = iniS:ReadString(szSection, "SelfSide", OTActionBar.Anchor.s)
	if value then
		Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", OTActionBar.Anchor.r)
	if value then
		Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", OTActionBar.Anchor.x)
	if value then
		Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", OTActionBar.Anchor.y)
	if value then
		Anchor.y = value
	end
	
	if Anchor.s and Anchor.r and Anchor.x and Anchor.y then
		OTActionBar.Anchor = Anchor
		FireEvent("OTACTION_BAR_ANCHOR_CHANGED")
	end

	iniS:Close()
end

RegisterLoadFunction(LoadOTActionBarSetting)
