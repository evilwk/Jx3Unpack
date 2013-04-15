NewRecipeTip = class()

local bNewRecipeTipShow = true
local nCurNewRecipeCount = 0

local NEWRECIPETIP_MAX_COUNT = 4
local NEWRECIPETIP_DEFAULT_YOFFSET = -150
local NEWRECIPETIP_HEIGHT = 100

local tNewRecipeTipMap = {}
for i = 1, NEWRECIPETIP_MAX_COUNT do
	tNewRecipeTipMap[i] = {}
end
local function GetTipMiniCountIndex()
	local nMiniCount = nil
	local nMiniIndex = nil
	for nIndex, tFrames in ipairs(tNewRecipeTipMap) do
		local nCount = #tFrames
		if not nMiniCount or not nMiniIndex or nMiniCount > nCount then
			nMiniIndex = nIndex
			nMiniCount = nCount
		end
	end
	return nMiniIndex
end

function NewRecipeTip.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
end

function NewRecipeTip.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		UpdateAnchor(this)
	end
end

local function OpenRecipePanel(hFrame)
	local dwSkillID, nLevel = GetSkillByRecipe(hFrame.dwRecipeID, hFrame.nLevel)
	if dwSkillID and nLevel then
		OpenMystiquePanel(dwSkillID, nLevel)
	end
	CloseNewRecipeTip(hFrame, true)
end

function NewRecipeTip.OnItemLButtonClick()
	OpenRecipePanel(this:GetRoot())
end

function NewRecipeTip.OnItemRButtonClick()
	OpenRecipePanel(this:GetRoot())
end

function NewRecipeTip.OnItemMouseEnter()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(true)
		local nType = this:GetObjectType()
		if nType == UI_OBJECT_SKILL then
			local dwSkillID, dwLevel = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true)
		elseif nType == UI_OBJECT_SKILL_RECIPE then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()		
			local dwID, dwLevel = this:GetObjectData()
			OutputSkillRecipeTip(dwID, dwLevel, {x, y, w, h})
		end
	end
end

function NewRecipeTip.OnItemMouseLeave()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(false)
		HideTip()
	end
end

local function UpdateAnchor(hFrame)
	local nYOffset = NEWRECIPETIP_DEFAULT_YOFFSET - NEWRECIPETIP_HEIGHT * (hFrame.nIndex - 1)
	hFrame:SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, nYOffset)
	hFrame:CorrectPos()
end

function OpenNewRecipeTip(dwRecipeID, nLevel, bDisableSound)
	local szFrameName = "NewRecipeTip_" .. dwRecipeID .. "_" .. nLevel
	local hFrame = Wnd.OpenWindow("NewRecipeTip", szFrameName)
	hFrame.dwRecipeID = dwRecipeID
	hFrame.nLevel = nLevel
	if not hFrame.nIndex then -- may be opened
		hFrame.nIndex = GetTipMiniCountIndex()
		table.insert(tNewRecipeTipMap[hFrame.nIndex], szFrameName)
	end
	
	local tSkillRecipe = Table_GetSkillRecipe(dwRecipeID, nLevel)
	local nIconID = -1
	local szName = ""
	if tSkillRecipe then
		nIconID = tSkillRecipe.nIconID
		szName = tSkillRecipe.szName
	end
	local hBox = hFrame:Lookup("", "Box_Recipe")
	hBox:SetObject(UI_OBJECT_SKILL_RECIPE, dwRecipeID, nLevel)
	hBox:SetObjectIcon(nIconID)
	
	local hName = hFrame:Lookup("", "Text_RecipeName")
	hName:SetText(szName)
	
	UpdateAnchor(hFrame)
	nCurNewRecipeCount = nCurNewRecipeCount + 1
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function CloseNewRecipeTip(hFrame, bDisableSound)
	local szName = hFrame:GetName()
	for nIndex, szFrameName in pairs(tNewRecipeTipMap[hFrame.nIndex]) do
		if szFrameName == szName then
			table.remove(tNewRecipeTipMap[hFrame.nIndex], nIndex)
		end
	end
	Wnd.CloseWindow(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end

function IsNewRecipeTipShow()
	return bNewRecipeTipShow
end

function SetNewRecipeTipShow(bShow)
	bNewRecipeTipShow = bShow
	if bShow then
		return
	end

	for _, tFrames in pairs(tNewRecipeTipMap) do
		for _, szFrameName in pairs(tFrames) do
			Wnd.CloseWindow(szFrameName)			
		end
		tFrames = {}
	end
end

function OnAddSkillRecipe()
	OpenNewRecipeTip(arg0, arg1)
	local nRetCode = GetClientPlayer().ActiveSkillRecipe(arg0, arg1)
	if nRetCode == SKILL_RECIPE_RESULT_CODE.SUCCESS then
		FireEvent("ON_ACTIVE_SKILL_RECIPE")
	end
end

RegisterEvent("ADD_SKILL_RECIPE", OnAddSkillRecipe)