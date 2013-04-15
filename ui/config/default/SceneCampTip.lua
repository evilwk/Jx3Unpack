SceneCampTip =
{
	DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 300},
	Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = 300}
}

local SCENE_CAMP_TIP_BG_FRAME = 
{
	[MAP_CAMP_TYPE.ALL_PROTECT] = 0,
	[MAP_CAMP_TYPE.PROTECT_GOOD] = 0,
	[MAP_CAMP_TYPE.PROTECT_EVIL] = 0,
	[MAP_CAMP_TYPE.NEUTRAL] = 2,
	[MAP_CAMP_TYPE.FIGHT] = 1,
},

RegisterCustomData("SceneCampTip.Anchor")

function SceneCampTip.OnFrameCreate()
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")

	SceneCampTip.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.ENTER_AREA, true)
	this:Lookup("", ""):Hide()
end

function SceneCampTip.OnFrameDragEnd()
	this:CorrectPos()
	SceneCampTip.Anchor = GetFrameAnchor(this)
end

function SceneCampTip.UpdateAnchor(hFrame)
	hFrame:SetPoint(SceneCampTip.Anchor.s, 0, 0, SceneCampTip.Anchor.r, SceneCampTip.Anchor.x, SceneCampTip.Anchor.y)
	hFrame:CorrectPos()
end

function SceneCampTip.OnEvent(szEvent)
	if szEvent == "PLAYER_ENTER_SCENE" then
		local hPlayer = GetClientPlayer()
		if hPlayer and arg0 == hPlayer.dwID then
			local hScene = hPlayer.GetScene()
			local hTotal = this:Lookup("", "")
			hTotal:Lookup("Text_CampText"):SetText(Table_GetMapName(hScene.dwMapID) .. "    " .. g_tStrings.STR_MAP_CAMP_TYPE[hScene.nCampType])
			hTotal:Lookup("Image_Bg"):SetFrame(SCENE_CAMP_TIP_BG_FRAME[hScene.nCampType])
			hTotal:SetAlpha(255)
			hTotal:Show()
		end
	elseif szEvent == "UI_SCALED" then
		SceneCampTip.UpdateAnchor(this)
	elseif szEvent == "ON_ENTER_CUSTOM_UI_MODE" or szEvent == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, true)
	elseif szEvent == "ENTER_SCENE_CAMP_ANCHOR_CHANGED" then
		SceneCampTip.UpdateAnchor(this)
	elseif szEvent == "CUSTOM_DATA_LOADED" then
		SceneCampTip.UpdateAnchor(this)
	end
end

function SceneCampTip.OnFrameBreathe()
	local hTotal = this:Lookup("", "")
	if hTotal:IsVisible() then
		local nLeft = hTotal:GetAlpha() - 0.4
		if nLeft < 0 then
			hTotal:Hide()
		else
			hTotal:SetAlpha(nLeft)
		end
	end
end

function SceneCampTip_SetAnchorDefault()
	SceneCampTip.Anchor = clone(SceneCampTip.DefaultAnchor)
	FireEvent("ENTER_SCENE_CAMP_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", SceneCampTip_SetAnchorDefault)
